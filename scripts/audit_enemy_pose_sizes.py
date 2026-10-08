"""Measure existing enemy poses and write conservative display corrections (no image edits)."""
import hashlib
import json
import math
import statistics
from pathlib import Path
from PIL import Image

ROOT = Path(__file__).resolve().parent.parent
catalog = json.loads((ROOT / 'data/enemy_visuals.json').read_text())
result = {}
for enemy, definition in catalog.items():
    path = ROOT / 'assets/enemies/animations' / f'{enemy}.png'
    if not path.exists():
        continue
    image = Image.open(path).convert('RGBA')
    measures = []
    for index in range(8):
        alpha = image.crop((index * 128, 0, (index + 1) * 128, 128)).getchannel('A')
        mask = alpha.point(lambda value: 255 if value >= 128 else 0)
        left, top, right, bottom = mask.getbbox()
        measures.append({'width': right-left, 'height': bottom-top,
                         'area': sum(mask.histogram()[128:]), 'bottom': bottom})
    idle = measures[:int(definition.get('idle_frames', 8))]
    height = statistics.median(pose['height'] for pose in idle)
    extent = statistics.median(pose['width']*pose['height'] for pose in idle)
    area = statistics.median(pose['area'] for pose in idle)
    factors = [1.0]*8
    for index in (range(4, 8) if int(definition.get("attack_frames", 0)) == 4 else []):
        pose = measures[index]
        footprint = pose['width']*pose['height']
        # Do not shrink large poses, or enlarge poses solely because wings fold.
        if pose['height'] < height*.9 and (footprint < extent*.85 or pose['area'] < area*.8):
            factors[index] = round(min(1.3, max(1.0, math.sqrt(extent/footprint), math.sqrt(area/pose['area']))), 4)
    result[enemy] = {'scale': factors, 'bottom': [pose['bottom'] for pose in measures],
                     'sha256': hashlib.sha256(path.read_bytes()).hexdigest()}
(ROOT/'data/enemy_pose_sizes.json').write_text(json.dumps(result, indent=2)+'\n')
print(f'{len(result)} atlases measured; {sum(any(f>1 for f in r["scale"]) for r in result.values())} with small attack poses')
