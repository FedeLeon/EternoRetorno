#!/usr/bin/env python3
"""Download the selected CC0 audio, normalize it and record its provenance.

Run locally with Python 3 and ffmpeg. Does not export the game.
"""
import hashlib
import io
import json
import re
import subprocess
import tempfile
import urllib.parse
import urllib.request
import zipfile
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
SOURCES = {
    'interface': ('Kenney', 'https://kenney.nl/assets/interface-sounds'),
    'rpg': ('Kenney', 'https://kenney.nl/assets/rpg-audio'),
    'impact': ('Kenney', 'https://kenney.nl/assets/impact-sounds'),
    'fantasy': ('rubberduck', 'https://opengameart.org/content/80-cc0-rpg-sfx'),
    'title': ('Nikke', 'https://opengameart.org/content/dark-intro'),
    'camp': ('Cal McEachern / Trex0n', 'https://opengameart.org/content/a-small-fire-will-do-calming-loop'),
    'battle': ('request', 'https://opengameart.org/content/heartfelt-battle-loopable-fantasy-stringspianohorn'),
    'crypt': ('yd', 'https://opengameart.org/content/dungeon-ambience'),
    'forest': ('TinyWorlds', 'https://opengameart.org/content/forest-ambience'),
    'fire': ('PagDev', 'https://opengameart.org/content/fireplace-sound-loop'),
    'wind': ('SketchMan3', 'https://opengameart.org/content/wind-whoosh-loop'),
    'birds': ('isaiah658', 'https://opengameart.org/content/ambient-bird-sounds'),
    'cave': ('JaggedStone', 'https://opengameart.org/node/29778'),
}
# Only these files become runtime resources; entire packs stay in temporary storage.
FILES = {
    'interface': {'ui_click': 'click_001.ogg', 'ui_hover': 'select_001.ogg', 'ui_back': 'back_001.ogg', 'ui_open': 'open_001.ogg', 'error': 'error_001.ogg', 'confirm': 'confirmation_001.ogg'},
    'rpg': {'card_select': 'bookFlip1.ogg', 'card_use': 'bookFlip2.ogg', 'coins': 'handleCoins.ogg', 'door': 'doorOpen_1.ogg', 'bag': 'handleSmallLeather.ogg', 'paper': 'bookFlip3.ogg', 'cloth': 'cloth2.ogg', 'blade_swish': 'knifeSlice.ogg', 'blade_swish_2': 'knifeSlice2.ogg', 'step': 'footstep03.ogg'},
    'impact': {'block': 'impactMetal_medium_000.ogg', 'block_2': 'impactMetal_medium_002.ogg', 'hit': 'impactPunch_medium_000.ogg', 'hit_2': 'impactPunch_medium_003.ogg', 'hammer': 'impactMining_000.ogg', 'bell': 'impactBell_heavy_000.ogg', 'bones': 'impactWood_light_002.ogg'},
    'fantasy': {'magic': 'spell_01.ogg', 'magic_2': 'spell_02.ogg', 'fire_spell': 'spell_fire_03.ogg', 'ash': 'spell_fire_01.ogg', 'heal': 'item_gem_01.ogg', 'upgrade': 'item_gem_03.ogg', 'poison': 'creature_slime_01.ogg', 'monster': 'creature_roar_01.ogg', 'monster_2': 'creature_roar_02.ogg', 'hurt': 'creature_hurt_01.ogg', 'death': 'creature_die_01.ogg', 'goblin': 'creature_misc_02.ogg', 'bow': 'blade_03.ogg', 'treasure': 'lock_01.ogg', 'victory': 'item_gem_04.ogg', 'defeat': 'creature_monster_03.ogg'},
    'title': {'title': 'Dark Intro_0.ogg'},
    'camp': {'camp': 'a_small_fire_will_do.wav'},
    'battle': {'battle': 'heartfelt-battle_loop.ogg'},
    'crypt': {'crypt': 'dungeon002_0.ogg'},
    'forest': {'forest': 'Forest_Ambience.mp3'},
    'fire': {'fire': 'fire.wav'},
    'wind': {'wind': 'wind woosh loop.ogg'},
    'birds': {'birds': 'birds-isaiah658_0.ogg'},
    'cave': {'cave': 'dungeon_ambient_1_0.ogg'},
}


def download(url):
    request = urllib.request.Request(url, headers={'User-Agent': 'EternoRetorno-audio-import/1.0'})
    with urllib.request.urlopen(request, timeout=90) as response:
        return response.read()


def main():
    records = []
    docs = ROOT / 'docs/audio'
    docs.mkdir(parents=True, exist_ok=True)
    licenses = docs / 'licenses'
    licenses.mkdir(exist_ok=True)
    with tempfile.TemporaryDirectory(prefix='eterno-audio-') as temporary:
        cache = Path(temporary)
        for pack, (author, page) in SOURCES.items():
            html = download(page).decode('utf-8')
            if not re.search(r'CC0|creativecommons.org/publicdomain/zero', html, re.I):
                raise RuntimeError(f'CC0 license not found: {page}')
            (licenses / (pack + '.html')).write_text(html)
            links = [urllib.parse.urljoin(page, urllib.parse.unquote(x.replace('&amp;', '&'))) for x in re.findall(r'href=["\']([^"\']+)["\']', html)]
            links = [urllib.parse.quote(x, safe=':/?=&%') for x in links]
            archive_url = next((x for x in links if x.endswith('.zip')), None)
            archive = zipfile.ZipFile(io.BytesIO(download(archive_url))) if archive_url else None
            for name, filename in FILES[pack].items():
                if archive:
                    member = next(x for x in archive.namelist() if Path(x).name == filename)
                    raw = archive.read(member)
                    url = archive_url
                else:
                    url = next(x for x in links if urllib.parse.unquote(x).endswith('/' + filename))
                    member = None
                    raw = download(url)
                source = cache / filename
                source.write_bytes(raw)
                category = 'music' if pack in ['title', 'camp', 'battle', 'crypt', 'forest'] else ('ambience' if pack in ['fire', 'wind', 'birds', 'cave'] else 'sfx')
                destination = ROOT / 'assets/audio' / category / (name + '.ogg')
                destination.parent.mkdir(parents=True, exist_ok=True)
                # Lower music loudness leaves room for hits; output is limited before Vorbis encoding.
                target = '-22' if category == 'music' else ('-25' if category == 'ambience' else '-18')
                subprocess.run(['ffmpeg', '-hide_banner', '-loglevel', 'error', '-y', '-i', str(source), '-af', f'loudnorm=I={target}:TP=-2:LRA=11', '-ar', '44100', '-ac', '2' if category == 'music' else '1', '-c:a', 'libvorbis', '-q:a', '4' if category == 'music' else '3', str(destination)], check=True)
                records.append({'id': name, 'file': str(destination.relative_to(ROOT)), 'author': author, 'page': page, 'download': url, 'archive_member': member, 'license': 'CC0-1.0', 'original_sha256': hashlib.sha256(raw).hexdigest(), 'sha256': hashlib.sha256(destination.read_bytes()).hexdigest(), 'processing': f'ffmpeg loudnorm I={target}, TP=-2, 44100Hz, Vorbis', 'downloaded': '2026-10-05'})
                print(destination.relative_to(ROOT), flush=True)
    (docs / 'sources.json').write_text(json.dumps(records, ensure_ascii=False, indent=2) + '\n')
    print(f'{len(records)} selected assets, {sum((ROOT / r["file"]).stat().st_size for r in records) / 2**20:.2f} MiB')


if __name__ == '__main__':
    main()
