# Generación del Portador Maldito

Herramienta: imagegen integrada. Referencia: concept art aportado por el usuario.
La segunda salida es la fuente elegida. Godot recorta y escala con vecino más cercano, conservando el canal alfa, para preparar cuadros de 64 px.

## Prompt inicial

Use case: stylized-concept. Asset type: production 2D pixel-art animation sprite sheet for Godot. Input image is CHARACTER DESIGN REFERENCE only, not a sheet to copy. Create an actual transparent RGBA sprite sheet with EXACTLY 6 equal columns and 5 equal rows (30 frames), square canvas 1536x1536. Each cell 256 wide by about307 high; prefer canvas1536x1280 so cells256x256 if possible. NO labels, NO grid lines, NO captions, NO backdrop, NO checkerboard painted into image. All cells completely isolated transparent margins, no floor or cast shadow. Same character scale, anchored feet at local y220, centerbody x128 in every cell. Character helmet-to-boot height about172px; generous room for sword/cape. Crisp chunky pixel art designed as 64x64 logical sprites enlarged nearest-neighbor 4x, limited palette, no blur. Face 3/4 RIGHT throughout. Faithfully recreate user's PORTADOR MALDITO: closed angular dark gunmetal helmet with vertical grilled mouth, thin glowing magenta eyes, swept purple plume; layered battered full steel plate with silver highlights, ragged long purple cape trailing LEFT; brown belt with round buckle; broad dark greatsword etched with magenta glow pointing RIGHT. No exposed face, no red clothing, no shield. Consistent anatomy and equipment across every frame.
ROW1 six idle frames: grounded stance sword down-right, subtle breathing and cape flutter; last loops smoothly to first.
ROW2 six basic sword attack frames: ready, windup sword raised behind, overhead anticipation, large sweeping diagonal strike down-right with narrow magenta trail, follow-through, return ready. Visibly different poses.
ROW3 six heavy attack frames: crouched charge magenta blade, high sword windup, weight forward, powerful extended cleave right with magenta arc, low follow-through, recover upright.
ROW4 six damage frames: normal stance, recoil backward left, head back knees flexed, recover halfway, almost upright, normal stance.
ROW5 six falling frames: wounded upright, drop onto one knee, both knees sword lowered, torso falling forward-right, collapsed low on ground, fully prone inert body with cape pooled. Last frame must be clearly lying down not standing.
Quality priority: faithful character identity, correct orderly animation cells, transparent background and no cross-cell overlap.

## Ajuste del espaciado

Edit this sprite sheet, preserving exact same knight design, palette, animations, row/column order and true transparent alpha. Repair frame spacing for game-engine slicing. EXACT SIX COLUMNS and FIVE ROWS equal square cells. Each of the 30 figures including all sword tips, trailing cape and magic arc must fit ENTIRELY in its own cell with at least 24 pixels empty transparent margin on LEFT and RIGHT (at this input resolution1374x1145 eachcell229). Shrink each character and effects to about75% of current size, keeping consistent scale across frames and foot baseline at local y200. No content can touch or cross any cell boundary. In row3 column3 shorten the extended blade enough to fit entirely in its own cell; row2column4 and row3column4 magenta arcs also must remain inside their own cells. Transparent padding TOP and BOTTOM too. Preserve all six successive poses per row, particularly fallen prone last two frames. No text, no grid, no extra frames. High quality crisp pixel art.

