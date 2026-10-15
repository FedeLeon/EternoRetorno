# Cartas de tablero y aro tecnológico — 14/10/2026

Los cuatro marcos comparten la estructura de una carta física de juego de mesa:
contorno de esquinas recortadas, capas de metal, filo claro, circuitos del color
del personaje, remaches, marcas de impresión y papel claro tramado para las reglas.
Se conserva la estética de cómic industrial y las ilustraciones de efecto mínimas.

## Datos y legibilidad

- Emblema de oficio y coste en espacios propios; mismo centro de energía para los
  cuatro marcos (0,89; 0,17), sin desplazar los números de Inés.
- Nombre de carta; franja independiente de nombre/oficio del personaje.
- «MEJORADA» cuando la instancia está mejorada; no se imprime en el PNG.
- Ventana de ilustración; descripción real de daño, impactos, bloqueo, curación,
  corrosión, modificadores y objetivo; pastilla de iconos/enlace conservada.
- Textos y cifras permanecen dinámicos. Los assets no contienen nombres, números,
  estadísticas falsas ni datos que puedan quedarse viejos al mejorar una carta.
- Se reservan áreas para todas las tallas usadas en batalla, mercado, recompensa,
  mazo y colección. Título y franja de personaje ajustan el tamaño al ancho; la
  descripción mantiene el límite sobre los iconos inferiores.

`card_view.gd` incorpora la franja y ajusta la ventana del dibujo. No calcula
reglas ni concede mejoras: sigue leyendo `Content.card/describe/effective_card`.
No se añaden estadísticas, rarezas o valores de colección inventados.

## Botón de terminar turno

`assets/ui/end_turn_round.png` usa un aro mecánico de placas biseladas, seis
remaches, segmentos cian, conexiones violetas y conectores superior/inferior.
El centro oscuro queda limpio para «Terminar turno». Sigue siendo circular,
136×136 px, con la misma zona de clic, acción y estados; foco cian tecnológico.
No altera el orden de cenizas de cartas, bloqueo ni ataques enemigos.

## Assets y procedencia

Se extendió el sistema **SVG nativo existente**, con geometría exacta para que
las decoraciones no invadan los datos. No se usó ImageGen para estos cinco recursos: son SVG del generador existente
y rasterizado de Godot.
Fuentes reproducibles en `scripts/postapocalyptic_ui_art.py` (`card_frame`,
`end_turn_frame`); `postapocalyptic_icons.py` delega el aro a esa función.

| Recurso activo | Fuente SVG |
| --- | --- |
| `assets/cards/frames/warrior.png` | `docs/art_direction/postapocalyptic/vectors/cards__frames__warrior.svg` |
| `assets/cards/frames/guardian.png` | `docs/art_direction/postapocalyptic/vectors/cards__frames__guardian.svg` |
| `assets/cards/frames/rogue.png` | `docs/art_direction/postapocalyptic/vectors/cards__frames__rogue.svg` |
| `assets/cards/frames/mage.png` | `docs/art_direction/postapocalyptic/vectors/cards__frames__mage.svg` |
| `assets/ui/end_turn_round.png` | `docs/art_direction/postapocalyptic/vectors/ui__end_turn_round.svg` |

Rasterizado por `scripts/import_postapocalyptic_icons.gd`, manteniendo rutas,
UIDs y política de importación anteriores. Hashes actualizados en el registro
`docs/art_direction/postapocalyptic/assets.json`. El número de recursos activos
permanece en 642; se sustituyen cinco diseños existentes.

## Validación

Resultados actuales: **89/89 suites headless**, cartas **1.249/0** en render
nativo y cartas de soporte **537/0** en headless. Se verificaron los 642 hashes
visuales, sin recursos antiguos o faltantes. Detalle en [validation.json](validation.json). Render local aislado
1280×720, llvmpipe, audio Dummy y perfil privado; revisión de cartas y botón en
batalla. Capturas en `artifacts/cards/gallery.png` y `artifacts/postapocalyptic/`,
ignoradas por Git/exportación. Se mantienen avisos de recursos al cerrar algunas
suites; no se certifica Web, dispositivo físico o escucha. Sin exportar.
