# El Bosque de las Raíces y pisos aleatorios

Implementado el 22/09/2026. Aventuras nuevas: **cripta → bosque → victoria**.
Las aventuras anteriores conservan sus nodos y su final de un piso.

## Recorridos y encuentros

Cada piso contiene 28 salas con la misma composición anterior. El generador usa
el RNG de la aventura para variar orden, conexiones, posiciones y encuentros.
Guarda el grafo completo; continuar una partida no cambia el mapa. El primer
combate de la cripta es individual. De los otros doce, siete se seleccionan como
dobles y dos combates tardíos pasan a triples (pueden coincidir con los dobles).
En el bosque los combates comunes son dobles, con hasta tres triples tardíos.
El élite tardío y el guardián del bosque llevan un acompañante.

| Enemigo | Apariencia | Función |
| --- | --- | --- |
| Goblin guerrero | `goblin_0` | Ataque, bloqueo y contraataque |
| Goblin arquero | `goblin_2` | Daño concentrado |
| Goblin chamán | `goblin_3` | Ataques a ambos héroes |
| Lobo gris | `beast_0` | Ataques alternos |
| Jabalí salvaje | `beast_1` | Carga y defensa |
| Oso ancestral | `beast_5` | Élite, daño grupal y contraataque |
| Jefe del clan goblin | `goblin_7` | Guardián con escolta |

Cambiar de piso conserva héroes, vida, mazo, consumibles, reliquias y progreso
del contrato. No cura gratuitamente. Reinicia visitadas y registro de almas por
sala para que los IDs del nuevo piso puedan conceder sus premios. Solo el final
de la aventura liquida contratos y habilita especializaciones por victoria.

## Arte y animación

17 recursos finales nuevos: dos escenarios de combate, un descanso forestal,
siete atlas y siete ilustraciones transparentes de ataque en primer plano.
Las viñetas atacan de derecha a izquierda desde la esquina inferior derecha y
permiten seguir viendo el escenario. El tesoro utiliza un escenario forestal
con el cofre interactivo existente.

- `assets/forest/{combat_glade,combat_ruins,rest}.png`: 1280×720.
- `assets/enemies/animations/<apariencia>.png`: 1024×128, ocho cuadros de 128×128.
  Cuadros 0–3 para reposo, 4–7 para ataque; conserva daño y disolución existentes.
- `assets/comic/enemies/<apariencia>.png`: ilustración RGBA de 900 px de ancho.
- Fuentes de generación en `sources/`, prompts y procedencia en los JSON de
  esta carpeta. Referencias: los sprites existentes de cada enemigo y la cripta.
  `goblin_0_motion_spacing.json` registra la corrección de espacio entre cuadros.
- `scripts/import_forest.gd`: recorte por silueta alfa, escala uniforme entre
  cuadros y pies alineados a y=120. No depende de red ni modifica las fuentes.

## Pruebas y límites

- `test_forest.gd`: 20.414 comprobaciones, 200 mapas, guardado y transición,
  victoria final y compatibilidad con aventuras de un piso.
- `test_forest_ui.gd`: 36 comprobaciones renderizadas, tres actores, ocho poses
  distintas por enemigo, viñetas orientadas a la izquierda y fondos por sala.
- `test_enemies.gd`: 631 comprobaciones; `test_game.gd`: 142.
- Regresiones: mapa 109, reliquias 134, campamento 192, equipo 90, mazmorra 66,
  tesoros 22 y tesoro renderizado 8; todas sin fallos.
- Revisión visual Linux/llvmpipe a 1280×720: mapa, tres goblins y tres bestias,
  viñetas del jefe goblin, chamán y lobo, y descanso. Capturas temporales retiradas tras revisar.
- El bot simple terminó 45 aventuras con 15 victorias. Omite mejoras y premios;
  esto verifica ejecución y aporta una observación, **no certifica equilibrio**.
  Se retiró su antigua exigencia de una victoria por pareja en tres semillas,
  basada en el recorrido anterior de un piso. Sigue exigiendo que cada simulación
  termine. Pendiente ajustar dificultad a partir de partidas humanas completas.
- Sin exportación Web/APK ni validación en móvil para estos cambios.

## Ampliación posterior del bosque

Seis enemigos adicionales, grupos comunes con tipos distintos y nuevas
animaciones/viñetas: [catálogo, assets y pruebas](expansion/README.md).
El bosque tiene ahora once comunes más élite y guardián; los resultados de la
entrega original anteriores son históricos.
