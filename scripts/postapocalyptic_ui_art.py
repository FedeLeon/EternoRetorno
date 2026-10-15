"""Native comic UI skins: predictable text windows, cost centers and route contrast."""
COLORS={'warrior':'#bd6be1','guardian':'#f0a657','rogue':'#69caa5','mage':'#75d8e6'}

def card_frame(hero,shapes):
    color=COLORS[hero]
    # Each silhouette remains rectangular: no crest or separate identity plaque.
    trims={
      'warrior':'<path d="M39 460L67 478V510L39 528ZM39 545L67 563V595L39 613ZM961 1060L933 1078V1110L961 1128ZM961 1145L933 1163V1195L961 1213Z"/>',
      'guardian':'<path d="M43 38H230L205 69H74V225L43 252ZM957 38H770L795 69H926V225L957 252ZM43 1460H230L205 1429H74V1275L43 1248ZM957 1460H770L795 1429H926V1275L957 1248Z"/>',
      'rogue':'<path d="M46 330H71V650H46ZM929 845H954V1165H929Z"/><path d="M49 695L68 677V735L49 753ZM951 750L932 768V710L951 692Z"/><circle cx="59" cy="795" r="10"/><circle cx="941" cy="650" r="10"/>',
      'mage':'<path d="M48 340H69V410L56 425V620M952 340H931V410L944 425V620M48 1050H69V1120L56 1135V1330M952 1050H931V1120L944 1135V1330" fill="none" stroke-width="7"/><circle cx="56" cy="620" r="10"/><circle cx="944" cy="620" r="10"/>'
    }
    trim=trims[hero]
    bolts=''.join(f'<g transform="translate({x} {y})"><circle r="12" fill="#63717b" stroke="#040a10" stroke-width="5"/><path d="M-6 -3H6M-3 6H4" stroke="#c2ccd0" stroke-width="3"/></g>' for x in [69,931] for y in [185,390,947,1370])
    texture=''.join(f'<circle cx="{x}" cy="{y}" r="2.2" fill="#777a80" opacity=".2"/>' for x in range(115,890,25) for y in [166,372,932,1397])
    return f'''<svg xmlns="http://www.w3.org/2000/svg" width="1000" height="1500" viewBox="0 0 1000 1500">
<defs><pattern id="print" width="16" height="16" patternUnits="userSpaceOnUse"><circle cx="4" cy="4" r="1.2" fill="#8b8990" opacity=".13"/></pattern></defs>
<path d="M82 20H918Q965 20 965 69V1390Q965 1470 913 1470H87Q35 1470 35 1390V69Q35 20 82 20Z" fill="#04080e" stroke="#02050a" stroke-width="18"/>
<path d="M82 41H918L947 70V1390L912 1449H88L53 1390V70Z" fill="#26343e" stroke="#657985" stroke-width="6"/>
<path d="M98 58H902L929 85V1380L902 1428H98L71 1380V85Z" fill="#101a26" stroke="{color}" stroke-width="5"/>
<path d="M83 75H330L352 58M670 58L692 75H917M59 407V478L79 498V660M941 822V887L921 907V1067M95 1408H306L331 1428M670 1428L695 1408H905" fill="none" stroke="{color}" stroke-width="5"/>
<path d="M58 166V352M942 1150V1370M103 49H385M614 1439H895" stroke="#d0d9dc" stroke-width="4"/>
<g fill="{color}" stroke="#040a10" stroke-width="3"><circle cx="79" cy="660" r="7"/><circle cx="921" cy="1067" r="7"/><path d="M61 765L80 747V798L61 816ZM938 492L919 510V559L938 541Z"/></g>
<path d="M108 90H789L813 114V225L789 236H108L89 217V112Z" fill="#ede4ce" stroke="#020710" stroke-width="9"/>
<path d="M113 103H775M109 223H776" stroke="#c0b79f" stroke-width="4"/>
<circle cx="890" cy="150" r="78" fill="#03070c"/><circle cx="890" cy="150" r="68" fill="#192b3a" stroke="{color}" stroke-width="7"/>
<circle cx="890" cy="150" r="59" fill="none" stroke="#5e7382" stroke-width="3"/>
<path d="M847 116Q866 100 889 102M929 171L922 185" stroke="#effaf5" stroke-width="5" fill="none"/>
<path d="M100 280H900V916H100Z" fill="#090f18" stroke="#04070c" stroke-width="12"/>
<path d="M109 289H891V907H109Z" fill="none" stroke="#6a808a" stroke-width="4"/>
<path d="M101 311V280H135M865 280H900V311M100 882V916H135M865 916H900V882" fill="none" stroke="{color}" stroke-width="8"/>
<path d="M113 944H887L906 965V1348L883 1380H117L94 1348V965Z" fill="#eee4d0" stroke="#020710" stroke-width="9"/>
<path d="M118 952H876V1371H118Z" fill="url(#print)"/>
<path d="M119 956H878M114 1365H871" stroke="#c6bba1" stroke-width="4"/>
<path d="M108 969V998M891 969V998M108 1324V1350M891 1324V1350" stroke="#506473" stroke-width="5"/>
<path d="M87 1419H254M747 1419H914" stroke="{color}" stroke-width="6"/>
<path d="M261 1419H288M294 1419H312M319 1419H328M338 1419H346M358 1419H387" stroke="#78909c" stroke-width="4"/>
<g fill="{color}" stroke="#070d16" stroke-width="4">{trim}</g>{bolts}{texture}</svg>'''

def end_turn_frame():
    bolts=''.join(f'<g transform="translate({x} {y})"><circle r="3.2" fill="#738996" stroke="#030810" stroke-width="1.3"/><path d="M-1.5 -.6H1.5" stroke="#d0e2e3" stroke-width=".8"/></g>' for x,y in [(32,17),(96,17),(15,64),(113,64),(32,111),(96,111)])
    return f'''<svg xmlns="http://www.w3.org/2000/svg" width="1024" height="1024" viewBox="0 0 128 128">
<circle cx="64" cy="64" r="62" fill="#03070d"/>
<path d="M41 4H87L111 20L124 45V83L108 111L85 124H43L17 108L4 84V44L18 18Z" fill="#1b2b38" stroke="#030810" stroke-width="3"/>
<path d="M43 7H85L108 23L121 46V81L105 108L84 121H44L20 105L7 83V45L21 21Z" fill="none" stroke="#667d8b" stroke-width="1.3"/>
<circle cx="64" cy="64" r="51" fill="#111e2b" stroke="#060b12" stroke-width="3"/>
<circle cx="64" cy="64" r="48" fill="none" stroke="#7ee3dc" stroke-width="2" stroke-dasharray="18 5 7 5"/>
<circle cx="64" cy="64" r="43" fill="#101923" stroke="#526b7b" stroke-width="1.2"/>
<path d="M28 19L38 13H50M78 13H91L102 24M116 48V56M12 73V85L23 102M80 115H92L105 102" fill="none" stroke="#b98ce5" stroke-width="2.2"/>
<path d="M46 8H71M10 48V59M117 86L111 100M38 119H52" stroke="#ccedf0" stroke-width="1.3"/>
<path d="M58 6V13H70V6M58 115V122H70V115" fill="#314b5e" stroke="#030810" stroke-width="1"/>
<path d="M61 9H67M61 119H67" stroke="#85f2dc" stroke-width="2"/>
{bolts}</svg>'''

def blueprint(tile=False):
    if tile:
        return '''<svg xmlns="http://www.w3.org/2000/svg" width="256" height="256" viewBox="0 0 256 256"><path d="M20 9H230L248 27V228L229 247H22L8 231V26Z" fill="#0b1724" stroke="#020810" stroke-width="7"/><path d="M24 17H224L239 31V224L224 238H26L17 224V32Z" fill="none" stroke="#52788a" stroke-width="3"/><path d="M28 20H61M20 31V63M194 236H224" fill="none" stroke="#86d2d2" stroke-width="3"/><path d="M25 222L34 231H64" fill="none" stroke="#886fb0" stroke-width="3"/></svg>'''
    grid=''.join(f'<path d="M{x} 0V720"/>' for x in range(0,1281,40))+''.join(f'<path d="M0 {y}H1280"/>' for y in range(0,721,40))
    return f'''<svg xmlns="http://www.w3.org/2000/svg" width="1280" height="720" viewBox="0 0 1280 720"><path d="M0 0H1280V720H0Z" fill="#152839"/><g fill="none" stroke="#254051" stroke-width="1" opacity=".42">{grid}</g><path d="M11 13H1268V706H13Z" fill="none" stroke="#080f19" stroke-width="8"/><path d="M20 22H1260V697H21Z" fill="none" stroke="#476779" stroke-width="2"/><g fill="none" stroke="#345367" stroke-width="2" opacity=".7"><path d="M32 95H104L136 127V175H192M30 109H93L122 138V190H180M30 605H126L161 569H210M940 640H1040L1076 604H1193M1030 32V66H1122L1160 102H1243"/></g><g fill="#688a94"><circle cx="192" cy="175" r="4"/><circle cx="210" cy="569" r="4"/><circle cx="940" cy="640" r="4"/></g><g stroke="#829d9f" stroke-width="2" opacity=".5"><path d="M40 22V33M80 22V28M120 22V33M160 22V28M200 22V33M240 22V28M280 22V33M320 22V28M360 22V33M400 22V28M440 22V33M480 22V28"/></g></svg>'''
