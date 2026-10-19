"""Inventory visual assets and traced consumers for the current comic artwork.

Style labels are conservative human-review decisions by family, not an image
classifier. No resource is deleted or altered. Sources without a resolved caller
remain 'unresolved' rather than being declared unused.
"""
from collections import Counter, defaultdict
import csv
import hashlib
import html
import json
import os
from pathlib import Path
import re
from PIL import Image
from audit_content import load_documents, EXPANSIONS

ROOT = Path(__file__).resolve().parents[1]
OUT = ROOT / 'artifacts/visual_inventory'
REFERENCES = re.compile(r'res://(assets/[^"\s\)]+)')
VISUAL_EXTENSIONS = {'.png', '.svg'}


def approved_assets():
    # Only the current production ledger defines approval; old migrations are
    # provenance, not competing sources of truth for the current visual state.
    ledger = ROOT / 'art_sources/art_direction/postapocalyptic/assets.json'
    return {asset: {'document': str(ledger.relative_to(ROOT)), 'sha256': record['sha256']}
            for asset, record in json.loads(ledger.read_text()).items()}


def screen_inventory(records):
    # Current screen/presenter chains, including backgrounds selected by floor.
    surfaces = {
        'Inicio y opciones':['title'], 'Campamento':['base_camp/dusk'],
        'Mercado':['market/interior.png'], 'Herrería':['forge/interior.png'],
        'Iglesia':['church/interior.png','church/warrior_','church/guardian_','church/rogue_','church/mage_'],
        'Expediciones':['expeditions/interior.png','expeditions/contract_'],
        'Refugio y vínculos':['refuge/interior.png'], 'Proyectos':['projects/interior.png'],
        'Elección de pareja':['camp/background.png','camp/fire-natural.png','rest/warrior.png','rest/guardian.png','rest/rogue.png','rest/mage.png'],
        'Equipo previo':['equipment'], 'Mapa de todas las mazmorras':['map'],
        'Combate: cripta':['dungeon/combat'], 'Combate: bosque':['forest/combat'],
        'Combate: fortaleza':['volcano/combat'], 'Descanso':['rest','forest/rest.png','volcano/rest.png','camp/fire-natural.png'],
        'Encuentros':['encounters','combat_depth/merchant.png','combat_depth/roots.png'],
        'Tesoro':['treasure','dungeon/combat','forest/combat','volcano/combat'],
        'Recompensa':['reward'], 'Ver mazo y bolsa':['inventory'],
        'Colección y bestiario':['collection'], 'Entrenamiento':['combat_depth/training.png','combat_depth/dummy.png'],
        'Cinemáticas e historias':['cinematics'], 'Cartas de combate y mercado':['cards'],
        'Intenciones y efectos':['battle_effects','camp/front-128.png'],
        'Objetos y reliquias':['objects','relics'], 'Equipo y HUD':['forge/badges','ui'],
        'Actores de héroes':['heroes/detail','heroes/actions','heroes/running','comic/static'],
        'Actores y ataques de enemigos':['enemies/animations','comic/enemies']}
    return [{'screen':name, 'assets':[r['path'] for r in records if r['type'] in VISUAL_EXTENSIONS
            and r['usage'] == 'referenced' and any(r['path'][7:].startswith(p) for p in prefixes)]}
            for name,prefixes in surfaces.items()]


def family(path):
    parts = Path(path).parts[1:]
    return '/'.join(parts[:2]) if len(parts) > 2 else parts[0]


def inventory():
    approved = approved_assets()
    consumers = defaultdict(set)
    text_sources = [p for base in ['src', 'data'] for p in (ROOT/base).rglob('*')]
    text_sources += list((ROOT/'assets').rglob('*.tres')) + [ROOT/'project.godot', ROOT/'main.tscn']
    for source in text_sources:
        if source.suffix not in {'.gd', '.json', '.tres', '.godot', '.tscn'}: continue
        for line, text in enumerate(source.read_text().splitlines(), 1):
            for match in REFERENCES.finditer(text):
                path = match.group(1)
                if (ROOT / path).is_file(): consumers[path].add(f'{source.relative_to(ROOT)}:{line}')
    documents, errors = load_documents(ROOT)
    if errors: raise ValueError(errors)
    content = documents['content']
    enemies = dict(content['enemies'])
    for name in EXPANSIONS['enemies']: enemies.update(documents[name])
    floors = defaultdict(set)
    for floor, definition in documents['dungeons'].items():
        for id in definition['common'] + [definition['elite'],definition['boss'],definition['escort']]: floors[id].add(floor)
    enemy_rows = []
    for id, definition in enemies.items():
        visual = definition['visual']; config = documents['enemy_visuals'][visual]
        row = {'id':id,'name':definition['name'],'visual':visual,'floors':sorted(floors[id]),
               'idle_frames':1,'attack_frames':1,
               'foreground_drawings':config.get('foreground_frames',1),'style':config.get('style','pending')}
        enemy_rows.append(row)
        for folder in ['comic/enemies']:
            consumers[f'assets/{folder}/{visual}.png'].add(f'enemy catalogue: {id} ({definition["name"]})')
        consumers[f'assets/enemies/hd/{visual}.png'].add(f'enemy static fallback: {id}')
    for kind, actors in documents['static_combat'].items():
        for identity, poses in actors.items():
            for action, pose in poses.items():
                consumers[pose['path'][6:]].add(f'static combat: {kind}/{identity}/{action}')
    for hero in content['heroes']:
        for suffix in ['attack','defense']:
            consumers[f'assets/comic/static/{hero}_{suffix}.png'].add('src/presentation/hero_cut_in.gd')
        consumers[f'assets/heroes/identity/portraits/{hero}.png'].add('src/ui/components/refuge_portrait.gd:34')
        consumers[f'assets/heroes/identity/postapocalyptic/{hero}.png'].add('src/ui/components/refuge_portrait.gd: individual full-body comic identity')
        consumers[f'assets/rest/{hero}.png'].add('selection_screen/rest_screen: seated party')
        consumers[f'assets/cards/frames/{hero}.png'].add('src/ui/components/card_view.gd:25')
        consumers[f'assets/cinematics/portraits/{hero}.png'].add('conditional cinematic portrait: chapter without image')
    for id in documents['battle_effects']: consumers[f'assets/battle_effects/{id}.png'].add(f'battle effect: {id}')
    for entry in documents['achievements']: consumers[f'assets/collection/icons/{entry["id"]}.png'].add(f'achievement: {entry["id"]}')
    for id,spec in documents['camp_expansion']['specializations'].items(): consumers[f'assets/church/{spec["art"]}.png'].add(f'specialization: {id}')
    for entry in documents['camp_expansion']['contracts']: consumers[f'assets/expeditions/contract_{entry["art"]}.png'].add(f'contract: {entry["id"]}')
    for id,art in documents['card_art'].items(): consumers[art['source'][6:]].add(f'card art: {id}')
    for folder in ['relics','relics/boss']:
        for path in (ROOT/'assets'/folder).glob('*.png'): consumers[str(path.relative_to(ROOT))].add('src/presentation/relic_art.gd: ID-based relic path')
    for hero in content['heroes']:
        for track in ['weapon','armor']:
            for rank in range(1,4): consumers[f'assets/forge/badges/{hero}_{track}_{rank}.png'].add('equipment_badges: hero/track/rank snapshot')
    for path in (ROOT/'assets/ui/numbers').glob('*.png'): consumers[str(path.relative_to(ROOT))].add('src/ui/components/number_view.gd:30')
    for path in (ROOT/'assets/run_setup').rglob('*.png'): consumers[str(path.relative_to(ROOT))].add('src/ui/screens/run_setup_screen.gd: dedicated difficulty/condition illustration')
    for floor in range(1,4):
        for count in range(1,4): consumers[f'assets/paths/floor_{floor}_{count}.png'].add('src/ui/screens/paths_screen.gd: floor/count-based junction')
    for kind in ['combat','event','treasure','rest','elite','boss']: consumers[f'assets/map/minimal/{kind}.png'].add(f'map node kind: {kind}')
    for id in content['events']:
        if (ROOT/f'assets/encounters/{id}.png').exists(): consumers[f'assets/encounters/{id}.png'].add('event backdrop (shared by related encounters)')
    for path in (ROOT/'assets/encounters').glob('*.png'): consumers[str(path.relative_to(ROOT))].add('encounter backdrop selection: event/alias')
    for path in (ROOT/'assets/ui/polished').glob('*.svg'): consumers[str(path.relative_to(ROOT))].add('src/ui/components/dark_skin.gd: trim(asset)')
    for id in ['market','forge','church','expeditions','refuge','projects','plot','training','fire']:
        consumers[f'assets/base_camp/dusk/{id}.png'].add('src/ui/screens/base_camp_screen.gd: ART + asset ID')
    for id in ['crypt','forest','volcano']:
        consumers[f'assets/cinematics/{id}.png'].add('src/ui/screens/run_result_screen.gd:8; floor background')
    for id in ['heal','upgrade']:
        consumers[f'assets/rest/{id}.png'].add('src/ui/screens/rest_screen.gd:85; rest choice art')
    for id in ['strength','weak','fracture']:
        consumers[f'assets/ui/{id}.svg'].add('src/ui/components/card_type_icons.gd:21; effect name')
    records = []
    for path in sorted((ROOT/'assets').rglob('*')):
        if not path.is_file() or path.suffix in {'.import','.uid'}: continue
        key = str(path.relative_to(ROOT)); group = family(key)
        visual = path.suffix in VISUAL_EXTENSIONS
        status = 'effect_review' if path.suffix == '.gdshader' else 'nonvisual'
        usage = 'referenced' if consumers[key] else 'unresolved'
        priority = None
        provenance = approved.get(key)
        verified = bool(provenance and hashlib.sha256(path.read_bytes()).hexdigest() == provenance['sha256'])
        if visual:
            status = 'pending'; priority = 3
            if key in approved:
                status = 'updated' if verified else 'review'
                priority = None if verified else 2
            elif group == 'comic/static' or key.startswith('assets/heroes/identity/'):
                status = 'review'; priority = 2
            elif group == 'ui/polished': status = 'adapted'; priority = 3
            elif path.suffix == '.svg': status = 'review'; priority = 3
            if group in ['heroes/detail','heroes/actions','heroes/running','rest','enemies/animations','comic/enemies']:
                priority = 1
            if group in ['enemies/hd','cinematics/portraits']:
                usage = 'conditional'; priority = 3
            if group in ['dungeon','forest','volcano','encounters','camp','base_camp','forge','market','church','expeditions','refuge','reward','inventory','equipment','title']:
                priority = 2
            if status == 'updated': priority = None
            if usage == 'unresolved': priority = 3
        dimensions = None
        if path.suffix == '.png':
            with Image.open(path) as image: dimensions = list(image.size)
        records.append({'path':key,'family':group,'type':path.suffix,'dimensions':dimensions,
                        'style':status,'usage':usage,'priority':priority,'consumers':sorted(consumers[key]),'bytes':path.stat().st_size,
                        'provenance':provenance['document'] if provenance else None,'provenance_hash_verified':verified})
    return {'assets':records,'enemies':enemy_rows,'screens':screen_inventory(records),'summary':{
        'physical_assets':len(records),'visual_assets':sum(r['type'] in VISUAL_EXTENSIONS for r in records),
        'types':dict(Counter(r['type'] for r in records)),
        'styles':dict(Counter(r['style'] for r in records)),
        'usages':dict(Counter(r['usage'] for r in records)),
        'referenced_pending_visuals':sum(r['type'] in VISUAL_EXTENSIONS and r['usage']=='referenced' and r['style']=='pending' for r in records),
        'provenance_hashes_verified':sum(r['provenance_hash_verified'] for r in records),
        'provenance_hash_mismatches':[r['path'] for r in records if r['provenance'] and not r['provenance_hash_verified']],
        'enemy_definitions':len(enemy_rows),'enemy_appearances':len({r['visual'] for r in enemy_rows}),
        'enemy_with_dedicated_attack_poses':len({r['visual'] for r in enemy_rows if r['attack_frames']>0}),
        'enemy_foreground_with_multiple_drawings':len({r['visual'] for r in enemy_rows if r['foreground_drawings']>1})}}


def write_outputs(report):
    OUT.mkdir(parents=True,exist_ok=True)
    (OUT/'inventory.json').write_text(json.dumps(report,ensure_ascii=False,indent=2)+'\n')
    with (OUT/'inventory.csv').open('w',newline='') as stream:
        writer = csv.DictWriter(stream,fieldnames=list(report['assets'][0]),lineterminator='\n')
        writer.writeheader();writer.writerows(report['assets'])
    rows = []
    for asset in report['assets']:
        if asset['type'] not in VISUAL_EXTENSIONS: continue
        relative = os.path.relpath(ROOT/asset['path'],OUT)
        safe = html.escape
        rows.append(f'<article data-path="{safe(asset["path"])}" data-usage="{asset["usage"]}" data-style="{asset["style"]}" data-family="{safe(asset["family"])}"><a href="{safe(relative)}"><img loading="lazy" src="{safe(relative)}" alt="{safe(asset["path"])}"></a><p>{safe(asset["path"])}</p><small>{asset["style"]} · {asset["usage"]}</small><details><summary>Consumidores</summary>{safe(chr(10).join(asset["consumers"]))}</details></article>')
    page = '''<!doctype html><html lang="es"><meta charset="utf-8"><title>Auditoría visual de cómic</title><style>body{background:#17131d;color:#dfd9e8;font:14px system-ui;margin:20px}main{display:grid;grid-template-columns:repeat(auto-fill,minmax(220px,1fr));gap:12px}article{padding:10px;border:1px solid #675274}img{width:100%;height:150px;object-fit:contain;background:#332c3b}p{overflow-wrap:anywhere}details{white-space:pre-wrap;font-size:11px}input,select{padding:10px;margin:8px}article[hidden]{display:none}</style><h1>Assets actuales: revisión de cómic</h1><p>Clasificación por familia y revisión visual. «unresolved» no demuestra que un recurso esté muerto. Los atlas completos se muestran tal como están guardados.</p><input id="q" placeholder="Buscar ruta o familia"><select id="s"><option value="">Todos</option><option>updated</option><option>adapted</option><option>pending</option><option>review</option></select><main>'''+''.join(rows)+'''</main><script>function filter(){document.querySelectorAll('article').forEach(a=>a.hidden=(!a.innerText.toLowerCase().includes(q.value.toLowerCase()))||(s.value&&s.value!==a.dataset.style))}q.oninput=filter;s.onchange=filter</script></html>'''
    screen_options = ''.join(f'<option>{html.escape(s["screen"])}</option>' for s in report['screens'])
    screen_data = json.dumps({s['screen']:s['assets'] for s in report['screens']},ensure_ascii=False)
    controls = '<select id="u"><option value="">Todos los usos</option><option>referenced</option><option>conditional</option><option>unresolved</option><option>provenance</option></select>'
    controls += '<select id="v"><option value="">Fondos/assets específicos por vista</option>'+screen_options+'</select>'
    page = page.replace('<main>',controls+'<main>')
    start = page.index('<script>')
    page = page[:start]+'''<script>const screens='''+screen_data+''';const q=document.querySelector('#q'),s=document.querySelector('#s'),u=document.querySelector('#u'),v=document.querySelector('#v');function filter(){document.querySelectorAll('article').forEach(a=>a.hidden=(!a.innerText.toLowerCase().includes(q.value.toLowerCase()))||(s.value&&s.value!==a.dataset.style)||(u.value&&u.value!==a.dataset.usage)||(v.value&&!screens[v.value].includes(a.dataset.path)))}[q,s,u,v].forEach(c=>{c.oninput=filter;c.onchange=filter})</script></html>'''
    (OUT/'gallery.html').write_text(page)


if __name__ == '__main__':
    report=inventory();write_outputs(report);print(json.dumps(report['summary'],ensure_ascii=False,indent=2))
