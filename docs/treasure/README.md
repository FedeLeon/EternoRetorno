# Cofres y consumibles — 16/09/2026

## Reglas actuales

- Toda aventura nueva comienza con inventario vacío. Los guardados anteriores conservan sus objetos.
- La sala de tesoro entrega una unidad aleatoria entre los ocho consumibles disponibles, con igual probabilidad.
- Hay un 15 % de probabilidad de trampa por cofre (`randi_range(0, 99) < 15`).
- La trampa resta hasta 4 PV a cada héroe vivo y nunca baja de 1 PV. No consume bloqueo ni Fénix. También entrega el ítem.
- El mapa actual tiene una sala de tesoro. No se añadieron salas ni fuentes alternativas de consumibles.

## Interacción y guardado

Cofre cerrado en primer plano → tocar → seis poses de apertura → modal con asset, nombre y efecto del ítem → Continuar al mapa. Las trampas añaden un destello rojo y el daño recibido por cada héroe.

El resultado se sortea y guarda al entrar en la sala. Al tocar, `Game.take_treasure()` concede el objeto, aplica daño y guarda `opened=true` y `losses` **antes** de animar. La animación bloquea nuevas aperturas y Atrás. Reabrir un guardado ya resuelto muestra directamente el modal; `leave_treasure()` confirma la salida sin conceder nada. Una reliquia pendiente de un guardado antiguo se conserva como premio legado.

## Archivos

- `src/rules/treasure.gd`: reglas aisladas y adaptación de premio legado.
- `src/game.gd`: validación de sala, coordinación del guardado y salida.
- `src/ui/screens/treasure_screen.gd`: presentación y señales; sin reglas ni escritura de partidas.
- `src/main.gd`: conexión entre acciones y pantalla.
- `assets/treasure/chest.png`: seis celdas de 256×256, transparencia y base alineada.
- `scripts/import_treasure.gd`: importación repetible desde `chest-source.png` (3×2).
- [Prompts y procedencia](prompts.md): generación de cofre y escenarios. `chest-source.png` conserva la fuente final con alfa; el ensayo previo fue retirado.

## Validación de esta entrega

- Reglas: `tests/test_treasure.gd`, 22 comprobaciones; 1519 trampas en 10000 sorteos con semilla fija. Guardado antes/después, sin duplicación, trampas no letales, inventario y premios legados.
- Juego: `tests/test_game.gd`, 137 comprobaciones y 45/45 aventuras simuladas ganadas con las 15 parejas. No equivalen a pruebas humanas de dificultad.
- Equipamiento: `tests/test_equipment.gd`, 90 comprobaciones. Los consumibles de prueba ahora se cargan explícitamente en las fixtures.
- Interfaz: `tests/test_treasure_ui.gd`, ocho comprobaciones con apertura, bloqueo de repetición/Atrás, modal pendiente y vuelta al mapa. Capturas `closed.png`, `opened.png`, `trap.png`, `battle-2.png`, `battle-4.png`.
- Renderizado local Linux, Compatibility/llvmpipe, 1280×720. Capturas revisadas visualmente. Sin exportación APK ni comprobación en emulador o dispositivo Android.

Pendiente: balancear la frecuencia de consumibles y daño con partidas humanas.

Regresión adicional de esta entrega: interfaz de equipamiento 12 y HUD 92 comprobaciones headless, sin fallos. En total 361 comprobaciones automatizadas; la interfaz de tesoros se accionó mediante eventos de ratón.
