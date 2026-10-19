# Arquitectura actual

Estado revisado el **19/10/2026**. Esta guía describe los módulos presentes, sin
reconstruir las implementaciones retiradas. Las rutas de esta página son relativas
a la raíz del repositorio.

## Responsabilidades

| Capa | Archivos principales | Responsabilidad |
| --- | --- | --- |
| Orquestación | `src/main.gd` | Construir vistas y coordinar navegación/presentación. |
| Estado y fachada | `src/game.gd` | Validar acciones, mantener perfil/aventura y confirmar checkpoints. |
| Reglas | `src/rules/` | Resolver combate, recompensas, mazos y progresión. |
| Contenido | `src/content.gd`, `src/data/json_catalog.gd`, `data/` | Cargar y combinar catálogos con IDs estables. |
| Interfaz | `src/ui/screens/`, `src/ui/components/` | Presentar datos y recibir decisiones del jugador. |
| Navegación | `src/ui/*_navigation.gd` | Conectar pantallas, callbacks y acciones de la fachada. |
| Presentación | `src/presentation/` | Dibujos por acción, primeros planos y efectos visuales. |
| Audio | `src/audio/` | Eventos, contexto, reproducción y mezcla. |
| Persistencia | `src/save_store.gd` | Escritura atómica, archivo temporal y respaldo. |

La interfaz y los efectos visuales no calculan daño, conceden premios ni guardan.
La resolución de una acción aceptada y su checkpoint preceden a la presentación.
Los contadores o retrasos visuales no deben modificar el RNG de la aventura.

## Flujo de combate

`combat_screen.gd` compone actores, objetivos, barras, intenciones, mano y HUD.
`combat_flow.gd` coordina la presentación del resultado confirmado.
`hero_attack_playback.gd`, `card_impacts.gd` y `enemy_action_playback.gd` muestran
la acción sin recalcularla. Los cálculos pertenecen a los módulos de combate en
`src/rules/`; las recompensas se confirman mediante `combat_rewards.gd`.

`static_combat_actor.gd` usa un `TextureRect` y un PNG por estado: `idle`,
`attack`, `guard`, `skill`, `hurt`, `death`. `detailed_hero.gd` y `enemy_sprite.gd`
son adaptadores de identidad sobre esa base. `data/static_combat.json` declara
ruta, escala, límites y apoyo para 360 dibujos: cuatro héroes y 56 modelos enemigos.
No hay reproductor de animación corporal, rig, mezcla de poses ni carrera victoriosa.

`begin_action()`/`finish_action()` mantienen la imagen durante el primer plano.
`play_once()` conserva una imagen durante un intervalo; no avanza fotogramas.
`hero_attack_playback.gd` conecta la liberación de la pose a `finished` y a la
salida del primer plano del árbol. `recover()` espera su salida antes de iniciar
el siguiente golpe; la recuperación de la barra no acorta ni alarga la pose.
Las revisiones de acción cancelan retornos obsoletos al interrumpir o restaurar.
El equipo se aplica directamente al actor con `apply_gear()` y un shader fijo.

Las 20 acciones de héroes usan nuevos PNG de 512×512, con escala y anclaje por
pose en el mismo catálogo. `scripts/import_hero_actions_hd.gd` extrae figuras
conectadas de las fuentes de producción y comparte una reducción proporcional
por héroe; no produce atlas de ejecución. `prepare_static_combat.py` y
`build_comic_style_index.py` conservan su borde ya dibujado al regenerar.

`combat_actor_scale.gd`, `combat_layout.gd` e `impact_feedback.gd` utilizan las
métricas de los dibujos para mantener suelo, tamaño y cifras legibles sin leer
píxeles de GPU por impacto. `hero_cut_in.gd` y los primeros planos enemigos son
presentación independiente con luces y partículas. `hit_slash.gd` dibuja el corte
y las chispas de impacto enemigo desde `impact_feedback.gd`: un nodo temporal
con geometría analítica, sin transformar el actor, leer imágenes de GPU ni consumir
RNG de reglas. Su tiempo de vida está acotado y respeta preferencias de destellos
y efectos reducidos. Véase [Combate](COMBATE.md).

## Cartas, reserva y parejas

`card_reserve.gd` conserva una carta apartada y su posición visual. La fachada
confirma guardar/cancelar antes del volteo. `combat_hand.gd` intercala el reverso
y conserva `hand_index` en las cartas jugables: posición visible e índice del
array no son equivalentes cuando hay reserva. La mano adapta escala y separación.

`pair_tactics.gd` y `synergy_actions.gd` resuelven las seis parejas;
`card_synergies.gd` describe oportunidades y `pair_link_fx.gd` muestra el enlace.
`guided_lessons.gd` y `guided_practice_navigation.gd` utilizan una instancia
temporal para la práctica, separada del progreso real.

## Exploración y pantallas

`dungeon_generator.gd` delega selección de grupos en `enemy_formations.gd` y
geometría en `map_geometry.gd`. `map_screen.gd` presenta el grafo y
`paths_screen.gd` las salidas inmediatas. Las adaptaciones visuales de mapas
cargados no regeneran su contenido ni cambian conexiones guardadas.

Las pantallas tienen archivos propios en `src/ui/screens/`: campamento,
selección, preparación, mapa, caminos, combate, recompensas, descanso,
encuentros, bolsa, mazo, edificios, colección, bestiario y cinemáticas.
`back_navigation.gd` permite retroceder solo en vistas reversibles;
`pause_navigation.gd` coordina la pausa. Las cinemáticas presentan capítulos
confirmados y no conceden premios.

## Perfil, economía y compatibilidad

`save_store.gd` conserva perfil y aventura en `user://eterno.save`; el estado
aleatorio se serializa sin perder su precisión de 64 bits. Las migraciones se
realizan desde las reglas/fachada, conservando IDs, equipo y progreso anteriores.

`forge_materials.gd` administra chatarra, aleación y recibos;
`forge_progression.gd` valida niveles de equipo. La entrega ocurre una sola vez
al resolver victoria. `forge_material_display.gd` presenta el depósito sin
modificarlo. La aventura conserva su instantánea de equipo.

`pet_companions.gd` valida la mascota y aplica su pasiva al inicio del combate.
`data/pets.json` define sus valores. Los datos narrativos de `hero_lives.json`
no cambian estadísticas ni introducen penalizaciones de memoria.

## Recursos y herramientas

El juego carga `assets/` y `data/`. `art_sources/` conserva producción y procedencia;
`docs/` contiene exclusivamente guías vigentes. Ambas carpetas quedan excluidas
de exportación, y sus marcadores `.gdignore` evitan importarlas como arte del juego.
Los auditores escriben informes en `artifacts/`.

`scripts/audit_repository.py` comprueba referencias literales, scripts alcanzables
y metadatos huérfanos. No deduce que una ruta dinámica es un archivo sin uso.
`resource_retirements.gd` consulta `art_sources/retired_resources.json` únicamente
desde importadores, para impedir que reinstalen recursos retirados. No participa
el mantenimiento en las reglas ni en el guardado del jugador.

## Reglas para ampliar el proyecto

- Crear nuevas pantallas en archivos propios y separar reglas de presentación.
- Revisar responsabilidades al superar aproximadamente 350–400 líneas, sin
  fragmentación artificial ni código comprimido para ajustarse al número.
- Mantener IDs/UIDs y compatibilidad al mover archivos; actualizar referencias.
- Registrar cada extracción completada en el historial y actualizar esta guía.

## Pendientes técnicos

`main.gd` y `game.gd` siguen concentrando orquestación y fachada. Las próximas
extracciones deben responder a cambios concretos, preservando APIs y guardados.
También quedan por investigar avisos de retención al cerrar algunas pruebas y
medir rendimiento real en navegador. Son pendientes, no mejoras ya verificadas.
