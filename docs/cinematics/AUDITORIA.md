# Revisión integral del juego — 08/10/2026

## Alcance y evidencia

Se revisaron composición y navegación, combate/presentación, catálogos de las tres
mazmorras, audio, carga de recursos y persistencia. Se recorrieron **36 vistas** en
Godot nativo, se probaron diez cinemáticas y seis enemigos adicionales y se ejecutó
el conjunto de regresiones. Es un análisis del estado local actual; no una
certificación de publicación, dispositivos o balance de partidas reales.

## Hallazgos y cambios

| Área | Hallazgo | Cambio aplicado |
| --- | --- | --- |
| Narrativa | Inicio, héroes y guardianes tenían progresión sin presentación narrativa propia | Diez escenas ilustradas con cámara, partículas, música, subtítulos y galería |
| Flujo de cinemáticas | Una escena obligatoria/repetida perjudicaría la navegación y la reanudación | Pausa, salto, opción global, controles de teclado/mando y flags compatibles; premios separados |
| Personajes | La galería podía cargar seis atlas HD completos o reutilizar retratos antiguos menos definidos | Seis cuadros HD extraídos, compactos y compartidos por galería/cinemáticas |
| Variedad | Seis plantillas elegidas seguían reservadas y sin encuentros | Dos enemigos adicionales por piso, con patrón/rol y debut gradual |
| Animación enemiga | Los ciclos arrancaban juntos y la recuperación del golpe era seca | Fase de reposo por apariencia, recuperación suavizada y estela breve; tamaño/apoyo conservados |
| Atmósfera | Escenarios de combate principalmente estáticos | Polvo, motas/hojas o brasas detrás de personajes; modo de menos efectos respetado |
| Impactos | El resultado dependía mucho de números/reacción del sprite | Chispas, arco de bloqueo y ondas en golpes fuertes, locales y temporales |
| Audio | Voces saturadas cortaban siempre el primer canal; música competía con impactos | Reutilización de la voz más antigua, limitador y reducción/recuperación suave de música |
| Música | Las nuevas escenas no tenían contexto sonoro diferenciado | Dos arreglos ambientales CC0, contexto por escena y música de guardianes desde su entrada |
| UX | Mensajes al pie competían con cartas y navegación; algunos encabezados duplicaban el logo | Avisos enmarcados que se esfuman y encabezado compartido para mercader/vínculos/eventos de cartas |
| Assets | Grillas generadas con dimensiones impares impedían el empaquetado | Normalización determinista previa al corte; alfa, ocho poses y hashes comprobados |
| Tamaño | Imágenes nuevas podían añadirse sin la política de compresión existente | Importación lossy 0,9 de fondos/HD y atlas pixel art sin pérdida; fuentes fuera del export |

## Arquitectura actual y propuesta

Hay 176 scripts de `src`, aproximadamente 9.300 líneas. `main.gd` sigue cerca
de 600 líneas y `game.gd` en 441; son los únicos módulos que superan ampliamente
la guía de tamaño. Esta entrega añade pantalla, navegación, presentación, audio
y datos en archivos propios de menos de 200 líneas. Extrae el encabezado compartido
en un componente; no reordena ni cambia IDs de sistemas existentes.

La separación mantiene: acción validada → resolución → checkpoint → animación.
Las cinemáticas, estelas y partículas no calculan daño, regeneran mapas ni conceden
recompensas. Los contextos de audio usan RNG propio. La expansión de catálogos
sigue los merges existentes, y los mapas ya guardados permanecen intactos.

**Propuesta futura, no realizada en esta entrega:** extraer las acciones de
preparación/navegación que quedan en `main.gd` cuando se amplíen; reducir la fachada
de `game.gd` por sistemas sin renombrar sus acciones públicas. Evitar una
reorganización masiva mezclada con nuevo contenido. No se elimina ningún recurso
por un grep: hay rutas dinámicas, importaciones y atlas que requieren comprobación.

## Recursos nuevos y procedencia

Cuatro fondos originales, seis retratos derivados y doce recursos enemigos
finales. Los gráficos suman **15,96 MiB como PNG de trabajo / 4,04 MiB importados**;
las dos músicas suman **0,94 MiB**. Estos datos describen recursos locales, no el
tamaño de un PCK o export, que no se generó. [Mediciones y hashes](asset_sizes.json).
Los originales de imagegen se conservan en documentación con `.gdignore` y `docs/*`
está excluido por los presets; los assets finales sí están en el proyecto.

Se mantienen licencias/autores de audios CC0 originales. Los arreglos nuevos usan
filtros, mezcla ambiental y fades; no hay voz narrada ni composición musical IA.
Prompts y procedencia enlazados desde [la guía del sistema](README.md).

## Pruebas realizadas para esta entrega

- **81/81 suites headless** completas aprobadas. Tras las últimas correcciones de
  encabezados/galería, se repitieron cinemáticas, UI y expansión según su alcance.
  Sin `SCRIPT ERROR` ni aserciones fallidas en los resultados finales.
- `test_cinematics.gd`: **98 comprobaciones nativas** sin fallos; escenas, pausa/salto/avance, secuencia de dos héroes,
  restauración de navegación/audio, entrada real desde `continue_run`, descubrimiento,
  reanudación sin duplicar premios y guardado/carga de campos nuevos.
- `test_cinematic_enemies.gd`: **48 comprobaciones nativas** sin fallos;
  ocho cuadros distintos por enemigo, vuelta a reposo, alfa/dirección HD,
  limpieza de partículas, opciones y recuperación del volumen de música.
- `test_polish_ui.gd`: **13 comprobaciones / 36 vistas nativas** sin fallos;
  informe de alturas de textos sin desbordamientos detectados.
- Capturas revisadas de las diez cinemáticas/galería, doce vistas de actores/cut-ins,
  efectos y pantallas principales. Archivos temporales bajo `artifacts/`, ignorados.
- `test_audio.gd` nativo: **82 comprobaciones** sin fallos; reproducción/contextos/mute/botones/combos y salida
  real del mezclador grabada en WAV (4,98 s, pico 0,891 y RMS 0,073); no se atribuye esta prueba a un navegador.
- Importación Godot, alfa de fuentes, métricas/hashes de 50 atlas, verificación
  de Python y `git diff --check`. No se exportó el juego.

## Límites y pendientes de validación

Entorno nativo: Linux, Godot 4.7.2, Compatibility, Mesa **llvmpipe**, 1280×720.
36 pantallas produjeron una muestra de 65 MiB de memoria estática y 268 MiB de
texturas; es una escena de pruebas con recursos acumulados, no un presupuesto
de memoria para móviles ni una medición representativa de FPS en GPU física.

Algunas suites presentan avisos de objetos/recursos aún activos al cerrar Godot;
la inspección `--verbose` de cinemáticas señala recursos y reproducciones Ogg.
Se distinguen de errores de script o aserciones: los nuevos flujos terminan y
liberan sus nodos, pero no se afirma haber eliminado esos avisos del motor.

No hubo exportación, prueba Web, emulador o dispositivo físico. Quedan para esos
entornos el desbloqueo de audio del navegador, consumo/fps reales, legibilidad a
escala de pantalla móvil y escucha subjetiva de la mezcla. La variedad se prueba
con cientos de mapas; el balance de los seis patrones nuevos requiere partidas
completas y opiniones de jugadores, no solo validación de catálogos.
