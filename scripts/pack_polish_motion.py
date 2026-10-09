"""Mechanically separate four drawn poses per row; preserve their RGBA pixels.

ImageGen can leave uneven gutters. Connected opaque body components identify
poses; detached particles and antialiasing go to the nearest body. No artwork,
colors or relative character scale is synthesized. Requires Pillow/NumPy/SciPy.
"""
from pathlib import Path
import json
import numpy as np
from PIL import Image
from scipy.ndimage import label, distance_transform_edt, find_objects

ROOT = Path(__file__).resolve().parents[1]
BASE = ROOT / 'docs/whole_game_polish'
OUT = BASE / 'normalized'
OUT.mkdir(exist_ok=True)
report = {}
for path in sorted((BASE / 'sources').glob('*_motion.png')):
    rgba = np.array(Image.open(path).convert('RGBA'))
    poses = []
    boxes = []
    for row in range(2):
        pixels = rgba[row * len(rgba) // 2:(row + 1) * len(rgba) // 2]
        components, _ = label(pixels[:, :, 3] >= 128, np.ones((3, 3)))
        areas = np.bincount(components.ravel())
        bodies = (np.argsort(areas[1:])[-4:] + 1).tolist()
        assert min(areas[bodies]) > 10000, path
        regions = find_objects(components)
        bodies.sort(key=lambda key: regions[key - 1][1].start)
        body_mask = np.isin(components, bodies)
        nearest = distance_transform_edt(~body_mask, return_distances=False, return_indices=True)
        assignment = components[tuple(nearest)]
        for key in bodies:
            mask = assignment == key
            visible_y, visible_x = np.where(mask & (pixels[:, :, 3] >= 128))
            x0, x1 = max(0, visible_x.min()-2), min(pixels.shape[1], visible_x.max()+3)
            y0, y1 = max(0, visible_y.min()-2), min(pixels.shape[0], visible_y.max()+3)
            pose = pixels[y0:y1, x0:x1].copy()
            pose[~mask[y0:y1, x0:x1]] = 0
            poses.append(Image.fromarray(pose))
            boxes.append([int(x0), int(y0), int(x1), int(y1)])
    width = max(p.width for p in poses) + 40
    height = max(p.height for p in poses) + 40
    sheet = Image.new('RGBA', (width * 4, height * 2))
    for index, pose in enumerate(poses):
        # Identical source scale, no per-pose resizing; transparent padding.
        sheet.paste(pose, ((index % 4) * width + (width-pose.width)//2,
                           (index // 4) * height + height - 20-pose.height))
    sheet.save(OUT / path.name)
    report[path.stem] = {'cell': [width, height], 'source_boxes_per_row': boxes,
                        'poses': 8, 'padding': 20, 'resized': False}
(BASE / 'packing.json').write_text(json.dumps(report, indent=2)+'\n')
print('Packed six complete 4x2 motion sheets with transparent gutters')
