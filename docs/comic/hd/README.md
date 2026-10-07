# Primeros planos de héroes en alta definición — 05/10/2026

## Motivo y formato

Las fuentes anteriores repartían 16 poses en una imagen de 1536×1024:
cada dibujo disponía de 384×256 píxeles. Ampliarlas a celdas de 600×400
y mostrarlas en primer plano hacía visible su baja resolución. El filtro
lineal ya estaba activo; cambiarlo no recuperaba detalles.

La restauración usa cuatro hojas 2×2 por secuencia: cada pose dispone ahora
de 768×512 píxeles, cuatro veces el área de origen. ImageGen reconstruye
el detalle conservando las poses, identidad, armas y colores de referencia.
El resultado mantiene 24 ataques y seis defensas, 16 dibujos por secuencia.

- Fuentes: `sources/`, 120 hojas RGBA de aproximadamente 1536×1024.
- Runtime: `assets/comic/motion/`, 30 atlas 3072×2048, celdas 768×512.
- Se conservan rutas, UIDs, combos, reloj, filtro lineal y luces/partículas.
- Mismo encuadre inferior izquierdo: escala 1,28 y desplazamiento (-0,10; 0,12).
- Sin cambios en reglas ni persistencia.

## Procedencia y reproducción

Generación mediante la herramienta integrada `image_gen.imagegen`, modo edición
con fondo transparente, sin API externa. `prompts.json` conserva las 120
instrucciones exactas y la referencia de cada hoja. `references/` es una carpeta
temporal ignorada por Git; sus 120 imágenes derivadas se retiraron el 07/10.
Se regeneran con `prepare_hero_hd_refs.gd` desde `docs/comic/smooth/sources/`,
sin redimensionar ni dibujar imágenes nuevas. Las 120 fuentes HD finales permanecen.

`sources.json` registra los originales generados y sus SHA-256. Los originales
permanecen en la carpeta de generación; las copias del proyecto son reproducibles
sin depender de esa ubicación. Las fuentes documentales están excluidas de la
importación y exportación del juego.

`spacing-prompts.json` conserva cinco correcciones de margen realizadas con
ImageGen para que espadas y flechas no crucen la separación entre celdas;
`sources.json` incluye también la procedencia anterior de esas hojas.

```sh
./scripts/run.sh --headless --script scripts/prepare_hero_hd_refs.gd
# Generar las hojas con los prompts y referencias documentados.
./scripts/run.sh --headless --script scripts/import_hero_motion.gd
./scripts/run.sh --headless --editor --import
```

El importador normaliza variaciones de unos pocos píxeles en el tamaño generado,
extrae las cuatro poses de cada hoja y aplica un único recorte y escala para las
16 poses. No sintetiza cuadros intermedios. Los comandos solo importan recursos.

## Validación

- Importación local de los 30 atlas y auditoría de 120 fuentes RGBA: correctas.
  Los bordes de celda no presentan segmentos opacos de más de ocho píxeles.
- `test_comic_motion.gd`, ejecución nativa a 1280×720: **2685 comprobaciones,
  cero fallos**. Recorre las 30 secuencias y comprueba 16 dibujos distintos,
  transparencia, reproducción ordenada y partículas que no interceptan entrada.
- Capturas locales revisadas de ataques de los seis héroes y defensa del explorador;
  escenario visible, encuadre inferior izquierdo y detalle mejorado. Godot 4.7.2,
  Compatibility/Mesa llvmpipe; capturas en `artifacts/comic_motion/` (no versionadas).
- Regresiones headless: `test_hero_cut_in.gd`, `test_enemy_cut_in.gd`,
  `test_counter.gd`, `test_turn_sequence.gd` (171) y
  `test_combat_presentation.gd` (25), cero fallos.
- Sin exportación ni validación en navegador, emulador o dispositivo físico.

## Tamaño y límites

Los PNG de runtime pasan de 140,0 a 270,6 MiB. Los recursos importados de estos
30 atlas suman 54,1 MiB con la compresión Lossy 0,85 existente. No es una medición
del tamaño de exportación. Cada atlas RGBA sin comprimir ocupa 24 MiB frente a
14,65 MiB antes; la mayor definición consume más memoria de textura. La restauración
es generativa y puede introducir pequeñas variaciones de detalle entre poses.
