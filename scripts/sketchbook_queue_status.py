"""Read one checkpoint for the integrated-tool orchestration; no provider/API calls."""
import argparse
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
DOCS = ROOT / 'docs/art_direction/migration'
ORDER = {kind:i for i,kind in enumerate(['idle_refinement','seated','map','scene','frame','enemy_actor','enemy_foreground','icon','objects_atlas','chest_atlas','numbers','specialization','contract','cinematic'])}

def pending(branch='all'):
    jobs = json.loads((DOCS/'queue.json').read_text())['jobs']
    jobs.sort(key=lambda j:(ORDER[j['kind']],j.get('target') or j['id']))
    tail = {j['id'] for j in [j for j in jobs if j['kind']=='icon'][40:]}
    output = []
    for index,job in enumerate(jobs):
        if branch.startswith('batch') and index%3!=int(branch[-1]): continue
        if branch=='main' and job['id'] in tail: continue
        if branch=='icons' and job['id'] not in tail: continue
        ledger = DOCS/'jobs'/f'{job["id"]}.json'
        if ledger.exists() and (ROOT/job['source']).exists(): continue
        output.append(dict(job,queue_position=index+1))
    return {'total':len(jobs),'branch':branch,'jobs':output}

if __name__=='__main__':
    parser=argparse.ArgumentParser()
    parser.add_argument('--branch',choices=['all','main','icons','batch0','batch1','batch2'],default='all')
    print(json.dumps(pending(parser.parse_args().branch)))
