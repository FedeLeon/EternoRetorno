"""Redraw editable SVG symbols using an irregular pencil contour vocabulary."""
from pathlib import Path
import hashlib,json
import xml.etree.ElementTree as ET
ROOT=Path(__file__).resolve().parents[1]
# Stroke-only variants preserve compact readable silhouettes and existing IDs.
HEADER='<svg xmlns="http://www.w3.org/2000/svg" width="64" height="64" viewBox="0 0 64 64">'
INK='#bbb0c8';DARK='#1b1722';VIOLET='#897393'
def path(d,stroke=INK,fill='none',width=2):return f'<path d="{d}" fill="{fill}" stroke="{stroke}" stroke-width="{width}" stroke-linejoin="round" stroke-linecap="round"/>'
def svg(body):return HEADER+body+'</svg>\n'
SHIELD='M12 10 L32 5 L53 11 L51 35 Q44 51 32 58 Q18 51 12 35 Z'
SWORD='M42 6 L48 8 L39 37 L32 40 L31 34 Z M23 31 L44 39 M30 39 L24 55 L19 53 L25 38'
shapes={
'assets/ui/sword.svg':path(SWORD)+path('M43 10L34 33 M15 56L28 39',VIOLET,width=1),
'assets/ui/strength.svg':path(SWORD)+path('M49 28L56 20L61 28 M56 20L55 42','#94bc85'),
'assets/ui/weak.svg':path(SWORD)+path('M50 18L51 40 M45 34L51 42L58 35','#c18c96'),
'assets/ui/fracture.svg':path(SHIELD,fill=DARK)+path('M34 8L26 21L36 28L27 40L33 56','#c18c96')+path('M15 14L19 34 M47 14L44 38',VIOLET,width=1),
'assets/ui/block_active.svg':path(SHIELD,fill='#39383f')+path('M16 15L30 10L47 15L46 34L32 51L18 34Z','#8d8b94',width=1)+path('M20 20L25 17 M39 43L35 48',width=1),
'assets/ui/block_up.svg':path('M32 57L31 14 M13 29L32 8L51 29','#88bd70',width=6)+path('M22 29L30 21', '#c3d6ad',width=1),
'assets/ui/heal.svg':path('M24 7L40 8L40 24L57 25L56 40L40 40L39 57L24 56L24 40L7 39L8 24L24 24Z','#ba6777',fill='#9a4354')+path('M28 13L28 28L13 28 M43 36L50 36', '#d4a5ab',width=1),
'assets/ui/poison.svg':path('M17 38Q8 34 10 21Q12 7 31 8Q53 7 54 25Q56 35 46 39L43 51L21 51Z','#91af76',fill='#283125')+path('M18 23L25 23L25 31L17 31Z M38 23L46 24L46 31L38 31Z M31 31L28 38L34 38Z', '#91af76',fill=DARK)+path('M27 45L27 52 M35 44L35 51 M14 16L20 12',width=1),
'assets/ui/chain.svg':path('M28 12Q39 6 46 15Q51 23 43 31L30 42Q20 49 13 40Q7 33 16 24Z',VIOLET,width=3)+path('M32 24Q44 17 51 25Q59 34 50 42L37 53Q27 60 20 51Q13 43 22 35Z',INK,width=3)+path('M24 34L37 24 M31 45L44 34',width=1),
'assets/ui/arrow_right.svg':path('M7 31L49 30 M34 14L53 30L35 48',INK,width=4)+path('M12 35L39 34 M39 17L50 29',VIOLET,width=1),
'assets/ui/arrow_left.svg':path('M57 31L15 30 M30 14L11 30L29 48',INK,width=4)+path('M24 17L15 29 M18 35L48 34',VIOLET,width=1),
'assets/map/minimal/current_room.svg':path('M12 18L32 49L52 17Z',INK,fill='#7b6689')+path('M18 22L32 44 M36 22L46 22',width=1),
'assets/ui/deck.svg':path('M8 15L35 7L48 48L21 57Z',VIOLET,fill=DARK)+path('M20 10L52 13L49 57L18 54Z',INK,fill=DARK)+path('M24 17L45 19L43 47L23 46Z',VIOLET,width=1)+path('M33 24L40 33L33 41L26 33Z',INK,fill='#66536f'),
'assets/ui/settings.svg':path('M25 5L39 5L41 13L48 17L56 15L61 29L54 34L53 42L58 49L47 59L40 53L32 55L26 61L13 53L15 45L10 39L2 36L4 22L12 20L17 14L17 7Z',INK,fill=DARK)+path('M42 25Q46 34 39 41Q31 47 23 39Q17 31 25 24Q34 18 42 25Z',VIOLET,width=3)+path('M27 10L37 10 M8 26L12 26 M44 51L49 46',width=1),
'assets/collection/secret.svg':path('M18 27L46 27L49 56L15 55Z',INK,fill=DARK)+path('M23 27L22 17Q22 7 32 7Q44 6 43 17L43 26',VIOLET,width=3)+path('M33 36L32 46 M22 31L20 48 M38 53L44 52',width=1),
'assets/icon.svg':path('M15 17Q39 3 51 25Q61 50 36 55Q12 58 10 35Q8 14 30 8',VIOLET,width=4)+path('M27 16L46 26L27 43Z',INK,fill=DARK)+path('M13 29L18 18 M38 50L47 44',width=1)}
def main():
    docs=ROOT/'docs/art_direction/migration';docs.mkdir(parents=True,exist_ok=True)
    manifest={}
    for name,body in shapes.items():
        file=ROOT/name
        old=ET.parse(file).getroot()
        content=svg(body).replace('width="64" height="64"',f'width="{old.get("width", "64")}" height="{old.get("height", "64")}" preserveAspectRatio="none"')
        file.write_text(content)
        manifest[name]={'sha256':hashlib.sha256(file.read_bytes()).hexdigest(),'method':'native SVG redraw: searched contours, graphite strokes, restrained functional color'}
    (docs/'vectors.json').write_text(json.dumps(manifest,indent=2)+'\n')
    print(f'{len(manifest)} SVG symbols redrawn; semantic colors and IDs preserved')
if __name__=='__main__':main()
