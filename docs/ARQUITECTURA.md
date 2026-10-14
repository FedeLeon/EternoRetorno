# Arquitectura y organización del código

Estado revisado el **14/10/2026**. Esta página describe el código actual y los
siguientes pasos, por separado. [Decisiones históricas](architecture/EVOLUCION.md).

## Estructura actual

Limpieza del 14/10: los 184 módulos activos conservan rutas/UIDs. Se retiran
importadores anteriores y se comparte la geometría en `sketchbook_sheet_packer.gd`;
se simplifica la presentación de héroes a partículas a lápiz y dibujos estáticos.
Las poses enemigas, reglas y persistencia se mantienen. La cola activa conserva
314 trabajos; cartas mínimas y recortes estáticos tienen sus importadores propios.
[Archivos, decisiones, pruebas y límites](cleanup/2026-10-14.md). Las menciones
a importadores retirados en las secciones fechadas inferiores son históricas.

Arte mínimo de cartas del 14/10: `import_minimal_cards.gd` prepara 88 imágenes
individuales acotadas a 512×288 y publica juntas las referencias de
`data/card_art.json`. Se reutiliza `ui/components/card_art.gd` en todas las vistas;
no se altera la fábrica, las reglas o los guardados. Los motivos y procedencia
se documentan aparte; la cola de migración deja fuera las cartas sustituidas y se retiran
los importadores históricos. [Assets y pruebas](cards/minimal/README.md).

Primeros planos de héroes del 14/10: `hero_cut_in.gd` selecciona ocho PNG
estáticos; `comic_cut_in.gd` admite ilustración inmóvil con partículas detrás.
La reproducción de cuadrículas se conserva para los enemigos, sin duplicar el
componente ni modificar reglas. Se retiran los montadores exclusivos de las
secuencias de héroes; `import_static_cutins.py` valida y copia originales RGBA.
[Assets, limpieza y pruebas](comic/static/README.md).

Conversión integral completada el 14/10: `sketchbook_sheet_packer.gd` comparte
recortes alfa y anclajes; los importadores de actores, assets y derivados están
en `scripts/`, sin resolver combate ni guardar partidas. `enemy_sprite.gd`
calcula el tamaño de celda real para admitir atlas de 128 o 256 píxeles sin
cambiar el tamaño externo; las métricas conservan el apoyo durante daño/cenizas.
El primer plano admite cuatro poses por enemigo cuando el catálogo lo indica.
La presentación de carrera comparte escala con el atlas clásico nuevo.
[Fuentes, cola y validación actual](art_direction/migration/README.md).

Campamento crepuscular del 13/10: `ui/screens/base_camp_screen.gd` compone
edificios y solares independientes desde el perfil recibido; no modifica reglas.
`campfire.gd` admite atlas/velocidad/estilo por instancia y comparte por defecto el fuego dibujado aprobado
con otras pantallas. El suelo ya no necesita máscaras de construcción
sobre la pintura; `camp_dusk.gdshader` solo presenta ambiente.
[Composición, assets y validación](base_camp/dusk/README.md).

Interiores del 13/10: `building_hero_picker.gd` comparte la galería 2×2 entre
mercado, herrería, iglesia y refugio, con padre opcional para reconstrucción
local. `refuge_portrait.gd` recibe tamaño de tarjeta sin cambiar sus valores
predeterminados para otras pantallas. Fondos y navegación permanecen en sus
pantallas; ninguna compra o configuración se calcula en estos componentes.
[Assets y validación actual](base_camp/interiors/README.md).

Auditoría visual posterior: `scripts/audit_visual_style.py` verifica hashes de
arte aprobado, resuelve los edificios dinámicos actuales y agrupa recursos por
28 vistas/superficies. `audit_visual_contact_sheets.py` crea previews temporales
sin modificar imágenes del juego. No se cambian módulos runtime en esta revisión.
[Inventario actual, incluidos mapas/mazmorras e iconos](art_direction/2026-10-13/review/README.md).

Elenco del 13/10: 184 módulos en `src/`. Cuatro protagonistas; los dos
personajes retirados ya no tienen contenido ni módulos de presentación.
`rules/content_migration.gd` depura referencias inexistentes antes de migraciones
de progresión y logros, sin guardar ni conceder premios. `game.gd` conserva la
carga, RNG y checkpoint. [Decisión y compatibilidad](cleanup/2026-10-13.md).
Galerías, primeros planos, actores y escenarios adoptan el sketchbook. `hero_cut_in.gd` activa el modo de partículas dibujadas de la presentación compartida, sin modificar reglas ni guardados.
[Alcance visual actual](art_direction/2026-10-13/README.md). [Auditoría de rutas, atlas y conversión completada](art_direction/2026-10-13/review/README.md).

Revisión técnica del 09/10: **184 módulos**; `main.gd` 549 líneas, `game.gd`
369. Cálculos/enlaces pasan a reglas propias y widgets/tema a `ui_factory.gd`.
La caché JSON central entrega copias independientes; persistencia protege el
respaldo recuperado. [Cambios, límites y pruebas actuales](architecture/TECHNICAL_REVIEW_2026_10_09.md).

Pulido posterior del 08/10: 180 módulos en `src/`; `main.gd` se conserva en 593
líneas, `game.gd` queda en 442 y `ui/combat_flow.gd` en 156. Las animaciones
enemigas y su reproducción se extraen a colaboradores de presentación.
[Estructura y validación de esta entrega](whole_game_polish/README.md).

Auditoría 08/10: los 176 módulos de `src/` tienen consumidores desde la entrada
del juego. Se retiró únicamente el helper sin llamadas `main.scroll_area`;
`main.gd` queda en 593 líneas y `game.gd` en 441. No se reorganizan sistemas ni
se cambian UIDs/guardados durante la [limpieza actual](cleanup/2026-10-08.md).

| Ubicación | Responsabilidad |
| --- | --- |
| `main.tscn`, `src/main.gd` | Entrada, navegación, composición de pantallas y helpers de UI todavía compartidos |
| `src/game.gd` | API pública de acciones, estado de aventura/perfil y puntos de guardado |
| `src/data/json_catalog.gd` | Fuentes JSON cacheadas, diagnósticos y copias independientes; sin estado de partida |
| `src/ui/components/ui_factory.gd` | Tema/widgets reutilizables; la fachada conserva navegación y bloqueo de acciones |
| `src/content.gd`, `data/` | Catálogos y diseño declarativo de la mazmorra |
| `src/dungeon.gd` | Fachada de definición/generación de pisos y coordenadas compatibles con guardados anteriores |
| `src/map_geometry.gd` | Geometría pura de la espiral y conexiones curvas; sin mutación de partidas |
| `src/rules/dungeon_generator.gd` | Grafo acíclico, distribución de salas y encuentros mediante RNG recibido |
| `src/rules/dungeon_progression.gd` | Transición entre pisos conservando el progreso de la aventura; no guarda ni concede victoria |
| `src/save_store.gd` | Persistencia atómica, versión y copia de respaldo |
| `src/rules/content_migration.gd` | Depura contenido inexistente al cargar, sin guardar ni conceder premios |
| `src/rules/` | Reglas de progresión, herrería, tesoros, sinergias y consumibles |
| `src/ui/screens/` | Composición de pantallas; selección, reliquias, mapa, mercado, herrería, tesoro, recompensa, bolsa y combate |
| `src/ui/components/` | Cartas, barras, números, paneles, botones y elementos reutilizables |
| `src/ui/combat_flow.gd` | Coordinación de una acción de combate resuelta con sus animaciones |
| `src/ui/forge_navigation.gd` | Construcción, acceso y acciones de la herrería |
| `src/audio/` | Gestor persistente, contextos y efectos de acciones resueltas; RNG independiente, sin reglas ni persistencia |
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

## Ampliación de combate — 30/09/2026

`data/enemy_expansion.json` amplía el catálogo a través de `content.gd`; los
pisos siguen usando el generador existente. `hero_cut_in.gd` configura 16
cuadros y encuadre para ataque/defensa sobre `comic_cut_in.gd`.
`hero_comic_fx.gd` separa las luces y partículas analíticas de la reproducción;
no usa RNG del juego, reglas ni persistencia. El reloj visual compartido limita
el avance de héroes a un cuadro por renderizado para evitar saltos ante una pausa
de carga. `import_hero_motion.gd` empaqueta 30 atlas 4×4 de 3072×2048 con recorte común;
los importadores anteriores delegan en él. Desde el 05/10 consume cuatro hojas
HD 2×2 por secuencia en `docs/comic/hd/sources/`. El utilitario
`prepare_hero_hd_refs.gd` recompone referencias desde las fuentes históricas,
sin generar poses. [Formato vigente y procedencia](comic/hd/README.md).
`scripts/import_combat_expansion.gd` empaqueta los recursos; reutiliza
`enemy_art_import.gd` para enemigos. No agrega responsabilidades a `main.gd`
ni a persistencia. [Detalles y fuentes](combat_expansion/README.md).

## Acoplamiento que todavía existe

La extracción es incremental: `combat_screen.gd` y otras fábricas reciben el
controlador `ui` y reutilizan sus helpers; no son escenas completamente autónomas.
`items.gd` recibe el juego y usa sus operaciones de robo y dueño de carta.
Eso evita duplicar reglas, pero es un límite pendiente de mejorar, no una
separación completa. `main.gd` y `game.gd` siguen por encima de la guía de tamaño.

## Próximas extracciones recomendadas

En orden de prioridad, al trabajar en esas funciones:

1. Continuar separando las composiciones restantes de pantalla mediante
   instantáneas y señales, como mapa, tesoros y encuentros ya extraídos.
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


## 22/09/2026 — Pantalla de descanso extraída

`rest_screen.gd` presenta fondo, héroes sentados, PV y tarjetas de opciones a
partir de una instantánea. `main.gd::room_view` conecta sus señales; `Game.rest`
conserva curación, mejora y checkpoint. Se retiró la composición anterior de
descanso de main.gd. Recursos y pipeline: [docs/rest](rest/README.md).


## 22/09/2026 — Luz de fogata compartida

`src/presentation/firelight.gd` adjunta un ShaderMaterial independiente a cada
pose sentada. Selección y descanso comparten assets y shader; no duplican el
cálculo visual ni modifican estado de juego. `src/campfire.gd` conserva su rol
de animar llama y chispas con el nuevo atlas de ocho cuadros.


## 22/09/2026 — Galería compartida de edificios

`building_hero_picker.gd` compone las seis tarjetas con `refuge_portrait.gd`.
Mercado y herrería alternan galería/detalle con selección temporal vacía al
entrar. Los controladores existentes conservan transacciones y navegación.
Retirado `hero_category.gd` y su UID al desaparecer sus últimos consumidores;
no se modifican IDs de héroes, recursos de guardado ni reglas.


## Expansión del campamento — 22/09/2026

Implementado, no propuesta: Iglesia y Expediciones tienen pantallas propias en
`ui/screens/church_screen.gd` y `expeditions_screen.gd`, coordinadas por
`ui/camp_expansion_navigation.gd`. Comparten `components/camp_offer_card.gd`
y reutilizan `building_hero_picker.gd` para la galería de héroes.

Los catálogos viven en `data/camp_expansion.json`; construcción/transacciones en
`rules/camp_expansion.gd`, contratos en `rules/expeditions.gd` y especializaciones
en `rules/specializations.gd`. Los módulos de reglas no guardan: `game.gd` añade
la API `camp_action`, los eventos de progreso, liquidación y snapshots y conserva
los checkpoints. Se extrajo el resultado final a `ui/screens/run_result_screen.gd`
al ampliarlo; `main.gd` solo enruta y delega estas vistas.

Próximo paso recomendado, aún no implementado: extraer la coordinación de fin de
aventura y transiciones de sala de `game.gd` si vuelven a crecer. No trasladar
recompensas ni resolución de combate a pantallas por reducir líneas artificialmente.


## Reliquias de aventura — 22/09/2026

Implementado: el catálogo adicional está en `data/elite_relics.json`;
`rules/run_relics.gd` concentra sorteo, adquisición y condiciones de bonos,
sin guardar ni depender de la UI. `game.gd` conserva los puntos de aplicación
y checkpoint. `presentation/relic_art.gd` resuelve el atlas legado o la textura
individual. `ui/components/elite_relic_reward.gd` presenta la reliquia ya concedida.

La barra de combate y el grupo del mapa reciben la misma lista de reliquias
iniciales y halladas. `run.reward_relic` es un recibo visual persistido, no una
segunda recompensa ni una cola de concesiones. Abrir/cerrar pantallas nunca
aplica efectos de adquisición. Las partidas anteriores sin el campo son válidas.

## Dos pisos y generación aleatoria — 22/09/2026

`data/dungeons.json` define nombres y grupos de enemigos por piso;
`data/forest_enemies.json` agrega siete enemigos mediante `content.gd`. La generación
se separa de `game.gd`: este último solicita un grafo, confirma la transición y guarda.
Los nodos completos (conexiones, posiciones y encuentros) permanecen en el guardado.
Solo se genera al empezar la aventura o entrar al siguiente piso, nunca al cargar.
`floor`, `floor_count` y `rooms_completed` son campos aditivos; sin `floor_count`
una aventura antigua termina como antes en su primer guardián.

`battle_background.gd` selecciona escenarios por piso; mapa, descanso y tesoro
reciben nombre/fondo por composición. `enemy_sprite.gd` interpreta los recuentos
de poses de `enemy_visuals.json`; la presentación no altera las reglas del ataque.
`scripts/import_forest.gd` convierte fuentes en atlas y recursos finales;
[procedencia y contrato de los recursos](forest/README.md).
`data/dungeon_floor1.json` fue retirado el 07/10/2026: el diseño fijo anterior
no se utiliza; los guardados antiguos ya contienen sus nodos. Se conservan
las coordenadas de respaldo en `dungeon.gd` para esos guardados.

## Porcentajes temporales de combate — 22/09/2026

- `data/support_cards.json`: ampliación independiente de 24 cartas, fusionada por
  `content.gd`. IDs existentes y mazos iniciales intactos. El precio controla el
  requisito de compra mediante `camp_progression.gd`, igual que el catálogo anterior.
- `rules/combat_modifiers.gd`: cálculo de fuerza/debilidad/fractura, expiración y
  no acumulación. Trabaja sobre diccionarios; no depende de nodos UI ni guarda.
- `game.gd`: aplica modificadores antes de impactos, los limpia al iniciar turno
  y combate, obtiene intenciones efectivas y confirma cada acción antes de animar.
- `ui/components/combat_modifier_badges.gd`: representación y diálogos de estados;
  las intenciones muestran los mismos valores efectivos usados por las reglas.
- Tres campos opcionales por unidad (`strength_pct`, `weak_pct`, `fracture_pct`),
  ausentes equivalen a cero. Se conservan al reanudar combate, no pasan al perfil.
- Arte independiente en el manifiesto existente, importador acotado y procedencia
  en [docs/cards/support](cards/support/README.md). No se concentra lógica en main.gd.

## Variedad de la cripta y empaquetado compartido — 22/09/2026

- `data/crypt_enemies.json` agrega seis enemigos sin ampliar el catálogo original.
- `data/dungeons.json` configura `distinct_common` y `min_stage`: mezcla de tipos
  y etapa mínima por enemigo, interpretadas por `rules/dungeon_generator.gd`.
  El bosque conserva su configuración; no se regenera ningún grafo al cargar.
- `scripts/enemy_art_import.gd` extrae el empaquetado que estaba dentro de
  `import_forest.gd`. Los importadores de bosque y cripta ahora delegan allí;
  responsabilidades y rutas finales permanecen separadas por contenido.
- Presentación reutiliza `enemy_sprite.gd` y `enemy_cut_in.gd`; no se suman reglas
  ni escritura de guardados a estos componentes.
- [Procedencia, fuentes y pruebas](enemies/crypt_expansion/README.md).

## Ampliación de variedad del bosque — 22/09/2026

- Se amplía `forest_enemies.json`, sin crear reglas ni pantallas paralelas.
- El piso 2 también usa `distinct_common` y `min_stage`; conserva mapas guardados.
- Importador acotado `import_forest_expansion.gd` reutiliza `enemy_art_import.gd`.
  Sus fuentes y manifiesto están en `docs/forest/expansion/`; los destinos siguen
  las carpetas compartidas de animaciones y ataques en primer plano.
- Se extienden las pruebas de bosque existentes para cobertura y presentación.

## Orden visual del fin de turno — 22/09/2026

`game.gd` entrega `resolved_enemy_blocks` como recibo transitorio de acciones
realmente ejecutadas; las reglas conservan el orden bloqueo → daño y guardado
previo a animaciones. `ui/combat_flow.gd` espera cenizas → muestra bloqueo →
presenta ataque. `status_effects.gd` conserva un escudo oculto a cero para poder
mostrar ganancias en vivo. No cambia el formato de guardado.

## Cierre voluntario de aventuras — 22/09/2026

`src/ui/pause_navigation.gd` compone pausa y confirmación de cierre, extraídas de
main. `game.end_adventure()` valida, llama al cierre existente sin victoria y
persiste. Contratos y premios siguen en las reglas de expediciones, nunca en
el diálogo. No introduce fases ni campos de guardado nuevos.

## Cuadros de ataque en primer plano — 22/09/2026

`comic_cut_in.gd` admite una cuadrícula opcional mediante AtlasTexture; el mismo
reloj gobierna cuadros y entrada/salida. `hero_cut_in.gd` configura 2×2 solo para
ataques de héroes. Defensa/enemigos mantienen un cuadro. No se toca resolución,
persistencia ni coordinación de golpes. Importador y fuentes en
`docs/comic/motion/` separados de assets finales; recorte común entre poses.

## Inicio temporal para pruebas — 22/09/2026

`ui/development_start.gd` compone el selector y delega al controlador.
`main.begin_on_floor` coordina reemplazo y navegación; `game.new_run` valida
el piso opcional antes de mutar estado y genera directamente su mapa.
Valor por defecto 1, sin campos nuevos de guardado ni premios simulados.

## Política de importación — 22/09/2026

`scripts/optimize_texture_imports.py` configura compresión y límites por familia
solo en importadores. Fuentes intactas, informe separado en docs/quality.
La exclusión explícita de cómics estáticos reemplazados conserva las cargas
dinámicas de cartas, enemigos y variantes de equipo. No cambia el runtime.

## Tema gótico compartido — 23/09/2026

`ui/components/dark_skin.gd` concentra el marco escalable y foco. Adaptadores
`button_skin.gd` y `modal_frame.gd` reutilizan dos texturas en assets/ui/dark.
Las pantallas mantienen acciones y reglas; el cambio solo afecta presentación.
Los IDs históricos de estilos se mantienen por compatibilidad.

### Alineación visual de héroes (23/09/2026)

`presentation/hero_grounding.gd` mantiene el borde inferior de los cuadros de
acción alineado con el reposo mediante `AnimatedSprite2D.offset`. Se conecta desde
`hero_idle.gd` para los seis actores existentes y responde a sustituciones de
atlas de herrería. No modifica recursos, posiciones de combate ni reglas.

### Fondo de inventario (23/09/2026)

`ui/components/inventory_background.gd` compone el fondo compartido de consulta
 de mazo y bolsa. No captura entradas ni depende del estado de la aventura.
Asset, procedencia e importación documentados en `docs/inventory/README.md`.

### Consulta del mazo extraída (23/09/2026)

`ui/screens/deck_screen.gd` contiene encabezado, contadores y galería de consulta.
`main.deck_view` delega esta composición y conserva la navegación de vuelta;
`card_upgrade_screen.gd` sigue siendo la vista de mejora independiente.

### Auditoría de limpieza (23/09/2026)

Se retiraron recursos sustituidos y auxiliares sin consumidores, sin cambiar
los límites entre reglas, presentación y persistencia. Véase el
[informe e inventario](cleanup/2026-09-23.md). `main.gd` y `game.gd` siguen
por encima de la guía de tamaño; próximas extracciones deben centrarse en
responsabilidades completas, acompañadas de pruebas de navegación y combate.

### Colección y logros (30/09/2026)

La colección sale de `main.gd` hacia `ui/screens/collection_screen.gd`, con
instantáneas preparadas por `ui/collection_navigation.gd`. La pantalla es de
consulta: no recibe condiciones secretas ni modifica partidas. El catálogo
vive en `data/achievements.json`; `rules/achievements.gd` acumula y migra estado.
`game.gd` sincroniza logros al cargar y antes del checkpoint atómico existente.
Los recibos de aventura evitan contar dos veces al reabrir o cambiar de piso.
No se cambia la versión del guardado ni se añaden recompensas de poder.

### Encuentros ilustrados (30/09/2026)

`ui/screens/encounter_screen.gd` reemplaza la composición de eventos de
`main.gd::room_view`. Recibe ID, textos y disponibilidad de la ofrenda; emite
señales de elección y menú. `Game.choose_event` conserva validación, efectos y
checkpoint. La pantalla no consulta ni modifica el guardado.

`assets/shaders/encounter_atmosphere.gdshader` anima regiones calibradas de tres
fondos en `assets/encounters/`. No mueve el cuadro ni el escenario completo.
La extracción de encuentros está terminada; sus reglas permanecen en Game.

### Encargados del campamento — 30/09/2026

`ui/components/attendant_dialogue.gd` comparte el globo ambiental entre mercado,
herrería, iglesia y expediciones. Frases en `data/camp_dialogue.json`; reloj y RNG
visuales independientes de Game y del guardado. Vive dentro de la pantalla,
ignora entradas y se libera con ella. Iglesia reutiliza la galería derecha de
`building_hero_picker.gd`; contratos y especializaciones conservan el componente
`camp_offer_card.gd`, adaptado al espacio disponible. No se añaden reglas a la UI.

### Audio y opciones — 05/10/2026

`audio/audio_manager.gd` vive bajo el controlador y permanece cuando se reconstruyen
las pantallas. Lee `data/audio.json`, administra buses y voces, fundidos musicales
y sonidos de botones. `audio/screen_audio.gd` selecciona ambientes por pantalla y piso;
`audio/battle_audio.gd` asigna efectos por familia de héroe/enemigo. La presentación
los reproduce después de que Game confirma la acción: no consumen RNG de la aventura,
no resuelven impactos ni escriben guardados.

La vista de opciones sale de `main.gd` a `ui/screens/options_screen.gd`. El controlador
conserva `set_option` y el checkpoint existente; agrega música y efectos al diccionario
de ajustes sin migración. Rutas y recursos de descarga en [Audio](audio/README.md).

## Ampliación de aventura — 07/10/2026

Extracciones terminadas, sin cambiar la API pública ni los IDs/UIDs existentes:

| Módulo | Líneas actuales | Responsabilidad |
| --- | ---: | --- |
| `src/main.gd` | 631 | Composición/navegación; delega fondos y pantallas nuevas |
| `src/game.gd` | 489 | Fachada, estado y checkpoints; delega ciclo, turno y premios |
| `rules/run_lifecycle.gd` | 74 | Crear/finalizar aventura y conservar resumen |
| `rules/combat_turns.gd` | 75 | Inicio/fin de turno e intenciones |
| `rules/combat_rewards.gd` | 83 | Fin de combate y elección/rechazo de premio |
| `rules/adventure_extensions.gd` | 72 | Dificultad, condición, fases, roles, vínculos y estadísticas |
| `rules/expanded_events.gd` | 51 | Encuentros propios y modificaciones de mazo |
| `rules/combat_preview.gd` | 31 | Predicción usando copia aislada del motor de reglas |
| `ui/screen_backgrounds.gd` | 56 | Composición compartida de fondos |
| `ui/components/card_drag.gd` | 111 | Gesto mouse/táctil, preview y objetivos visuales |

Pantallas `run_setup`, `bonds`, `event_cards` y opciones ampliadas viven en archivos
propios. `presentation/preferences.gd` entrega preferencias a efectos, sin persistir.
El arrastre solicita una acción normal al controlador: no descuenta energía por su
cuenta. La vista previa usa `Game(false)` y copia perfil/aventura/RNG; los premios de
esa copia no afectan el perfil real. Las reglas extraídas nunca llaman checkpoint.

La siguiente extracción sigue siendo la resolución de cartas de `game.gd` y la
navegación de salas de `main.gd`; ambos aún superan la guía de tamaño. No se hizo
una migración masiva. Guardados con uno/dos pisos conservan su límite; los nuevos
contienen tres. [Alcance y validación](expansion_2026_10/README.md).

## Combate táctico y actores detallados — 07/10/2026

Estado actual: `main.gd` 638 líneas, `game.gd` 481. Se extrajo la resolución de
cartas a `rules/card_actions.gd`; `card_upgrades.gd`, `combat_depth.gd`,
`relic_sets.gd` y `travel_encounters.gd` mantienen reglas y estado serializable.
`Game` valida/delega y confirma el guardado; la UI reproduce recibos de impactos,
incluidos los preparados que se ejecutan al comenzar el siguiente turno.

Pantallas nuevas en archivos propios: entrenamiento, bestiario y mercader.
`training_navigation.gd` conserva la instancia original y usa otra sin persistencia,
con copia del perfil; salir restaura exactamente la referencia original. Avisos
`components/tactical_badges.gd` y lector `reading_dialog.gd` solo presentan datos.
La colección consume snapshots enriquecidos de historia.

`presentation/detailed_hero.gd` reemplaza el actor de batalla, conserva la interfaz
`sprite`, `play_once`, `set_fallen` y usa doce cuadros de 256 px por acción.
Equipo se presenta mediante shader independiente para los dos niveles; las variantes
clásicas de atlas permanecen para campamento y herrería. Importación y métricas en
`scripts/import_detailed_heroes.gd` y `data/detailed_heroes.json`. Los actores,
fundidos y partículas no calculan daño, premios o persistencia.

Compatibilidad: `tactics_version`, `upgrade_variant`, bestiario e historia ampliada
son opcionales. Los gráficos nuevos pueden representar una aventura antigua, sin
cambiar su grafo, nivel de equipo o efecto de mejoras anteriores.

Propuesta futura, aún no realizada: extraer los helpers generales/navegación restantes
de `main.gd` y acciones de sala de `game.gd` cuando vuelva a crecer esa responsabilidad.
[Reglas, assets y validación de esta entrega](combat_depth_2026_10/README.md).

## Limpieza de recursos — 07/10/2026

Sin reorganizar código de ejecución ni modificar IDs/UIDs activos. Se retiraron
los importadores exclusivos de marcos/botones sustituidos y el generador inicial
que ya no reproducía los enemigos vigentes. `data/content.json` es la fuente
declarativa de los datos base; `additional_cards.json` era una copia exacta de
sesenta definiciones ya incluidas allí. Las ampliaciones conservan sus archivos.
El grafo se genera únicamente con `dungeon_generator.gd` y `data/dungeons.json`.

Las referencias de cuatro poses del proceso HD son salidas regenerables de
`prepare_hero_hd_refs.gd`, ignoradas por Git. Fuentes finales, prompts y procedencia
permanecen en `docs/comic/hd/`; los treinta atlas de primer plano siguen activos.
[Inventario, criterios y pruebas de esta limpieza](cleanup/2026-10-07.md).

## Pulido y objetivos — 07/10/2026

Extracciones terminadas: `rules/room_actions.gd` concentra transacciones de salas
sin guardado; `ui/room_navigation.gd` construye tesoro, descanso y encuentros.
`main.gd` delega composición y Game conserva API/checkpoint. Las pantallas nuevas
proyectos/reliquias de guardián y el modal de entrenamiento tienen archivos propios.

Nuevas reglas: `risk_cards`, `boss_mechanics`, `boss_rewards`, `adventure_choices`,
`enemy_coordination`, `building_projects`, `deck_analysis`, `training_config`,
`combat_telemetry`; `polish_actions` despacha validaciones. Presentación:
`action_motion`, `battle_projectile`, `impact_feedback`. La capa de equipo
`equipment_layers` se retiró en la corrección visual posterior de este día.
`combat_input` y `map_room_prompt` coordinan entrada y confirmación sin conceder
premios ni guardar. `polish_theme` comparte tipografía y estilos.

La versión de estas reglas se guarda por aventura. Assets de acciones son atlas
por héroe/acción; caché máxima de dos héroes. No se mezcla arte/reglas/persistencia.
El tamaño actual es 598 líneas en main y 441 en Game; siguiente extracción
recomendada es resolver enlaces en un módulo de reglas, manteniendo la fachada.
[Alcance, procedencia y pruebas](polish_2026_10/README.md).

## Efectos de batalla mediante iconos — 07/10/2026

Extracción terminada de los carteles de `tactical_badges.gd`:
`ui/components/battle_effect_snapshot.gd` lee estado confirmado y prepara
descripciones; `battle_effect_strip.gd` solo distribuye iconos/valores y abre
consulta. `enemy_intent.gd` integra la tira junto a las intenciones compactas;
`combat_screen.gd` la compone también en héroes y adapta la altura de vida.

`data/battle_effects.json` contiene títulos/textos; artwork separado en
`assets/battle_effects/`. `combat_modifier_badges.gd` entrega datos en vez de
crear botones de porcentaje. `status_effects.gd` conserva la API del bloqueo
activo requerida por `card_impacts.gd`; veneno pasa a la tira común. El componente
`boss_objective.gd` prepara la acción del modal, delegando transacción/checkpoint
a Game. Ningún componente calcula daño ni concede efectos/recompensas.

Arte actualizado el 08/10: `scripts/import_battle_effects.gd` delega a
`import_refined_effect_icons.gd`, que normaliza originales PNG transparentes de
`docs/battle_effects/refined/sources/`. Es una herramienta de desarrollo separada
de presentación/reglas; conserva los 36 IDs y sus rutas de runtime. Los SVG
minimalistas previos quedan documentados como fuentes históricas.

No se cambian persistencia, IDs/UIDs existentes ni responsabilidades de reglas.
Main/Game mantienen sus tamaños; las extracciones futuras propuestas anteriormente
siguen pendientes. [Sistema, procedencia y validación](battle_effects/README.md).

### Corrección de capas de equipo — 07/10/2026

Se elimina la instanciación y API privada de `equipment_layers` en
`presentation/detailed_hero.gd`. El módulo y su UID no tienen otros consumidores
activos y se retiran. El actor conserva `gear`, `apply_gear` y el shader de nivel;
`equipment_badges.gd` sigue presentando las mejoras en el HUD. No cambia la
arquitectura de reglas, persistencia ni las interfaces de reproducción del actor.

### Navegación del bestiario desde Inicio — 07/10/2026

Se reutiliza `bestiary_screen.gd`, sin pantalla nueva. `main.home` registra Inicio
como origen en `return_screen`; el acceso de `base_camp_screen.gd` registra Campamento.
El encabezado delega en `main.back`, que conserva el origen. No cambia el catálogo,
las reglas de descubrimiento ni la persistencia.

## Generación de formaciones — 08/10/2026

`rules/enemy_formations.gd` extrae la elección del grupo de `dungeon_generator.gd`.
Recibe grafo, sala, catálogo, contador temporal y RNG; consulta antecesores y
formaciones cercanas. No lee perfil, guarda, calcula daño ni cambia mapas cargados.
La fachada `dungeon.gd` y las transiciones mantienen sus APIs.

`ui/screens/run_setup_screen.gd` mantiene en memoria la selección previa mediante
ButtonGroup y siete tarjetas. Confirma preferencias únicamente al iniciar; reglas
de dificultad/condición y persistencia permanecen en sus colaboradores anteriores.

## Geometría de mapa compartida — 08/10/2026

El generador delega posiciones en `map_geometry.gd` y guarda la marca opcional de
espiral con cada nodo nuevo. La pantalla consulta el mismo módulo para muestrear
curvas y comprime sus coordenadas igual que las salas. No cambia relaciones,
permisos de navegación ni mapas cargados. Los nodos anteriores conservan su
presentación recta y el fallback de doce salas en `dungeon.gd`.

## Aproximación de actores cuerpo a cuerpo — 08/10/2026

`presentation/melee_motion.gd` encapsula clasificación visual y traslado temporal
sin mover barras o controles del objetivo. Conserva/restaura el padre, coordenadas,
escala y orden del actor. `card_impacts.gd` coordina la visita, la pose, el impacto
confirmado y el regreso, con HD simultáneo. Resolución, energía y checkpoint siguen
en las reglas/Game antes de estas animaciones. Los proyectiles mantienen su módulo.

## Cinemáticas y pulido integral — 08/10/2026

Extracciones terminadas:

- `presentation/cinematic_player.gd`: reproducción ilustrada sin mutación de juego;
  `ui/cinematic_navigation.gd`: entradas, descubrimientos y restauración de contexto;
  `ui/screens/cinematics_screen.gd`: galería. Catálogo en `data/cinematics.json`.
- `audio/audio_mix.gd`: limitador y reducción temporal de música, independiente
  del RNG de aventura y del volumen persistido.
- `presentation/impact_burst.gd`, `actor_attack_trail.gd` y `battle_atmosphere.gd`:
  presentación local, duración acotada y opciones de efectos respetadas.
- `ui/components/message_toast.gd` y `section_header.gd`: mensajes/títulos legibles
  y compartidos; el helper de encabezado del orquestador solo delega.
- `data/cinematic_enemies.json` amplía el catálogo mediante la misma fachada
  `content.gd`; IDs y guardados anteriores permanecen válidos.

El final de jefe se marca y guarda en el controlador **antes** de reproducir;
las cinemáticas no conceden premios. [Auditoría y propuesta futura](cinematics/AUDITORIA.md).
No se convierte esta entrega en una reorganización masiva: los dos archivos
más grandes siguen siendo `main.gd` y `game.gd`, mientras los módulos nuevos
permanecen separados por responsabilidad.

## Revisión de composición — 08/10/2026

Las pantallas de mazo, mejora, decisiones de cartas, vínculos, mercader y resultado
conservan archivos propios. `run_result_screen.gd` compone el resumen confirmado
con métricas y detalles desplazables, sin conceder premios. `section_header.gd`
acepta acción/ancho opcionales y `inventory_background.gd` un padre opcional;
sus valores predeterminados conservan los consumidores existentes.
No se añadieron responsabilidades a `main.gd` ni cambios de reglas/persistencia.
[Decisiones visuales y validación actual](ui_layout/README.md).

## Pulido de acciones y consulta — 08/10/2026

`presentation/enemy_motion.gd` contiene perfiles y tiempos visuales;
`enemy_action_playback.gd` reproduce daño confirmado por enemigo/objetivo.
`rules/combat_turns.gd` agrega un recibo transitorio a `game.resolved_enemy_hits`
después del cálculo existente; no cambia reglas ni lo introduce en el guardado.
`support_feedback.gd` y `map_route_flow.gd` son efectos locales con opciones
respetadas, sin RNG del juego. Bestiario conserva fábrica propia y copia de
descubrimientos para filtrar sin mutaciones. Seis definiciones adicionales se
fusionan desde `data/polish_enemies.json`; los mapas cargados no se regeneran.
Audio mantiene mezcla/contextos separados y RNG privado; los arreglos son
recursos Ogg normales. [Sistemas, fuentes y límites](whole_game_polish/README.md).

## Geometría versionada y planos de relato — 08/10/2026

`map_geometry.gd` conserva centros legados y añade geometría 2; el generador guarda
`layout_version` en mapas nuevos y ordena conexiones alternativas. `map_screen.gd`
adapta espirales anteriores en copia profunda sin modificar partidas. Los
capítulos de `data/cinematics.json` tienen `image` opcional y el presentador
resuelve cambio/fundido/cámara; no concede premios ni guarda. Duración de viñeta
configurable por adaptador, conservando el valor anterior como predeterminado.
El taller permanente se compone en la pantalla de campamento, con navegación
al sistema de proyectos existente, sin nueva construcción/regla/persistencia.
[Archivos, assets y validación](presentation_refinements/README.md).

## Extracciones técnicas — 09/10/2026

`rules/combat_stats.gd` y `rules/synergy_actions.gd` reciben juego para calcular
y resolver mediante colaboradores existentes; no escriben guardados. La fachada
conserva APIs y checkpoint tras acciones aceptadas. `ui_factory.gd` no recibe
`game` ni el controlador; recibe un padre visual y callbacks. `json_catalog.gd`
centraliza IO declarativo con copias profundas, invalidación y diagnósticos.
La validación de contenido precede a regresiones. [Análisis y pendientes](architecture/TECHNICAL_REVIEW_2026_10_09.md).

## Elenco visible y dirección artística — 13/10/2026

`rules/hero_roster.gd` concentra los cuatro IDs elegibles. No elimina contenido ni
limita la resolución de aventuras legadas; UI y ofertas nuevas consultan esta
política. Migración de contratos recibe el estado de aventura para preservar
selecciones en curso. `refuge_portrait.gd` recorta una hoja sketchbook compartida;
SVG de marcos mantiene sus márgenes y añade borde irregular discreto. La conversión
de actores/escenarios es pendiente y no se simula con filtros. Pruebas aisladas
por suite mediante XDG_DATA_HOME. [Entrega y alcance](art_direction/2026-10-13/README.md).

## Metadata narrativa civil — 13/10/2026

`data/hero_lives.json` concentra una propuesta de mundo y cuatro vidas. La fachada
`content.gd` agrega `civilian` y lore sin renombrar IDs/clases ni calcular efectos.
Galerías reciben la ficha por argumento y muestran nombre/oficio; vínculos leen
sus voces. Las reglas no dependen de estos textos. Los guiones de cinematicas
conservan IDs y planos existentes. Retrato sin máscara del Pícaro independiente
de la hoja compartida, para preservar los otros tres dibujos. No agrega una
pantalla, tabla de guardado o sistema de trabajos/olvido. [Fichas y alcance](story/2026-10-13/README.md).

## Recursos según formato de tarjeta — 13/10/2026

`refuge_portrait.portrait(hero, compact)` separa cuatro rostros PNG compactos
de los cuerpos/crops verticales vigentes. Sigue siendo presentación: no calcula
reglas ni altera estado. Usa proporción centrada para caras y fallback de
recursos legados. Importador mecánico proporcional con fuentes excluidas de
exportación y pruebas de baseline. [Recursos y validación](portraits/2026-10-13/README.md).
