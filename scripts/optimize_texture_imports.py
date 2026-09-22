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
    # Atlas regions in sprites and original card art use fixed pixel coordinates.
    if path.startswith('assets/comic/'):
        return 1, 0.85, 0  # Keep animation frames and portrait crops unchanged.
    if path.startswith('assets/cards/art/'):
        return 1, 0.85, 0 if path.endswith('/originals.png') else 512
    if path.startswith('assets/ui/buttons/'):
        return 0, 0.7, 512
    if path.startswith('assets/cards/frames/'):
        return 0, 0.7, 768
    if path.startswith('assets/map/minimal/'):
        return 0, 0.7, 192
    if path in ['assets/map/group_tab.png', 'assets/equipment/door.png', 'assets/dungeon/bag.png', 'assets/ui/end_turn_round.png']:
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
        excluded = sum(r['bytes'] for r in rows if r['asset'].startswith('assets/comic/attacks/'))
        print(f'Imported PNGs: {total / 1048576:.2f} MiB; included after exclusions: {(total-excluded) / 1048576:.2f} MiB')
        return
    if not baseline.exists(): baseline.write_text(json.dumps(rows, indent=2)+'\n')
    presets = ROOT / 'export_presets.cfg'
    text = presets.read_text()
    text = re.sub(r'^exclude_filter="([^"]*)"', lambda m: 'exclude_filter="'+m[1]+('' if 'assets/comic/attacks/*' in m[1] else ',assets/comic/attacks/*')+'"', text, flags=re.M)
    presets.write_text(text)
    print('Policy applied; originals untouched. Reimport in Godot, no export needed.')

if __name__ == '__main__': main()
