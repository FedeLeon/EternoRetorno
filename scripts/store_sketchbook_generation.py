"""Store an image already delivered by the built-in tool, atomically with its prompt."""
import json
import hashlib
import os
from pathlib import Path
import shutil
import sys

ROOT = Path(__file__).resolve().parents[1]
record = json.loads(sys.argv[1])
source = ROOT/record['source']
source.parent.mkdir(parents=True,exist_ok=True)
temporary = source.with_suffix(f'.pending-{os.getpid()}')
shutil.copyfile(record['original'],temporary)
temporary.replace(source)
ledger = ROOT/'docs/art_direction/migration/jobs'/f'{record["id"]}.json'
if ledger.exists():
    history=ledger.parent/'history'
    history.mkdir(exist_ok=True)
    fingerprint=hashlib.sha256(ledger.read_bytes()).hexdigest()[:12]
    shutil.copyfile(ledger,history/f'{record["id"]}__{fingerprint}.json')
temporary = ledger.with_suffix(f'.pending-{os.getpid()}')
temporary.write_text(json.dumps(record,ensure_ascii=False,indent=2)+'\n')
temporary.replace(ledger)
print(record['id'])
