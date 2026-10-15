"""Original comic deck and supply-bag symbols for the existing HUD assets."""

def hud_icon(kind):
    if kind == 'deck':
        art = '''
<path d="M5 12L31 4L46 53L20 61Z" fill="#775796"/>
<path d="M32 4L57 12L43 61L18 53Z" fill="#397a88"/>
<path d="M17 7H47L52 12V58L47 62H17L12 57V12Z" fill="#849aa8"/>
<path d="M18 12H44L47 15V54L44 57H18L17 54V15Z" fill="#182737"/>
<path d="M21 16H39M21 50H42" stroke="#a2e4e5" stroke-width="2"/>
<path d="M34 21L23 35H31L28 46L41 30H33Z" fill="#f7bc6d" stroke-width="1.4"/>
<path d="M7 18L11 17M53 19L57 20M8 23L12 22M52 24L56 25" stroke="#c7a6ef" stroke-width="1.5"/>
<path d="M15 9H23M45 58H49" stroke="#ebf6ec" stroke-width="1.6"/>
'''
    elif kind == 'journal':
        art = '''
<path d="M17 5H49L55 11V56L49 61H16L10 55V11Z" fill="#756184"/>
<path d="M20 9H47L50 12V54L46 57H20Z" fill="#d7d5c3"/>
<path d="M17 5H23V61H17Z" fill="#344958"/>
<path d="M8 14H19M8 25H19M8 36H19M8 47H19" stroke="#adc6cd" stroke-width="3.5"/>
<path d="M29 19H43M29 26H43M29 33H39" stroke="#455362" stroke-width="2.4"/>
<path d="M39 49L48 34L53 37L44 52L38 55Z" fill="#e7b56d"/>
<path d="M48 34L51 29L56 32L53 37Z" fill="#83d9d4"/>
<path d="M27 11H45" stroke="#f7f5e3" stroke-width="1.5"/>
'''
    else:
        art = '''
<path d="M20 13V8Q20 3 25 3H39Q44 3 44 8V13H38V10H26V13Z" fill="#9aa8b1"/>
<path d="M15 14H49L55 23L58 52L52 60H12L6 52L9 23Z" fill="#665273"/>
<path d="M12 21H52L49 38H15Z" fill="#a58b9d"/>
<path d="M16 24H48L45 31H19Z" fill="#79627e" stroke="none"/>
<path d="M12 42H52V54H12Z" fill="#333e52"/>
<path d="M19 35H25V47H19ZM39 35H45V47H39Z" fill="#e5b56b"/>
<path d="M20 38H24M40 38H44" stroke="#fff2b8" stroke-width="1.4"/>
<path d="M28 19H36V27H28Z" fill="#6ce4dc" stroke-width="1.5"/>
<path d="M8 46H12M52 46H56M16 55H22M42 55H48" stroke="#a8d4d5" stroke-width="1.5"/>
'''
    return ('<svg xmlns="http://www.w3.org/2000/svg" width="64" height="64" viewBox="0 0 64 64">'
            '<g stroke="#080e19" stroke-width="2.5" stroke-linejoin="round" stroke-linecap="round">'
            + art + '</g></svg>')
