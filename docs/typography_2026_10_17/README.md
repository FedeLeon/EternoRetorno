# Tipografía anterior y números eléctricos legibles — 17/10/2026

## Cambios

- Restaurada Source Sans 3: cuerpo 550, encabezados 800, cartas 700. Botones y
  barras vuelven a heredar el tema; no usan Comic Neue ni Bangers.
- Se conserva el rasterizado doble sin MSDF de las cartas para impedir los
  huecos en la letra e. No se revierten los marcos ni sus áreas de texto.
- Diez números nuevos, marfil sólido, borde oscuro y acento cian fino. Sin
  mecanismos ni adornos que oculten el dígito. PNG transparentes de 32×48;
  altura óptica uniforme y base compartida en fila 46, también para 1 y 5.
- Se mantienen rutas e IDs; sin cambios de reglas, guardados o economía.

## Procedencia y reproducción

Fuente ImageGen: `sources/minimal_electric_numbers.png`. Prompt exacto, origen
local, destinos y parámetros en
`../comic_rebuild_2026_10_17/jobs/props_ui__numbers__0.json` y su cola.
La generación anterior queda conservada en `previous_numbers_job.json`, con
su fuente original intacta. Licencia de la fuente: `assets/fonts/SourceSans3-OFL.txt`.

Empaquetado geométrico: `scripts/comic_rebuild_packer.gd`, números versión 5 en
`import_comic_rebuild.gd`; se conserva el manifest de procedencia y sus hashes.

## Validación de esta revisión

- HUD nativo: 113 comprobaciones; cartas nativas: 30; inicio nativo: 18.
- Ajuste de cartas, headless: 665 comprobaciones, sin fallos.
- Auditoría de procedencia: 716/716 recursos, sin errores.
- Capturas locales revisadas: energía, bloqueo, costes y textos de cartas.
- Logs en `artifacts/typography_2026_10_17/`. Algunas suites informan recursos
  pendientes al cerrar; no fallaron sus comprobaciones.
- Sin exportación ni prueba web/dispositivo físico. Las 107 suites de la
  renovación anterior son evidencia histórica, no una nueva ejecución completa.
