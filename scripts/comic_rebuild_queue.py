"""Inspect durable ImageGen work; does not call a paid API or modify game assets."""
import json,sys
from pathlib import Path
root=Path(__file__).resolve().parents[1];base=root/'art_sources/comic_rebuild_2026_10_17'
q=json.loads((base/'queue.json').read_text());phase=sys.argv[1] if len(sys.argv)>1 else 'status'
jobs=q['jobs'][100:] if phase=='remaining' else q['jobs']
pending=[j for j in jobs if not (base/'jobs'/f'{j["id"]}.json').exists()]
if phase in ['remaining','pending']:
 limit=int(sys.argv[2]) if len(sys.argv)>2 else 4
 if phase=='remaining' and all((base/'jobs'/f'{j["id"]}.json').exists() for j in q['jobs'][:100]):limit=2
 print(json.dumps({'pending':len(pending),'jobs':pending[:limit]},ensure_ascii=False))
else:
 print(json.dumps({'generated':len(q['jobs'])-len(pending),'generation_jobs':len(q['jobs']),'raster_targets':q['raster_targets'],'vector_targets':len(q['vector_targets']),'pending':len(pending)}))
