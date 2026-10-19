"""Original vector artwork: six paired tool emblems, comic ink and roster colors."""
import hashlib,json,pathlib
root=pathlib.Path(__file__).resolve().parents[1]
colors={'warrior':'#bd6be1','guardian':'#f0a657','rogue':'#69caa5','mage':'#75d8e6'}
# Motifs occupy one 44x66 panel each; thick strokes remain legible at 30px.
paths={
 'warrior':'<path d="M8 52L34 12 39 17 34 22 36 26 30 29 30 34 25 36 24 41 18 43 12 57Z" fill="COLOR"/><path d="M8 52L3 61M3 49L16 57"/>',
 'guardian':'<path d="M6 15L22 7 39 15 37 39Q33 52 22 60 11 52 8 39Z" fill="COLOR"/><path d="M22 17V45M13 31H31"/>',
 'rogue':'<path d="M16 10H29V26L39 45Q43 58 31 59H12Q1 57 7 44L16 26Z" fill="COLOR"/><path d="M10 42H36M14 10H31M19 18H27"/><circle cx="21" cy="49" r="3" fill="#f2f5eb" stroke="none"/>',
 'mage':'<path d="M25 7L8 34H22L16 60 39 27H26L34 7Z" fill="COLOR"/><path d="M6 19Q-1 30 5 39M38 12Q48 26 42 40" fill="none"/>'}
folder=root/'assets/synergies';folder.mkdir(exist_ok=True)
manifest_path=root/'art_sources/art_direction/postapocalyptic/assets.json';manifest=json.loads(manifest_path.read_text())
for recipe in json.loads((root/'data/synergies.json').read_text()):
 a,b=recipe['heroes']; shape=f'<svg xmlns="http://www.w3.org/2000/svg" width="128" height="128" viewBox="0 0 128 128"><path d="M64 4L114 30V88L64 124 14 88V30Z" fill="#101722" stroke="#e3e8ed" stroke-width="4"/><path d="M64 10L108 34V85L64 116 20 85V34Z" fill="none" stroke="{colors[a]}" stroke-width="4"/><path d="M64 10L108 34V85L64 116" fill="none" stroke="{colors[b]}" stroke-width="4"/>'
 for x,hero in [(19,a),(67,b)]: shape+=f'<g transform="translate({x} 28)" stroke="#090f18" stroke-width="3" stroke-linejoin="round" stroke-linecap="round">'+paths[hero].replace('COLOR',colors[hero])+'</g>'
 shape+='<path d="M58 95L64 89 70 95 64 102Z" fill="#fff3b0"/></svg>\n'
 dest=folder/(recipe['id']+'.svg');dest.write_text(shape)
 def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
 manifest[str(dest.relative_to(root))]={'sha256':sha(dest),'source':'scripts/synergy_emblems.py','source_sha256':sha(pathlib.Path(__file__)),'style':'postapocalyptic_comic','processing':'Original vector pair motifs, roster colors, transparent canvas'}
manifest_path.write_text(json.dumps(manifest,indent='\t',ensure_ascii=False)+'\n')
