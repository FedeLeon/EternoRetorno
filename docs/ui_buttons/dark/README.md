# Interfaz gótica oscura — 23/09/2026

Referencia visual: `assets/title/background.png`, pantalla de inicio actual.
Dos assets nuevos generados con la habilidad imagegen y herramienta integrada:
`assets/ui/dark/button.png` y `panel.png`. Prompts y rutas de procedencia en
`prompts.json`; los PNG del proyecto conservan el resultado original generado.
Importación sin pérdida con límite de 512 px; no se modificó el arte del inicio.

## Apariencia y alcance

Negro carbón, metal gris envejecido y acentos violeta apagados. Ornamentos
inspirados en las esquinas del inicio, sin tablones de madera ni marcos dorados.
Texto nativo legible; estados hover, pulsado, deshabilitado y foco de teclado.

- Botones comunes, compras, navegación, Menú y carteles del campamento.
- Barras de campamento, preparación, descanso y combate; pie de selección.
- Paneles generales de secciones, modales y descripciones de objetos/reliquias.
- Marco del título del mapa, panel del grupo y columna lateral.
- Terminar turno: círculo oscuro definido en código y contorno violeta gris.
- Mantienen su identidad ilustraciones, marcos de cartas, colores por héroe,
  objetos, dígitos, barras de vida, fondos de escenarios y assets del mapa.

`dark_skin.gd` centraliza marco escalable y foco. `button_skin.gd` mantiene sus
IDs históricos wood_button/wood_menu para compatibilidad de llamadores, aunque
ya carga el nuevo arte. `modal_frame.gd` delega el estilo. `main.panel` aplica el
marco en bloques grandes; paneles pequeños y colores semánticos conservan sus
funciones. El mercado ajusta márgenes de sus títulos para evitar ornamentos.

## Validación local

Mercado 61, herrería 110, equipo 48, mapa 109 comprobaciones sin fallos;
prueba de bolsa sin fallos. Se actualizó la prueba de equipo para elegir la
cripta en el selector temporal de desarrollo que ya existía. Comparación visual
renderizada a 1280×720 de inicio, campamento, mercado, pausa y combate; ajuste
posterior de márgenes y revisión final. Capturas temporales retiradas.
Sin exportación, sin validación en navegador ni dispositivo físico. No se
atribuyen los resultados de la optimización anterior a estos assets nuevos.

## Marcos contenidos y botones metálicos — 23/09/2026

- `assets/ui/dark/dialog_trim.svg`: marco fino angular para modales y cuadros
  de reliquias, objetos e intenciones; decoración limitada a los primeros 10 px.
- `assets/ui/dark/button_trim.svg`: borde metálico gris/violeta, doble filete,
  esquinas biseladas y cuatro pequeños remaches; centro oscuro sin ornamentos.
- Ambos SVG fueron dibujados en código para este ajuste, sin generación IA ni
  fuentes externas. El propio SVG es la fuente editable. Se escalan por nueve
  regiones mediante `DarkSkin.trim`; los márgenes visuales quedan fijos a 10 px.
- `DarkSkin.dialog` se aplica en `modal_frame`, `relic_popover` y `combat_tip`.
  `DarkSkin.button` conserva tintes de estado y separación del texto. Barras y
  bloques grandes conservan sus assets ornamentales. Terminar turno mantiene
  su asset circular original (la descripción inicial del tema es histórica).
- Revisión renderizada local a 1280×720 del campamento y el texto del Escudo del
  Peregrino: bordes fuera del texto, botones y carteles legibles. Prueba local
  headless de bolsa sin fallos. Sin exportación ni revisión web/móvil.

## Perímetro sin franja exterior — 23/09/2026

`DarkSkin.frame` limita la región de muestreo al perímetro metálico del asset,
quitando la franja negra que quedaba fuera del borde. Las coordenadas son
normalizadas para respetar el límite de importación. Se conservan los PNG
originales: es un recorte de presentación, no una edición destructiva del arte.
Los márgenes de nueve regiones pasan a 24/6 px en encabezados y 32 px en paneles,
reduciendo la invasión de esquinas en el contenido. Se aplica a todos los
consumidores del marco compartido; botones y modales finos conservan su estilo.

En `combat_hud.gd` los iconos de reliquias/equipo empiezan en x32/y8 con altura
48; sus niveles se recolocan dentro del espacio disponible. Revisión renderizada
local a 1280×720 con reliquia y cuatro mejoras: ninguna cruza el marco.
Prueba headless de equipo: 48 comprobaciones sin fallos. Sin exportar.
