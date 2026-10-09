"""Create two local arrangements from the game's licensed CC0 recordings. No export."""
import hashlib
import json
import subprocess
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent


def main():
    records = []
    for name, ambient, filters in [
        ('battle_forest', 'birds', 'highpass=f=70,equalizer=f=900:t=q:w=0.8:g=2,lowpass=f=11000'),
        ('battle_volcano', 'fire', 'highpass=f=40,bass=g=3:f=110,equalizer=f=1800:t=q:w=1:g=1'),
    ]:
        music = ROOT / 'assets/audio/music/battle.ogg'
        atmosphere = ROOT / f'assets/audio/ambience/{ambient}.ogg'
        output = ROOT / f'assets/audio/music/{name}.ogg'
        graph = f'[0:a]{filters}[music];[1:a]volume=0.07[amb];[music][amb]amix=inputs=2:duration=first:normalize=0,loudnorm=I=-22:TP=-2:LRA=11[out]'
        subprocess.run(['ffmpeg','-hide_banner','-loglevel','error','-y','-i',str(music),'-stream_loop','-1','-i',str(atmosphere),'-filter_complex',graph,'-map','[out]','-ar','44100','-ac','2','-c:a','libvorbis','-q:a','4',str(output)],check=True)
        records.append({'id':name,'file':str(output.relative_to(ROOT)),'license':'CC0-1.0','sources':[str(music.relative_to(ROOT)),str(atmosphere.relative_to(ROOT))],'source_sha256':[hashlib.sha256(p.read_bytes()).hexdigest() for p in [music,atmosphere]],'sha256':hashlib.sha256(output.read_bytes()).hexdigest(),'processing':graph,'original_credits':'docs/audio/sources.json','date':'2026-10-08','type':'arrangement of existing licensed recordings, not a new composition'})
    destination = ROOT / 'docs/whole_game_polish/music_sources.json'
    destination.write_text(json.dumps(records,indent=2)+'\n')
    print('Two dungeon battle arrangements prepared')


if __name__ == '__main__':
    main()
