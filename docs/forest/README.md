# El Bosque de las Raíces y pisos aleatorios

## Paso directo tras la reliquia del guardián — 08/10/2026

Al elegir la reliquia exclusiva, se abre directamente el mapa del siguiente
piso: cripta → bosque → fortaleza. No aparece el mapa del piso vencido ni hace
falta tocar «Entrar al bosque» o la escalera. La primera sala queda disponible.
La última mazmorra conserva la acción de completar aventura; partidas antiguas
sin selección de reliquia conservan su transición anterior.

`src/rules/boss_rewards.gd` concede la reliquia y delega el avance a
`room_actions.gd`/`dungeon_progression.gd`, antes del único checkpoint de
`Game.polish_action`. Al reanudar se conserva el mapa nuevo y la reliquia sin
duplicarla. Vida, mazo, inventario y contrato continúan; no se cuenta una victoria
de aventura al pasar entre pisos. IDs y formato de guardado no cambian.

Validación actual: reglas de pulido 61, bosque/persistencia 24616 y juego 143
comprobaciones headless sin fallos. Navegación de reliquias: 14 comprobaciones
en ventana local, con clic real simulado, destino de ambos pisos y final del
tercero. Mapa del bosque revisado a 1280×720. Sin exportar Web/APK ni probar en
navegador, emulador o dispositivo físico.

## Implementación inicial — 22/09/2026

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

## Ampliación del 07/10/2026

Las aventuras nuevas ahora siguen cripta → bosque → fortaleza → victoria. Los guardados anteriores conservan su límite de uno/dos pisos. Bosque tiene 18 comunes y tres encuentros propios.

[Reglas, assets y pruebas actuales](../expansion_2026_10/README.md).

## Variedad de formaciones en los tres pisos — 08/10/2026

La progresión actual es cripta → bosque → fortaleza → victoria. El catálogo común
contiene 16, 18 y 14 enemigos respectivamente. La fortaleza incorpora cinco tipos
ya existentes: guerrero y arquero esqueléticos, berserker esquelético, elemental de
roca y corcel de la cripta, con sus animaciones y ataques en primer plano originales.
No se generaron assets nuevos ni se duplicaron apariencias.

`rules/enemy_formations.gd` selecciona grupos al generar el mapa: prioriza tipos
menos usados en el piso y en sus antecesores; penaliza los enemigos de los combates
comunes más próximos de cada camino. Evita repetir su formación completa, aunque
el orden de los enemigos sea distinto. Una preferencia moderada por apoyo/protector
sustituye la obligación de incluirlo en cada grupo. Se mantienen grupos sin duplicados,
los tamaños de combate y la introducción gradual de enemigos fuertes.

El RNG recibido sigue determinando los desempates. No se cambia el mapa al cargar:
la mejora se aplica a pisos recién generados (aventura nueva o siguiente piso),
no a salas que ya forman parte de un guardado. Élites y guardianes mantienen su identidad.

Validación actual headless Godot 4.7.2:

- `test_enemy_formations.gd`: 43.678 comprobaciones, 600 mapas; determinismo,
  catálogo completo, al menos doce tipos por mapa, debut progresivo, ausencia de
  formaciones consecutivas repetidas en todos los caminos y recursos de animación/viñeta.
- `test_forest.gd`: 24.616; guardado/transiciones y grafo. `test_dungeon.gd`: 66.
- `test_adventure_expansion.gd`: 5.224; progresión, reglas y compatibilidad.
- `test_adventure_assets.gd`: 78; reproducción de actores/viñetas existentes,
  sin fallos funcionales; avisos de cuatro instancias y un recurso al cerrar.
- Sin revisión visual nueva de enemigos, exportación o pruebas Web/móviles.
