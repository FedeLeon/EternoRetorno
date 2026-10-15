# Caminos en primera persona — 14/10/2026

Después de cobrar la recompensa de una batalla se presenta la vista de caminos,
con los destinos reales de `Game.available_nodes()`. También se reutiliza al
salir de cofres, descansos y encuentros para mantener la navegación consistente.
Cada salida muestra el tipo de la próxima sala y, bajo «Después», las alternativas
inmediatas posteriores. No se inventan conexiones ni se altera la semilla.

## Presentación y assets

Nueve fondos de cómic postapocalíptico: uno, dos y tres pasajes por cada zona.
Primera persona a la altura de los ojos, sin personajes dibujados ni iconos
horneados en la ilustración. Los destinos se superponen según la partida:
Combate, Cofre, Encuentro, Descanso, Élite o Guardián. El pasaje completo es
clicable; foco/hover lo resaltan sin tapar el escenario.

| Zona | Fondos activos |
| --- | --- |
| Red de mantenimiento | `assets/paths/floor_1_1.png`, `floor_1_2.png`, `floor_1_3.png` |
| Cinturón industrial | `assets/paths/floor_2_1.png`, `floor_2_2.png`, `floor_2_3.png` |
| Central del Reinicio | `assets/paths/floor_3_1.png`, `floor_3_2.png`, `floor_3_3.png` |

`jobs.json` conserva el conjunto de prompts; `floor_*.json` conserva cada prompt,
referencia, ruta original y herramienta integrada `image_gen.imagegen`.
`sources/` conserva los originales (1672×940/941); se copian completos al juego,
sin generar arte por código. La importación limita la textura a 1280 px y usa
compresión con pérdida a 0,9, conforme a los fondos de pantalla del proyecto.
No se exportó para medir un tamaño de distribución.

El icono de mapa es SVG nativo: plano plegado, nodos y ruta, paleta industrial.
Fuente `map.svg`, recurso `assets/ui/map.svg`. Las diez altas están registradas
por hash/fuente en `docs/art_direction/postapocalyptic/assets.json`.

## Menú y flujo

- La columna derecha reutiliza Grupo y Mazo; añade Mapa con el nuevo icono.
- Grupo conserva vida, componentes y sus explicaciones al tocar.
- Mazo vuelve a la vista desde la que se abrió; Mapa permite consultar y elegir
  una sala disponible. Desde Mapa, «Caminos» o Volver regresa a la bifurcación.
- Los riesgos conservan su diálogo de confirmación antes de entrar.
- Desde la actualización de preparación del 14/10, una aventura nueva entra
  directamente en la primera batalla. Después de un jefe se conservan
  carta, cinemática y componente exclusivo antes de avanzar automáticamente:
  el siguiente sector se abre en primera persona con su única entrada inicial.
- Tras el jefe final, la misma vista ofrece «Completar aventura», que delega en
  la operación existente. Consultar el mapa no finaliza ni vuelve a conceder premios.

## Arquitectura y guardados

`src/ui/adventure_navigation.gd` decide la pantalla visible y prepara snapshots.
`src/ui/screens/paths_screen.gd` solo presenta y emite IDs. La navegación continúa
por `map_room_prompt.gd`, `Game.enter_node()` y sus checkpoints.

`src/ui/components/adventure_scene.gd` extrae del mapa los datos de presentación,
señales y helpers comunes; `map_screen.gd` conserva dibujo, rutas y resplandores.
`map_group_drawer.gd` comparte la columna y el panel con ambas vistas.
`screen_backgrounds.gd` evita un fondo duplicado y `screen_audio.gd` mantiene la
ambientación de la zona en Caminos, Mapa y Mazo.

La fase persistida sigue siendo **`map`**. `paths` es solo una pantalla: al
reanudar se reconstruye a partir de `current`, `rooms_completed`, conexiones y
estado del jefe. No se añade otro checkpoint, migración o flag temporal. Se
conservan IDs/UIDs, posiciones guardadas, recompensas y reglas.

## Pruebas de esta entrega

`tests/test_paths.gd` cubre nueve configuraciones obtenidas de mapas reales,
conteo/IDs/tipos exactos, alternativas siguientes, rail libre, consulta del mapa
sin mutación, vuelta desde Mazo, audio por zona, recompensa previa, reanudación,
confirmación de riesgo y clic real que entra en el destino correcto.
`test_boss_relic_navigation.gd` cubre componentes exclusivos y transiciones de
piso/final. Las pruebas anteriores del mapa abren ahora explícitamente el mapa
cuando comprueban su presentación; las de salas comprueban el retorno a Caminos.

Resultados actuales: **89/89 suites headless**, 1.502 controles de contenido sin
errores; render nativo de Caminos **153/0** y transiciones de jefe **14/0**.
642 hashes de recursos actuales verificados; cero recursos antiguos/faltantes.
Las suites conservan avisos de recursos al cerrar, registrados por separado.
Resultados y límites finales en [validation.json](validation.json). Evidencia
local en `artifacts/paths/` y `artifacts/boss-navigation/`, ignorada por Git y
exportación. Render aislado 1280×720, llvmpipe, audio Dummy y perfil privado;
no certifica navegador, dispositivo físico, rendimiento de GPU ni escucha.
