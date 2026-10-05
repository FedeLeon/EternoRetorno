# Héroes en primer plano: 16 sprites por acción — 01/10/2026

> Actualización 05/10/2026: las poses fueron reconstruidas en mayor resolución.
> Ver [fuentes HD y formato vigente](../hd/README.md). Esta página conserva el
> formato y las pruebas históricas del 01/10.

## Resultado del 01/10/2026

Los seis héroes tienen cuatro variantes de ataque y una defensa, cada una con
16 dibujos consecutivos: **30 secuencias y 480 cuadros**. Sustituyen las hojas de
ocho cuadros del 30/09. Las variantes siguen rotando entre golpes de un combo.

- Hojas RGBA 4×4 en `assets/comic/motion/`, 2400×1600, celdas de 600×400.
- Entrada, poses, destellos y salida comparten el reloj de `comic_cut_in.gd`.
  Duración nominal de 0,72 s: un dibujo cada 45 ms. Si el renderizado se demora,
  el reloj avanza como máximo una pose por fotograma; la duración real se alarga
  en ese caso para mostrar la secuencia completa.
- `hero_comic_fx.gd` agrega halos locales, arcos de impacto y 48 partículas
  escalonadas con estelas y brillo aditivo. Ataques proyectan chispas hacia el
  arma; defensas distribuyen las partículas alrededor del impacto.
- Mantiene transparencia, escala 1,28 y desplazamiento relativo (-0,10; 0,12):
  primer plano grande, abajo a la izquierda, parcialmente fuera del encuadre.
- Los efectos no capturan clics ni usan RNG de aventura. No resuelven daño,
  premios ni guardado. Los enemigos conservan su configuración de reproducción.

## Assets y procedencia

Generados con la herramienta integrada **image_gen.imagegen**, usando como
referencias las hojas anteriores de `docs/combat_expansion/sources/`.

- `prompts.json`: 30 instrucciones exactas, identidad, acción y referencia.
- `spacing-prompts.json`: correcciones de márgenes de ocho hojas para evitar
  armas o poderes cortados entre celdas.
- `sources.json`: salida generada seleccionada, SHA-256, fuente local y prompts
  aplicables. Los originales generados permanecen en su ubicación de origen.
- `sources/`: 30 hojas finales originales de 1536×1024, con alfa real.

El empaquetador aplica un recorte común a las 16 poses y una escala uniforme,
para no introducir cambios de tamaño entre cuadros. No sintetiza poses.
Conserva importación lossy 0,85 y rutas existentes. Las fuentes de documentación
están fuera de la importación y exportación del juego.

```sh
./scripts/run.sh --headless --script scripts/import_hero_motion.gd
./scripts/run.sh --headless --editor --import
```

`import_comic_motion.gd` delega al nuevo importador; la rama de héroes de
`import_combat_expansion.gd` también usa este formato. El segundo comando solo
importa recursos; no exporta el juego.

## Validación

Validación local realizada el 01/10/2026, después del último ajuste del reloj:

- Importación Godot completada sin errores; 30 fuentes RGBA auditadas y
  procedencia verificada por SHA-256.
- `test_comic_motion.gd`, renderizado nativo a 1280×720 con Mesa llvmpipe:
  **2669 comprobaciones / 0 fallos**, las 30 secuencias recorren sus 16 cuadros.
  El número de comprobaciones por fotograma depende de la velocidad de render.
- Headless: `test_hero_cut_in.gd` (rotación, encuadre, limpieza y render lento),
  `test_enemy_cut_in.gd`, `test_counter.gd`, `test_turn_sequence.gd`
  (171 comprobaciones) y `test_combat_presentation.gd` (25), todos sin fallos.
- Revisión de capturas locales: ataque de maga, guerrero y explorador; defensa
  de guardiana, pícaro y clériga. Transparencia, efectos y encuadre comprobados.
  Capturas temporales en `artifacts/comic_motion/`, excluidas de Git.
- `git diff --check` y lectura de los tres JSON de procedencia sin errores.

No se exportó Web ni APK, ni se probó en navegador, emulador o dispositivo físico.
La revisión nativa no certifica rendimiento en esos destinos.
