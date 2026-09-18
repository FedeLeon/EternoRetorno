# Cartas por héroe

**Contenido actual:** 90 cartas, 15 por héroe. [Catálogo](CATALOGO.md) y
[progresión del mercado](../market/README.md). Se añadieron 60 cartas y se
redujo la potencia del mazo inicial sin modificar partidas ya iniciadas.

**Actualización:** la distribución vigente se describe en
[Combate de mazmorra](../dungeon/README.md). Ahora se roban seis cartas,
la mano se asoma desde abajo y las ilustraciones se asignan por ID de carta.
[Ilustraciones minimalistas: fuentes e integración](art/README.md).
La explicación y galería siguientes conservan el diseño de la etapa inicial.

Marcos derivados del concepto `cartas.png` mediante imagegen. Guerrero rojo,
guardiana verde azulado, pícaro verde, maga violeta, clériga dorada y explorador
azul. El pistolero del concepto se adapta al pícaro existente.

`generated-frames.png` conserva la generación original. `scripts/import_cards.gd`
recorta los seis marcos y los escala con vecino más cercano a 96 × 144 en
`assets/cards/`. La generación no entregó transparencia exterior: se usan
recortes rectangulares del marco, sin el fondo de presentación.

`src/main.gd::card_panel` comparte el diseño entre mano, mazo, mejoras y
recompensas. Los nombres, costes y efectos son texto de Godot, calculados desde
los datos reales. Las ilustraciones reutilizan poses de los sprites existentes
según ataque, protección, curación y veneno. No se alteran reglas ni valores.

La mano tiene más altura y los paneles de combatientes son más compactos.
Más de cinco cartas permiten desplazamiento horizontal. El contorno dorado
indica selección; las cartas no disponibles aparecen atenuadas.

Validación local, Godot 4.7.2 Compatibility:

- `tests/test_cards.gd`: 30 cartas normales y mejoradas; texto sin recorte,
  clic sobre ilustración, objetivo y carta sin energía. Genera `gallery.png`.
- `tests/test_ui.gd`: límites de etiquetas y selección de pareja.
- `tests/test_equipment_ui.gd`: preparación, consumibles y mano de siete cartas.
- `tests/test_warrior.gd`: regresión de animaciones de combate.

La galería y la mano ampliada se revisaron renderizadas en Linux. Sin compilación
de APK ni pruebas nuevas en dispositivo Android.

## Iconos de tipo — 16/09/2026

Coste gráfico movido a la esquina superior izquierda. La esquina superior derecha
muestra espada para daño/veneno, escudo para bloqueo y ambos en cartas mixtas.
Cartas de curación pura no reciben un icono ofensivo/defensivo incorrecto.
`src/ui/components/card_type_icons.gd` compone estos indicadores en mano, mazo,
recompensas y colección a través del constructor compartido de cartas. Los títulos
en cartas estrechas usan tamaño 12 para conservar la lectura con ambos márgenes.

## Mano en abanico — 16/09/2026

La mano de combate se distribuye en arco suave: cartas de 174 px separadas
128 px (46 px de superposición), rotación progresiva de −8° a +8° y centro
más alto. Al tocar una carta se endereza, sube y se amplía a 218 px para leerla.
Se mantiene desplazamiento horizontal si la mano crece por robo adicional.
`src/ui/components/hand_layout.gd` calcula solo presentación; mazo, recompensas
y colección conservan sus disposiciones anteriores.

Validación actual: `test_combat_layout.gd`, ocho comprobaciones renderizadas
sin fallos; selección por ratón sobre carta rotada, carta elevada visible,
fin de turno y navegación. Abanico y carta seleccionada revisados en escritorio.
Capturas temporales retiradas; sin APK ni validación Android.

## Mano completa visible — 16/09/2026

Reemplaza los valores del abanico anterior: cartas de 174×278, paso de 160 px,
rotación ±3° y arco de 8 px. La mano empieza alrededor de y=420, con todos los
bordes y textos dentro de la pantalla. Seleccionar mantiene la elevación
(y=358), endereza y amplía a 218 px. El scroll conserva manos con robo adicional.
El botón Terminar turno ocupa el lateral izquierdo sobre la energía.

## Cabecera reorganizada — 16/09/2026

La fila superior muestra coste y, a su derecha, espada/escudo. Las cartas mixtas
muestran ambos iconos en horizontal. El nombre de la carta ocupa la antigua fila
del nombre del héroe, sobre la ilustración. Se elimina la etiqueta del héroe en
la cara de la carta; el dueño se conserva en datos, color y tooltip.
Cambio en el constructor compartido `main.gd::card_panel()` y
`card_type_icons.gd`, por lo que aplica también a mazo y recompensas.
Validación actual: layout 33 renderizadas, UI 91 headless, sin fallos. La cuenta
UI baja al retirar una etiqueta por carta. Revisión visual local a 1280×720;
capturas temporales retiradas. Sin exportación Web/APK.

## Inspección sin energía — 16/09/2026

Toda carta en la mano se puede seleccionar, levantar y volver a bajar aunque
no alcance la energía. Conserva el aspecto atenuado si no se puede jugar.
Seleccionar no gasta energía: `valid_targets()` no habilita objetivos y
`play_card()` rechaza la acción si el coste supera la energía disponible.
Cambio de presentación en `main.gd`, sin modificar reglas.
Validación: layout headless, 36 comprobaciones sin fallos, incluyendo selección
con energía cero, intento de jugar sin cambios de estado y deselección.
Sin exportación Web/APK ni nueva revisión visual.

## Enlaces entre héroes

Doce cartas de recompensa (dos por clase) llevan ENLACE. Conservan sus efectos
individuales y pueden consumirse junto a una carta de su compañero para un
ataque especial. [Las 15 combinaciones y reglas](../synergies/README.md).

## Mazo inicial de 20 cartas

Cada héroe aporta 10: cuatro copias de su ataque básico, cuatro de su defensa
básica y una de cada una de sus otras dos cartas iniciales modestas. Todas
cuestan 1 de energía. Las cartas de mercado, victoria y ENLACE se siguen
consiguiendo después. Se mantienen seis cartas robadas por turno y tres de
energía. Solo cambia el inicio de nuevas aventuras; las guardadas conservan
sus instancias. La fuente es `scripts/create_content.py` y su catálogo generado.

## Texto legible en cartas inclinadas (17/09/2026)

`ui/components/card_typography.gd` aplica una copia compartida de la fuente
integrada de Godot con MSDF y filtrado lineal a las etiquetas de cada carta
(nombre, descripción y ENLACE). Se evita heredar nearest del arte pixelado al
rotar letras pequeñas. No cambia la fuente global, los marcos, las ilustraciones,
los dígitos gráficos, tamaños ni el abanico. Se usa la fábrica común de cartas.

Referencia: https://docs.godotengine.org/en/stable/classes/class_fontfile.html
Validación local: distribución 38 e interfaz 271, sin fallos. Revisión renderizada
Linux a 1280×720 de texto inclinado. Capturas temporales eliminadas. Sin exportación
APK/Web; legibilidad en navegador y dispositivos aún no comprobada en esta revisión.

## Marcos fieles al concepto — 18/09/2026

Seis nuevos marcos en `assets/cards/frames/`, generados con image_gen integrado
a partir de `cartas.png`. [Prompts y procedencia](frames/provenance.json).
Colores/emblemas: guerrero rojo/espada, guardiana turquesa/escudo, pícaro
verde/dagas cruzadas, maga violeta/luna, clériga dorado/cruz y explorador azul/ojo.
La referencia del pistolero se adapta al pícaro; no agrega otra clase.

`src/ui/components/card_view.gd` presenta la carta completa: título sobre
pergamino, coste arriba a la derecha, ilustración con márgenes, texto inferior
y pastilla de espada/escudo (ambos si corresponde). Curación sin ataque ni
bloqueo no muestra esa pastilla. Conserva MSDF, selección y elevación.
`main.gd::card_panel` delega la presentación; reglas y persistencia no cambian.
Los marcos antiguos siguen usados por las categorías del mercado.

Validación local: distribución de combate 38, presentación 10 y mercado 34
comprobaciones sin fallos. Revisión renderizada Linux 1280×720 de combate,
mercado y galería de los seis héroes. `scripts/preview_cards.gd` permite repetir
la galería sin tocar guardados. Capturas temporales eliminadas. Sin exportar
APK/Web ni pruebas en navegador o dispositivo.

## Desintegración al jugar — 18/09/2026

Cada carta aceptada se desintegra de abajo hacia arriba en unos 0,85 segundos,
con borde de brasa y partículas de ceniza ascendentes. Se captura la carta
completa (marco, ilustración, textos y números) en un SubViewport y se aplica
`assets/shaders/card_ash.gdshader`. Las partículas y el shader son procedurales,
creados en código para este efecto; no usan imágenes generadas adicionales.

`src/presentation/card_ash.gd` solo presenta y libera sus recursos. Main conserva
los índices antes de resolver, guarda primero y anima después. Las jugadas
rechazadas no producen cenizas; las sinergias animan las dos cartas consumidas.
El descarte de fin de turno no activa el efecto. La interfaz espera su limpieza
antes de reconstruir la pantalla. En headless se prueba el ciclo de vida sin GPU.

Validación: presentación renderizada Linux, 12 comprobaciones sin fallos y
revisión de captura durante la desintegración. Sin exportar APK/Web ni probar
en dispositivo.

Prueba adicional headless: 14 comprobaciones sin fallos, incluyendo consumo
y animación de ambas cartas de sinergia, rechazo sin energía y limpieza del efecto.

## Separación y pastilla izquierda — 18/09/2026

`hand_layout.gd` aumenta el paso horizontal de 132 a 160 px. La zona de mano
en `main.gd` ocupa x=100, ancho=1014; los márgenes internos se reducen para
mostrar las seis cartas. Se conservan inclinación y elevación al seleccionar;
los extremos suben 12 px para mantener visible la pastilla inferior izquierda.
`card_type_icons.gd` sitúa la pastilla a 12 px del borde izquierdo.
Los dígitos de coste de `card_view.gd` se dibujan por encima del solapamiento.

Validación de este ajuste: 38 comprobaciones de distribución sin fallos,
revisión renderizada Linux a 1280×720. Capturas temporales eliminadas.
Sin exportar APK/Web ni comprobar en dispositivo.

## Carta seleccionada sin recuadro — 18/09/2026

`src/ui/components/card_view.gd` usa estilos vacíos en todos los estados del
botón para retirar el rectángulo amarillo exterior, incluido el foco.
Se conservan el marco ilustrado, el tamaño ampliado y la elevación al seleccionar.
Validación actual: 38 comprobaciones de distribución sin fallos y revisión
renderizada de la carta seleccionada en Linux a 1280×720. Capturas temporales
eliminadas; sin exportar APK/Web ni verificar en dispositivo.

## Menú por encima de la mano — 18/09/2026

`dialog_view.gd` coloca el diálogo completo, incluido el oscurecimiento, en
z absoluto 200, por encima de cartas seleccionadas (10), dígitos y efectos
del combate (hasta 100). No cambia la selección al abrir/cerrar el menú.
Validación local actual: 41 comprobaciones de distribución sin fallos; incluye
abrir el menú con carta seleccionada, bloqueo de clics sobre la carta y Volver
conservando la selección. Revisión renderizada Linux a 1280×720; capturas
temporales eliminadas. Sin exportar APK/Web ni probar en dispositivo.

## Costes por marco y pastilla mayor — 18/09/2026

`card_view.gd::COST_CENTERS` define el centro normalizado del círculo de cada
marco. Se conserva el del guerrero y se ajustan guardiana, pícaro, maga, clériga
y explorador según su ilustración. El componente compartido aplica el ajuste
a combate, mercado y demás vistas de cartas. No se modifica el valor del coste.
`card_type_icons.gd`: pastilla de 24 px de alto (antes 20), iconos de 22 px
(antes 18), paso de 24 px; conserva el borde inferior izquierdo y separación.

Validación actual: 41 comprobaciones de distribución sin fallos y galería
renderizada de seis héroes, ataque/defensa, a 1280×720. Sin exportar.

## Icono de enlace y acabado de cartas — 18/09/2026

Se elimina la etiqueta ENLACE de encima de la ilustración. `card_view.gd` detecta
si la carta participa en alguna receta y pasa esa información a
`card_type_icons.gd`: añade `assets/ui/chain.svg` al final de la pastilla inferior,
junto a espada/escudo, ampliando la pastilla. El tooltip conserva las combinaciones.

`presentation/card_finish.gd` añade resplandor dorado discreto a los enlaces y
un barrido de reflejo a todas las cartas del componente compartido (combate,
recompensas, mercado, mazo). Shaders en `assets/shaders/card_link_glow.gdshader`
y `card_sheen.gdshader`; se enmascaran con la transparencia del marco. Los
efectos no capturan eventos ni cambian textos/reglas. Cadena SVG y shaders
creados en código, sin generación de imágenes adicional.

Cada carta utiliza un RNG visual independiente: primera espera entre 0,8 y
7 segundos, barrido de 0,85 s y siguientes pausas entre 4 y 11 s. No hay
disparo global sincronizado; coincidencias casuales pueden ocurrir. Al
reconstruir la vista se crean temporizadores nuevos. No consume RNG de partida
ni requiere persistir estados decorativos; se libera junto con la carta.

Validación de este cambio: 19 comprobaciones de sinergia UI renderizada y
18 de presentación de combate headless aprobadas. Incluyen cadena/resplandor,
ausencia de etiqueta, temporizadores distintos, inicio/reprogramación del
barrido y conservación del RNG de juego. Revisión visual local de cartas de
enlace en combate. Sin exportación APK/Web ni prueba en dispositivo.

## Impactos múltiples — 18/09/2026
Los ataques de varios golpes reproducen cada golpe y su reducción de vida por separado. Un enemigo con postura de contraataque devuelve 4 por impacto si sobrevive; caer cancela la secuencia. Consultar [Enemigos](../enemies/README.md).

## 18/09/2026 — Cruz roja para cartas de sanación

`src/ui/components/card_type_icons.gd` añade una cruz roja cuando `heal > 0`
a la pastilla inferior compartida de combate, mazo, mercado y recompensas.
Las cartas mixtas conservan espada/escudo y los enlaces conservan la cadena;
la pastilla adapta su ancho. Asset nuevo `assets/ui/heal.svg`, vector dibujado
en código con contorno claro y sombreado escalonado siguiendo los iconos
existentes; sin generación de imágenes ni cambios de reglas.

Validación local headless: `test_cards.gd`, 544 comprobaciones sin fallos;
importación del editor y `git diff --check` correctos. Sin revisión visual
manual de este cambio ni exportación.

## 18/09/2026 — Espada y calavera para cartas de veneno

La pastilla inferior incorpora espada seguida de calavera verde cuando
`poison > 0`, incluso sin daño directo. Se reutiliza `assets/ui/poison.svg`,
el mismo icono del estado de veneno en combate. El componente compartido
`src/ui/components/card_type_icons.gd` conserva los demás iconos y adapta
el ancho en combate, mazo, mercado y recompensas. Sin cambios de reglas
ni assets nuevos.

Validación local headless: `test_cards.gd`, 544 comprobaciones sin fallos;
`git diff --check` correcto. Sin revisión visual manual ni exportación.

## 18/09/2026 — Vista previa y confirmación de mejora de cartas

En el descanso, tocar una carta sin mejorar selecciona una copia mejorada
para mostrar sus valores y un resplandor. Solo hay una seleccionada; tocar
otra restaura la anterior. El botón inferior «Mejorar» empieza deshabilitado
y confirma la selección. Volver descarta la vista previa. Cartas ya mejoradas
no son seleccionables. Previsualizar no cambia el mazo, consume el descanso
ni guarda; confirmar llama a `game.rest(false, index)`, que valida y guarda.

Se extrae `src/ui/screens/card_upgrade_screen.gd` con selección local y copia
del mazo; `main.gd::deck_view` delega el modo de mejora. Se reutilizan marcos,
shader de resplandor y botón de madera existentes, sin assets nuevos.

Validación: prueba dedicada por clics para botón inicial, selección/cambio,
valores mejorados, mazo intacto en vista previa, carta ya mejorada bloqueada
y confirmación de una única instancia. Revisión visual Linux 1280×720;
HUD: 107 comprobaciones headless sin fallos tras la extracción del modo de
mejora. `git diff --check` correcto. Captura temporal eliminada. Sin exportar.

### Primeros planos por impacto — 18/09/2026

Las cartas de dos/tres golpes muestran dos/tres viñetas ofensivas distintas,
una antes de cada impacto resuelto. Cada héroe rota entre cuatro poses. La
muerte del atacante o del objetivo interrumpe los golpes restantes; los
contraataques conservan su lugar entre golpes. No hay una viñeta introductoria
adicional. Para ataques de área no se duplica la viñeta del mismo golpe por
objetivo. Detalles y assets en [cómic](../comic/README.md).
