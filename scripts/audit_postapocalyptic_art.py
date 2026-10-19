"""Report actual new-direction coverage, independently of previous sketchbook approvals."""
from pathlib import Path
import hashlib
import json
from PIL import Image

ROOT=Path(__file__).resolve().parents[1]
DOC=ROOT/'art_sources/art_direction/postapocalyptic'

def audit():
    queue=json.loads((DOC/'queue.json').read_text())
    manifest=json.loads((DOC/'assets.json').read_text()) if (DOC/'assets.json').exists() else {}
    ready=[];pending=[];bad_alpha=[]
    for j in queue['jobs']:
        source=ROOT/j['source'];ledger=DOC/'jobs'/f'{j["id"]}.json'
        if not source.exists() or not ledger.exists():pending.append(j['id']);continue
        record=json.loads(ledger.read_text())
        if record.get('prompt')!=j['prompt']:
            pending.append(j['id']);continue
        if j['transparent']:
            with Image.open(source) as im:
                if im.mode!='RGBA' or im.getchannel('A').getextrema()[0]>12:
                    bad_alpha.append(j['id']);pending.append(j['id']);continue
        ready.append(j['id'])
    converted=[];legacy=[];mismatches=[]
    for path in sorted((ROOT/'assets').rglob('*')):
        if path.suffix not in ['.png','.svg']:continue
        relative=str(path.relative_to(ROOT));record=manifest.get(relative)
        valid=bool(record and hashlib.sha256(path.read_bytes()).hexdigest()==record['sha256'])
        if valid and record.get('source_sha256') and record.get('source'):
            source=ROOT/record['source']
            valid=source.exists() and hashlib.sha256(source.read_bytes()).hexdigest()==record['source_sha256']
        if valid:
            for source,digest in record.get('inputs_sha256',{}).items():
                original=ROOT/source
                if not original.exists() or hashlib.sha256(original.read_bytes()).hexdigest()!=digest:valid=False
        if valid:converted.append(relative)
        else:
            legacy.append(relative)
            if record:mismatches.append(relative)
    report=dict(direction='postapocalyptic_comic',production_jobs=len(queue['jobs']),
                generated_sources=len(ready),pending_sources=len(pending),pending_jobs=pending,
                invalid_alpha=bad_alpha,converted_resources=len(converted),converted=converted,
                legacy_resources=len(legacy),legacy=legacy,hash_mismatches=mismatches,
                complete=not pending and not legacy and not mismatches)
    output = ROOT / 'artifacts/art_provenance'
    output.mkdir(parents=True, exist_ok=True)
    (output/'status.json').write_text(json.dumps(report,ensure_ascii=False,indent=2)+'\n')
    print(json.dumps({k:v for k,v in report.items() if not isinstance(v,list)},ensure_ascii=False,indent=2))
    return report

if __name__=='__main__':audit()
