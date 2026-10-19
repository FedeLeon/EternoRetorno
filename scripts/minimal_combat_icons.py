"""Author flat comic pictograms. Native SVG source; no generated bitmap illustration."""
from pathlib import Path
import json, re, hashlib

ROOT = Path(__file__).resolve().parents[1]
DOC = ROOT / 'art_sources/battle_effects/minimal_comic_2026_10_19'
INK = '#131927'
WHITE = '#fff5e8'
BLUE = '#80c5f5'
TEAL = '#76ddd1'
RED = '#ff847e'
GREEN = '#a2df77'
GOLD = '#ffd078'
PURPLE = '#c5a0f2'

# Large shapes only: a dominant silhouette and, at most, a few interior marks.
def path(d): return f'<path d="{d}"/>'
def circle(x,y,r): return f'<circle cx="{x}" cy="{y}" r="{r}"/>'
SHIELD = path('M13 11L32 6L51 11V29Q49 45 32 57Q15 45 13 29Z')
SWORD = path('M17 40L43 10L54 7L52 20L25 47L20 43L11 55L7 51L17 40ZM12 35L29 49L33 45L16 31Z')
BOLT = path('M35 7L15 34H29L24 57L50 27H36L42 7Z')
HEART = path('M32 55L12 36Q1 22 12 13Q23 5 32 18Q41 5 52 13Q63 22 52 36Z')
CROSS = path('M25 11H39V25H53V39H39V53H25V39H11V25H25Z')
BOTTLE = path('M25 8H39V21L49 45Q53 56 41 56H23Q11 56 15 45L25 21Z')
ARROW_UP = path('M14 29L32 10L50 29H40V55H24V29Z')
ARROW_DOWN = path('M14 35L32 54L50 35H40V9H24V35Z')
RETURN = path('M27 10L9 25L27 39V29H37Q50 29 50 41Q50 51 38 53V60Q59 56 59 41Q59 20 37 20H27Z')
FLAME = path('M33 6Q35 23 45 26Q55 34 51 46Q46 58 32 58Q15 58 11 43Q7 31 23 19Q21 34 28 34Q36 30 33 6Z')

# id -> (color, outlined silhouette, interior detail). Distinct shape per effect.
ICONS = {
 'attack': (RED,SWORD,path('M26 35L45 15')),
 'guard': (BLUE,SHIELD,path('M32 15V43')),
 'counter': (GOLD,RETURN,''),
 'rear_guard': (BLUE,path('M7 13L24 8L41 13V29Q39 40 24 50Q9 40 7 29Z')+path('M25 21L42 16L57 21V35Q55 47 42 56Q27 47 25 35Z'),''),
 'protector': (TEAL,SHIELD,path('M32 22V40M23 31H41')),
 'roots': (TEAL,path('M8 44H56V51H8Z M8 29H56V36H8Z')+path('M35 8L24 26H34L29 43L46 21H36L41 8Z'),''),
 'resurrection': (TEAL,path('M45 17Q31 6 18 19Q5 33 19 47Q29 57 43 48L48 55Q29 68 12 51Q-2 36 8 18Q22-3 45 9V3L58 17L45 29Z'),path('M32 23V43M22 33H42')),
 'embers': (GOLD,FLAME,path('M31 39L27 49')),
 'imprisonment': (PURPLE,path('M13 9H24V26L30 32L24 38V55H13V36L17 32L13 28Z M51 9H40V26L34 32L40 38V55H51V36L47 32L51 28Z'),''),
 'charged_strike': (GOLD,BOLT,path('M10 12L15 17M51 47L56 52')),
 'vampiric': (RED,path('M32 7Q25 20 17 31Q6 49 22 56Q32 62 43 55Q56 47 45 30Z'),path('M32 32V48M24 40H40')),
 'bulwark': (BLUE,path('M9 10H22V18H28V10H39V18H45V10H56V28L50 54H14L9 28Z'),path('M23 33H42M32 27V45')),
 'frenzy': (RED,path('M11 51L20 12H27L20 53Z M26 55L36 8H43L35 55Z M42 52L51 17H58L50 52Z'),''),
 'beast_command': (GOLD,path('M8 29L37 12V52L8 36Z M21 41L30 41L35 57H24Z'),path('M46 24L55 18M47 39L56 45')),
 'grief': (RED,path('M12 19L22 12L32 22L42 12L52 19V42L42 53H22L12 42Z'),path('M21 30L27 33M43 30L37 33M25 43H39')),
 'healer': (GREEN,CROSS,''),
 'prepared': (GOLD,path('M18 9H46V17L37 30L46 45V55H18V45L27 30L18 17Z'),path('M25 17H39M25 47H39')),
 'armor_plates': (BLUE,path('M8 16L26 9L31 15V45L23 53L8 46Z M33 15L38 9L56 16V46L41 53L33 45Z'),''),
 'source': (TEAL,path('M21 8H43V15H51V55H13V15H21Z'),path('M35 22L25 35H35L30 47')),
 'enraged': (RED,path('M8 54L24 12L35 22L45 9L57 54Z'),path('M33 30V41M33 48V49')),
 'ambush': (PURPLE,path('M7 32Q32 7 57 32Q32 57 7 32Z'),circle(32,32,8)),
 'tainted': (GREEN,path('M32 7Q25 20 17 31Q6 49 22 56Q32 62 43 55Q56 47 45 30Z'),path('M21 42H43')),
 'strength': (RED,ARROW_UP,''),
 'weakness': (PURPLE,ARROW_DOWN,''),
 'fracture': (PURPLE,SHIELD,path('M35 9L27 27L37 31L27 51')),
 'poison': (GREEN,BOTTLE,path('M23 38H41M27 47H37')),
 'weapon_boost': (GOLD,path('M9 53L27 35L24 27L29 18L38 14L35 25L42 30L53 25L50 36L42 41L34 38L16 57Z'),path('M44 7V16M40 11H49')),
 'magic_boost': (TEAL,path('M11 14H53V50H11Z'),BOLT.replace('/>',' fill="'+WHITE+'"/>')),
 'bond_focus': (PURPLE,path('M27 15L21 9Q16 5 11 11L6 18Q2 24 8 29L18 39Q24 44 30 38L35 32M37 49L43 55Q49 59 54 53L59 46Q63 40 57 35L46 25Q40 20 34 26L29 32'),path('M24 40L40 24')),
 'curse_blood': (RED,path('M32 7Q25 20 17 31Q6 49 22 56Q32 62 43 55Q56 47 45 30Z'),path('M21 25L42 47')),
 'curse_burden': (PURPLE,path('M22 13Q32 3 42 13V21H50L57 55H7L14 21H22Z'),path('M24 15H40')),
 'curse_scar': (PURPLE,HEART,path('M35 13L27 28L38 33L29 49')),
 'set_multi': (RED,path('M8 48L19 12L26 15L15 52Z M25 48L36 12L43 15L32 52Z M42 48L53 12L59 15L49 52Z'),''),
 'set_poison': (GREEN,BOTTLE,circle(27,43,3)+circle(39,43,3)),
 'set_block': (BLUE,SHIELD,path('M24 21V40M40 21V40')),
 'set_heal': (GREEN,HEART,path('M32 25V43M23 34H41')),
}

# Open paths need stroked outlines instead of filled, closed silhouettes.
OPEN = {'bond_focus'}

def svg_for(id, width=128, height=128):
 color, silhouette, details = ICONS[id]
 fill='none' if id in OPEN else color
 return (f'<svg xmlns="http://www.w3.org/2000/svg" width="{width}" height="{height}" viewBox="0 0 64 64">'
         f'<g fill="{fill}" stroke="{WHITE}" stroke-width="7" stroke-linejoin="round" stroke-linecap="round">{silhouette}</g>'
         f'<g fill="{fill}" stroke="{INK}" stroke-width="3" stroke-linejoin="round" stroke-linecap="round">{silhouette}</g>'
         f'<g fill="none" stroke="{INK}" stroke-width="3.5" stroke-linejoin="round" stroke-linecap="round">{details}</g></svg>\n')

def create():
 DOC.mkdir(parents=True, exist_ok=True)
 (DOC/'sources').mkdir(exist_ok=True)
 catalog=json.loads((ROOT/'data/battle_effects.json').read_text())
 assert set(ICONS)==set(catalog), 'Every battle effect must have its own symbol'
 records=[]
 for id in catalog:
  source=f'art_sources/battle_effects/minimal_comic_2026_10_19/sources/{id}.svg'
  (ROOT/source).write_text(svg_for(id))
  records.append(dict(id=id,title=catalog[id]['title'],source=source,target=f'assets/battle_effects/{id}.png',dimensions=[128,128]))
 # Same visual vocabulary for all native battle HUD symbols.
 native={'assets/ui/intent/attack.svg':'attack','assets/ui/intent/guard.svg':'guard','assets/ui/intent/counter.svg':'counter'}
 for target,id in native.items():
  old=(ROOT/target).read_text()
  w=re.search(r'width="([^"]+)"',old)[1];h=re.search(r'height="([^"]+)"',old)[1]
  (ROOT/target).write_text(svg_for(id,w,h))
  records.append(dict(id=id,target=target,source=target,native=True))
 # Active block must keep a dark center for digits and the existing contour.
 target='assets/ui/block_active.svg'
 old=(ROOT/target).read_text();w=re.search(r'width="([^"]+)"',old)[1];h=re.search(r'height="([^"]+)"',old)[1]
 (ROOT/target).write_text(f'<svg xmlns="http://www.w3.org/2000/svg" width="{w}" height="{h}" viewBox="0 0 64 64"><g fill="{INK}" stroke="{WHITE}" stroke-width="2" stroke-linejoin="round"><path d="M6 10L32 5L58 10V31Q55 47 32 59Q9 47 6 31Z"/></g></svg>\n')
 records.append(dict(id='active_block',target=target,source=target,native=True))
 target='assets/ui/block_up.svg'
 (ROOT/target).write_text(f'<svg xmlns="http://www.w3.org/2000/svg" width="14" height="22" viewBox="0 0 32 40"><path d="M16 3L3 17H11V36H21V17H29Z" fill="{GREEN}" stroke="{WHITE}" stroke-width="2.5" stroke-linejoin="round"/></svg>\n')
 records.append(dict(id='block_up',target=target,source=target,native=True))
 (DOC/'assets.json').write_text(json.dumps(records,indent=2,ensure_ascii=False)+'\n')
 (DOC/'brief.json').write_text(json.dumps(dict(request='Todos los iconos de efectos, protector, contraataque, retaguardia cubierta, espada y escudo en comic minimalista.',method='Native editable SVG authored in scripts/minimal_combat_icons.py; rasterized with Godot. No ImageGen or API.',constraints=['Legible at 28 px','Flat colors, thick ink, thin light outer cutout','No textures, tiny objects, lighting or decorative particles','Distinct silhouettes, retain effects dialogs, values and IDs']),indent=2,ensure_ascii=False)+'\n')
 print(f'MINIMAL COMIC: {len(catalog)} effects + {len(native)+2} native HUD SVGs')

if __name__=='__main__':create()
