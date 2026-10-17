"""Plan complete raster families, keeping resource paths and sprite formats stable."""
import json,re,math
from pathlib import Path
from PIL import Image
ROOT=Path(__file__).resolve().parents[1]
BASE=ROOT/'docs/comic_rebuild_2026_10_17'
q=json.loads((BASE/'queue.json').read_text()); jobs=q['jobs']; style=q['direction']
manifest=json.loads((ROOT/'docs/art_direction/postapocalyptic/assets.json').read_text())
old=json.loads((ROOT/'docs/art_direction/postapocalyptic/queue.json').read_text())['jobs']
identities=json.loads((ROOT/'docs/art_direction/postapocalyptic/heroes.json').read_text())
covered={t['path'] for j in jobs for t in j['targets']}

def add(id,kind,prompt,targets,transparent=True,hero=None,**kw):
    if any(j['id']==id for j in jobs):return
    targets=[p for p in targets if p in manifest and p not in covered]
    if not targets:return
    jobs.append(dict(id=id,kind=kind,prompt=prompt+'\n'+style,targets=[{'path':p,'dimensions':list(Image.open(ROOT/p).size)} for p in targets],transparent=transparent,hero=hero,source=f'docs/comic_rebuild_2026_10_17/sources/{id}.png',**kw));covered.update(targets)

def plain_prompt(record):
    return record['prompt'].replace('NO panels','No opaque panels in transparent sheets').replace('NO motion lines','Only tiny comic ink motion accents').replace('PIXEL ART','INKED COMIC ART').replace('pixel art','inked comic art').replace('pixel clusters','ink shapes').replace('NO inked comic art','NO pixel art').replace('NO INKED COMIC ART','NO PIXEL ART')

# Preserve the recently authored 24-frame guard, 12-pose attacks and eight-frame gait.
fluid=json.loads((ROOT/'docs/combat_refinement/jobs.json').read_text())
guards=json.loads((ROOT/'docs/guard_weather_2026_10_16/jobs.json').read_text())
for hero in identities:
    identity=identities[hero]
    for action in ['idle','attack','skill','guard','hurt','death','run','thrust','sweep','charged','guard24','run8']:
        target=f'assets/heroes/guard/{hero}.png' if action=='guard24' else f'assets/heroes/running/{hero}.png' if action=='run8' else f'assets/heroes/{"actions" if action in ["thrust","sweep","charged"] else "detail"}/{hero}_{action}.png'
        if action=='guard24':
            prompt=next(j['prompt'] for j in guards if j.get('hero')==hero and j['kind']=='guard');cols,rows,count=6,4,24
        elif action=='run8':
            prompt=f'Exactly EIGHT full-body chronological RUNNING drawings, 4 columns by 2 rows. Natural alternating arms and legs. {identity}. All face RIGHT, identical scale, no shadows, transparent gutters, grounded foot at SAME baseline per cell.';cols,rows,count=4,2,8
        else:
            found=next((j for j in fluid if j['hero']==hero and j['action']==action),None)
            action_prompt={'idle':'subtle guard, breathing, small hand/weapon shifts, wind through hair and clothing, boots remain planted','attack':'clear windup, improvised weapon strike to RIGHT, settle back into guard','skill':'charge and discharge of improvised civilian tool, preparation, effect, recovery','guard':'raise the held tool/shield to brace, absorb impact, return to guard','hurt':'small recoil from incoming hit and settle, no falling or shrinking','death':'progressively stumble to one knee and slump fully down, final pose fallen','run':'run towards RIGHT naturally alternating arms and legs','thrust':'straight forward thrust towards RIGHT with the improvised tool','sweep':'wide sweeping attack towards RIGHT with the improvised tool','charged':'prepare a powerful charged improvised tool strike, impact then recover'}[action]
            prompt=found['prompt'] if found else f'Production animation sheet of {identity}. TWELVE distinct coherent full-body drawings, FOUR columns THREE rows: {action_prompt}. Same scale/camera in every cell, generous transparent gutters, planted foot baseline identical, no cropping, no labels, no terrain.'
            cols,rows,count=4,3,12
        add(f'{hero}_{action}','hero_sheet',prompt,[target],True,hero,action=action,columns=cols,rows=rows,frames=count)
# Classic and forge variants are rederived from the new civilian action sheets.
for hero in identities:
    for p in manifest:
        if p==f'assets/{hero}/{hero}-128.png' or p.startswith(f'assets/forge/heroes/{hero}_'):
            covered.add(p)
# Machine families, with the six expressive banks retaining eight authored poses.
expressive=json.loads((ROOT/'docs/combat_refinement/enemy_jobs.json').read_text())
expressive_ids={j['id'] for j in expressive}
for j in old:
    if j['kind']=='machine_bank':
        ids=j['machines'];targets=[]
        for id in ids:
            if id not in expressive_ids:targets += [f'assets/enemies/animations/{id}.png',f'assets/enemies/hd/{id}.png']
        add('machines_'+j['id'],'machine_bank',plain_prompt(j),targets,True,machines=ids,columns=4,rows=4)
    elif j['kind']=='machine_foreground_bank':
        add('foreground_'+j['id'],'enemy_foreground_bank',plain_prompt(j)+' Four different machine closeups in a 2x2 grid, fully isolated transparent cells. Strong white cutout rim, selective action speed hatching, no opaque background panels. Faces and sensors visible, attacking toward LEFT.',[f'assets/comic/enemies/{id}.png' for id in j['machines']],True,machines=j['machines'],columns=2,rows=2)
for j in expressive:
    add('expressive_'+j['id'],'enemy_sheet',plain_prompt(j),[f'assets/enemies/animations/{j["id"]}.png',f'assets/enemies/hd/{j["id"]}.png'],True,enemy=j['id'],columns=4,rows=2)
# Cards are an authored icon bank per hero; structural frames remain blank for live text.
for j in old:
    if j['kind']=='card_bank':add('cards_'+j['hero'],'card_bank',plain_prompt(j)+' Each illustration is an inked miniature comic vignette, slightly richer than a flat symbol but restrained and readable; white cutline around its focal shapes, Ben-Day corner texture. Maintain every specified cell subject/order. Matte near-black backdrop per cell. No text.',[f'assets/cards/art/minimal/{id}.png' for id in j['cards']],False,j['hero'],cards=j['cards'],columns=6,rows=4)
for hero in identities:
    for typ in ['frame','back']:
        j=json.loads((ROOT/f'docs/cards/pixel_retain/{typ}_{hero}.json').read_text())
        add(f'{typ}_{hero}','direct',plain_prompt(j)+' New final card aesthetic: bold hand-inked comic book panel, thin ivory paper cutout outer boundary, dark technological violet/steel trim, small halftone in corners and speed-hatch fittings. Preserve EXACT layout normalized slots of title, cost, image, type and description; no text/numbers baked in. Clean pale ivory description area for black live lettering. No pixel-art texture.',[j['target']],True,hero)
# The current static foreground variants get genuinely new drawings too.
for j in json.loads((ROOT/'docs/visual_polish_2026_10_16/jobs.json').read_text()):
    if j['kind']=='cut_in':add(j['id'],'direct',j['prompt']+' Bold graphic comic cut-paper design and a thin white silhouette rim, half-tone/speed accents only in transparent margins.',[j['target']],True,j['hero'])
# Cinematic portraits derive from new identity images, retaining dimensions.
for hero in identities:
    p=f'assets/cinematics/portraits/{hero}.png'
    if p in manifest:covered.add(p)
# Props, animal sheets and existing ember/fire atlases.
for j in json.loads((ROOT/'docs/base_camp/companions/jobs.json').read_text()):
    add('companion_'+j['id'],'animal_sheet',j['prompt'],[j['target']],True,columns=4,rows=2)
for j in old:
    if j['kind'] in ['objects_atlas','chest_atlas','numbers']:
        add('props_'+j['id'],j['kind'],plain_prompt(j),[j['target']] if j['kind']!='numbers' else [f'assets/ui/numbers/{i}.png' for i in range(10)],True,columns=4 if j['kind']=='objects_atlas' else 3 if j['kind']=='chest_atlas' else 5,rows=4 if j['kind']=='objects_atlas' else 2)
# One consistently animated ember bank feeds old compatible fire formats.
covered.add('assets/camp/front-128.png')
fires=[p for p in manifest if p in ['assets/base_camp/dusk/fire.png','assets/camp/fire-natural.png','assets/camp/fire-flames.png']]
add('barrel_embers','fire_bank','Exactly 24 chronological animation cells, 6 columns x 4 rows. ONE metal postapocalyptic fire barrel, same barrel perfectly stationary in every frame. Warm orange light flickers inside, few floating tiny sparks rise, thin blue-gray smoke curls, NO visible tall flame tongues. Black comic inks, white rim around barrel only. True alpha, empty gutters, equal size, NO horizontal barrel motion, no terrain, no text.',fires,True,columns=6,rows=4)
# Path scenery retains authored route counts/layout and receives page gutters.
for j in json.loads((ROOT/'docs/paths/jobs.json').read_text()):
    add('path_'+j['id'],'direct',j['prompt']+' Draw a new sinister dark comic setting with ivory page gutter at extreme 1 percent margin and inked panel corners. All specified fork exits remain clearly readable, large empty sign/UI overlay zones unchanged. No baked labels.',[j['target']],False)
# Remaining wide images are explicit single assets (panoramas, navigation paper, HUD frames).
remaining=[p for p in manifest if p.endswith('.png') and p not in covered]
critical={'assets/ui/battle_energy_cell.png':'a chunky salvaged battery counter with a large EMPTY nearly-black central rectangular number window, copper bolts and cyan side-tubes; preserve number space centered, no digits', 'assets/ui/cell.png':'one scavenged cyan battery cell token, clear white silhouette border', 'assets/ui/end_turn_round.png':'a large hollow ROUND technological end-turn button frame, dark empty center for live words, ivory outer rim and angular inked lightning notches, no text', 'assets/ui/settings.png':'a simple large dark steel settings cog, white contour and violet tiny electricity accents, central hole clear', 'assets/map/minimal/parchment.png':'an empty dark postapocalyptic route chart, light ivory page gutters, faint blank comic panels only at margins, open center for live node map', 'assets/map/minimal/room_papyrus.png':'a square dark gray paper map node tile with irregular white edge and thick black comic outline, empty middle, no text'}
for p in list(remaining):
    if p in critical:
        add('standalone_'+Path(p).stem,'direct',critical[p]+' Orthographic production UI asset. Keep specified transparent holes and preserve the existing purpose. No letters, numbers or captions.',[p],p not in ['assets/map/minimal/parchment.png'])
# All remaining standalone symbols are generated as consistent 3x3 icon sheets.
remaining=[p for p in manifest if p.endswith('.png') and p not in covered]
icons=[p for p in remaining if Image.open(ROOT/p).width/Image.open(ROOT/p).height<2.2 and not p.startswith('assets/camp/')]
for chunk in range(0,len(icons),9):
    paths=icons[chunk:chunk+9]
    subjects=[]
    for i,p in enumerate(paths):
        name=Path(p).stem.replace('_',' ')
        if p.startswith('assets/forge/badges/'):
            name+='; recognizable improvised civilian weapon/tool or scrap protective workwear, hero violet for warrior, orange for guardian, teal green for rogue, cyan violet for mage'
        if p.startswith('assets/battle_effects/'):name+='; clear symbolic battle status, restrained details, readable at 28 pixels'
        subjects.append(f'cell {i+1}: {name}')
    add(f'icons_{chunk//9:02d}','icon_bank','Production icon bank, exactly NINE equal cells in 3 columns x3 rows, square 1536x1536 canvas. '+ '; '.join(subjects)+f'. Last {9-len(paths)} cells empty. Each subject is a DISTINCT readable standalone icon, tight centered composition, white cut-paper silhouette edge, heavy black ink, strong flat accent color, sparse halftone. True transparent alpha in each cell, clear wide gutters, no sheet borders, no words or numbers. Civilian/industrial machine world. Not a flat geometric placeholder, moderate comic detail.',paths,True,columns=3,rows=3)
# Any residual wide standalone resource receives its own clear redraw.
for p in [p for p in manifest if p.endswith('.png') and p not in covered]:
    add('remaining_'+re.sub('[^a-zA-Z0-9]','_',p),'direct','Redraw a production game illustration for '+p+'. Original postapocalyptic civilian machine resistance world. Maintain its role indicated by file name; dark comic panel backdrop with ivory margins if scenery, otherwise transparent prop cutout. No lettering. Preserve wide framing.',[p],False)
# Vector assets are rewritten through the native SVG ink system, not rasterized.
vectors=[p for p in manifest if p.endswith('.svg')]
q.update(jobs=jobs,covered=len(covered),raster_targets=sum(p.endswith('.png') for p in manifest),derived_targets=sorted(p for p in covered if not any(p==t['path'] for j in jobs for t in j['targets'])),vector_targets=vectors,pending_targets=sorted(set(manifest)-covered-set(vectors)))
(BASE/'queue.json').write_text(json.dumps(q,indent=2,ensure_ascii=False)+'\n')
print(f'{len(jobs)} generation jobs; {len(covered)} raster targets covered; {len(vectors)} vectors; pending {len(q["pending_targets"])}')
