"""Build a resumable asset queue from the audited current consumers."""
import json
from pathlib import Path
from PIL import Image
ROOT=Path(__file__).resolve().parents[1]
DOCS=ROOT/'docs/art_direction/migration'

def plan():
    report=json.loads((ROOT/'docs/art_direction/2026-10-13/review/inventory.json').read_text())
    jobs=[];derived=[]
    for asset in report['assets']:
        p=asset['path'];family=asset['family']
        if asset['style'] != 'pending' or asset['usage'] != 'referenced' or asset['type'] != '.png':continue
        if family in ['heroes/detail','heroes/actions']:continue
        if family in ['forge/heroes','heroes/running'] or p in [f'assets/{h}/{h}-128.png' for h in ['warrior','guardian','rogue','mage']]:
            derived.append(p);continue
        if p.startswith('assets/ui/numbers/') or p in ['assets/camp/front-128.png','assets/camp/fire-natural.png']:
            derived.append(p);continue
        kind='scene'
        if family=='enemies/animations':kind='enemy_actor'
        elif family=='comic/enemies':kind='enemy_foreground'
        elif family.startswith('cards/art'):continue  # Dedicated minimal-card pipeline.
        elif family=='cards/frames':kind='frame'
        elif family=='battle_effects' or family.startswith('relics') or family=='forge/icons' or family=='collection/icons' or family=='ui':kind='icon'
        elif family=='church':kind='specialization'
        elif family=='expeditions':kind='contract'
        elif family=='objects':kind='objects_atlas'
        elif family=='treasure':kind='chest_atlas'
        elif p.startswith('assets/rest/') and Path(p).stem in ['warrior','guardian','rogue','mage']:kind='seated'
        elif family=='cinematics/shots':kind='cinematic'
        elif family=='map/minimal':kind='map' if Path(p).stem in ['parchment','room_papyrus'] else 'icon'
        elif p=='assets/map/group_tab.png' or p=='assets/dungeon/bag.png' or p=='assets/equipment/door.png':kind='icon'
        im=Image.open(ROOT/p)
        alpha=kind in ['icon','enemy_actor','enemy_foreground','seated','frame','objects_atlas','chest_atlas','map'] or (im.mode=='RGBA' and im.getchannel('A').getextrema()[0]<64)
        hero=next((h for h in ['warrior','guardian','rogue','mage'] if Path(p).stem.startswith(h+'_') or Path(p).stem==h or Path(p).stem.startswith('hero_'+h)),None)
        ident=p.removeprefix('assets/').removesuffix('.png').replace('/','__')
        jobs.append({'id':ident,'target':p,'family':family,'kind':kind,'hero':hero,'dimensions':list(im.size),'transparent':alpha,'source':f'docs/art_direction/migration/sources/{kind}/{ident}.png'})
    # Shared glyph bank; extracted glyphs retain their PNG paths and have one baseline.
    jobs.append({'id':'number_bank','kind':'numbers','target':None,'hero':None,'transparent':True,'dimensions':[1536,1024],'source':'docs/art_direction/migration/sources/numbers/number_bank.png'})
    for p in report['assets']:
        if p['usage']=='conditional' and p['type']=='.png':derived.append(p['path'])
    existing=DOCS/'queue.json'
    if existing.exists():
        prior=json.loads(existing.read_text())
        merged={j['id']:j for j in prior['jobs']}
        for job in jobs: merged.setdefault(job['id'],job)
        jobs=list(merged.values())
        derived=list(dict.fromkeys(prior['derived']+derived))
    DOCS.mkdir(parents=True,exist_ok=True)
    (DOCS/'queue.json').write_text(json.dumps({'jobs':jobs,'derived':derived},indent=2)+'\n')
    return {'jobs':len(jobs),'derived':len(derived),'groups':{k:sum(j['kind']==k for j in jobs) for k in sorted({j['kind'] for j in jobs})}}
if __name__=='__main__':print(json.dumps(plan(),indent=2))
