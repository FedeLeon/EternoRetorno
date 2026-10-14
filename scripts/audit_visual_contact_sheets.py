"""Disposable review previews only. Never modify game artwork or imports."""
import json
import math
from pathlib import Path
from PIL import Image, ImageDraw, ImageFont

ROOT = Path(__file__).resolve().parents[1]
OUT = ROOT / 'artifacts/sketchbook-review-current'
FONT = ImageFont.truetype('/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf', 12)

def representative(asset):
    image = Image.open(ROOT/asset['path']).convert('RGBA')
    path = asset['path']
    if '/enemies/animations/' in path or '/heroes/running/' in path:
        image = image.crop((0,0,image.width//8,image.height))
    elif '/heroes/detail/' in path or '/heroes/actions/' in path:
        image = image.crop((0,0,image.width//4,image.height//3))
    elif '/forge/heroes/' in path or path in [f'assets/{h}/{h}-128.png' for h in ['warrior','guardian','rogue','mage']]:
        image = image.crop((0,0,128,128))
    elif path in ['assets/camp/fire-natural.png','assets/base_camp/dusk/fire.png']:
        image = image.crop((0,0,256,256))
    return image

def group(asset):
    path = asset['path']
    if '/enemies/' in path: return 'enemies'
    if '/cards/' in path: return 'cards'
    if any(f'assets/{folder}/' in path for folder in ['heroes','warrior','guardian','rogue','mage','forge/heroes','comic/static']): return 'heroes'
    if any(f'assets/{folder}/' in path for folder in ['battle_effects','relics','forge/icons','collection/icons','objects','ui']): return 'icons'
    return 'screens'

def generate():
    report = json.loads((ROOT/'docs/art_direction/2026-10-13/review/inventory.json').read_text())
    OUT.mkdir(parents=True,exist_ok=True)
    (ROOT/'artifacts/.gdignore').touch()
    families = {}
    for asset in report['assets']:
        if asset['type'] == '.png' and asset['usage'] == 'referenced':
            families.setdefault(group(asset),[]).append(asset)
    pages=[]
    for name,assets in families.items():
        for start in range(0,len(assets),30):
            selected = assets[start:start+30]
            width,height,columns = 250,195,5
            sheet = Image.new('RGB',(columns*width,math.ceil(len(selected)/columns)*height),'#27212e')
            drawing = ImageDraw.Draw(sheet)
            for index,asset in enumerate(selected):
                x,y = index%columns*width,index//columns*height
                picture = representative(asset)
                picture.thumbnail((width-12,height-48))
                sheet.paste(picture,(x+(width-picture.width)//2,y+(height-48-picture.height)//2),picture)
                drawing.text((x+5,y+height-43),asset['path'].removeprefix('assets/')[:39],font=FONT,fill='#eee7f4')
                drawing.text((x+5,y+height-24),asset['style'],font=FONT,fill='#bca2de' if asset['style']=='updated' else '#d6b982')
            path=OUT/f'{name}-{start//30+1}.png'
            sheet.save(path)
            pages.append({'path':str(path.relative_to(ROOT)),'assets':[a['path'] for a in selected]})
    (OUT/'index.json').write_text(json.dumps(pages,indent=2)+'\n')
    return {'images':sum(len(v) for v in families.values()),'pages':len(pages),'families':{k:len(v) for k,v in families.items()}}

if __name__ == '__main__': print(json.dumps(generate(),indent=2))
