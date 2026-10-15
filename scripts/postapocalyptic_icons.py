"""Extend the game's native vector icon language with inked industrial symbols."""
from pathlib import Path
import json

ROOT=Path(__file__).resolve().parents[1]
DOC=ROOT/'docs/art_direction/postapocalyptic'
SHAPES={
 'saw':'<path d="M11 49L45 9L55 17L50 22L45 21L45 27L39 27L39 33L33 33L33 39L27 39L25 45L19 44L15 53Z"/><path d="M8 48L17 55L11 61L3 54Z"/>',
 'shield':'<path d="M12 10L32 4L52 10V31Q49 48 32 59Q15 48 12 31Z"/><path d="M19 17L32 12L45 17V30Q42 41 32 49Q22 41 19 30Z" fill="#172432"/>',
 'bolt':'<path d="M35 3L12 35H29L23 61L54 24H36L43 3Z"/>',
 'acid':'<path d="M24 6H40V16L49 43Q54 57 40 59H23Q10 57 15 43L24 16Z"/><path d="M20 36H44L48 48Q49 53 41 54H23Q17 53 18 48Z" fill="#213b2d"/><circle cx="29" cy="43" r="3" fill="#d6ff8c"/>',
 'cross':'<path d="M24 7H40V23H56V40H40V56H24V40H8V23H24Z"/>',
 'chip':'<path d="M15 15H49V49H15Z"/><path d="M23 23H41V41H23Z" fill="#172432"/><path d="M23 5V15M33 5V15M43 5V15M23 49V59M33 49V59M43 49V59M5 23H15M5 33H15M5 43H15M49 23H59M49 33H59M49 43H59" fill="none"/>',
 'armor':'<path d="M21 7L30 13H34L43 7L56 18L48 32L43 28V56H21V28L16 32L8 18Z"/><path d="M25 26H39V44H25Z" fill="#172432"/>',
 'chain':'<path d="M27 14L21 8Q16 4 11 10L5 18Q1 24 7 29L18 39Q24 45 30 38L35 32M37 49L43 55Q49 60 54 53L60 45Q63 39 57 34L46 24Q40 18 34 25L29 31" fill="none"/><path d="M23 41L41 23" fill="none"/>',
 'eye':'<path d="M4 32Q32 3 60 32Q32 61 4 32Z"/><circle cx="32" cy="32" r="11" fill="#101722"/><circle cx="35" cy="29" r="4" fill="#ecfff7"/>',
 'lock':'<path d="M14 27H50V57H14Z"/><path d="M21 27V18Q21 4 32 4Q43 4 43 18V27" fill="none"/><path d="M32 37V47" fill="none" stroke="#101722"/>',
 'up':'<path d="M14 30L32 8L50 30H40V56H24V30Z"/>',
 'down':'<path d="M14 34L32 56L50 34H40V8H24V34Z"/>',
 'coil':'<path d="M15 52H49M20 46H44M22 38L42 32L22 26L42 20L26 14V6H38V14" fill="none"/><path d="M12 18L5 27H13L9 38M53 11L46 20H54L50 31" fill="none"/>',
 'wrench':'<path d="M42 5L36 18L44 26L57 20Q58 34 44 36L22 57Q15 64 8 56Q2 49 9 43L30 23Q29 8 42 5Z"/><circle cx="15" cy="51" r="3" fill="#101722"/>',
 'heart':'<path d="M32 56L9 34Q-1 14 14 8Q25 4 32 17Q39 4 50 8Q65 14 55 34Z"/><path d="M8 32H22L28 24L34 40L40 31H56" fill="none" stroke="#ffe6df"/>',
 'radio':'<path d="M15 19H50V57H15Z"/><path d="M22 19L36 4" fill="none"/><path d="M23 26H43V34H23Z" fill="#101722"/><path d="M23 43H42M23 49H42" fill="none" stroke="#101722"/>',
 'case':'<path d="M7 19H57V54H7Z"/><path d="M23 19V9H41V19M7 33H57M28 29H36V39H28Z" fill="none"/>',
 'flame':'<path d="M30 4Q34 21 45 17Q43 28 53 35Q62 52 43 59H22Q2 51 13 33L23 18Q22 37 29 35Q39 27 30 4Z"/><path d="M31 32Q50 47 34 55Q19 51 31 32Z" fill="#ffe28c"/>',
 'home':'<path d="M6 31L32 8L58 31H50V57H14V31Z"/><path d="M26 39H38V57H26Z" fill="#101722"/>',
 'steps':'<path d="M8 53H22V40H35V27H49V13H59" fill="none"/><path d="M9 10L23 8L24 25L14 31L7 24Z M31 25L43 23L46 41L36 47L28 39Z"/>',
 'check':'<path d="M15 7H51V58H9V13Z"/><path d="M19 22L25 28L40 13M19 42H40M19 49H40" fill="none" stroke="#101722"/>',
 'flag':'<path d="M13 60V7M16 8Q31 1 42 9L55 8L49 33Q34 39 18 31"/><path d="M7 60H24" fill="none"/>',
 'gear':'<path d="M25 5H39L41 13L49 16L57 14L63 27L56 33L57 42L59 49L46 57L39 51L31 53L25 61L12 55L13 46L7 39L1 35L6 21L15 22L22 16Z"/><circle cx="32" cy="32" r="12" fill="#101722"/>',
 'battery':'<path d="M23 4H41V11H50V59H14V11H23Z"/><path d="M34 18L23 35H32L28 51L43 30H34Z" fill="#101722"/>',
 'group':'<circle cx="22" cy="19" r="9"/><circle cx="43" cy="21" r="8"/><path d="M6 56V44Q7 31 22 31Q37 31 38 44V56Z M39 36Q57 33 59 48V56H43V45Z"/>',
 'fracture':'<path d="M14 8H49L53 52H38L34 40L39 29L30 20L35 8M28 8L23 22L30 31L23 43L27 56H10Z"/>',
}
EFFECTS={'ambush':'eye','armor_plates':'armor','attack':'saw','beast_command':'radio','bond_focus':'chain','bulwark':'shield','charged_strike':'bolt','counter':'saw','curse_blood':'heart','curse_burden':'case','curse_scar':'fracture','embers':'flame','enraged':'flame','fracture':'fracture','frenzy':'bolt','grief':'heart','guard':'shield','healer':'cross','imprisonment':'lock','magic_boost':'coil','poison':'acid','prepared':'check','protector':'shield','rear_guard':'shield','resurrection':'battery','roots':'chain','set_block':'shield','set_heal':'cross','set_multi':'saw','set_poison':'acid','source':'battery','strength':'up','tainted':'acid','vampiric':'heart','weakness':'down','weapon_boost':'saw'}

def symbol(stem,path):
    if 'battle_effects' in path:return EFFECTS[stem]
    if stem=='end_turn_round':return 'radio'
    if stem=='group_tab':return 'group'
    for key,shape in [('guardian','shield'),('warrior','saw'),('rogue','acid'),('mage','coil'),('armor','armor'),('weapon','saw'),('chest','case'),('treasure','case'),('purchase','case'),('contract','check'),('upgrade','wrench'),('home','home'),('steps','steps'),('elite','gear'),('guardian','shield'),('battle','saw'),('victor','flag'),('breath','heart'),('oath','chain'),('echo','radio'),('pact','lock'),('cog','gear'),('blood','heart'),('ruby','heart'),('lantern','battery'),('seal','chip'),('crown','gear'),('spark','bolt'),('ward','shield'),('eye','eye'),('thorn','saw'),('bell','radio'),('tusk','saw'),('knot','chain'),('mirror','chip'),('chain','chain'),('quill','check'),('chisel','wrench'),('mask','eye'),('thread','chain'),('seed','battery'),('shard','bolt'),('drum','coil'),('hammer','wrench'),('charm','shield'),('tooth','acid'),('bag','case'),('boss','chip'),('combat','saw'),('event','radio'),('rest','flame')]:
        if key in stem:return shape
    return 'chip'

def svg_for(stem,path):
    shape=symbol(stem,path)
    color='#6ae4dc' if shape in ['chip','battery','radio','coil','eye'] else '#91e875' if shape=='acid' else '#ef666b' if shape in ['cross','heart'] else '#f6b15a' if shape in ['flame','wrench','gear','case'] else '#b58bf0'
    if shape=='armor':color='#c9d4dd'
    body=SHAPES[shape]
    extra=''
    if stem in ['counter','resurrection']:extra='<path d="M6 24Q3 6 22 5L15 1M22 5L17 13" fill="none" stroke="#f4eee3" stroke-width="4"/>'
    if stem in ['rear_guard','protector','set_block']:extra='<path d="M45 55V38L38 45M45 38L52 45" fill="none" stroke="#eafefb" stroke-width="4"/>'
    if stem in ['frenzy','set_multi']:extra='<path d="M43 43L48 38M49 49L56 42M54 55L61 48" stroke="#f9e9c1" stroke-width="3"/>'
    if path.startswith('assets/relics/'):
        import hashlib
        seed=int(hashlib.sha256(stem.encode()).hexdigest()[:8],16)
        a=10+(seed%9);b=43+((seed>>4)%10)
        extra+=f'<path d="M5 {a}H12V{a+7}H18M46 {b}H53V{b-7}H59" fill="none" stroke="#bff3ec" stroke-width="2"/><circle cx="5" cy="{a}" r="2" fill="#f4cc82"/><circle cx="59" cy="{b-7}" r="2" fill="#f4cc82"/>'
    if path.startswith('assets/collection/'):
        tier=3 if 'fifty' in stem else 2 if stem.startswith(('ten_','five_')) else 1
        for i in range(tier):extra+=f'<path d="M{25+i*7} 58L{28+i*7} 53L{31+i*7} 58Z" fill="#f3c66f" stroke="#0b1621" stroke-width="1"/>'
        body='<path d="M32 1L60 15V49L32 63L4 49V15Z" fill="#142432" stroke="#6f90a1" stroke-width="2"/>'+f'<g transform="translate(8 8) scale(.75)">{body}</g>'
    if stem == 'end_turn_round':
        from postapocalyptic_ui_art import end_turn_frame
        return end_turn_frame()
    return f'<svg xmlns="http://www.w3.org/2000/svg" width="128" height="128" viewBox="0 0 64 64"><g fill="{color}" stroke="#070d16" stroke-width="6" stroke-linejoin="round" stroke-linecap="round">{body}</g><g fill="{color}" stroke="{color}" stroke-width="3" stroke-linejoin="round" stroke-linecap="round">{body}</g>{extra}</svg>'

def create():
    (DOC/'vectors').mkdir(exist_ok=True)
    queue=json.loads((DOC/'queue.json').read_text())
    records=[]
    for job in queue['derived']:
        if job['kind']!='icon':continue
        stem=Path(job['target']).stem;source='docs/art_direction/postapocalyptic/vectors/'+job['id']+'.svg'
        (ROOT/source).write_text(svg_for(stem,job['target']))
        records.append(dict(target=job['target'],source=source,dimensions=job['dimensions'],symbol=symbol(stem,job['target'])))
    from postapocalyptic_ui_art import card_frame, blueprint
    for job in queue['derived']:
        if job['kind'] not in ['frame','map']:continue
        source='docs/art_direction/postapocalyptic/vectors/'+job['id']+'.svg'
        art=card_frame(job['hero'],SHAPES) if job['kind']=='frame' else blueprint(job['target'].endswith('room_papyrus.png'))
        (ROOT/source).write_text(art)
        records.append(dict(target=job['target'],source=source,dimensions=job['dimensions'],symbol='card frame' if job['kind']=='frame' else 'route blueprint'))
    # Native UI vectors keep their physical sizes and public resource paths.
    names={'sword':'saw','poison':'acid','heal':'cross','strength':'up','weak':'down','fracture':'fracture','chain':'chain','settings':'gear','deck':'check','block_active':'shield','block_up':'shield'}
    import re
    for stem,shape in names.items():
        p=ROOT/f'assets/ui/{stem}.svg';old=p.read_text()
        w=re.search(r'width="([^"]+)"',old)[1];h=re.search(r'height="([^"]+)"',old)[1]
        color = '#ef666b' if stem=='heal' else '#91e875' if stem=='poison' else '#b9c6cf' if stem in ['block_active','block_up'] else '#83d7d4'
        s=f'<svg xmlns="http://www.w3.org/2000/svg" width="{w}" height="{h}" viewBox="0 0 64 64"><g fill="{color}" stroke="#070d16" stroke-width="3" stroke-linejoin="round" stroke-linecap="round">{SHAPES[shape]}</g><g fill="{color}" stroke="{color}" stroke-width="1.5" stroke-linejoin="round" stroke-linecap="round">{SHAPES[shape]}</g></svg>'
        if stem=='block_up':
            s=s.replace('</svg>','<path d="M44 50V29L37 36L32 30L48 14L63 30L57 36L51 29V50Z" fill="#8fe98f" stroke="#081522" stroke-width="3" stroke-linejoin="round"/></svg>')
        p.write_text(s)
    (DOC/'vectors.json').write_text(json.dumps(records,ensure_ascii=False,indent=2)+'\n')
    print('Industrial comic vector symbols:',len(records))

if __name__=='__main__':create()
