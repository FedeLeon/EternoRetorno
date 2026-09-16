# Presentación de combate

Fondo generado a partir de `conceptoMazmorras.png`, guardado en
`assets/dungeon/combat.png`. Bolsa independiente en `assets/dungeon/bag.png`.
No se crean nuevos tipos de sala ni mecánicas de trampas en este cambio.

- Barra horizontal superior: sala, mazo, bolsa, menú y turno a la derecha.
- Personajes sobre el suelo, objetivos sin paneles cuadrados; flecha dorada
  para señalar objetivos válidos al seleccionar una carta.
- Energía abajo a la izquierda. Seis cartas al inicio de cada turno.
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
