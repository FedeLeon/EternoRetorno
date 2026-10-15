"""Comic room symbols: authored vector assets, shared by map and route previews."""
ROOMS = ('combat', 'rest', 'event', 'treasure', 'elite', 'boss')


def room_icon(kind):
    art = {
        'combat': '''
<path d="M12 8L49 45L43 51L6 14V7Z" fill="#a1b7c4"/>
<path d="M12 10L47 45" stroke="#e7f5f5" stroke-width="1.8"/>
<path d="M37 48L48 37L53 42L42 53Z" fill="#f79561"/>
<path d="M47 49L56 58L60 54L51 45Z" fill="#6d526e"/>
<path d="M51 5L18 39L25 46L58 12V5Z" fill="#d3e1e4"/>
<path d="M51 8L22 39" stroke="#fbffff" stroke-width="1.8"/>
<path d="M19 33L31 45L26 50L14 38Z" fill="#f79561"/>
<path d="M18 43L5 56L10 61L23 48Z" fill="#6d526e"/>
<path d="M6 30L2 27M58 30L62 27M31 5V1" stroke="#ff7776" stroke-width="2.4"/>
''',
        'rest': '''
<path d="M9 57L18 52H48L57 57L51 61H13Z" fill="#514c62"/>
<path d="M17 31H47L45 55Q31 63 19 55Z" fill="#768a97"/>
<path d="M20 34V53L27 56V36Z" fill="#adc0c8" stroke="none"/>
<path d="M18 43H46M19 51H45" fill="none" stroke="#283241"/>
<ellipse cx="32" cy="31" rx="15" ry="5" fill="#232636"/>
<path d="M26 32Q14 24 29 10Q27 20 36 22Q41 18 38 9Q53 24 39 32Z" fill="#ff9560"/>
<path d="M30 31Q25 26 33 20Q32 26 38 26L36 32Z" fill="#ffe8a1" stroke="none"/>
<path d="M14 17L10 12M49 20L53 16M33 5V2" stroke="#ffc678" stroke-width="2"/>
''',
        'event': '''
<path d="M8 6H51L59 14V39L52 46H32L19 57V46H8L3 40V12Z" fill="#70d9d0"/>
<path d="M10 12H50L53 16V35L48 40H29L24 45V40H10Z" fill="#243144" stroke="none"/>
<path d="M27 22Q26 15 34 15Q44 15 42 23Q41 27 35 29V32" fill="none" stroke="#e6f9e7" stroke-width="3.6"/>
<circle cx="35" cy="37" r="2" fill="#e6f9e7" stroke="none"/>
<path d="M45 49H60V60H41V53Z" fill="#a78cdb"/>
<path d="M48 49L53 44M46 54H55" fill="none" stroke="#243144" stroke-width="2"/>
''',
        'treasure': '''
<path d="M7 24L16 13H48L57 24V55L51 61H13L7 55Z" fill="#d28b43"/>
<path d="M7 24H57V33H7Z" fill="#f1c977"/>
<path d="M13 36V53H23V36M41 36V53H51V36" fill="#86613e"/>
<path d="M18 14V24M46 14V24M14 29H22M42 29H50" stroke="#fff0b4" stroke-width="2"/>
<path d="M26 28H38V42H26Z" fill="#394c5a"/>
<path d="M30 32H34V38H30Z" fill="#7eede7" stroke="none"/>
<path d="M31 3V8M53 4L50 9M10 5L13 9" stroke="#ffe2a0" stroke-width="2.5"/>
''',
        'elite': '''
<path d="M8 18L3 6L18 13M46 13L61 6L56 18" fill="#a99cc3"/>
<path d="M16 9H48L57 20V40L47 47V56H17V47L7 40V20Z" fill="#a18dc2"/>
<path d="M17 14H46L51 21V36L43 41H21L13 36V21Z" fill="#293144" stroke="none"/>
<path d="M15 23L28 26L25 33H16ZM49 23L36 26L39 33H48Z" fill="#ffb269"/>
<path d="M32 32L27 40H37Z" fill="#a18dc2"/>
<path d="M23 48V56M32 46V57M41 48V56" stroke="#343147" stroke-width="2.5"/>
<path d="M20 17H25M39 17H44" stroke="#e9dbff" stroke-width="2"/>
''',
        'boss': '''
<path d="M6 25V15H13V5L24 13H40L51 5V15H58V25Z" fill="#b35465"/>
<path d="M9 25H55V52L46 61H18L9 52Z" fill="#5e637d"/>
<path d="M16 28H48V47L42 53H22L16 47Z" fill="#232b3d"/>
<path d="M19 32H45L41 40H23Z" fill="#ff7775"/>
<path d="M24 34H40" stroke="#ffe1b8" stroke-width="2"/>
<path d="M23 45H41M27 50H37" stroke="#a6b9c7" stroke-width="2"/>
<path d="M3 32H9M3 43H9M55 32H61M55 43H61" stroke="#b35465" stroke-width="4"/>
<path d="M27 16L32 11L37 16L32 21Z" fill="#ffc780"/>
'''
    }[kind]
    return ('<svg xmlns="http://www.w3.org/2000/svg" width="128" height="128" viewBox="0 0 64 64">'
            '<g stroke="#080e19" stroke-width="2.8" stroke-linejoin="round" stroke-linecap="round">'
            + art + '</g></svg>')
