# Cartas de tablero y aro tecnológico — 14/10/2026

**Actualización 15/10/2026:** El diseño actual de frentes/reversos y su distribución está en [Cartas y reserva](../pixel_retain/README.md). Lo siguiente conserva la entrega anterior.


Los cuatro marcos comparten la estructura de una carta física de juego de mesa:
contorno de esquinas recortadas, capas de metal, filo claro, circuitos del color
del personaje, remaches, marcas de impresión y papel claro tramado para las reglas.
Se conserva la estética de cómic industrial y las ilustraciones de efecto mínimas.

Actualización: contorno rectangular sin emblema circular que sobresalga por arriba
y sin placa de identidad/oficio. La ventana de ilustración ocupa ahora del 19 al
60 % de la altura; título y coste suben dentro de la carta. Cada marco tiene un
acabado propio, además del color:

| Personaje | Color | Detalle del borde |
| --- | --- | --- |
| Carpintero | Violeta | Dientes y muescas industriales |
| Constructora | Naranja | Refuerzos anchos en las cuatro esquinas |
| Boticario | Verde menta | Conductos, conectores y franjas laterales |
| Profesora | Cian | Pistas dobles y terminales de circuito |

Son cuatro assets rasterizados desde SVG del sistema existente; no variantes
de una ilustración generada. Rutas y UIDs conservados. `CardOwner` y su tipografía
exclusiva retirados; ninguna pantalla imprime nombre/oficio sobre la carta.
El tooltip conserva la identidad y el título añade «+» al mejorar, como ya hacía.

## Datos y legibilidad

- Títulos y descripciones en **Source Sans 3 Bold**, eje variable `wght=700`.
  `card_typography.gd` comparte esta fuente y usa sus métricas para ajustar los
  textos al ancho/alto disponible; conserva MSDF para cartas rotadas y ampliadas.
  Sin descargar tipografías nuevas ni modificar las del resto de la interfaz.
- Coste en espacio propio; mismo centro de energía para los cuatro marcos
  (0,89; 0,10), sin desplazar los números de Inés.
- Nombre de carta; «+» cuando la instancia está mejorada.
- Ventana de ilustración; descripción real de daño, impactos, bloqueo, curación,
  corrosión, modificadores y objetivo; pastilla de iconos/enlace conservada.
- Textos y cifras permanecen dinámicos. Los assets no contienen nombres, números,
  estadísticas falsas ni datos que puedan quedarse viejos al mejorar una carta.
- Se reservan áreas para todas las tallas usadas en batalla, mercado, recompensa,
  mazo y colección. El título ajusta el tamaño al ancho; la
  descripción mantiene el límite sobre los iconos inferiores.

`card_view.gd` compone datos y ajusta la ventana del dibujo. No calcula
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
permanece en 667 actualmente; este ajuste sustituye solo los cuatro marcos.
`import_postapocalyptic_icons.gd -- --frames-only` permite rasterizarlos sin
reconstruir los demás iconos. No se generan nuevas ilustraciones ni prompts.

## Validación

Texto en negrita: repetidas las suites nativas de cartas **1073/0** y soporte
**537/0**, con revisión de captura actual. Sin textos recortados en los tamaños
cubiertos; avisos de recursos al cerrar. Audio Dummy; sin exportación ni prueba Web.

Actualización sin emblema/placa: **1073/0** comprobaciones de cartas y **537/0**
de cartas de soporte, ambas con render nativo aislado; cuatro marcos y tarjetas
de soporte revisados visualmente. Se verifican costes, títulos, mejoras, área de
ilustración ampliada, textos y resolución de objetivos. Auditoría: **667 hashes
vigentes, cero recursos antiguos**. Avisos de recursos al cerrar ambas suites,
sin errores de script/aserciones. Sin exportar ni probar Web/dispositivo.

Registro anterior al ajuste:

Resultados actuales: **89/89 suites headless**, cartas **1.249/0** en render
nativo y cartas de soporte **537/0** en headless. Se verificaron los 642 hashes
visuales, sin recursos antiguos o faltantes. Detalle en [validation.json](validation.json). Render local aislado
1280×720, llvmpipe, audio Dummy y perfil privado; revisión de cartas y botón en
batalla. Capturas en `artifacts/cards/gallery.png` y `artifacts/postapocalyptic/`,
ignoradas por Git/exportación. Se mantienen avisos de recursos al cerrar algunas
suites; no se certifica Web, dispositivo físico o escucha. Sin exportar.
