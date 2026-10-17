# Cartas de metal y papel; reserva de una carta — 15/10/2026

## Marcos anteriores recuperados — 17/10/2026

Se restauran los cuatro marcos y reversos de esta colección, manteniendo las
ilustraciones nuevas. [Detalle y pruebas](../restored_frames_2026_10_17/README.md).
La renovación descrita abajo queda como registro histórico.

## Renovación de cómic — 17/10/2026

88 ilustraciones, cuatro marcos y cuatro reversos renovados; conservan metal y
papel con tinta, tramas y borde blanco. Source Sans 3 en negrita (restaurada tras la revisión tipográfica), centros de título/coste
medidos por héroe, tipo elevado dentro de su banda y filtrado lineal al reducir.
La reserva reversible y las reglas de cartas se mantienen. Los dígitos comparten
línea de base; el importador normaliza RGBA y la auditoría detecta dibujos vacíos.
[Prompts, fuentes y resultados actuales](../../comic_rebuild_2026_10_17/README.md).

## Arrastre sin cartel superpuesto — 15/10/2026

`card_drag.gd` deja de crear el bloque oscuro «Soltá sobre un objetivo iluminado»
y su texto cambiante de previsualización. Conserva carta flotante, objetivos
iluminados, reconocimiento del objetivo bajo el puntero, arrastre táctil/mouse,
cancelación y validación al soltar. Se retiran Label, fondo y ajuste de altura
que solo usaba el cartel. No cambia reglas ni explicaciones de otros controles.

Validación posterior: `test_expansion_ui.gd` **17/0 nativo aislado**, con ataques,
defensa propia, cancelación, falta de energía y mouse/táctil simulados. Captura
de arrastre revisada en `artifacts/expansion/drag-preview.png`, sin el cartel.
Audio Dummy, sin exportar ni probar navegador o dispositivo táctil real.

## Corrección del hueco en la «e» — 15/10/2026

La negrita variable de Source Sans 3 presentaba un pequeño hueco en la «e» al
forzar MSDF en `card_typography.gd`. Reproducido en render nativo con «de bloqueo»,
«Su dueño» y «energía» a 16/24/42 px; aumentar MSDF de 48 a 96/128 mantenía el
defecto. El rasterizado normal con oversampling 2 elimina el hueco. Se conserva
la fuente y el peso 700, con suavizado al girar cartas; no cambia la fuente
global ni las imágenes de números. Es una limitación conocida de MSDF con
[contornos superpuestos](https://docs.godotengine.org/en/4.4/classes/class_fontfile.html#class-fontfile-property-multichannel-signed-distance-field).

Componente compartido actualizado para título, categoría y descripción.
Comparación actual en `artifacts/card-font/compare.png` y cuatro cartas reales
revisadas en `artifacts/pixel_cards/fronts_backs.png`. Validación posterior:
cartas **1361/0** y apoyo **537/0**, headless; cartas/reserva **18/0 nativo
aislado** a 1280×720. Avisos de recursos al cerrar la suite nativa; sin fallos
de script/aserciones. Audio Dummy, sin exportar ni probar Web/dispositivo.

## Ajuste de lectura y centrado — 15/10/2026

- Título centrado en la superficie de papel, con centro horizontal al 45% de
  la carta para respetar el círculo de energía. Coste desplazado ligeramente
  arriba/derecha y categoría subida al centro de su placa.
- Descripción en negrita más grande, con ancho útil del 78%, interlineado de
  2 px y ajuste al espacio real según las líneas envueltas. Las explicaciones
  largas reducen la fuente solo lo necesario, también en cartas de habilidad.
- La pastilla inferior conserva corrosión, curación, modificadores y enlaces;
  elimina espada/escudo porque Ataque/Defensa ya se indica en la categoría.
  Las cartas sin efectos especiales no añaden una pastilla vacía.
- Cambios compartidos en `card_view.gd` y `card_type_icons.gd`; sin cambiar
  assets, costes, reglas, categorías ni guardados.
- Validación local actual: cartas **1361/0**, apoyo **537/0**, sinergias **19/0**,
  headless; cartas/reserva **18/0 nativo aislado**, 1280×720. Revisadas capturas
  de los cuatro frentes/reversos y de la mano en combate. Avisos de recursos
  al cerrar algunas suites, sin errores de script/aserciones. Audio Dummy;
  sin exportar ni probar Web/dispositivo. Capturas: `artifacts/pixel_cards/`.

## Dirección visual

Referencia: hoja de concept art aportada por el usuario. Los cuatro frentes y
reversos usan metal gastado en pixel art, papel claro y emblemas del oficio.
Tras la primera generación de ilustraciones detalladas, el usuario pidió conservar
los marcos/reversos y simplificar los dibujos. La dirección vigente para las
ilustraciones es **cómic minimalista**: un motivo dominante, contorno negro,
sombras planas, fondo oscuro despejado y color de identidad. No se rediseñan
escenarios ni protagonistas del resto del juego con este cambio.

| Héroe | Frente y reverso | Motivos de ilustración |
| --- | --- | --- |
| Nicolás, Carpintero | Violeta, sierra y uniones reparadas | Sierra, cuñas, madera y herramientas |
| Inés, Constructora | Naranja, chapas y refuerzos | Escudos de señalización, cables y protección |
| Mauro, Boticario | Verde, frascos y botiquín | Cuchillos utilitarios, vendajes y ácido |
| Vera, Profesora | Cian, bobinas y cuaderno | Emisores, señales y electricidad |

Las ilustraciones alternan objetos y acciones de los civiles; no llevan cifras
ni texto pintado. Título, categoría, coste, descripción, mejoras e iconos de
efecto siguen siendo UI dinámica. Se mantienen IDs y rutas de los 88 dibujos
anteriores; cada uno se reemplaza por una generación individual. Los cuatro
reversos son recursos nuevos en `assets/cards/backs/`.

## Reserva: comportamiento

1. Seleccionar una carta y pulsar **Guardar carta**, encima de Terminar turno.
2. La carta se voltea **en su lugar dentro de la mano**; no pasa a un espacio
   lateral ni se esfuma al terminar el turno.
3. Puede haber **una carta guardada a la vez**. Tocarla boca abajo o pulsar
   **Recuperar carta** vuelve a mostrar su frente y permite guardar otra.
   Guardar/deshacer no consume energía. Mientras está boca abajo no puede
   jugarse, arrastrarse para aplicar efectos ni participar en enlaces.
4. Al comenzar el turno siguiente vuelve boca arriba, **además del robo normal**.
   Conserva mejoras y cualquier dato de su instancia. Puede volver a guardarse.
5. Si su dueño cae antes de recuperarla, pasa a inactivas. Una batalla nueva
   empieza sin reservas. El panel de mazo muestra la cantidad reservada.

Guardar/cargar conserva carta, mejoras y posición (`reserved_index`). Guardados
antiguos sin posición recuperan la carta de forma segura al principio. Estado y
checkpoint se resuelven antes de ambos volteos; la animación no concede cartas.
El contador Mano incluye la carta boca abajo y aclara esa cantidad entre paréntesis.

Internamente se conserva `combat.reserved` para compatibilidad y para excluirla
de las acciones jugables. `combat_hand` intercala el reverso en la mano visual;
las cartas jugables llevan `hand_index` para que selección, arrastre y cenizas
usen su índice real, no su posición entre nodos. Al consumir cartas anteriores
(incluidos enlaces, costes y retirada de inactivas), la posición reservada se
ajusta. Se conserva `reserve_used` en guardados, pero la disponibilidad depende
de si hay una reserva activa: deshacer habilita una nueva elección.

Validación de reserva reversible: reglas **36/0 headless** (guardar/deshacer,
reemplazar, mejoras, orden, RNG/energía, guardado/carga y posición heredada),
interfaz **30/0 nativo aislado** (clic real, reserva intercalada, cambio, cenizas
a ambos lados, resumen de mazo y turno siguiente), captura actual de mano
revisada en `artifacts/pixel_cards/reserved.png`. Regresión general **99/99**,
anterior al último ajuste del contador de Mano; después se repitieron reglas,
interfaz nativa y `test_reward_ui` sin fallos. Audio Dummy, avisos de recursos
al cerrar UI; sin exportar ni validar Web/dispositivo.

## Archivos y regeneración

- `src/rules/card_reserve.gd`: validación, reserva/deshacer, posición y devolución.
- `Game.reserve_card`/`unreserve_card`: fachada y checkpoint; `combat_turns` devuelve la carta
  antes del robo; retirada de cartas inactivas y migración incluyen la reserva.
- `ui/components/combat_hand.gd`: composición de mano extraída de la pantalla.
- `ui/card_reserve_navigation.gd`: reverso dentro de la mano y ambos volteos.
- `presentation/card_flip.gd`: contracción horizontal, cambio de cara y apertura.
- `ui/components/card_view.gd`: frentes, campos medidos y categoría dinámica.
- `scripts/import_pixel_cards.gd`: valida el conjunto antes de reemplazar activos,
  ajusta tamaño e inventario; `--frames-only` procesa los ocho frentes/reversos.
- El importador de bancos antiguos no sobreescribe las ilustraciones nuevas;
  los frentes se retiran del índice de vectores para no regenerarlos por SVG.

## Procedencia

Herramienta integrada **`image_gen.imagegen`**, una llamada por recurso. `jobs.json`
es el plan de 96 recursos: 88 ilustraciones, cuatro frentes y cuatro reversos.
Cada `<id>.json` conserva prompt exacto, ruta original de generación y referencia;
`sources/` guarda los originales. El inventario general conserva hashes del
activo/fuente. Los intentos detallados descartados están documentados en
`superseded_detailed/`; no se cargan en el juego. `docs/.gdignore` y las exclusiones
de exportación evitan incorporar originales/documentación al juego exportado.

Los activos se preparan a 512×340 para ilustración y 512×768 para frentes/reversos;
texto en negrita con rasterizado suavizado y costes se mantienen separados de los dibujos.

## Validación local del conjunto final

- `test_card_reserve.gd`: **23 comprobaciones, 0 fallos**, incluidas persistencia,
  límite tras recargar, duplicados/mejoras, enlace, inmovilización e inactivas.
- `test_pixel_cards_ui.gd`: **18/0 nativo** en Xephyr/llvmpipe y audio Dummy;
  resolución antes de animación, espacio reservado, siguiente mano de siete,
  vuelta boca arriba y galería de los cuatro frentes/reversos.
- `test_pixel_card_catalog.gd`: **88/0 nativo**; captura real con las 88 imágenes,
  revisada junto con frentes/reversos y batalla con reserva.
- Auditoría de cartas: **96 recursos**, 88 ilustraciones únicas, sin errores de
  catálogo, medidas, prompts o hashes. Auditoría general: **678 recursos válidos**.
- Importación headless sin errores de script. La prueba de bordes de retratos usa
  comparación aproximada: Godot devuelve diferencias de 0,000002 px al colocar
  tamaños proporcionales. Se mantiene la exigencia de borde de 2 px y proporción.
  **Regresión global final: 94/94 suites correctas**, seis procesos headless,
  `artifacts/pixel_cards/passing-regressions/results.json`.
- Hay avisos de recursos/ObjectDB al cerrar algunas suites; se distinguen de
  errores de script y aserciones. Audio Dummy, sin probar reproducción de audio,
  Web, emulador ni dispositivo físico. Sin exportación ni guardado personal.

Capturas desechables en `artifacts/pixel_cards/` (ignoradas por Git); originales
ilustrados y prompts en esta carpeta. Intentos con identidad mezclada se conservan
como histórico en `superseded_identity/`, sin referencias desde el juego.
