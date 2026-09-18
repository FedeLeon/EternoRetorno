# Arquitectura y organización del código

Estado revisado el **18/09/2026**. Esta página describe el código actual y los
siguientes pasos, por separado. [Decisiones históricas](architecture/EVOLUCION.md).

## Estructura actual

| Ubicación | Responsabilidad |
| --- | --- |
| `main.tscn`, `src/main.gd` | Entrada, navegación, composición de pantallas y helpers de UI todavía compartidos |
| `src/game.gd` | API pública de acciones, estado de aventura/perfil y puntos de guardado |
| `src/content.gd`, `data/` | Catálogos y diseño declarativo de la mazmorra |
| `src/dungeon.gd` | Encuentros por semilla y coordenadas compatibles con guardados anteriores |
| `src/save_store.gd` | Persistencia atómica, versión y copia de respaldo |
| `src/rules/` | Reglas de progresión, herrería, tesoros, sinergias y consumibles |
| `src/ui/screens/` | Composición de pantallas; selección, reliquias, mapa, mercado, herrería, tesoro, recompensa, bolsa y combate |
| `src/ui/components/` | Cartas, barras, números, paneles, botones y elementos reutilizables |
| `src/ui/combat_flow.gd` | Coordinación de una acción de combate resuelta con sus animaciones |
| `src/ui/forge_navigation.gd` | Construcción, acceso y acciones de la herrería |
| `src/presentation/` | Efectos visuales, viñetas compartidas (`comic_cut_in.gd`, adaptadores de héroes/enemigos) y selección de apariencia del equipo |
| `src/*_sprite.gd` | Animaciones de actores; se mantienen rutas/UIDs actuales |
| `assets/` | Recursos finales usados por el juego, agrupados por sistema |
| `docs/` | Documentación, prompts, procedencia y fuentes que permiten regenerar arte |
| `scripts/` | Importadores, herramientas locales y preparación/exportación explícita |
| `tests/` | Pruebas de reglas, compatibilidad, recursos e interfaz |
| `artifacts/` | Capturas y resultados temporales, ignorados por Git y exportación |
| `builds/`, `TestWeb/` | Entregables existentes; no son fuentes ni recursos del juego |

## Flujo y límites

1. Una pantalla solicita una acción al controlador.
2. `game.gd` valida y aplica reglas. Sus colaboradores en `rules/` no guardan.
3. El controlador de juego confirma el estado mediante `save_store.gd`.
4. El flujo de UI presenta el resultado y espera las animaciones.
5. La pantalla se reconstruye a partir del estado confirmado.

Cerrar el juego durante una animación no debe volver a conceder premios o
consumir cartas. Los efectos de ceniza, luz y movimiento no calculan daño.
Los módulos de presentación tampoco leen/escriben guardados.

La selección previa de héroes/reliquia solo vive en memoria. Una aventura nueva
empieza vacía; volver dentro de la preparación conserva la elección actual.
El grafo y las posiciones se guardan con la aventura; partidas legadas mantienen
su recorrido de 12 salas y nuevas aventuras reciben 28.

## Extracciones terminadas en esta limpieza

| Módulo | Líneas | Cambio |
| --- | ---: | --- |
| `main.gd` | 702 (antes 893) | Delega pantalla y secuencia de combate |
| `game.gd` | 550 (antes 586) | Delega objetivos y aplicación de consumibles; mantiene checkpoint |
| `ui/screens/combat_screen.gd` | 100 | HUD, actores, objetivos y mano |
| `ui/combat_flow.gd` | 99 | Resolución, guardado previo, animaciones y transición |
| `rules/items.gd` | 45 | Validación de objetivos y efectos de los ocho consumibles |

Los métodos públicos anteriores permanecen como delegaciones para conservar
llamadores y pruebas. No cambiaron IDs, formato de guardado ni reglas.

## Acoplamiento que todavía existe

La extracción es incremental: `combat_screen.gd` y otras fábricas reciben el
controlador `ui` y reutilizan sus helpers; no son escenas completamente autónomas.
`items.gd` recibe el juego y usa sus operaciones de robo y dueño de carta.
Eso evita duplicar reglas, pero es un límite pendiente de mejorar, no una
separación completa. `main.gd` y `game.gd` siguen por encima de la guía de tamaño.

## Próximas extracciones recomendadas

En orden de prioridad, al trabajar en esas funciones:

1. Extraer descanso/evento, mazo, colección y resultados a pantallas
   propias, pasando instantáneas y callbacks como en mapa y tesoros.
2. Extraer tema/helpers visuales de `main.gd` a componentes concretos, sin crear
   otra clase gigante con todos los helpers.
3. Separar resolución de combate y recompensas de `game.gd`, manteniendo allí
   la API pública y el checkpoint atómico. Hacerlo con pruebas de guardado y
   recompensas para impedir duplicaciones.
4. Reducir gradualmente la dependencia de fábricas respecto de `ui.game` y
   sustituirla por datos y señales. No hacer una migración masiva de escenas ahora.

No se recomienda reorganizar los sprites por estética de carpetas ni renombrar
IDs/UIDs; no resuelve la concentración de responsabilidades y aumenta el riesgo.

## Convenciones para el crecimiento

- Pantalla nueva, archivo propio; componentes reutilizables en `ui/components/`.
- Reglas en `rules/`; efectos en `presentation/`; persistencia en `save_store.gd`.
- Revisar responsabilidades cerca de 350–400 líneas. No fragmentar funciones
  pequeñas solo para cumplir un número.
- Un cambio incluye documento del sistema, historial y pruebas pertinentes.
- Conservar fuentes/procedencia útiles; capturas solo en `artifacts/`.
- No exportar APK/Web durante el desarrollo salvo petición explícita.
- Documentar por separado estructura existente, cambios completados y propuestas.

## Pantalla de recompensa extraída — 18/09/2026

`ui/screens/reward_screen.gd` compone fondo, HUD compartido y ofertas; mantiene
`game.choose_reward` como única operación de selección. `CombatHUD.show_energy`
permite reutilizar la barra sin mostrar el orbe fuera del combate.

## Ilustraciones defensivas — 18/09/2026

`presentation/hero_cut_in.gd` recibe héroe y tipo visual (`attack`/`defense`).
`ui/combat_flow.gd` selecciona el tipo según la carta ya resuelta; el componente
visual no consulta el juego ni modifica bloqueo/guardados. Assets finales en
`assets/comic/defense/`, prompts y procedencia en `docs/comic/defense.json`.

## Primer plano enemigo — 18/09/2026

La animación común se extrajo a `presentation/comic_cut_in.gd` para evitar
duplicar entrada, duración, transparencia y liberación. `enemy_cut_in.gd`
configura seis IDs visuales y entrada derecha; el adaptador de héroes conserva
su API. `game.resolved_enemy_attacks` entrega los índices ejecutados al flujo
visual; es transitorio, no forma parte del guardado.

## Acabado visual de cartas — 18/09/2026

`presentation/card_finish.gd` administra resplandor de enlaces y reflejo
individual; `card_view.gd` le entrega el marco y un booleano. RNG local visual,
sin acceso al juego ni guardados. `card_type_icons.gd` reúne los iconos inferiores
de ataque, bloqueo y cadena; `synergy_view.gd` conserva tooltips y selección.

## Presentación de actores — 18/09/2026

`presentation/hero_idle.gd` comparte reposo localizado entre los seis scripts
de héroes, incluidas sustituciones de atlas de herrería. `enemy_ash.gd` encapsula
muerte visual y limpieza de partículas; `enemy_sprite.gd` conserva el estado
fallen. Ambos usan shaders propios, sin reglas ni persistencia.

## Bolsa extraída — 18/09/2026

`items_screen.gd` y `item_popover.gd` presentan datos/acciones explícitos.
`ui/items_navigation.gd` prepara objetivos y ejecuta la API pública `use_item`.
El controlador principal delega; reglas de consumibles y guardado permanecen
en sus módulos actuales. La extracción de inventario ya está terminada.


## Resolución y presentación de impactos — 18/09/2026

- `rules/card_hits.gd`: impactos de cartas y respuestas de contraataque,
  detiene secuencias al caer atacante u objetivo; no guarda.
- `game.gd`: valida, consume carta/energía, resuelve fin de combate y guarda.
  Expone recibos transitorios ordenados de impactos, nunca persistidos.
- `presentation/card_impacts.gd`: reproduce los recibos con actores,
  barras y escudos, sin modificar reglas ni estado guardado.
- `ui/components/combat_tip.gd`: cuadro anclado compartido para consulta
  de bloqueo/intenciones, con cierre por toque externo.

Son extracciones implementadas; se mantiene pendiente la separación más
amplia del controlador de reglas descrita arriba.

## Insignias de equipo — 18/09/2026
`presentation/equipment_badges.gd` convierte la instantánea de equipo de los héroes en descripciones/texturas para `combat_hud.gd`. Combate y recompensa aportan los datos; el HUD reutiliza su cuadro de reliquias. No consulta el perfil ni aplica mejoras.

## Mejora de cartas — 18/09/2026
Extracción terminada: `ui/screens/card_upgrade_screen.gd` mantiene selección y vista previa sobre una copia del mazo. `main.gd::deck_view` delega este modo y conserva la consulta normal del mazo. La confirmación usa `game.rest` y el checkpoint existente; la pantalla no aplica reglas ni guarda.

## Categorías de héroes compartidas — 18/09/2026
`ui/components/hero_category.gd` presenta miniatura, nombre y marco de clase en mercado y herrería. Recibe datos y callback; conserva IDs de botones y no gestiona compras. Extracción completada desde `market_screen.gd`.

## Ambientación diurna — 18/09/2026
`assets/shaders/camp_day.gdshader` anima zonas del fondo del campamento. `main.gd::background` solo asigna el material; máscaras y movimiento permanecen en el shader, sin afectar reglas, guardados o hitboxes.

## Acciones de inicio — 18/09/2026
`ui/components/title_actions.gd` compone Salir y el engranaje de Opciones. Delega la navegación en el controlador y el guardado en `game.checkpoint`; distingue salida nativa y mensaje Web.

### Variación visual de ataques — 18/09/2026

`rules/card_hits.gd` incorpora el índice de golpe al recibo transitorio;
`presentation/card_impacts.gd` lo usa para reproducir una viñeta por golpe
sin calcular daño ni alterar su orden. `hero_cut_in.gd` mantiene la rotación
visual por héroe entre cuatro texturas, fuera de persistencia y del RNG de
juego. `combat_flow.gd` evita duplicar la introducción cuando reproduce recibos.
Los 18 PNG nuevos y sus prompts viven en `assets/comic/attacks/` y
`docs/comic/attacks/`, respectivamente. No se amplió `main.gd`.

## Refugio y mazos iniciales — 18/09/2026

Implementado: `rules/starter_decks.gd` valida repartos de básicas y compone
mazos; `game.configure_starter` guarda mediante checkpoint y `new_run` toma
la configuración del perfil. `ui/refuge_navigation.gd` prepara datos/callbacks;
`ui/screens/refuge_screen.gd` mantiene el borrador de edición y galería;
`ui/components/refuge_portrait.gd` encuadra los cómics existentes con AtlasTexture.
El nuevo campo opcional `profile.starter_attacks` no cambia IDs ni versión
de guardado ni el contenido de runs existentes. La pantalla no aplica reglas
ni escribe guardados. Detalles en `docs/refuge/README.md`.

## Carrera de héroes — 18/09/2026
`presentation/hero_run.gd` registra ocho cuadros en los SpriteFrames de cada
héroe y administra escala/inicio/fin; `combat_effects.leave_room` solo desplaza
mientras se reproduce el bucle. `hero_equipment.gd` conserva esa animación al
sustituir las acciones de equipo. Atlas finales pequeños separados en
`assets/heroes/running`; fuentes, prompts e importador documentados en
`docs/running/README.md`. Un ciclo visual por héroe compartido entre niveles
de equipo; variantes específicas por nivel pendientes. Sin reglas/guardados
en los componentes de presentación ni ampliación de main.gd.
