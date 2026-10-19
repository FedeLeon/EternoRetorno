"""Small exportable index: finished cutouts need no runtime dilation shader."""
import json
from pathlib import Path
root=Path(__file__).resolve().parents[1]
m=json.loads((root/'art_sources/art_direction/postapocalyptic/assets.json').read_text())
paths={p:True for p,r in m.items() if (r.get('comic_rebuild_revision')==1 or r.get('user_preserved_revision') or r.get('hero_action_hd_revision')==1) and r.get('outline_baked',True)}
(root/'data/comic_art.json').write_text(json.dumps({'version':1,'baked':paths},indent=2)+'\n')
print('BAKED COMIC ART:',len(paths))
