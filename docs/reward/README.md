# Elección de recompensa — 18/09/2026

`src/ui/screens/reward_screen.gd` compone esta pantalla; `main.gd` delega.
Tres cartas centradas de 248×414, sin actores encima. Fondo generado oscuro
con energía periférica en `assets/reward/background.png`; [prompt y procedencia](background.json).

Se reutiliza `CombatHUD` con `show_energy = false`: conserva turno, reliquias,
mazo, bolsa y menú. La bolsa permite consultar existencias; consumibles solo se
usan durante combate. Volver desde mazo/bolsa mantiene la recompensa pendiente.
Elegir o saltar sigue pasando por `game.choose_reward`, sin nuevos guardados
ni concesión de premios desde componentes visuales.

Los contadores de robo/descarte/inactivas ya no aparecen sobre la batalla.
Se muestran junto al total y la mano en `DeckSummary` al abrir el mazo durante
combate. Fuera de combate el visor muestra el total, sin pilas de una batalla pasada.

## Validación actual

- `test_reward_ui.gd` renderizado local sin fallos: barra, cartas altas, contadores
  en mazo, regreso desde mazo/bolsa, premio único y rechazo de segunda concesión.
- `test_combat_layout.gd`: 41 comprobaciones aprobadas.
- Revisión visual Linux 1280×720 de recompensa; captura temporal eliminada.
- Sin exportación APK/Web ni prueba en emulador/dispositivo.
