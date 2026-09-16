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
