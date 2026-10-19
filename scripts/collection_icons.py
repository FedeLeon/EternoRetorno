"""Original inked industrial collection badges; deterministic native SVG artwork."""
UI = ('achievements', 'history', 'victory', 'return')


def collection_icon(name):
    # Shared industrial badge, with purpose-specific multicolour centre drawings.
    amber = '#efb56d'
    teal = '#70d9d3'
    violet = '#bc94e5'
    red = '#ee8b86'
    motifs = {
        'boot': '<path d="M19 9H35L34 34L48 42L50 51H10V43L17 36Z" fill="#9974ab"/><path d="M10 51H51V57H10Z" fill="#b7c6ce"/><path d="M22 19H33M21 26H32M20 33H31" stroke="#e5c18d" stroke-width="3"/><path d="M45 9H50M50 20H55M48 30H53" stroke="#75d8dd" stroke-width="3"/>',
        'battle': '<path d="M8 5L49 46L43 52L5 14Z" fill="#b5c8d1"/><path d="M55 5L14 46L20 52L59 14Z" fill="#dbe5df"/><path d="M37 48L48 37M16 37L27 48" stroke="#efa46a" stroke-width="6"/><path d="M45 49L55 59M19 49L9 59" stroke="#a786c8" stroke-width="6"/>',
        'machine': '<path d="M13 9H49L56 20V40L44 47V55H20V47L8 40V20Z" fill="#ac94c2"/><path d="M15 22L28 25L25 34H15ZM49 22L36 25L39 34H49Z" fill="#edac68"/><path d="M23 47V55M32 44V56M41 47V55" stroke="#293747" stroke-width="3"/><path d="M18 8L10 2M46 8L54 2" stroke="#d9d7e4" stroke-width="3"/>',
        'core': '<path d="M19 5H45L58 18V44L45 58H19L6 45V19Z" fill="#8c637b"/><path d="M22 14H42L49 22V41L41 49H22L15 41V22Z" fill="#25364a"/><path d="M28 14L35 27L26 35L35 49" stroke="#f2bf7b" stroke-width="4" fill="none"/><path d="M3 30H10M54 30H61M31 2V8M31 54V62" stroke="#c8dbe1" stroke-width="4"/>',
        'crate': '<path d="M7 20L16 9H48L57 20V53L51 59H13L7 53Z" fill="#b97b4f"/><path d="M7 20H57V30H7Z" fill="#e9ba74"/><path d="M17 34V51M47 34V51" stroke="#654c43" stroke-width="6"/><path d="M26 24H38V40H26Z" fill="#344b59"/><path d="M30 29H34V35H30Z" fill="#8ef1df" stroke="none"/>',
        'card': '<path d="M13 5H48L54 11V54L48 60H13L7 54V11Z" fill="#a6bbc8"/><path d="M15 12H45V48H15Z" fill="#28374b"/><path d="M21 18H39M21 25H39M21 43H39" stroke="#7edfdc" stroke-width="3"/><path d="M35 28L23 36H32L29 42L42 31H33Z" fill="#edbb78" stroke-width="1"/>',
        'flag': '<path d="M17 59V7M9 59H27" stroke="#b5c8d1" stroke-width="5"/><path d="M19 8L33 4L52 11L47 36L33 31L19 35Z" fill="#b895dc"/><path d="M25 15L33 12L43 16L39 25L32 21L25 24Z" fill="#eed094" stroke-width="1"/>',
        'trophy': '<path d="M17 9H47V28Q46 40 35 43V51H46V59H18V51H29V43Q18 40 17 28Z" fill="#edb86e"/><path d="M17 15H7V26Q8 36 21 36M47 15H57V26Q56 36 43 36" fill="none" stroke="#b7cbd2" stroke-width="5"/><path d="M25 14H39L35 22L39 30H25L29 22Z" fill="#9c708a" stroke-width="1.5"/>',
        'saw': '<path d="M8 42L47 5L58 15L51 20L46 19L46 26L39 26L39 33L32 33L28 40L22 40L14 49Z" fill="#b6cbd2"/><path d="M8 43L21 54L15 61L2 50Z" fill="#976eac"/><path d="M18 39L46 12" stroke="#ecf4e5" stroke-width="2"/>',
        'shield': '<path d="M15 6H48L57 15V39L41 57H21L6 39V15Z" fill="#df9a61"/><path d="M19 13H43L49 20V36L36 49H26L14 36V20Z" fill="#446b79"/><path d="M21 30H43M32 19V41" stroke="#d7e4dd" stroke-width="6"/>',
        'vial': '<path d="M23 5H41V15L51 43Q57 59 41 60H23Q7 59 13 43L23 15Z" fill="#9ac7bf"/><path d="M18 37H46L49 48Q51 54 40 55H24Q14 54 16 48Z" fill="#82c76f" stroke-width="1.5"/><path d="M23 8H41M25 15H39" stroke="#b68ea2" stroke-width="5"/><circle cx="28" cy="43" r="3" fill="#e6f4b9" stroke="none"/>',
        'coil': '<path d="M17 58H47M22 52H42M23 43L41 35L23 27L41 19L28 12V5H37V12" fill="none" stroke="#78d9df" stroke-width="5"/><path d="M14 20L5 32H14L9 44M52 11L45 24H55L50 35" fill="none" stroke="#c69be5" stroke-width="3"/>',
        'wallet': '<path d="M8 14L46 7L53 17V53H8Z" fill="#8c708f"/><path d="M8 21H56V55H8Z" fill="#b58c74"/><path d="M37 32H59V45H37Z" fill="#3f5667"/><circle cx="46" cy="38" r="3" fill="#8be3d7" stroke="none"/><path d="M15 26H30M15 48H29" stroke="#efcfa0" stroke-width="2"/>',
        'armor': '<path d="M21 5L30 11H34L43 5L58 17L49 32L44 27V58H20V27L15 32L6 17Z" fill="#a6bac3"/><path d="M24 25H40V46H24Z" fill="#6a5c80"/><path d="M27 31H37M27 39H37" stroke="#82d9dd" stroke-width="3"/><path d="M23 16L29 21H35L41 16" stroke="#f3cc89" stroke-width="2" fill="none"/>',
        'contract': '<path d="M15 5H44L53 14V59H11V9Z" fill="#d4d6c7"/><path d="M44 5V15H53M20 20H40M20 27H35" fill="none" stroke="#6d7990" stroke-width="2"/><path d="M21 41L29 49L45 32" fill="none" stroke="#538f8a" stroke-width="6"/><path d="M8 14H15M8 25H15M8 36H15M8 47H15" stroke="#a4b8ca" stroke-width="3"/>',
        'chain': '<path d="M31 15L23 7Q17 2 11 9L6 16Q1 23 8 29L19 40Q26 46 32 39L39 32M33 49L41 57Q47 63 53 56L58 49Q63 42 56 36L45 25Q38 18 32 25L25 32" fill="none" stroke="#b9c9d0" stroke-width="7"/><path d="M23 42L42 23" stroke="#e6b477" stroke-width="6"/>',
        'nodes': '<path d="M17 17H47V47H17Z" fill="none" stroke="#8bd4d5" stroke-width="4"/><circle cx="17" cy="17" r="9" fill="#bd8edb"/><circle cx="47" cy="17" r="9" fill="#e6ad70"/><circle cx="17" cy="47" r="9" fill="#8fcfa6"/><circle cx="47" cy="47" r="9" fill="#83dbe4"/><path d="M27 32H37M32 27V37" stroke="#e5dbb9" stroke-width="3"/>',
        'heart': '<path d="M32 55L10 34Q0 16 14 10Q25 5 32 18Q39 5 50 10Q64 16 54 34Z" fill="#d6838c"/><path d="M8 31H23L29 22L35 41L41 31H56" fill="none" stroke="#eddfab" stroke-width="3"/>',
        'home': '<path d="M5 30L32 6L59 30H52V58H13V30Z" fill="#a480a8"/><path d="M23 58V34H41V58" fill="#375165"/><path d="M20 23L32 13L44 23" fill="none" stroke="#f2bf78" stroke-width="3"/><path d="M28 40H36V49H28Z" fill="#82e3da" stroke="none"/>',
        'lock': '<path d="M17 28V18Q17 4 32 4Q47 4 47 18V28" fill="none" stroke="#adc2cf" stroke-width="7"/><path d="M12 26H52V55L46 61H18L12 55Z" fill="#877195"/><circle cx="32" cy="39" r="6" fill="#d2d7cd"/><path d="M30 42V50H34V42" fill="#d2d7cd" stroke="none"/>',
        'hourglass': '<path d="M16 5H48V12H16ZM16 53H48V60H16Z" fill="#a9c1ce"/><path d="M21 13H43Q43 23 35 31Q43 39 43 52H21Q21 39 29 31Q21 23 21 13Z" fill="#5e8795"/><path d="M26 17H38L32 27ZM25 48L32 36L39 48Z" fill="#eccb8b" stroke="none"/>'
    }
    choices = {
        'first_steps': ('boot', teal), 'first_battle': ('battle', red),
        'ten_battles': ('battle', amber), 'fifty_battles': ('battle', violet),
        'first_elite': ('machine', violet), 'ten_elites': ('machine', amber),
        'first_guardian': ('core', red), 'first_chest': ('crate', amber),
        'ten_chests': ('crate', teal), 'first_upgrade': ('card', teal),
        'ten_upgrades': ('card', violet), 'first_victory': ('flag', amber),
        'five_victories': ('trophy', teal), 'ten_victories': ('trophy', amber),
        'warrior_victory': ('saw', violet), 'guardian_victory': ('shield', amber),
        'rogue_victory': ('vial', '#8bd1a3'), 'mage_victory': ('coil', teal),
        'first_purchase': ('wallet', amber), 'ten_purchases': ('wallet', violet),
        'master_weapon': ('saw', amber), 'master_armor': ('armor', teal),
        'first_contract': ('contract', amber), 'oathbound': ('chain', amber),
        'forbidden_pact': ('vial', violet), 'six_echoes': ('nodes', violet),
        'last_breath': ('heart', red), 'home_again': ('home', teal),
        'secret': ('lock', violet), 'achievements': ('trophy', amber),
        'unlocks': ('lock', teal), 'history': ('contract', violet),
        'hourglass': ('hourglass', teal), 'victory': ('flag', amber),
        'return': ('home', violet)
    }
    motif, accent = choices[name]
    extra = ''
    # New tiers have different framing, lights and compositions, not just hue swaps.
    if name in ('ten_battles', 'ten_chests', 'ten_upgrades', 'ten_elites', 'ten_purchases'):
        extra = '<path d="M9 48L3 38V21M55 48L61 38V21" fill="none" stroke="'+accent+'" stroke-width="3"/><path d="M9 53L16 61H48L55 53" fill="#39475e"/>'
    if name in ('fifty_battles', 'ten_victories'):
        extra = '<path d="M9 50L3 42L8 39L2 31L8 29L4 19L11 20M55 50L61 42L56 39L62 31L56 29L60 19L53 20" fill="none" stroke="#e4be7d" stroke-width="3"/>'
    if name.startswith('master_'):
        extra = '<path d="M13 57H21M28 57H36M43 57H51" stroke="#f5d68f" stroke-width="4"/>'
    if name == 'forbidden_pact':
        extra = '<path d="M10 7L6 20H14L11 32M53 31L47 43H55L51 56" fill="none" stroke="#ba91e7" stroke-width="3"/>'
    if name == 'unlocks':
        # Distinct unlocked shackle for the category tab.
        motifs['lock'] = motifs['lock'].replace('M17 28V18Q17 4 32 4Q47 4 47 18V28', 'M17 28V18Q17 4 32 4Q47 4 47 18')
    return ('<svg xmlns="http://www.w3.org/2000/svg" width="192" height="192" viewBox="0 0 96 96">'
            '<path d="M26 4H70L91 25V71L70 92H26L5 71V25Z" fill="#080e18" stroke="#03070d" stroke-width="3"/>'
            '<path d="M28 9H68L86 27V69L68 87H28L10 69V27Z" fill="#26394a" stroke="#8c9fac" stroke-width="1.7"/>'
            '<path d="M30 13H66L82 29V67L66 83H30L14 67V29Z" fill="#151e30" stroke="'+accent+'" stroke-width="2"/>'
            '<path d="M27 7H39M70 15L80 25M8 58V68M55 89H67" stroke="#d5e4df" stroke-width="1.5"/>'
            '<g transform="translate(20 20) scale(.875)" stroke="#080e19" stroke-width="2.4" stroke-linejoin="round" stroke-linecap="round">'+motifs[motif]+extra+'</g>'
            '<path d="M36 87H42M46 87H50M54 87H60" stroke="'+accent+'" stroke-width="2"/></svg>')


def write_auxiliary(root):
    folder = root / 'assets/collection/ui'
    folder.mkdir(parents=True, exist_ok=True)
    for name in UI:
        (folder / (name+'.svg')).write_text(collection_icon(name))
