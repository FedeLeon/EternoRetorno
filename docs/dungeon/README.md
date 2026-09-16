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
- Zona de ilustración vacía con márgenes; pergamino de efectos también con
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
