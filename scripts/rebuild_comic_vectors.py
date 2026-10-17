"""Re-ink existing semantic SVG drawings; preserve paths, sizes and transparency."""
from pathlib import Path
import json,hashlib,copy,xml.etree.ElementTree as ET
ROOT=Path(__file__).resolve().parents[1];BASE=ROOT/'docs/comic_rebuild_2026_10_17'
manifest_path=ROOT/'docs/art_direction/postapocalyptic/assets.json'
manifest=json.loads(manifest_path.read_text());q=json.loads((BASE/'queue.json').read_text())
ET.register_namespace('','http://www.w3.org/2000/svg')
for name in q['vector_targets']:
 p=ROOT/name;backup=BASE/'sources'/('vector_'+name.replace('/','__'))
 if not backup.exists():backup.write_bytes(p.read_bytes())
 if name not in ['assets/ui/polished/button.svg','assets/ui/polished/panel.svg']:
  root=ET.fromstring(backup.read_bytes());box=[float(x) for x in root.get('viewBox','0 0 128 128').split()]
  originals=list(root);root[:]=[]
  # Thin ivory cut-line behind the exact recognizable symbol, never over its letters.
  stroke=1.4*min(box[2:])/96
  rim=ET.Element('{http://www.w3.org/2000/svg}g',{'transform':f'translate({box[2]*.025} {box[3]*.025}) scale(.95)'})
  body=copy.deepcopy(rim)
  for child in originals:
   border=copy.deepcopy(child)
   for shape in border.iter():
    if shape.tag.split('}')[-1] not in ['path','circle','rect','ellipse','polygon','polyline','line']:continue
    if shape.get('fill','black')!='none':shape.set('fill','#fff4df')
    shape.set('stroke','#fff4df');shape.set('stroke-linejoin','round');shape.set('stroke-linecap','round')
    try:width=float(shape.get('stroke-width','0'))
    except ValueError:width=1
    shape.set('stroke-width',str(width+stroke*2))
   rim.append(border);body.append(copy.deepcopy(child))
  root.extend([rim,body]);p.write_bytes(ET.tostring(root,encoding='utf-8'))
 manifest[name]={'sha256':hashlib.sha256(p.read_bytes()).hexdigest(),'source':str(backup.relative_to(ROOT)),'source_sha256':hashlib.sha256(backup.read_bytes()).hexdigest(),'style':'postapocalyptic_comic','comic_rebuild_revision':1,'processing':'native SVG re-inking with ivory silhouette rim; polished chrome redrawn as comic panels'}
manifest_path.write_text(json.dumps(manifest,indent='\t',ensure_ascii=False)+'\n')
print('COMIC VECTORS:',len(q['vector_targets']))
