# Actores con mayor detalle — 16/09/2026

## Resultado actual

- Seis héroes: atlas de **128×128 por cuadro**, 210 cuadros originales en total.
  Incluye reposo, ataques, habilidades, daño, caída y recuperación. La recuperación
  reutiliza la secuencia de caída invertida.
- Selección: seis vistas frontales reimportadas a 128×128.
- Biblioteca de **56 enemigos**: sprites estáticos de 128×128, incluidos los 50
  reservados para futuros pisos.
- Los seis enemigos de la primera cripta tienen además **ocho poses dibujadas por
  ciclo** (48 cuadros nuevos), de 128×128.

El detalle de héroes y biblioteca se recuperó de las fuentes originales de mayor
resolución; **no se agrandaron los PNG de 64 px**. Se conservan sus diseños,
paletas, poses y filtro nearest. Hay cuatro veces más píxeles por cuadro; el
tamaño de los actores en pantalla se mantiene con escala interna compensada.
Los atlas antiguos de 64 px se retiraron durante la limpieza; las fuentes originales se conservan.

## Enemigos activos

| Sprite | Ciclo de movimiento | Ataque procedural adicional |
| --- | --- | --- |
| crypt_bat | Aleteo de ocho poses, cuerpo alineado por el ojo | Ascenso y picado |
| crypt_slime | Ondulación, cambios de volumen y burbujas | Compresión y salto viscoso |
| crypt_lancer | Pasos cortos, lanza y escudo | Anticipación y estocada larga |
| crypt_shaman | Capa, mano y llama del bastón | Gesto con brillo cálido y avance |
| crypt_automaton | Pasos mecánicos y brazos articulados | Balanceo y golpe pesado |
| skeleton_6 | Cambio de postura, espada y capa | Anticipación y golpe inclinado |

Los cuadros nuevos se reproducen en reposo/movimiento. Ataque, impacto rojo y
muerte conservan la composición por tweens sobre esos sprites; no se presentan
como tres atlas nuevos de ocho cuadros por enemigo. Los 50 enemigos reservados
mantienen sus movimientos procedurales anteriores, con arte más detallado.

Las poses terrestres comparten línea visible de suelo y escala uniforme por
secuencia. El murciélago usa un anclaje facial para evitar saltos causados por
las alas. Ningún movimiento modifica reglas, RNG, IDs o guardados.

## Archivos y reproducción

- Héroes: `assets/<clase>/<clase>-128.png`; consumidos por `src/*_sprite.gd`.
- Selección: `assets/camp/front-128.png`.
- Biblioteca: `assets/enemies/hd/<id>.png`.
- Ciclos: `assets/enemies/animations/<id>.png`, atlas de 1024×128.
- Fuentes nuevas: `docs/enemies/animations/<id>.png`.
- [Prompts completos](../enemies/animations/prompts.md): seis llamadas a la
  herramienta integrada **imagegen**, usando como referencia los atlas originales
  de los conceptos del usuario. No se usó API/CLI externa.
- Fuentes de héroes/biblioteca: `docs/<clase>/generated-sheet.png`,
  acciones adicionales del pícaro y `docs/enemies/sheet-1.png` a `sheet-7.png`.
  Su procedencia y prompts anteriores se mantienen en cada carpeta.

Importar originales, con Godot local:

```bash
for hero in warrior guardian rogue mage cleric ranger; do
  ./scripts/run.sh --headless --script "scripts/import_${hero}.gd"
done
./scripts/run.sh --headless --script scripts/import_camp.gd
./scripts/run.sh --headless --script scripts/import_enemies.gd
./scripts/run.sh --headless --script scripts/import_enemy_animations.gd
./scripts/run.sh --headless --editor --import
```

Los importadores recortan atlas y ajustan resolución/alineación de forma
reproducible, preservando alfa; no repintan las imágenes.

## Vista previa y comprobaciones

Galería actual (archivo retirado en la limpieza) · Vídeo de movimiento y ataques (archivo retirado en la limpieza).
Se generan desde Godot con:

```bash
./scripts/run.sh --script scripts/preview_actors.gd
```

El script imprime la carpeta de 32 fotogramas en `user://actor-preview`.
El vídeo se codificó con ffmpeg a 8 fps, H.264, CRF 16, yuv420p, desde esos
fotogramas renderizados. No es una captura de Android.

Últimas pruebas headless: guerrero 62, guardiana 67, pícaro 69, maga 70,
clériga 71, explorador 71, enemigos 498 y selección 47:
**955 comprobaciones sin fallos**. Cubren tamaño/alpha, alineación, ocho poses
distintas, ciclos, ataque/daño/muerte, seis encuentros, recuperación, entradas
bloqueadas y guardado antes de animaciones.

También se ejecutó la galería de enemigos con renderizado en escritorio y se
revisaron capturas de combate y la vista conjunta. La nueva vista previa incluye
los ataques diferenciados de la revisión final. Importación y `git diff --check`
correctos. No se compiló APK ni se midió rendimiento en Android; las texturas de
128 px requieren más memoria que las anteriores.
