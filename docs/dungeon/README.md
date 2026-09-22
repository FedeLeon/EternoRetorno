# Presentación de combate

Fondo generado a partir de `conceptoMazmorras.png`, guardado en
`assets/dungeon/combat.png`. Bolsa independiente en `assets/dungeon/bag.png`.
No se crean nuevos tipos de sala ni mecánicas de trampas en este cambio.

- Barra horizontal superior: reliquias personales, mazo, icono de bolsa, menú
  y turno a la derecha; no se muestra la sala. Ver [actualización del HUD](../hud/README.md).
- Personajes sobre el suelo, objetivos sin paneles cuadrados; flecha dorada
  para señalar objetivos válidos al seleccionar una carta.
- Orbe celeste con la energía disponible abajo a la izquierda. Seis cartas al inicio de cada turno.
- Mano asomada desde el borde inferior; tocar una carta la eleva y amplía
  para leerla, tocar el objetivo la juega. Más cartas permiten desplazamiento.
- Ilustración de cada carta con márgenes; pergamino de efectos también con
  márgenes internos. Diseño compartido con recompensas, mazo y mejoras.
- Las partidas existentes reciben seis cartas en el próximo robo normal;
  no se modifica una mano ya guardada al continuar.

Pruebas: `test_combat_layout.gd` verifica selección, carta elevada, márgenes,
terminar turno y botones de barra; `test_cards.gd`, `test_ui.gd`,
`test_equipment_ui.gd`, `test_equipment.gd` y `test_game.gd` cubren regresiones.
Capturas locales en Linux, Godot 4.7.2 Compatibility. Sin APK ni prueba Android.

## 16/09/2026 — Actores de combate al doble de tamaño

En `src/main.gd::combat_view`, los controles visuales de héroes y enemigos usan
escala 2 respecto al tamaño previo. El pivote inferior mantiene la línea del
suelo; en enemigos se descuentan los 4 píxeles transparentes inferiores del
frame a su escala nativa. Los sprites y animaciones base no se modifican, por
lo que selección, campamento y otras pantallas conservan su tamaño anterior.

Las zonas táctiles comienzan más arriba para incluir la silueta ampliada; los
nombres, vida y bloqueo mantienen sus posiciones. Las intenciones enemigas
suben para dejar espacio a los sprites. Se conserva filtrado nearest.

Validación local: prueba de distribución e interacción, regresión de animaciones
del guerrero y revisión renderizada de `combat.png`. Sin APK ni prueba Android.

## Ajuste de tamaño (16/09/2026, posterior al aumento)

Héroes y enemigos vuelven a escala de Control 1, equivalente al **50 % del
tamaño anterior**. Se conservan sus posiciones y la línea de apoyo de los pies.
Nombres, vida, bloqueo y zonas táctiles mantienen su tamaño.
La captura actual está en `../hud/combat.png`; las capturas de esta carpeta
anteriores a este ajuste muestran los personajes más grandes.
Pruebas actuales: distribución 8 y HUD 85 headless; HUD renderizado 86 sin fallos.

## Ajuste posterior: aumento del 25 % (16/09/2026)

La escala actual de héroes y enemigos es **1,25**, un 25 % mayor que la revisión
anterior de escala 1. Se conserva el apoyo de los pies. Debajo de la vida, solo
se muestran bloqueo y veneno positivos, con escudo/calavera verde y cantidades.
Captura actual: `../hud/combat.png`. HUD renderizado 91 y distribución headless
8 comprobaciones sin fallos; sin validación Android ni APK.

## Escenarios adicionales — 16/09/2026

`combat_columns.png`: cripta con vitrales. `combat_canal.png`: acueducto
subterráneo con suelo seco para los actores. Se suman a `combat.png`.
`BattleBackground.path_for(seed, node)` selecciona uno de los tres de manera
estable al volver a la sala y sin alterar el generador aleatorio de reglas.
Fuentes generadas con imagegen; [prompts](../treasure/prompts.md).
Capturas actuales: cripta (archivo retirado en la limpieza),
acueducto (archivo retirado en la limpieza). Revisadas en escritorio a 1280×720.

## PV superiores y mano completa — 16/09/2026

PV de ambos bandos en y=278, encima de los sprites. Bloqueo y veneno en y=241;
intención enemiga en y=190. Se retiran los nombres de los héroes de combate;
el nombre enemigo se conserva sobre su intención. Los personajes siguen en
su posición de suelo y los contadores de vida conservan sus animaciones.

La mano se muestra completa con arco y superposición suaves; la seleccionada
se eleva. Terminar turno pasa al lateral izquierdo (16,478) sobre la energía.
Cambios en `main.gd` y `ui/components/hand_layout.gd`; sin cambios de reglas.

Validación actual: layout 33 comprobaciones renderizadas, UI 121 headless,
sin fallos. Bordes de las seis cartas comprobados dentro del alto visible;
revisión visual de textos y PV en Linux a 1280×720. Sin APK ni prueba web/Android.
Capturas temporales retiradas después de revisar.

## Espacio de combate y mano (17/09/2026)

Barras de vida a y=205 para ambos bandos, separadas de los sprites. Intenciones
 a y=160 (42 px de alto), con 3 px hasta la vida enemiga. Estados activos encima
 de las intenciones; héroes mantienen sus estados sobre la vida.
Mano a x=160, ancho 938: paso 132 px, inclinación máxima 7° y curva de 18 px.
Cartas en reposo 14 px más abajo, con borde inferior parcialmente fuera de pantalla;
las descripciones permanecen visibles verticalmente. Selección sigue elevando y
enderezando la carta. Manos mayores conservan desplazamiento horizontal.
Terminar turno ocupa un círculo de 136 px a la derecha (1120,568); no recibe clics
 en esquinas transparentes. El HUD sigue sin almas.

Validación local: distribución 38, HUD 92, sin fallos; revisión renderizada de
mano normal y seleccionada a 1280×720. Sin exportación APK/Web ni Android/navegador.

## Actores ampliados y contraste (17/09/2026)

En combate los enemigos pasan de escala 1,25 a 1,5625 (+25 %). Los héroes usan
altura visible común de 142,19 px: la silueta mayor anterior (guardiana, 91 px
opacos × 1,25) ampliada un 25 %. Los más bajos reciben además compensación por
márgenes transparentes. La escala es uniforme en ambos ejes y fija por clase,
con pivote en los pies; no cambia entre frames. La postura, armas y efectos
propios conservan sus diferencias. Solo cambia la presentación de combate.

Medidas máximas de siluetas en los seis frames idle de los atlas de 128 px,
con alfa > 0,5: guerrero 78, guardiana 91, pícaro 87, maga 90, clériga 85,
explorador 81. Recalibrar `combat_actor_scale.gd` si se reemplazan los atlas.
Nombre e intención enemigos llevan placas oscuras al 65 % de opacidad, sin
interceptar toques. `combat_backplate.gd` comparte el estilo.

Pruebas locales de esta revisión: distribución 38 y HUD 92 sin fallos (ajustada
la expectativa antigua de escala). Revisión renderizada Linux de las seis clases
en tres parejas; capturas temporales retiradas. Sin exportación APK/Web ni pruebas
nuevas en navegador, emulador o dispositivo físico.

## Separación de responsabilidades — 18/09/2026

La composición de combate vive ahora en `src/ui/screens/combat_screen.gd`;
`src/ui/combat_flow.gd` coordina acciones y animaciones. `main.gd` delega y el
guardado continúa ocurriendo antes de animar.

Validación: batería local completa de 30 scripts aprobada.
[Detalle de la auditoría](../cleanup/2026-09-18.md).

## Primeros planos de ataque — 18/09/2026

Las cartas ofensivas válidas presentan una viñeta del héroe antes de la animación
del actor. [Comportamiento, límites y pruebas](../comic/README.md).

## Selector temporal de mazmorra — 22/09/2026

Al tocar Iniciar aventura se elige Mazmorra 1 (Cripta) o Mazmorra 2
(Bosque). El diálogo avisa que es para pruebas y se eliminará en la versión
final. Volver conserva la preparación y cualquier aventura activa. Solo
confirmar un destino reemplaza la aventura. No recuerda la última elección.
Ambas opciones crean una run con 20 cartas, inventario vacío, reliquia y
mejoras iniciales normales. El bosque comienza sin simular premios de la cripta.
Terminar el bosque conserva el flujo normal de victoria y desbloqueos.

Retirada futura: quitar la llamada a `ui/development_start.gd` de `begin()`
y llamar directamente a `begin_on_floor(1)`. Selector también disponible en
builds exportados durante desarrollo; no depende de OS.is_debug_build().
