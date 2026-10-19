"""Small checkpoint reader and safe image-tool result storage; never generates artwork."""
from pathlib import Path
import hashlib
import json
import shutil
import sys
from PIL import Image

ROOT=Path(__file__).resolve().parents[1]
DOC=ROOT/'art_sources/art_direction/postapocalyptic'

def pending(limit):
    jobs=json.loads((DOC/'queue.json').read_text())['jobs']
    todo=[]
    for job in jobs:
        ledger=DOC/'jobs'/f'{job["id"]}.json'
        if ledger.exists() and (ROOT/job['source']).exists():
            previous=json.loads(ledger.read_text())
            if (not job['transparent'] or previous.get('transparent',False)) and previous.get('prompt')==job['prompt']:continue
        if (DOC/'jobs'/f'{job["id"]}.error.json').exists():continue
        todo.append(job)
    # Establish the entire visual language before filling less visible inventories.
    def priority(j):
        p=j['target']
        if p.endswith('_idle.png') or j['kind']=='hero_bank':return 0
        if j['kind']=='hero_foreground':return 1
        if p in ['assets/title/background.png','assets/base_camp/dusk/background.png','assets/dungeon/combat.png','assets/forest/combat_glade.png','assets/volcano/combat.png']:return 2
        return {'building':3,'portrait':4,'interior':5,'hero_action':6,'machine_bank':7,'machine_foreground_bank':8,'enemy_bank':7,'card_bank':8,'enemy_actor':7,'enemy_foreground':8}.get(j['kind'],9)
    todo.sort(key=priority)
    return dict(total=len(jobs),generated=len(jobs)-len(todo),pending=len(todo),paused=(DOC/'generation.pause').exists(),jobs=[] if (DOC/'generation.pause').exists() else todo[:limit])

def store(record):
    job=record['id']
    if not all(c.isalnum() or c=='_' for c in job):raise ValueError('Invalid job id')
    source=ROOT/record['source']
    if not source.resolve().is_relative_to((DOC/'sources').resolve()):raise ValueError('Invalid source')
    image=Image.open(record['original'])
    if record['transparent'] and (image.mode!='RGBA' or image.getchannel('A').getextrema()[0]>12):
        raise ValueError('Expected genuine alpha: '+job)
    source.parent.mkdir(parents=True,exist_ok=True)
    temporary=source.with_suffix('.pending')
    shutil.copyfile(record['original'],temporary)
    temporary.replace(source)
    record.update(status='generated',source_sha256=hashlib.sha256(source.read_bytes()).hexdigest(),actual_dimensions=list(image.size))
    ledger=DOC/'jobs'/f'{job}.json'
    if ledger.exists():
        history=DOC/'jobs/history';history.mkdir(exist_ok=True)
        digest=hashlib.sha256(ledger.read_bytes()).hexdigest()[:12]
        shutil.copyfile(ledger,history/f'{job}_{digest}.json')
    temporary=ledger.with_suffix('.pending')
    temporary.write_text(json.dumps(record,ensure_ascii=False,indent=2)+'\n')
    temporary.replace(ledger)
    print(job)

if __name__=='__main__':
    if sys.argv[1]=='store':store(json.loads(sys.argv[2]))
    elif sys.argv[1]=='pending':print(json.dumps(pending(int(sys.argv[2]) if len(sys.argv)>2 else 8),ensure_ascii=False))
