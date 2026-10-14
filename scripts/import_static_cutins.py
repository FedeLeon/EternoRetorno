"""Install eight original static foreground drawings; preserve generated RGBA pixels."""
from pathlib import Path
import hashlib
import json
import shutil
from PIL import Image

ROOT = Path(__file__).resolve().parents[1]
DOCS = ROOT / 'docs/comic/static'
HEROES = ['warrior', 'guardian', 'rogue', 'mage']


def install():
    manifest = {}
    for hero in HEROES:
        for action in ['attack', 'defense']:
            ledger = ROOT / f'docs/art_direction/migration/jobs/static_{hero}_{action}.json'
            job = json.loads(ledger.read_text())
            source, target = ROOT / job['source'], ROOT / job['target']
            with Image.open(source) as image:
                if image.mode != 'RGBA' or image.width < 1200 or image.height < 800:
                    raise ValueError(f'Expected HD RGBA illustration: {source}')
                hist = image.getchannel('A').histogram()
                clear = sum(hist[:13]) / (image.width * image.height)
                if clear < .20 or image.getbbox() is None:
                    raise ValueError(f'Expected genuine transparent cutout: {source}')
                dimensions = list(image.size)
            target.parent.mkdir(parents=True, exist_ok=True)
            shutil.copyfile(source, target)
            record = dict(job, sha256=hashlib.sha256(target.read_bytes()).hexdigest(),
                          dimensions=dimensions, clear_fraction=round(clear, 4), status='integrated')
            manifest[job['target']] = record
            source.with_suffix('.json').write_text(json.dumps(record, ensure_ascii=False, indent=2)+'\n')
    (DOCS / 'assets.json').write_text(json.dumps(manifest, ensure_ascii=False, indent=2)+'\n')
    print(f'STATIC CUT-INS: installed {len(manifest)} original RGBA illustrations')


if __name__ == '__main__':
    install()
