"""Disposable contact sheets for visual review; never alter game illustration files."""
import json
import math
from pathlib import Path
from PIL import Image, ImageDraw, ImageFont

ROOT = Path(__file__).resolve().parents[1]
OUT = ROOT / 'artifacts/minimal-card-review'
FONT = ImageFont.truetype('/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf', 14)

def review():
    OUT.mkdir(parents=True, exist_ok=True)
    (ROOT/'artifacts/.gdignore').touch()
    jobs = json.loads((ROOT/'docs/cards/minimal/queue.json').read_text())['jobs']
    pages = []
    for hero in ['warrior','guardian','rogue','mage']:
        available = [j for j in jobs if j['hero']==hero and (ROOT/j['source']).is_file()]
        for start in range(0,len(available),12):
            selection = available[start:start+12]
            canvas = Image.new('RGB',(1280,math.ceil(len(selection)/4)*225),'#25202b')
            draw = ImageDraw.Draw(canvas)
            for index, job in enumerate(selection):
                picture = Image.open(ROOT/job['source']).convert('RGB')
                picture.thumbnail((312,175))
                x,y = index%4*320,index//4*225
                canvas.paste(picture,(x+(320-picture.width)//2,y))
                draw.text((x+5,y+177),job['card']['name'],font=FONT,fill='#e7e1ed')
                draw.text((x+5,y+198),job['card_id'],font=FONT,fill='#bca6d2')
            target = OUT/f'{hero}-{start//12+1}.png'
            canvas.save(target)
            pages.append(str(target.relative_to(ROOT)))
    print(json.dumps({'available':sum((ROOT/j['source']).is_file() for j in jobs),'total':len(jobs),'pages':pages},indent=2))

if __name__=='__main__': review()
