"""Prove real conversion coverage and source hashes, without rewriting images."""
import json,hashlib
from PIL import Image
from pathlib import Path
ROOT=Path(__file__).resolve().parents[1];BASE=ROOT/'docs/comic_rebuild_2026_10_17'
def sha(path):return hashlib.sha256(path.read_bytes()).hexdigest()
def audit():
 q=json.loads((BASE/'queue.json').read_text());m=json.loads((ROOT/'docs/art_direction/postapocalyptic/assets.json').read_text())
 planned={t['path']:tuple(t['dimensions']) for j in q['jobs'] for t in j['targets']}
 card_art={t['path'] for j in q['jobs'] if j['kind']=='card_bank' for t in j['targets']}
 pending=[];errors=[];done=[];preserved=[]
 for path,record in m.items():
  if record.get('user_preserved_revision'):
   preserved.append(path)
  elif record.get('comic_rebuild_revision')!=1:pending.append(path);continue
  else:done.append(path)
  if path in planned:
   with Image.open(ROOT/path) as image:
    if image.size!=planned[path]:errors.append('Target dimensions mismatch: '+path)
    if path in card_art and max(high-low for low,high in image.convert('RGB').getextrema())<32:
     errors.append('Missing card illustration: '+path)
  if sha(ROOT/path)!=record['sha256']:errors.append('Target hash mismatch: '+path)
  source=ROOT/record['source']
  if not source.is_file() or sha(source)!=record['source_sha256']:errors.append('Source mismatch: '+path)
 report={'generated_jobs':len(list((BASE/'jobs').glob('*.json'))),'generation_jobs':len(q['jobs']),'converted_resources':len(done),'user_preserved_resources':len(preserved),'resources':len(m),'pending_resources':pending,'errors':errors,'complete':not errors and not pending}
 (BASE/'status.json').write_text(json.dumps(report,indent=2,ensure_ascii=False)+'\n')
 print(json.dumps({k:v for k,v in report.items() if k not in ['pending_resources']},ensure_ascii=False))
 return report
if __name__=='__main__':raise SystemExit(bool(audit()['errors']))
