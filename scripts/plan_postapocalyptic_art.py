"""Explicit, resumable production inventory for the new comic world. No image edits."""
from pathlib import Path
import json
from PIL import Image

ROOT = Path(__file__).resolve().parents[1]
DOC = ROOT / 'docs/art_direction/postapocalyptic'
HEROES = ['warrior', 'guardian', 'rogue', 'mage']
STYLE = ('Original post-apocalyptic civilian resistance world. AMERICAN ACTION COMIC, '
         'late 1990s arcade fighting-game illustration. Bold confident BLACK INK contours, '
         'clean angular silhouettes, rich FLAT vibrant colors, large HARD-EDGED cel-shaded '
         'shadows, sparse printed halftone. Deep ink black and aubergine, vivid teal/cyan '
         'electronics, rusty orange and violet clothing, warm natural skin. NOT pencil '
         'sketchbook, NOT grayscale, NO dense scratchy crosshatching, NO photorealism, '
         'NO 3D, NO pixel art. Ordinary people with patched civilian clothes and improvised '
         'tools fight autonomous machines. NO medieval armor, swords, cloaks, runes, '
         'magic staffs, skeletons, goblins or monsters. No franchise characters, logos '
         'or superhero costumes. No text or UI baked in unless explicitly required. ')
MACHINES = {
 'crypt_bat':('Sonda de conductos','small one-eyed bat-shaped inspection drone, sheet-metal wings'),
 'crypt_lancer':('Operario perforador','skeletal exposed-frame maintenance robot, long drill lance'),
 'crypt_shaman':('Relé incendiario','hunched cable-covered relay robot with a welding torch'),
 'crypt_slime':('Fuga corrosiva','low tracked chemical-cleaning robot leaking bright green coolant'),
 'skeleton_6':('Custodio de acceso','heavy biped security robot with broad riot shield and blue sensor'),
 'crypt_automaton':('Guardián del subsuelo','massive broken hydraulic tunnel guardian, claw and cylindrical reactor chest'),
 'skeleton_0':('Cortador industrial','thin biped factory cutter robot with saw-arm and rusted orange shell'),
 'skeleton_2':('Torreta móvil','thin biped mobile rivet-launcher robot with long crossbar gun'),
 'skeleton_3':('Unidad de contención','rectangular shield-bearing biped security robot with short shock baton'),
 'skeleton_5':('Desguazador','bare-frame aggressive demolition robot with twin rotating cutters'),
 'elemental_2':('Compactador','bulky concrete-crushing construction robot with piled armor slabs'),
 'elemental_7':('Interferencia negra','angular stealth surveillance robot wrapped in dark fiber panels, violet optic'),
 'goblin_0':('Recolector armado','small hunched junk-collector robot with steel hook'),
 'goblin_2':('Disparador de clavos','small scavenger robot with pneumatic nail launcher'),
 'goblin_3':('Nodo de reparación','small cable-haired repair robot carrying green coolant canisters'),
 'beast_0':('Sabueso de patrulla','lean four-legged robotic patrol hound, gray panels, cyan eye'),
 'beast_1':('Excavador compacto','low stocky four-legged excavator with boar-like front plow'),
 'beast_5':('Triturador pesado','massive bear-shaped industrial demolition robot with piston forearms'),
 'goblin_7':('Supervisor del cinturón','large industrial supervisor robot with hazard-striped armor and crane claw'),
 'goblin_1':('Recolector de asta','small salvage robot holding a long grappling pole'),
 'goblin_4':('Portacargas explosivas','small round demolition robot with exposed explosive red canister'),
 'goblin_5':('Desmontador','nimble salvage robot with twin mechanical pincers'),
 'goblin_6':('Patrulla de arrastre','small salvage robot mounted on a separate single-wheel motor chassis'),
 'beast_2':('Dron de ala ancha','large wing-shaped search drone with two articulated folding metal wings'),
 'beast_7':('Carroñero aéreo','black bird-shaped scrap-recovery drone with long articulated beak clamp'),
 'skeleton_4':('Enlace de reactivación','thin cable-limbed robot with antenna coil and violet power cell'),
 'elemental_0':('Incinerador','compact walking incinerator robot, vented furnace body with orange flame nozzle'),
 'crypt_beetle':('Blindado de inspección','six-legged metal beetle inspection robot with broad domed armored shell'),
 'bandit_2':('Vigía de precisión','lean biped security automaton with long improvised-looking rail launcher'),
 'beast_4':('Fumigador','squat four-legged chemical robot with big green pressurized tank'),
 'elemental_6':('Enredador de cables','walking root-like tangle of industrial cables controlled by a small orange core'),
 'skeleton_1':('Perforador de riel','rail-maintenance biped robot with long steel spike and cyan sensor'),
 'skeleton_7':('Corredor de carga','horse-shaped quadruped cargo robot with exposed pistons and battery packs'),
 'elemental_1':('Refrigerador móvil','heavy insulated coolant robot, ice-blue tanks, thick hose arms'),
 'flying_0':('Dron nocturno','compact black wing drone with two red night-vision sensors'),
 'flying_4':('Aguijón de seguridad','wasp-shaped security drone with yellow chassis and needle tail'),
 'flying_7':('Ojo de rastreo','owl-shaped surveillance drone with large paired camera optics'),
 'bandit_0':('Asaltante de chatarra','small fast biped raider robot with broad scraper blade and scrap panels'),
 'bandit_1':('Punzón de la central','tall furnace-service robot with long red-hot industrial lance'),
 'bandit_3':('Barrera de la central','wide biped guard robot with heavy heat shield and orange sensor'),
 'bandit_5':('Prensa de demolición','huge riveted industrial press automaton with a hammer piston arm'),
 'flying_2':('Dron de combustión','small twin-wing furnace drone with two orange burner nozzles'),
 'elemental_5':('Filtro de ceniza','floating industrial filter drone with segmented dust-extraction tubes'),
 'flying_3':('ARCA, núcleo del reinicio','massive dragon-shaped autonomous reactor maintenance machine with articulated wings, cable tail and bright cyan central reactor; entirely mechanical'),
 'elemental_3':('Bobina de tormenta','Tesla-coil maintenance robot with violet electric arcs and two articulated legs'),
 'beast_3':('Pinza de túnel','scorpion-shaped utility robot with twin pincers and welding tail'),
 'elemental_4':('Nebulizador industrial','hovering toxic mist extraction robot, green compressor and bent antenna'),
 'bandit_6':('Rastreador de perímetro','slender camouflage-panel security robot with cable crossbow launcher'),
 'bandit_4':('Lanzacargas','broad-shouldered demolition robot with orange shoulder mortar'),
 'flying_5':('Coraza de vuelo','six-legged black heat-shield inspection drone with small folding wings'),
 'crypt_bandit':('Extractor de archivos','agile archive-recovery automaton with utility blade and storage satchel'),
 'beast_6':('Serpentín refrigerante','long segmented mechanical coolant serpent with cyan fluid tubes'),
 'flying_1':('Dron alfa','large angular bat-wing surveillance drone with violet scanning optic'),
 'flying_6':('Vigía de azotea','long-wing black reconnaissance drone with cyan camera head'),
 'crypt_wolf':('Sabueso térmico','four-legged black robot hound with hot orange vents and metal claws'),
 'bandit_7':('Supervisor de fundición','towering broad biped foundry supervisor robot with orange hazard panels and huge welding tool'),
}
SCENES = {
 'cinematics/crypt':'Wide empty subterranean transit maintenance network, abandoned rail cars, cyan emergency power and rusted pipes, recently disabled huge hydraulic tunnel guardian in distance. No camp or medieval architecture.',
 'cinematics/forest':'Wide overgrown automated factory belt, vines around broken loading cranes, a disabled industrial supervisor and a distant route toward cooling towers. No camp or medieval buildings.',
 'cinematics/volcano':'Wide automated power station after shutdown, massive silent reactor machinery, cyan cables fading, warm dawn beyond the broken gate. No castle or dragon creature, no camp.',
 'cinematics/intro':'Wide post-apocalyptic civilian refuge among ruined transit infrastructure, salvaged shelters and a warm barrel stove, immense distant autonomous city-control tower. Four small ordinary neighbors with work tools at a distance.',
 'title/background':'Wide post-apocalyptic city at dusk, broken elevated transit, tangled cables, enormous distant machine control tower. Four small CIVILIAN silhouettes below. EXACT title ETERNO RETORNO at upper center, large highly legible inked comic lettering; leave lower middle calm for menu buttons. No other words.',
 'base_camp/dusk/background':'Elevated slightly top-down settlement courtyard at sunset nearly night, reclaimed concrete plaza between ruined industrial walls. EMPTY buildable flat zones at left-upper, left-lower, right-upper and bottom-center, empty tent zone center-left, small empty workshop zone bottom-right. A small circular campfire seat depression centered x50percent y62percent, NO fire baked in. Safe route exit at upper right. NO buildings in foreground because separate cutouts are overlaid. No large props at actor/building zones.',
 'camp/background':'Quiet ruined-city refuge courtyard at dusk. Central EMPTY campfire space at x50percent y64percent, NO fire or barrel drawn because an animated barrel fire is overlaid, flat concrete ground on both sides for TWO seated civilians. Reclaimed tarps, old transit columns, distant ruined skyline. No characters.',
 'dungeon/combat':'Subterranean transit maintenance hall, pipes and broken commuter turnstiles, cyan emergency lamps, rusted rails at far back. Broad FLAT concrete fighting floor begins at38percent image height, entire band45-65percent is clear walkable floor FULL WIDTH. No characters.',
 'dungeon/combat_columns':'Underground machine depot with heavy concrete support columns and inactive industrial arms in distance. Wide floor begins at38percent, unobstructed across full width at45-65percent. No characters.',
 'dungeon/combat_canal':'Subterranean water-treatment room, narrow canal only in distant background, rusty pumps. Wide uninterrupted concrete fighting platform begins at38percent, no pits or water under fighters at45-65percent full width.',
 'forest/combat_glade':'Overgrown industrial service yard, trees and vines engulfing broken autonomous factory equipment, teal filtered daylight. Broad level cracked concrete floor beginning at38percent full width; vegetation behind the battle zone, not covering feet.',
 'forest/combat_ruins':'Overgrown railway loading platform with collapsed steel gantries and vines, defunct robots in distance. Clear level asphalt combat floor from38percent image height to bottom across full width.',
 'volcano/combat':'Automated central power station courtyard, massive reactor gate and cooling towers, orange foundry vents and cyan power cables. NO castle, no statues or medieval architecture. Level broad concrete combat floor begins at37percent height and continues to bottom. Clear floor full width at45-65percent. Any steps end ABOVE37percent. Debris only extreme bottom corners.',
 'rest/background':'Underground maintenance shelter with central EMPTY space near x50percent y65percent for an animated barrel fire, NO fire or barrel drawn. Level concrete ground and clear empty space for seated heroes on both sides. Pipes, reclaimed blankets and low industrial light. No characters.',
 'forest/rest':'Sheltered abandoned bus stop amid overgrown industrial ruins, central EMPTY space x50percent y65percent for an animated barrel fire, NO fire or barrel drawn, clear ground both sides for seated civilians. No characters.',
 'volcano/rest':'Abandoned reactor-service alcove, central EMPTY space x50percent y65percent for an animated barrel fire, NO fire or barrel drawn, pipes and locked cabinets at back. Empty ground either side for seated civilians. No characters.',
 'collection/background':'Refuge archive room, pinned civilian photographs, recovered storage drives, broken city map and violet desk lamp. Calm dark central/right empty space for achievement interface, no legible labels.',
 'inventory/background':'Close open reclaimed field backpack on industrial workshop table with medical supplies, cables and salvage components along edges. Dark clean center for deck/inventory overlay. No medieval objects.',
 'reward/background':'Dark industrial power discharge halo around screen EDGES, vivid cyan and violet angular comic lightning, mostly empty charcoal center for three reward cards. No actual cards or words.',
 'equipment/valhalla':'Improvised supply lockers in ruined urban refuge, repaired armor pads, batteries and utility tools at side edges, quiet middle for equipment selection. No palace or medieval objects.',
 'combat_depth/training':'Refuge practice yard with battered concrete, old tires, makeshift robot training target in DISTANCE; clear level floor begins38percent. No characters in fighting area.',
 'combat_depth/dummy':'ONE isolated improvised training mannequin made of tires, scrap steel plates and taped padding on two thin concrete-supported posts, cyan painted target mark. TRUE transparent cutout, no scenery.',
 'combat_depth/merchant':'ONE isolated tired civilian traveling salvage vendor in patched teal raincoat, satchel of cables, batteries and medicine. Visible face, no weapons, no medieval fantasy. Transparent cutout.',
 'combat_depth/roots':'ONE isolated compact bundle of hostile cable tendrils and hydraulic restraints wrapping around an empty central space, cyan sparks and black rubber, no vegetation, no person. True transparency.',
 'encounters/well':'Broken municipal water purification pump beneath a cracked concrete canopy, one repaired tap with clean water. Post-apocalyptic city, no people.',
 'encounters/altar':'Abandoned emergency power terminal with an unstable violet battery and exposed cables, not a religious altar.',
 'encounters/library':'Ruined school archive with torn exercise books, offline data terminals and a cyan emergency lamp, no people.',
 'encounters/forest_spring':'Rainwater collector in an overgrown factory yard, broken pipes and a clean small tank, no people.',
 'encounters/forest_hunter':'An ordinary stranded scavenger beside an empty disabled drone chassis in overgrown factory ruins, patched civilian clothes, wary human face.',
 'encounters/forest_spirit':'An old botanical research terminal still projecting a faint broken cyan schematic among vines, not a magical spirit.',
 'encounters/forge_altar':'Emergency reactor maintenance station with orange hot machinery and a cracked recoverable power core, no religion.',
 'encounters/ash_archive':'Ruined control-room archive with fire-scorched hard drives and paper logs, cyan monitor still lit.',
 'encounters/lava_bridge':'Broken industrial service bridge over hot power plant exhaust, orange heat below and black cables. No medieval fortress.',
}


def create():
    identities = json.loads((DOC/'heroes.json').read_text())
    old = json.loads((ROOT/'docs/art_direction/migration/queue.json').read_text())['jobs']
    jobs = []

    def add(target, kind, hero=None, **extra):
        if kind == 'cinematic':
            hero = next((h for h in HEROES if 'hero_'+h in target), hero)
        ident = target.removeprefix('assets/').removesuffix('.png').replace('/','__')
        dimensions = list(Image.open(ROOT/target).size) if (ROOT/target).exists() else [1536,1024]
        job = dict(id=ident,target=target,kind=kind,hero=hero,dimensions=dimensions,
                   transparent=kind in ['icon','frame','seated','enemy_actor','enemy_foreground','machine_bank','machine_foreground_bank','hero_bank','hero_action','hero_foreground','portrait','building','fire','numbers','objects_atlas','chest_atlas'],
                   source=f'docs/art_direction/postapocalyptic/sources/{ident}.png',**extra)
        if kind in ['map']:job['transparent']=target.endswith('room_papyrus.png')
        if kind == 'portrait':job['transparent']=False
        if kind == 'scene' and target in ['assets/combat_depth/dummy.png','assets/combat_depth/merchant.png','assets/combat_depth/roots.png']:job['transparent']=True
        job['prompt'] = prompt_for(job, identities)
        if target=='assets/cinematics/shots/intro_2.png':job['reference_bank']='docs/art_direction/postapocalyptic/sources/cast_reference.png'
        jobs.append(job)

    for oldjob in old:
        if oldjob['kind'] in ['idle_refinement','numbers']:continue
        add(oldjob['target'],oldjob['kind'],oldjob.get('hero'))
    for hero in HEROES:
        for action in ['idle','attack','skill','guard','hurt','death','run','thrust','sweep','charged']:
            folder='actions' if action in ['thrust','sweep','charged'] else 'detail'
            add(f'assets/heroes/{folder}/{hero}_{action}.png','hero_action',hero,action=action)
        for action in ['attack','defense']:add(f'assets/comic/static/{hero}_{action}.png','hero_foreground',hero,action=action)
        add(f'assets/heroes/identity/portraits/{hero}.png','portrait',hero)
    for id in ['background','market','expeditions','forge','church','refuge','projects','training','plot','fire']:
        add(f'assets/base_camp/dusk/{id}.png','scene' if id=='background' else ('fire' if id=='fire' else 'building'),building=id)
    for id in ['market','forge','church','expeditions','refuge','projects']:
        add(f'assets/{id}/interior.png','interior',building=id)
    cards=json.loads((ROOT/'docs/cards/minimal/queue.json').read_text())['jobs']
    for card in cards:add(f'assets/cards/art/minimal/{card["card_id"]}.png','card',card['hero'],card=card['card'])
    add('assets/ui/numbers/0.png','numbers')
    jobs=list({j['target']:j for j in jobs}.values())
    derived=[]
    compact=[]
    for job in jobs:
        kind=job['kind']
        if kind in ['icon','card','enemy_foreground','frame','map'] or (kind=='hero_action' and job['action']!='idle'):
            derived.append(job)
            continue
        if kind=='enemy_actor':
            derived.append(job)
            continue
        compact.append(job)
    for hero in HEROES:
        target=f'assets/heroes/detail/{hero}_attack.png'
        add(target,'hero_bank',hero)
        job=jobs[-1]
        job['prompt']=STYLE+'Protagonist MUST match reference: '+identities[hero]+'. EXACT24 full-body key poses in SIX columns by FOUR rows on1536x1024, each cell256x256. All face RIGHT, same clothing/tool/body scale, clear margins. Reading left to right then top to bottom: cells0-2 quiet idle;3-6 windup/start attack/contact/recovery with improvised tool;7-8 defensive brace/parry;9-10 hurt recoils;11-13 falling/near ground/lying defeated;14-19 SIX natural running gait phases with opposite arms/legs alternating;20-23 special tool preparation/release/contact/recovery. No numbering or labels, no grid, no floor, TRUE transparent RGBA. Same base position in each cell except fall. No duplicate characters inside a cell.'
        compact.append(job)
        hero_cards=[c for c in cards if c['hero']==hero]
        motifs=[]
        for i,c in enumerate(hero_cards):
            effect='red medical aid' if c['card'].get('heal',0) else 'green corrosive vial' if c['card'].get('poison',0) else 'defensive bracing tool' if c['card'].get('block',0) and not c['card'].get('damage',0) else 'improvised tool attack'
            motif=c['motif']
            for old,new in [('sword','improvised saw blade'),('shield','sheet-metal panel'),('rune','circuit trace'),('staff','antenna'),('crystal','capacitor'),('stars','sparks'),('scroll','work notes'),('cloak','work jacket'),('frost','coolant'),('prism','signal splitter'),('magic','electric'),('arcane','electromagnetic'),('dagger','utility knife'),('gauntlet','work glove'),('helmet','hardhat'),('gold','copper')]:motif=motif.replace(old,new)
            motifs.append(f'cell{i}: {motif}')
        add(f'assets/cards/art/minimal/{hero}_bank.png','card_bank',hero,cards=[c['card_id'] for c in hero_cards])
        job=jobs[-1]
        job['dimensions']=[1536,1024]
        job['prompt']=STYLE+'ONE card-symbol atlas, SIX columns by FOUR rows24cells1536x1024. All cells have the same opaque dark charcoal background #131922, no visible grid or borders. Minimalist symbols,1to3 simple shapes per cell, no full hero or portraits. NO people, heads, faces, shoulders, armor wearers or full bodies in ANY cell. Only isolated objects or abstract action marks. Professional tools: rusted saw blades for carpenter, street-sign metal panels and crowbar for builder, utility knives and chemical vials for pharmacist, antenna coils and battery pulses for teacher. All symbols centered inside central65percent width and central50percent height of each cell. EXACT reading order left to right top to bottom: '+'; '.join(motifs)+'. Cells22and23 empty. NO text or numbers. Bold clean ink outlines, flat bright colors, very sparse hard shadows, no tiny detail.'
        compact.append(job)
    for group in range(14):
        machines=list(MACHINES)[group*4:group*4+4]
        descriptions='; '.join(f'row{i+1}: {MACHINES[id][1]}' for i,id in enumerate(machines))
        add(f'assets/enemies/animations/{machines[0]}.png','machine_bank',machines=machines)
        job=jobs[-1]
        job['prompt']=STYLE+'ONE mechanical enemy animation atlas, FOUR columns by FOUR rows1536x1024. FOUR DIFFERENT machine designs, ONE machine per ROW. Exact row order: '+descriptions+'. Each ROW has4 full-body poses of its machine: idle, windup, attack contact toward LEFT, recovery. Same scale and ground line within each row, entire limbs/tools inside cells,20px clear alpha gutters. All face LEFT. No scenery/floor/grid/numbers/labels, TRUE transparent background. Not a montage: regular sprite sheet.'
        compact.append(job)
        add(f'assets/comic/enemies/{machines[0]}.png','machine_foreground_bank',machines=machines)
        job=jobs[-1]
        job['dimensions']=[1536,1024]
        job['prompt']=STYLE+'ONE four-character foreground cutout atlas, TWO columns by TWO rows1536x1024. Each768x512 cell contains exactly ONE machine attacking LEFT in one STATIC dramatic contact pose, same recognizable chassis as machine-sheet reference. Exact order top-left/top-right/bottom-left/bottom-right: '+'; '.join(MACHINES[id][1] for id in machines)+'. Big head/sensors and weapon or claws, close framing. White thin outer outline around machine AND tool. All art fully within own cell with25px clear margin. No scene/floor/grid/text, TRUE transparent RGBA. No consecutive animation: FOUR DIFFERENT enemies.'
        job['reference_bank']=f'docs/art_direction/postapocalyptic/sources/enemies__animations__{machines[0]}.png'
        compact.append(job)
    jobs=compact
    priorities={'hero_action':0,'hero_foreground':1,'portrait':2,'building':3,'interior':4,'scene':5,'enemy_actor':6,'enemy_foreground':7,'seated':8,'frame':9,'map':10,'card':11,'icon':12,'fire':13,'cinematic':14}
    jobs.sort(key=lambda j:(priorities.get(j['kind'],15),j['target']))
    (DOC/'queue.pending').write_text(json.dumps({'direction':'postapocalyptic_comic','jobs':jobs,'derived':derived},ensure_ascii=False,indent=2)+'\n')
    (DOC/'queue.pending').replace(DOC/'queue.json')
    (DOC/'machines.json').write_text(json.dumps(MACHINES,ensure_ascii=False,indent=2)+'\n')
    print(json.dumps({'jobs':len(jobs),'kinds':{k:sum(j['kind']==k for j in jobs) for k in sorted({j['kind'] for j in jobs})}},indent=2))


def prompt_for(j, identities):
    kind=j['kind'];path=j['target'];stem=Path(path).stem;hero=j['hero']
    text='Use case: stylized-concept. Production asset for Eterno Retorno. '+STYLE
    if hero:text+='Protagonist design MUST match the reference exactly: '+identities[hero]+' '
    if kind=='hero_action':
        action={'idle':'quiet idle, feet and torso stationary, tiny hand/clothing shifts only, NO attacks', 'attack':'swinging the improvised tool forward toward RIGHT', 'skill':'stronger deliberate use of the same improvised weapon toward RIGHT', 'guard':'bracing and parrying with the same tool or sheet-metal shield','hurt':'brief recoil from impact, stay upright','death':'gradually falling to the ground, NOT disintegration','run':'natural human running toward RIGHT, legs and opposite arms alternate clearly, same full body scale','thrust':'forward thrust with the same improvised tool','sweep':'wide sweeping strike with the same tool','charged':'winding up and releasing a powerful strike with the same tool'}[j['action']]
        if hero=='mage' and j['action'] in ['attack','skill','thrust','sweep','charged']:action='aiming and discharging her homemade electromagnetic antenna toward RIGHT, cyan electrical arc, ordinary civilian posture'
        return text+'EXACTLY TWELVE sequential poses of '+action+'. FOUR columns by THREE rows,1536x1024 sprite sheet. Same face/outfit/equipment/proportions in all12 cells. Full body facing RIGHT. Each pose inside its cell with at least25px clear margins, no overlap. Feet/base same line except falling. TRUE transparent RGBA background, no scenery or floor, no grid lines, no labels or numbers.'
    if kind=='hero_foreground':
        action='ferociously attacking toward RIGHT' if j['action']=='attack' else 'bracing defensively against a strike from the RIGHT, blocking with the same weapon or shield'
        return text+'ONE frozen COMIC foreground closeup, '+action+'. Fierce furious expression, brows down, teeth clenched or battle cry. Face, torso, arms and improvised tool large and clear. Thin white silhouette outline around body AND weapon. Landscape1536x1024, clear margins, TRUE transparent background. No sprite sheet, no multiple poses. Colored lights and sparks limited to a few isolated marks; game animates effects behind.'
    if kind=='portrait':return text+'ONE close-up face and upper torso, three-quarter almost profile looking RIGHT. Large face centered, head fully visible, clothes/tool hints only. Compact landscape portrait2:1, dark inked teal/violet plain background, no scenery, readable at small size, no text. Keep5percent clear margins. OPAQUE background.'
    if kind in ['enemy_actor','enemy_foreground']:
        machine=MACHINES[stem][1]
        if kind=='enemy_foreground':return text+'Enemy: '+machine+'. ONE STATIC foreground attack illustration, attacking from RIGHT toward LEFT. Large sensor/head and attacking tool/claw prominent, aggressive machine posture. Thin clean white outline around complete machine AND weapon. Single frozen pose, NOT sheet/panels. Landscape1536x1024 TRUE transparent background, generous clear margins.'
        return text+'Enemy: '+machine+'. EXACT EIGHT full-body machine poses, FOUR columns by TWO rows on1536x1024. First row4 subtle idle poses, second row4 distinct sequential attack poses windup/swing/contact/recovery. Faces LEFT in every pose. Identical scale and base support line, entire limbs/tools inside each cell with30px transparent gutters. TRUE transparent background, no ground/scenery/grid/words.'
    if kind=='seated':return text+'ONE full-body civilian seated on a low salvaged crate resting, faces RIGHT, warm light fromRIGHT, improvised weapon at rest. Entire body/tool visible, NO medieval gear. TRUE transparent background, no fire, no scenery, no ground. Full cutout with margins.'
    if kind=='building':
        subjects={'market':'scrap-built supply kiosk made from shipping container, open counter and hanging salvaged tools','forge':'small improvised repair workshop with corrugated steel roof, workbench, welding equipment','church':'small community electronics laboratory inside a repurposed concrete utility shelter, cyan battery and antenna; NO religious symbols','expeditions':'small radio dispatch post, patched shipping-container booth, handmade antenna mast and maps','refuge':'patched civilian shelter made from heavy violet canvas, salvaged doors and corrugated panels','projects':'compact neighborhood construction shed, ladders, plans, salvaged solar panel','training':'square icon showing an improvised tire-and-metal robot practice dummy','plot':'ONE empty square concrete foundation pad with scattered scrap at edge and clear center'}
        return text+'ONE isolated '+subjects[j['building']]+'. View slightly from above and front, matches refuge camp camera, grounded base, warm sunset fromupperleft. TRUE transparent RGBA, no surrounding landscape, no people, no text. Generous clear margins. Building proportions wide and squat, not tall.'
    if kind=='interior':
        places={'market':'supply trading kiosk, shelves of batteries and medicine, warm teal work lamp, older civilian woman vendor','forge':'repair workshop with welders and reclaimed tools, stocky civilian mechanic with gloves','church':'community electronics laboratory with scavenged monitors, thoughtful older civilian engineer, no priest or religion','expeditions':'radio dispatch room with antenna equipment and route maps, civilian radio operator with headset','refuge':'sleeping shelter with camp bed and patched blankets, no attendant','projects':'construction planning shed with paper plans and reclaimed components, civilian architect'}
        return text+'Wide16:9 interior: '+places[j['building']]+'. Attendant if present confined to LEFT30percent, waist-up framing. Entire HEAD must fit between20percent and45percent image height, with clear space ABOVE it so a top HUD cannot cover the face. No oversized portrait or head at the top edge. If no attendant specified, show ONLY the furnished room, NO person at all. Keep RIGHT65percent spacious, dark, low detail for2x2 hero cards or contract cards. Foreground desk only along bottom/left. No actual UI cards, no text, no labels.'
    if kind=='scene':return text+SCENES.get(path.removeprefix('assets/').removesuffix('.png'),'Post-apocalyptic civilian refuge illustration representing '+stem.replace('_',' ')+'. Clear dark central space for interface.')+' Wide landscape3:2. No characters unless explicitly requested.'
    if kind=='cinematic':
        shots={'hero_warrior_0':'Nicolas works at a cramped carpenter bench repairing a neighbors door, bare head and ordinary shirt/apron, saw used as a normal tool, no combat pose','hero_warrior_1':'Nicolas checks a repaired evacuation handcart and tightens its wooden wheel outside the refuge, bent nails in his hand, quiet determination, no battle','hero_guardian_0':'Ines braces a salvaged sheet-metal door during a civilian evacuation through a damaged alley, work clothes and braid, no medieval armor','hero_guardian_1':'Ines marks a weak concrete support with chalk while a neighbor holds a work light; repaired homes and shared practical work, no battle','hero_rogue_0':'Mauro carefully counts medicine drops under a work lamp, distinct labeled-by-color vials without actual lettering, entire unmasked face visible, pharmacist at work','hero_rogue_1':'Mauro hands clean bandages to an anonymous neighbors outstretched hand at the refuge exit; medical satchel and utility knives at rest, face visible','hero_mage_0':'Vera teaches children to write in reused school notebooks inside a patched classroom; teacher civilian coat, pencil, ordinary peaceful work, NO weapon or fighting','hero_mage_1':'Vera records drone radio patterns on a shelter roof beside her homemade antenna and salvaged battery; one tiny cyan electrical arc, curious concentration, NOT magical casting','intro_0':'Wide deserted ruined-city panorama, automated convoy passing locked residential gates, morning alarm lamps, NO people closeup','intro_1':'Intimate warm refuge shot: ordinary neighbors repairing tools, writing notes and heating water around a barrel stove; natural everyday gestures','intro_2':'Exactly FOUR ordinary neighbors with the FOUR reference faces/outfits leaving the refuge at dawn with their improvised professional tools, not soldiers or superheroes','boss_1_0':'Broken huge tunnel-maintenance guardian lies inert beneath transit rails; TWO anonymous small survivor silhouettes catch their breath','boss_1_1':'Two small survivor silhouettes open a service hatch toward a distant overgrown factory zone, cooler green daylight ahead','boss_2_0':'Defeated industrial supervisor machine hangs still among vines in an abandoned loading yard; two anonymous survivor silhouettes nearby','boss_2_1':'A cleared overgrown road leads toward enormous distant orange-lit reactor cooling towers, two tiny survivors walk onward','boss_3_0':'The massive autonomous ARCA reactor machine collapses between cables and cracked power-station concrete; two tiny survivor silhouettes, no gore','boss_3_1':'Wide quiet sunrise over the civilian refuge, neighbors starting repairs and teaching again beside a dim barrel stove, no victory superheroes'}
        if stem in shots:return text+'ONE single cinematic shot: '+shots[stem]+'. Wide16:9 composition, strong dramatic comic staging, quiet lower25percent for subtitles. No panels or collage, no words or UI.'
        context=('subterranean transit network' if 'boss_1' in stem or stem=='crypt' else 'overgrown industrial belt' if 'boss_2' in stem or stem=='forest' else 'automated power station' if 'boss_3' in stem or stem=='volcano' else 'ruined city refuge')
        return text+'ONE cinematic shot, not montage/panels. Scene '+stem.replace('_',' ')+', setting '+context+'. '+('Intimate civilian everyday life scene matching the named profession and reference hero, working with ordinary tools, no fighting.' if hero or 'hero_' in stem else 'Distant ordinary survivor pair discovers an immense broken autonomous machine and a route onward through ruins, not superhero poses.')+' Strong wide composition,16:9, calm lower quarter for subtitles, no baked-in subtitles or UI.'
    if kind=='frame':return text+'ONE vertical2:3 game card FRAME. Keep exact functional layout: small profession emblem TOPCENTER, light cream clean title strip x12-74percent y14-23percent, dark empty image window y27-61percent, light cream clean description area y63-91percent, dark cost medallion at x88percent y17percent, small icon pill bottom. Thin bold ink black border, angular chipped industrial plate corners, restrained teal/violet highlights. No text/numbers/portrait, true alpha outside silhouette. No ornaments invading text.'
    if kind=='map':return text+('ONE small square scrap of dark industrial route-planning paper, slight ragged ink edge, dark clean center for room icon, TRUE transparency outside scrap.' if 'room_papyrus' in path else 'ONE large worn gray-blue industrial route blueprint sheet, subtle paper texture and rubbed edges, empty central area for map nodes. NO paths, no printed labels, no icons, no UI, no medieval parchment or scroll. Wide16:9.')
    if kind=='card':
        c=j['card'];effect='healing medical kit' if c.get('heal',0) else 'defensive scrap shield or improvised bracing tool' if c.get('block',0) and not c.get('damage',0) else 'green corrosive vial and utility blade' if c.get('poison',0) else 'damaging improvised hand tool'
        return text+'ONE MINIMAL card illustration,2or3 simple shapes showing '+effect+', action metaphor for '+c['name']+' ('+c['id']+'). Replace every fantasy item with carpenter saw, construction sheet metal, pharmacist corrosive vial or teacher electromagnetic cable coil as appropriate to this hero. NO full character, NO detailed portrait, at most cropped hand. Bold clean readable symbol, flat saturated class accent, sparse cel shadows. Landscape16:9, most background empty matte charcoal #131922, central motif occupies65percent, no text/frame/numbers.'
    if kind=='fire':return text+'EXACT TWENTY-FOUR sequential small campfire frames SIX columns by FOUR rows1536x1024, one same salvaged metal barrel stove base each cell, orange flame fluctuates smoothly, subtle rising embers. Same scale/base position, each flame inside cell with15px clear gutters. TRUE transparent background, no scenery, no text/grid. Comic ink contours and cel-shaded orange/yellow fire, no pixel art.'
    if kind=='numbers':return text+'ONE glyph bank, FIVE columns by TWO rows1536x1024. EXACT top row 0 1 2 3 4, bottom row5 6 7 8 9, one bold ivory comic numeral per cell, thin dark ink outline, same cap height/baseline, readable at32x48. TRUE transparency, no backdrop, no other symbols.'
    if kind in ['objects_atlas','chest_atlas']:
        return text+('EXACT FOUR columns by FOUR rows16 isolated survival supply icons: red cardiac monitor module, blue power capacitor ring, emergency restart relay, green corrosive injector tip, violet amplifier coil, reinforced work boots, metal protection plate, salvage exchange token, red medical ampoule, blue energy battery flask, emergency defibrillator cartridge, orange stimulant injector, green concentrated acid bottle, gray armor patch canister, blue cooling ampoule, green antidote injector. Read left to right top to bottom, transparent gutters, no text.' if kind=='objects_atlas' else 'SIX sequential poses of ONE salvaged metal supply case opening, THREE columns by TWO rows1536x1024. Closed to fully open with cyan interior light. Same scale and base, transparent gutters, no scenery or text.')+' TRUE transparent background.'
    if kind=='specialization':return text+'ONE readable comic specialization card illustration: '+stem.replace('_',' ')+'. Show the civilian reference hero using professional equipment in a small industrial workshop context. No fantasy armor/magic. Same hero identity, one action, no text/UI/frame. Landscape3:2.'
    if kind=='contract':return text+'ONE simple comic contract card illustration representing '+stem.replace('_',' ')+': industrial route plan, civilian partnership or machine recovery mission, matching the idea in filename. Spare composition, large single main silhouette, no words or UI border. Dark teal/violet background.'
    return text+'ONE SIMPLE minimalist UI icon representing '+stem.replace('_',' ')+'. Functional meaning must stay readable at30-60pixels. Industrial scrap, electronics or survival supplies instead of fantasy objects. Clear black ink outline, two flat colors, simple shading, ample transparent margin. TRUE transparent background, NO scene, NO words, NO portrait, NO decorative border. Sword icon means improvised saw blade; shield means metal patch; poison means green corrosive vial; soul means recovered blue battery cell; relic means electronic component. Circular controls keep a clean dark center for numbers/text.'

if __name__=='__main__':create()
