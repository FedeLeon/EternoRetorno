"""Apply reviewed 2D import policy without editing source images or exporting."""
from pathlib import Path
import json
import re
import sys

ROOT = Path(__file__).resolve().parents[1]
REPORT = ROOT / 'docs/quality/import_optimization'

def imported_bytes(text):
    return sum((ROOT / p).stat().st_size for p in re.findall(r'^path(?:\.\w+)?="res://([^"]+)"', text, re.M) if (ROOT / p).exists())

def policy(path):
    if path.startswith(('assets/equipment/components/', 'assets/run_setup/', 'assets/forge/badges/')) or path in ['assets/ui/cell.png', 'assets/ui/battle_energy_cell.png']:
        return 1, 0.9, 512  # Dedicated HD preparation icons.
    if path == 'assets/camp/fire-flames.png':
        return 1, 0.9, 0  # 24 fixed-region transparent flame poses.
    if path.startswith('assets/paths/'):
        return 1, 0.9, 1280  # Full-screen first-person junction illustrations.
    if path.startswith('assets/cinematics/'):
        return 1, 0.9, 1280  # Story art is viewed full-screen with a gentle pan.
    if path.startswith(('assets/heroes/detail/', 'assets/heroes/actions/')):
        return 1, 0.9, 0  # Fixed frame coordinates, preserve all twelve poses.
    if path.startswith('assets/relics/boss/'):
        return 0, 0.9, 256
    if path.startswith('assets/combat_depth/'):
        return 1, 0.9, 512 if path.endswith('/roots.png') else (0 if path.endswith('/dummy.png') else 1280)
    # Atlas regions in sprites and original card art use fixed pixel coordinates.
    if path.startswith('assets/encounters/'):
        return 1, 0.85, 1280
    if path.startswith('assets/collection/icons/'):
        return 0, 0.85, 256
    if path.startswith('assets/comic/static/'):
        return 1, 0.9, 0  # Full-resolution static hero illustrations with alpha.
    if path.startswith('assets/comic/'):
        return 1, 0.85, 0  # Keep animation frames and portrait crops unchanged.
    if path.startswith('assets/cards/art/minimal/'):
        return 0, 0.9, 512  # Sparse pencil strokes: lossless bounded illustrations.
    if path.startswith('assets/cards/frames/'):
        return 0, 0.7, 768
    if path == 'assets/map/minimal/parchment.png':
        return 0, 0.85, 1280  # Full-screen drawing, not a node icon.
    if path.startswith('assets/map/minimal/'):
        return 0, 0.7, 192
    if path in ['assets/map/group_tab.png', 'assets/dungeon/bag.png', 'assets/ui/end_turn_round.png']:
        return 0, 0.7, 256
    if Path(path).name in ['background.png', 'interior.png', 'combat.png', 'combat_columns.png', 'combat_glade.png', 'combat_ruins.png', 'valhalla.png', 'rest.png'] and not path.startswith('assets/cards/'):
        return 1, 0.85, 1280
    return 0, 0.7, 0

def main():
    REPORT.mkdir(exist_ok=True)
    baseline = REPORT / 'before.json'
    rows = []
    report_only = '--report' in sys.argv
    for file in sorted((ROOT / 'assets').rglob('*.png.import')):
        path = file.relative_to(ROOT).as_posix()[:-7]
        text = file.read_text()
        mode, quality, limit = policy(path)
        rows.append({'asset': path, 'bytes': imported_bytes(text), 'mode': mode, 'quality': quality, 'size_limit': limit})
        if report_only: continue
        for key, value in [('compress/mode',mode), ('compress/lossy_quality',quality), ('process/size_limit',limit)]:
            text = re.sub(r'^' + re.escape(key) + r'=.*$', f'{key}={value}', text, flags=re.M)
        file.write_text(text)
    if report_only:
        (REPORT / 'after.json').write_text(json.dumps(rows, indent=2)+'\n')
        total = sum(r['bytes'] for r in rows)
        print(f'Imported PNGs: {total / 1048576:.2f} MiB')
        return
    if not baseline.exists(): baseline.write_text(json.dumps(rows, indent=2)+'\n')
    print('Policy applied; originals untouched. Reimport in Godot, no export needed.')

if __name__ == '__main__': main()
