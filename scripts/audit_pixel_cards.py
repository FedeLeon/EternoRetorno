"""Verify installed card artwork, generation provenance and complete catalogue coverage."""
from pathlib import Path
import hashlib
import json
from PIL import Image

ROOT = Path(__file__).resolve().parents[1]
BASE = ROOT / 'docs/cards/pixel_retain'

def audit():
    jobs = json.loads((BASE / 'jobs.json').read_text())
    catalogue = json.loads((ROOT / 'data/card_art.json').read_text())
    manifest = json.loads((ROOT / 'docs/art_direction/postapocalyptic/assets.json').read_text())
    errors = []
    illustrations = [j for j in jobs if j['kind'] == 'illustration']
    if len(jobs) != 96 or len(illustrations) != 88:
        errors.append('Expected 88 illustrations and eight fronts/backs')
    if {j['id'] for j in illustrations} != set(catalogue):
        errors.append('Illustration IDs differ from production catalogue')
    hashes = set()
    for job in jobs:
        source, target = ROOT / job['source'], ROOT / job['target']
        ledger = BASE / (job['id'] + '.json')
        if not source.exists() or not target.exists() or not ledger.exists():
            errors.append('Missing source, active asset or provenance: ' + job['id'])
            continue
        meta = json.loads(ledger.read_text())
        if meta.get('prompt') != job['prompt']:
            errors.append('Prompt mismatch: ' + job['id'])
        digest = hashlib.sha256(target.read_bytes()).hexdigest()
        record = manifest.get(job['target'], {})
        if digest != record.get('sha256') or record.get('source_sha256') != hashlib.sha256(source.read_bytes()).hexdigest():
            errors.append('Inventory hash mismatch: ' + job['id'])
        expected = (512, 340) if job['kind'] == 'illustration' else (512, 768)
        with Image.open(target) as image:
            if image.size != expected:
                errors.append('Unexpected active dimensions: ' + job['id'])
        if job['kind'] == 'illustration':
            if digest in hashes:
                errors.append('Duplicate illustration: ' + job['id'])
            hashes.add(digest)
            if catalogue[job['id']]['source'] != 'res://' + job['target']:
                errors.append('Runtime reference mismatch: ' + job['id'])
    result = {'assets': len(jobs), 'illustrations': len(illustrations), 'unique_illustrations': len(hashes), 'errors': errors}
    report = ROOT / 'artifacts/pixel_cards'
    report.mkdir(parents=True, exist_ok=True)
    (report / 'art_audit.json').write_text(json.dumps(result, indent=2) + '\n')
    return result

if __name__ == '__main__':
    result = audit()
    print(json.dumps(result, ensure_ascii=False, indent=2))
    raise SystemExit(bool(result['errors']))
