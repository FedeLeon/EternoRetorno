"""Inspect actual battle atlas regions without changing their pixels."""
import hashlib
import json
from pathlib import Path
from PIL import Image

ROOT = Path(__file__).resolve().parents[1]

def audit():
    records, errors = [], []
    for folder, columns, count in [('heroes/detail', 4, 12), ('heroes/actions', 4, 12), ('heroes/guard', 6, 24), ('enemies/animations', 8, 8)]:
        for path in sorted((ROOT / 'assets' / folder).glob('*.png')):
            with Image.open(path) as image:
                width = image.width // columns
                height = image.height // (4 if count == 24 else 3 if count == 12 else 1)
                poses = []
                for index in range(count):
                    x, y = index % columns * width, index // columns * height
                    alpha = image.crop((x, y, x + width, y + height)).getchannel('A')
                    bounds = alpha.point(lambda value: 255 if value > 127 else 0).getbbox()
                    if not bounds or bounds[2] - bounds[0] < 20 or bounds[3] - bounds[1] < 20:
                        errors.append(f'{path.relative_to(ROOT)}: empty/tiny frame {index}')
                    poses.append({'bounds': bounds})
            records.append({'path': str(path.relative_to(ROOT)), 'frames': count,
                            'cell': [width, height], 'poses': poses,
                            'sha256': hashlib.sha256(path.read_bytes()).hexdigest()})
    report = {'sheets': len(records), 'poses': sum(row['frames'] for row in records),
              'errors': errors, 'records': records}
    (ROOT / 'docs/animation_review/atlas_audit.json').write_text(json.dumps(report, indent=2) + '\n')
    print(f'BATTLE ATLASES: {report["sheets"]} sheets / {report["poses"]} frames / {len(errors)} errors')
    for error in errors:
        print(error)
    return bool(errors)

if __name__ == '__main__':
    raise SystemExit(audit())
