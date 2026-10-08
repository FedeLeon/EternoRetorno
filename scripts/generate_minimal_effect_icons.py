#!/usr/bin/env python3
"""Author simple vector symbols; Godot importer rasterizes the runtime PNGs."""
import json
from pathlib import Path
ROOT = Path(__file__).resolve().parents[1]
OUT = ROOT / 'docs/battle_effects/minimal'
OUT.mkdir(exist_ok=True)
(OUT / '.gdignore').touch()
sword = '<path d="M12 36L34 8L38 8L38 13L16 39M9 29L23 40M9 40L15 34"/>'
shield = '<path d="M24 7L39 13V25Q37 35 24 41Q11 35 9 25V13Z"/>'
heart = '<path d="M24 39L10 25C0 10 17 4 24 16C31 4 48 10 38 25Z"/>'
flame = '<path d="M23 5C30 17 37 17 36 29Q35 41 24 42Q10 41 12 28L18 17L19 28Q28 22 23 5Z"/>'
cross = '<path d="M24 10V38M10 24H38"/>'
up = '<path d="M32 23V8M26 14L32 8L38 14"/>'
down = '<path d="M32 8V23M26 17L32 23L38 17"/>'
skull = '<path d="M14 33V40H34V33Q42 28 39 18Q35 7 24 7Q13 7 9 18Q6 28 14 33Z"/><circle cx="17" cy="23" r="3"/><circle cx="31" cy="23" r="3"/><path d="M24 29V34M20 39V35M28 39V35"/>'
link = '<rect x="7" y="17" width="22" height="13" rx="6" transform="rotate(-35 18 23)"/><rect x="20" y="17" width="22" height="13" rx="6" transform="rotate(-35 31 23)"/>'
star = '<path d="M24 6L28 19L41 24L28 28L24 41L20 28L7 24L20 19Z"/>'
drop = '<path d="M24 6L36 25Q43 41 24 42Q5 41 12 25Z"/>'
clock = '<circle cx="24" cy="24" r="15"/><path d="M24 13V24L32 29"/>'
shapes = {
'rear_guard': (shield + '<path d="M15 24H33M20 19L15 24L20 29"/>', '#93bdd4'),
'roots': ('<path d="M24 7V25M24 25L12 32L8 40M24 25L35 31L40 40M24 25V41M12 32L8 28M35 31L41 27"/>', '#b7ce83'),
'resurrection': ('<path d="M10 27A15 15 0 1 0 16 11M9 8L16 11L13 18"/>' + '<path d="M24 17V32M17 25H31"/>', '#bea3f0'),
'embers': (flame, '#f7a156'),
'imprisonment': ('<rect x="9" y="8" width="30" height="33" rx="3"/><path d="M19 9V40M29 9V40"/>', '#a6c489'),
'charged_strike': (sword + '<path d="M9 9L6 18L14 18L11 26"/>', '#f0bf73'),
'vampiric': ('<path d="M9 11L12 32L19 20M39 11L36 32L29 20"/><path d="M24 25L29 33Q32 40 24 41Q16 40 19 33Z"/>', '#e78593'),
'bulwark': (shield + '<path d="M17 17V30M24 14V34M31 17V30"/>', '#b8c1cc'),
'frenzy': ('<path d="M10 37L16 9L22 37M27 37L33 9L39 37"/>', '#e78968'),
'beast_command': ('<ellipse cx="24" cy="31" rx="11" ry="9"/><circle cx="10" cy="21" r="4"/><circle cx="19" cy="11" r="4"/><circle cx="30" cy="11" r="4"/><circle cx="39" cy="21" r="4"/>', '#deb97c'),
'grief': ('<path d="M12 8L36 40M36 8L12 40M8 27L22 37M26 37L40 27"/>', '#d9a0b5'),
'protector': (shield + '<path d="M24 17V31M17 24H31"/>', '#87c7cd'),
'healer': (cross + '<circle cx="24" cy="24" r="19"/>', '#8ecda0'),
'prepared': (clock + '<path d="M7 5L3 15M38 4L44 12"/>', '#c8b3e5'),
'armor_plates': ('<path d="M10 10H38L35 20H13ZM13 24H35L32 33H16ZM16 37H32L28 43H20Z"/>', '#c5bd9d'),
'source': ('<path d="M7 31H41L34 41H14ZM24 28V7M17 14L24 7L31 14"/>', '#b7a0ee'),
'enraged': (flame + '<path d="M23 28V33M23 37V38"/>', '#eb7864'),
'ambush': ('<path d="M5 24Q24 5 43 24Q24 43 5 24Z"/><circle cx="24" cy="24" r="6"/>', '#d8bb80'),
 'tainted': (shield + '<path d="M27 15L20 25H29L22 34"/>', '#ba8bde'),
'strength': ('<path d="M10 37V22L17 13L24 15L23 24L31 24L35 17L41 22L39 36Z"/>', '#eea576'),
'weakness': ('<g transform="translate(-1 9) scale(.75)">' + sword + '</g><g transform="translate(4 0)">' + down + '</g>', '#b8a4da'),
'fracture': ('<path d="M20 8L9 13V25L16 37L23 41M28 8L39 13V25L31 38M25 10L21 20L28 25L21 33L25 40"/>', '#e9a581'),
'poison': (skull, '#a0d578'),
'weapon_boost': ('<g transform="translate(-1 9) scale(.75)">' + sword + '</g><g transform="translate(4 0)">' + up + '</g>', '#e7c780'),
'magic_boost': (star, '#9bbced'),
'bond_focus': (link, '#dcc98a'),
'curse_blood': (drop + '<path d="M16 18L32 34"/>', '#e48294'),
'curse_burden': ('<path d="M20 15V10Q24 4 28 10V15M13 16H35L41 40H7Z"/><path d="M24 22V34M19 29L24 34L29 29"/>', '#b69cce'),
'curse_scar': (heart + '<path d="M26 12L20 22L28 26L21 36"/>', '#d98caa'),
'set_multi': ('<path d="M7 14H34L29 9M7 24H40L35 19M7 34H34L29 29"/>', '#eaaa81'),
'set_poison': (drop + '<path d="M24 21V34M18 27H30"/>', '#a8d785'),
'set_block': (shield + '<path d="M16 32L24 20L32 32"/>', '#a2c3d7'),
'set_heal': (heart + '<path d="M24 20V31M19 25H29"/>', '#ee9899'),
'attack': (sword, '#e5d4ac'),
'guard': (shield, '#91cfa2'),
'counter': ('<path d="M12 37L32 12M8 29L22 39M24 8H39V23M39 8L28 19"/>', '#d7b2eb'),
}
catalog = json.loads((ROOT / 'data/battle_effects.json').read_text())
assert set(shapes) == set(catalog)
for name, (shape, color) in shapes.items():
    svg = f'<svg xmlns="http://www.w3.org/2000/svg" width="128" height="128" viewBox="0 0 48 48"><g fill="none" stroke="#0b0b12" stroke-width="6" stroke-linecap="round" stroke-linejoin="round">{shape}</g><g fill="none" stroke="{color}" stroke-width="3.5" stroke-linecap="round" stroke-linejoin="round">{shape}</g></svg>\n'
    (OUT / (name + '.svg')).write_text(svg)
print(f'{len(shapes)} minimal vector masters written to {OUT}')
