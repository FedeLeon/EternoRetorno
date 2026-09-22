# Barra de combate y números gráficos — 16/09/2026

- Reliquias personales en la esquina superior izquierda, en orden de héroes.
  No se muestra el nombre de sala. Solo se dibuja el icono, sin recuadro.
  Tocar abre nombre del dueño, descripción y estado de uso del Fénix.
- Bolsa como icono sin texto ni recuadro. Conserva área de toque de 56 × 56,
  descripción emergente y realce al pasar el ratón o recibir foco de teclado.
- Energía disponible sobre un orbe celeste; sin panel, palabra «energía» ni máximo.
- Diez dígitos transparentes independientes, ya usados en energía, turnos y costes.
  Soportan cero y números de varias cifras, ajustándose al espacio asignado.

## Archivos y reutilización

- `assets/ui/energy.png`: orbe RGBA, 128 × 128.
- `assets/ui/numbers/0.png` a `9.png`: dígitos RGBA, 32 × 48.
- `scripts/import_hud.gd`: separación, escalado y alineación reproducibles.
- `energy-source.png`, `digits-source.png`, `prompts.md`: fuentes y procedencia.
- `src/ui/components/number_view.gd` (`ERNumberView`): recibe `value` y tamaño,
  compone las cifras; no depende del estado de la partida. Al cambiar `value`,
  actualiza sus texturas. No recibe eventos de ratón/táctiles.
- `src/ui/components/combat_hud.gd` (`ERCombatHUD`): recibe una instantánea de
  reliquias, turno y energía. Emite señales para bolsa, mazo, menú y reliquias.
  No guarda, calcula ventajas ni cambia pantallas por su cuenta.
- `src/main.gd`: prepara esos datos y conecta señales con navegación y modales,
  conservando bloqueo de acciones durante animaciones.

Ejemplo para otro contador (definir el tamaño antes de añadirlo):

```gdscript
var counter = preload("res://src/ui/components/number_view.gd").new()
counter.size = Vector2(80, 40)
counter.value = 12
add_child(counter)
```

## Validación

452 comprobaciones locales sin fallos (HUD 69, distribución 8, cartas 243,
interfaz 121 y bolsa/equipamiento 11).

Pruebas locales: `test_hud.gd`, `test_combat_layout.gd`, `test_cards.gd`,
`test_ui.gd`, `test_equipment_ui.gd`. Incluyen iconos interactivos sin panel,
propietario de reliquia, bloqueo durante acciones, cero, múltiples cifras y
costes reales en cartas normales y mejoradas.

Capturas `combat.png` y `zero-energy.png` renderizadas en Linux, Godot 4.7.2
Compatibility. Sin exportación de APK ni comprobación en Android para este cambio.


## Bloqueo y elección única (16/09/2026)

Las nuevas aventuras muestran una sola reliquia equipada. Las antiguas pueden
conservar dos. Debajo de la vida aparece un pequeño escudo con el bloqueo
actual, incluido cero, en héroes vivos y enemigos. Usa `block_indicator.gd`,
el escudo del atlas de objetos y los dígitos compartidos; no afecta las reglas
ni intercepta pulsaciones. `combat.png` muestra 12 de bloqueo aliado y 7 enemigo.
Ver [validación actual](../objects/README.md).

## Esfera animada y descripción anclada (16/09/2026)

La esfera usa `assets/ui/shaders/energy_flow.gdshader`: filamentos celestes
ascendentes y ondulantes dentro del círculo. El borde y el número permanecen
quietos y legibles. Es un efecto procedural sobre el asset existente, sin nuevos
bitmaps ni cambios en energía/reglas. Se ejecuta con el renderizador Compatibility.

Al pulsar una reliquia, `relic_popover.gd` muestra portador, nombre y efecto
debajo de ese icono, con una pequeña punta. No contiene botones ni oscurece la
pantalla. Se cierra con otra pulsación en el icono, una pulsación fuera o Atrás.
La pulsación exterior solo cierra el cuadro para evitar acciones accidentales.
El estado del Fénix utilizado sigue apareciendo en su descripción.

Validación de esta revisión: HUD 85 comprobaciones headless; distribución 8.
HUD renderizado: 86, incluyendo comparación de dos fotogramas del orbe a 0,4 s
de distancia. Sin fallos. Capturas `combat.png`, `relic-popover.png` revisadas;
`energy-frame-a.png` y `energy-frame-b.png` registran el movimiento.
No se probó en Android ni se exportó APK.

## Alcance compartido (16/09/2026)

En aventuras nuevas la reliquia tiene encabezado «Equipo» y aparece una sola vez.
El Fénix lista disponibilidad por héroe. Aventuras anteriores conservan iconos
personales identificados como efecto de partida anterior.

## Escudo de bloqueo más visible (16/09/2026)

`block_indicator.gd` recorta el margen transparente de la celda del atlas al
presentarla y coloca el escudo en un espacio de 32×32, conservando su proporción.
El número empieza a 3 px del espacio del icono y su ancho se ajusta a la cantidad
de dígitos, evitando el hueco que introducía el centrado en un ancho fijo.
Se aplica a héroes y enemigos. No se modificó la imagen fuente ni las reglas.

Verificación actual: HUD renderizado en escritorio, 86 comprobaciones sin
fallos; captura `combat.png` revisada visualmente. Sin APK ni pruebas Android.

## Estados activos y tamaño actual (16/09/2026)

Esta revisión reemplaza la indicación anterior de mostrar bloqueo cero.
Héroes vivos y enemigos vivos muestran solo efectos con cantidad mayor que cero:
escudo para bloqueo y calavera verde para veneno, cada uno con el número al lado.
Si ambos están activos aparecen juntos; al agotarse desaparecen, sin dejar huecos.
La fila se centra bajo la vida y no intercepta selección de objetivos.

- `status_effects.gd`: compone la fila a partir de una instantánea del actor.
- `block_indicator.gd`: icono configurable y número, oculto con valor cero.
- `assets/ui/poison.svg`: calavera verde propia, dibujada con formas vectoriales
  en una cuadrícula de 16×16 y presentada con filtro nearest. No usa fuentes externas.
- Actores de combate: escala 1,25 respecto del tamaño anterior; pivotes intactos.

No se cambiaron las reglas de veneno. Actualmente las acciones existentes aplican
veneno a enemigos; la interfaz también admite el campo opcional `hero.poison`.
La captura de prueba asigna 2 al héroe y 4 al enemigo para verificar ambos casos.

Validación actual: HUD renderizado 91 y distribución headless 8, sin fallos.
Revisadas aparición y desaparición, dos estados simultáneos, tamaños y captura
`combat.png`. Importación local correcta; sin APK ni pruebas Android.

## Vida animada y daño (16/09/2026)

La barra usa `src/ui/components/health_bar.gd`: conserva vida mostrada y objetivo
visual separados del estado de juego. Al recibir daño, el relleno y el contador
bajan de uno en uno (intervalo mínimo 25 ms, máximo un punto por fotograma).
El número nunca sobrepasa el resultado y al llegar a cero muestra «CAÍDO».
Los incrementos de vida resueltos por cartas/recuperación también se animan.

El controlador inicia el descenso junto con la reacción al impacto y espera a
que terminen todos los contadores antes de reconstruir la pantalla. Héroes de
todas las clases reciben un destello rojo breve, que restaura su color anterior;
los enemigos mantienen su reacción roja y la reciben también al morir.
Reglas y guardado siguen resolviéndose antes de las animaciones; reabrir muestra
la vida ya confirmada, sin repetir daño. Un golpe totalmente bloqueado no baja PV.

Validación actual: prueba de guerrero renderizada (62) y distribución headless
(8), sin fallos. Verifica secuencias enteras de vida para ambos bandos, destello
rojo/restauración, bloqueo de entradas, guardado previo, muerte, derrota y
recuperación. Captura `../warrior/hurt.png` revisada. Sin APK ni Android.

## Iconos de mazo, bolsa y reliquias (16/09/2026)

«Ver mazo» se reemplaza por tres cartas superpuestas, sin texto visible ni marco
de botón. Conserva tooltip «Ver mazo» y la misma acción de navegación.
Asset: `assets/ui/deck.svg`, ilustración vectorial propia de 64×64, con dorsos
azul, violeta y verde y bordes dorados; sin fuentes externas.

Los gráficos de reliquias y bolsa pasan de 48×48 a 60×60 (**25 % más grandes**),
centrados en sus zonas de interacción existentes. Permanecen dentro de la barra.
Archivo de presentación: `src/ui/components/combat_hud.gd`.

Validación actual: importación correcta, HUD renderizado en escritorio con 93
comprobaciones sin fallos, incluida apertura del mazo desde su nuevo icono.
Captura `combat.png` revisada visualmente. Sin exportar APK ni probar en Android.

## Intenciones y efectos de combate — 16/09/2026

`enemy_intent.gd` reemplaza la intención escrita por espada + daño con
`NumberView`, retrato enmarcado del objetivo y escudo + bloqueo cuando corresponde.
Ataques a ambos muestran las dos caras; intenciones de bloqueo sin daño no muestran
espada ni retratos. Enemigos derrotados no muestran intención. Los retratos recortan
las caras del atlas frontal existente, sin duplicar archivos de arte.

`assets/ui/sword.svg` es un icono propio de código, con acero y oro, reutilizado
en cartas/intenciones. El escudo reutiliza la reliquia existente con márgenes
transparentes recortados. Se conservan los números gráficos ya creados.

`src/presentation/combat_effects.gd` contiene un destello blanco de 0,14 s y alfa
inicial 0,18 al atacar (incluye ataques absorbidos por bloqueo). Curación y defensa
no producen este destello. Se aplica también a cada ataque enemigo, no a sus
acciones exclusivamente defensivas.

Al ganar, tras impactos y contadores de vida, ambos héroes salen por la derecha
antes de la recompensa. Carrera procedural: desplazamiento, inclinación, rebote
y ciclo de reposo acelerado; no se generó un atlas nuevo de piernas corriendo.
Compañeros recuperados participan. No se ejecuta en derrota. También se contempla
una victoria resuelta al usar un consumible. Reglas y guardado permanecen antes
de las animaciones; continuar un guardado resuelto abre la recompensa directamente.

Validación de estos cambios: `test_combat_presentation.gd` 10 comprobaciones
renderizadas (objetivo, área, defensa, victoria, recuperación y derrota);
`test_cards.gd` 243, `test_ui.gd` 121 y `test_combat_layout.gd` 8 headless.
Sin fallos; intenciones/cartas revisadas en escritorio a 1280×720. Capturas
eliminadas después de revisar. No se exportó APK ni se probó Android.

## Objetivos iluminados y botón de turno — 16/09/2026

Se reemplaza la flecha de objetivo por un halo dorado pulsante detrás del sprite.
`target_glow.gd` recibe elegibilidad del controlador y usa `target_glow.gdshader`;
no intercepta toques ni calcula objetivos. Sin energía no aparece. Se oculta al
resolver una acción, antes de las animaciones. Los marcadores del mapa no cambian.

Mazo y bolsa quedan separados por 12 px entre áreas táctiles de 56 px
(mazo x=829, bolsa x=897). Conservan sus acciones y tooltips.

`end_turn_button.gd` aplica `assets/ui/end_turn.png`, generado con imagegen:
marco metálico, detalles dorados y gemas violetas. Texto nativo para legibilidad;
estados de hover/pulsación modulados. [Procedencia y prompt](end-turn-prompt.md).

Pruebas actuales: layout 38 renderizadas y HUD 92 headless, sin fallos.
Se precisó el selector del test de estados para no contar los indicadores de
intención como bloqueo/veneno ya activos. Revisión visual de halo, botón y barra
en Linux a 1280×720; capturas temporales retiradas. Sin exportación Web/APK.

## Almas (actualizado 17/09/2026)

Retirado el saldo del HUD de combate. Solo se muestra en campamento y edificios;
las reglas siguen concediendo almas al ganar.

## Vida, intenciones y turno circular (17/09/2026)

Vida elevada para no tapar actores, intención enemiga inmediatamente encima.
Botón Terminar turno circular a la derecha de la mano. Asset generado con
imagegen integrado: `assets/ui/end_turn_round.png`; [prompt y procedencia](end-turn-round.json).
`end_turn_button.gd` aplica estados; `round_button.gd` limita el área pulsable al
círculo y conserva interacción de teclado. La barra de combate no muestra almas.

## Bloqueo junto a la vida — 18/09/2026

- `status_effects.gd` coloca el bloqueo activo a la izquierda de la barra de vida
  con escudo de 32 px y dígitos de 18 px (antes 24). `combat_screen.gd` proporciona
  la posición relativa a cada barra; veneno permanece arriba. Solo aparecen
  valores positivos en unidades vivas.
- `enemy_intent.gd`: espada, escudo de bloqueo previsto y retrato del objetivo,
  en ese orden. El escudo previsto añade `assets/ui/block_up.svg`, flecha verde
  ascendente dibujada en SVG para reutilizar el escudo existente. Número de 18 px.
  La intención de ataque conserva su tamaño; intenciones sin daño no muestran espada.
- `block_indicator.gd` comparte dimensiones configurables y flecha opcional.
- `button_skin.gd`: márgenes verticales simétricos (8/8) para centrar Menú
  en todas las barras que utilizan el tablón compartido.
- No cambian valores de bloqueo, reglas, estados ni guardado.

Revisión visual local de combate a 1280×720 y prueba HUD renderizada: 93
comprobaciones aprobadas. Sin exportación APK/Web ni dispositivo.


## Consulta de bloqueo e intenciones — 18/09/2026

Tocar el escudo de bloqueo activo de cualquier unidad abre un cuadro pequeño
anclado con su cantidad y funcionamiento. Las intenciones de ataque, bloqueo
futuro y contraataque también son pulsables. Solo hay un cuadro abierto;
otro icono lo reemplaza, otro toque sobre el mismo lo cierra y tocar afuera
lo descarta. Los eventos no se propagan al objetivo de una carta.
El cuadro queda debajo de los modales y se cierra al comenzar una acción.

Implementación: `combat_tip.gd`, `block_indicator.gd`, `status_effects.gd`
y `enemy_intent.gd`, dentro de `src/ui/components/`.
El nuevo `assets/ui/counter.svg` es un vector creado en código para esta
petición: espada y flecha naranja de retorno, siguiendo los iconos existentes;
no procede de un generador de imágenes.

## Equipo mejorado — 18/09/2026
La barra comparte la fila y cuadros de reliquias con armas y armaduras mejoradas de los héroes. Icono por tipo/nivel y dígitos de nivel; solo niveles positivos de la instantánea de aventura. [Detalles y validación](../forge/README.md).

### Arte de equipo renovado — 18/09/2026
Las insignias usan ahora los PNG detallados de `assets/forge/icons/`, con tres niveles por tipo. Se mantienen dígitos y cuadros de efecto. [Prompts/procedencia](../forge/hud-icons.json).

## 18/09/2026 — Bloqueo de héroes encima de la vida

Solo en héroes, escudo y número de bloqueo activo vuelven a la fila encima
de la barra de vida. Sin veneno se centran; con veneno se distribuyen ambos
indicadores sin solaparse. Los enemigos conservan sus posiciones anteriores.
Se mantiene la consulta al tocar y la ocultación cuando no hay bloqueo.
`combat_screen.gd` aporta posiciones de héroes; `status_effects.gd` admite
una posición opcional del veneno sin alterar el valor predeterminado.

Validación: `test_hud.gd` renderizado, 108 comprobaciones sin fallos,
incluyendo posición, ausencia de solapamiento, clics y ocultación. Revisión
visual Linux 1280×720; captura temporal eliminada. Sin exportación.

## Corazón en las barras de vida — 18/09/2026

`health_bar.gd` muestra `assets/ui/heart.svg` al inicio izquierdo de todas
las barras de combate, tanto héroes como enemigos. Icono de 24×24, sin
interceptar clics; el texto reserva 30 píxeles a la izquierda. Se conservan
la animación de vida, el relleno y los indicadores de bloqueo. Asset vectorial
original dibujado en código, rojo con luces y contorno oscuro escalonado;
sin IA ni dependencia de símbolos de fuente.

Validación local renderizada Linux/llvmpipe: 108 comprobaciones del HUD sin
fallos y revisión visual del corazón en ambos bandos. Sin exportación Web.

## Línea de base de los dígitos — 18/09/2026

El dibujo opaco del 5 termina en la fila 40 de su PNG 32×48 y el 6 en la 41;
el resto termina en la 46. `number_view.gd` compensa 6 y 5 píxeles de origen,
respectivamente, escalados según la textura dibujada. Esto alinea la base en
almas y demás contadores compartidos, sin editar los assets ni sus importadores.
Revisión renderizada local de 85260 y todos los dígitos, a alturas 36 y 48;
sin exportación ni revisión Web.


## 22/09/2026 — Fondo para estados de héroes

Bloqueo y veneno sobre la vida reutilizan combat_backplate.gd: fondo oscuro
al 65 %, con esquinas suaves. status_effects.gd recibe show_backplates desde
combat_screen.gd solo para héroes. El fondo se oculta con el indicador y no
intercepta clics. Enemigos sin cambios.

Validación: test_hud.gd, 108 comprobaciones aprobadas con render Linux/llvmpipe
y revisión visual a 1280×720. Capturas retiradas. Sin exportación Web/APK.

## Secuencia del fin de turno — 22/09/2026

`ui/combat_flow.gd` espera a que terminen las cenizas de toda la mano descartada
antes de presentar reacciones por veneno o acciones enemigas. Para cada enemigo
que actuó, actualiza su bloqueo activo y deja 0,30 s para leerlo si es positivo,
luego reproduce su ataque. Los enemigos que solo bloquean no muestran ataque.

Las reglas y el guardado siguen resolviéndose antes de la presentación.
`game.resolved_enemy_blocks` es un recibo transitorio, igual que el registro de
ataques, y no se guarda: evita presentar bloqueos de enemigos muertos por veneno
o que no llegaron a actuar por derrota del grupo. `status_effects.gd` mantiene
un indicador de bloqueo oculto a cero que puede actualizarse sin reconstruir
la pantalla. No aparece un escudo mientras no haya bloqueo activo.

Prueba renderizada `test_turn_sequence.gd`: observa cenizas, bloqueo y ataque
cuadro a cuadro; verifica ausencia de superposición, defensa sin ataque, muerte
por veneno y acciones interrumpidas por derrota.
