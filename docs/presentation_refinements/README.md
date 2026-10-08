# Viñetas, mapa, campamento y relato — 08/10/2026

## Cambios actuales

- Primeros planos de ataque y defensa de los seis héroes: **0,96 s**, antes
  0,72 s, aproximadamente un tercio más. Los dieciséis cuadros y las partículas
  usan la misma fase normalizada. Se mantienen el encuadre inferior izquierdo,
  el fondo transparente, los combos, la velocidad de combate elegida y la duración
  anterior de las viñetas enemigas. No se altera resolución ni guardado del daño.
- Mapa de los tres pisos: espiral rectangular con una vuelta exterior amplia y
  retorno interior, capas de opciones alineadas y conexiones nuevas ordenadas
  para evitar trenzar ramas opuestas. La entrada continúa iluminada y el guardián
  cierra el recorrido interior. Caminos futuros más tenues, recorrido realizado
  más oscuro y salidas actuales destacadas. Sin textos de tipo de sala.
- Nuevas aventuras conservan 28 salas, inventario, élites, variantes aleatorias,
  bifurcaciones de tres opciones y acceso al guardián. Cambia la distribución de
  conexiones nuevas; aventuras guardadas conservan exactamente sus conexiones,
  encuentros y progreso. Los mapas antiguos de doce salas mantienen su geometría.
- Espirales guardadas reciben la distribución visual nueva en una copia privada
  de UI; no se reescribe la partida ni se vuelven a generar enemigos/salas.
- Campamento: **Proyectos** tiene un taller pequeño permanente, junto a la fogata,
  entre Iglesia y Aventuras; se abre tocando edificio o cartel. No necesita
  construcción ni consume almas para acceder. Los proyectos internos mantienen
  sus requisitos y costes. Entrenamiento es un botón cuadrado con muñeco y espada,
  sin texto; su tooltip explica el acceso. Bestiario solo tiene acceso desde Inicio.
- Diez cinemáticas: **21 ilustraciones distintas**, una por capítulo; tres en la
  introducción, dos por héroe y dos por guardián. Fundido de 0,55 s entre escenas y
  cámara suave. Pausa congela también el fundido; efectos reducidos cambian de
  imagen inmediatamente. La imagen del capítulo reemplaza el retrato estático.
  La galería Historias muestra la primera imagen propia de cada película ilustrada.
- Bloqueo: dos choques de metal de Kenney CC0, procesados para destacar el golpe
  y una resonancia breve. Se oyen tanto al absorber todo el daño como al absorber
  una parte; daño sin bloqueo mantiene su sonido anterior.

## Arte y procedencia

Generación mediante **imagegen integrado**, sin CLI/API alternativa.

| Recurso final | Fuentes y prompts conservados |
| --- | --- |
| `assets/base_camp/projects_building.png` | `docs/base_camp/projects/prompts.json` y `sources/building.png` |
| `assets/base_camp/training_icon.png` | mismo registro, `sources/training.png` |
| `assets/cinematics/shots/*.png` (21) | `docs/cinematics/film/prompts.json`, `sources.json` y `sources/*.png` |
| `assets/audio/sfx/metal_clash.ogg`, `metal_clash_2.ogg` | `docs/audio/sources.json`, originales en `docs/audio/metal/sources/` |

[Kenney Impact Sounds](https://kenney.nl/assets/impact-sounds) declara licencia
CC0. Se usan `impactMetal_heavy_001.ogg` y `impactMetal_heavy_004.ogg`.
Los originales de arte/audio tienen `.gdignore`; no se cargan como recursos del
juego. `scripts/import_film_assets.gd` normaliza las escenas a 1280×720 y conserva
alpha en edificio/icono. Los capítulos usan importación con pérdida a calidad 0,9.
Las 21 escenas suman **31,40 MiB de PNG fuente / 5,47 MiB importados**; esta es
una medición local de recursos, no el tamaño de una exportación.

## Archivos y arquitectura

`hero_cut_in.gd` configura la duración y `comic_cut_in.gd` comparte la reproducción.
`map_geometry.gd` define geometría versionada; `dungeon_generator.gd` ordena ramas
nuevas; `map_screen.gd` solo adapta su instantánea y dibuja. `base_camp_screen.gd`
compone el taller y los accesos existentes. `cinematic_player.gd` cambia imágenes,
`data/cinematics.json` declara capítulos y `cinematics_screen.gd` muestra miniaturas.
`impact_feedback.gd` selecciona sonido según daño absorbido; `data/audio.json`
resuelve las variantes. No se ampliaron `main.gd` ni los sistemas de guardado.

## Validación actual

- Godot 4.7.2 local, Compatibility/llvmpipe, 1280×720.
- Prueba nueva `test_presentation_refinements.gd`: **142 comprobaciones headless**
  y **143 nativas**, sin fallos. Revisa duración/fin de todos los héroes, acceso
  gratuito a Proyectos, icono cuadrado, Bestiario en Inicio, mapas antiguos sin
  mutación, 21 imágenes únicas realmente mostradas, fundido pausado, bloqueos
  completos/parciales y salida real del mezclador de sonido.
- Capturas nativas de campamento construido/sin construir, tres mapas, mapa
  guardado adaptado y todos los capítulos. Se revisaron capturas y hojas de
  contacto de las 21 ilustraciones. Muestra de audio del mezclador en
  `artifacts/film-review/metal-impact.wav`.
- Geometría: **166.354 comprobaciones** sobre 300 mapas, sin fallos; posiciones,
  determinismo, acceso a todas las salas, ausencia de solapamiento de botones,
  curvas dentro de límites y compatibilidad de mapas anteriores.
- Regresiones: **82/82 suites aprobadas**, contando repeticiones de los casos
  afectados tras corregir un margen inferior detectado por `test_dungeon.gd`.
  Audio nativo: **84 comprobaciones** aprobadas. `git diff --check` aprobado.
- Algunos tests históricos conservan advertencias de recursos al cerrar; el
  nuevo recorrido nativo final cierra sin esas advertencias. No se certifican
  todas las intersecciones posibles de curvas mediante la prueba de botones.

Informes y capturas locales: `artifacts/film-review/`, ignorado. Sin exportación
Web/APK, navegador, emulador ni dispositivo físico. La primera ejecución de la
suite completa falló por un margen; ese resultado se conserva separado del informe
final combinado con las repeticiones.
