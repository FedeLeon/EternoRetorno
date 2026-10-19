"""Validate every isolated machine foreground and its approved attack/defense pair."""
from pathlib import Path
import hashlib
import json
from PIL import Image
from audit_content import load_documents, EXPANSIONS

ROOT = Path(__file__).resolve().parents[1]
BASE = ROOT / 'art_sources/enemy_cutins_2026_10_19'


def audit():
    documents, errors = load_documents(ROOT)
    visuals = documents['enemy_visuals']
    enemies = dict(documents['content']['enemies'])
    for name in EXPANSIONS['enemies']:
        enemies.update(documents[name])
    manifest = json.loads((ROOT / 'art_sources/art_direction/postapocalyptic/assets.json').read_text())
    seen = set()
    assets = 0
    for visual, config in visuals.items():
        paths = config.get('foreground', {})
        if set(paths) != {'attack', 'defense'}:
            errors.append(f'{visual}: missing independent attack/defense mapping')
            continue
        job_path = BASE / 'jobs' / f'{visual}.json'
        if not job_path.exists():
            errors.append(f'{visual}: missing generation record')
            continue
        job = json.loads(job_path.read_text())
        reference = f'assets/combat_static/enemies/{visual}/idle.png'
        if job.get('reference') != reference or hashlib.sha256((ROOT / reference).read_bytes()).hexdigest() != job.get('reference_sha256'):
            errors.append(f'{visual}: wrong machine identity reference')
        if job.get('review_status') != 'approved':
            errors.append(f'{visual}: pair not visually approved')
        for action in ['attack', 'defense']:
            path = paths[action].removeprefix('res://')
            target = ROOT / path
            if not target.is_file():
                errors.append(f'{visual}/{action}: missing PNG')
                continue
            assets += 1
            digest = hashlib.sha256(target.read_bytes()).hexdigest()
            if digest in seen:
                errors.append(f'{visual}/{action}: reused illustration')
            seen.add(digest)
            record = manifest.get(path, {})
            if record.get('sha256') != digest or record.get('visual') != visual or record.get('action') != action:
                errors.append(f'{visual}/{action}: invalid asset provenance/mapping')
            source = ROOT / record.get('source', '')
            if not source.is_file() or hashlib.sha256(source.read_bytes()).hexdigest() != record.get('source_sha256'):
                errors.append(f'{visual}/{action}: invalid original source')
            with Image.open(target) as image:
                if image.mode != 'RGBA' or image.size != (768, 512):
                    errors.append(f'{visual}/{action}: expected individual RGBA 768x512')
                elif image.getpixel((0, 0))[3] or image.getpixel((767, 511))[3]:
                    errors.append(f'{visual}/{action}: opaque background')
                elif image.getchannel('A').point(lambda a: 255 if a > 127 else 0).getbbox() is None:
                    errors.append(f'{visual}/{action}: empty illustration')
    for enemy, definition in enemies.items():
        if set(visuals.get(definition['visual'], {}).get('foreground', {})) != {'attack', 'defense'}:
            errors.append(f'{enemy}: missing machine foreground actions')
    if list((ROOT / 'assets/comic/enemies').glob('*.png')):
        errors.append('Old mixed foregrounds remain in runtime assets')
    result = {'enemy_definitions': len(enemies), 'machine_models': len(visuals), 'assets': assets,
              'unique_illustrations': len(seen), 'errors': errors,
              'visual_review': 'manual approval of identity and absence of humans; not inferred from pixel tests'}
    output = ROOT / 'artifacts/enemy_cutins_review'
    output.mkdir(parents=True, exist_ok=True)
    (output / 'audit.json').write_text(json.dumps(result, ensure_ascii=False, indent=2) + '\n')
    return result


if __name__ == '__main__':
    result = audit()
    print(json.dumps(result, ensure_ascii=False, indent=2))
    raise SystemExit(bool(result['errors']))
