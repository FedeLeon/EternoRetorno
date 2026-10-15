# Auditoría actual — 15/10/2026

[Informe integral](AUDITORIA_2026_10_15.md): 98/98 suites, contenido 1510/0,
683 recursos con procedencia válida y 96 atlas/928 cuadros sin celdas vacías
según el auditor. Render nativo aislado de combate/opciones 125/0 y edificios
84/0; muestra de cinco vistas revisada. Hay avisos al cierre en 35 suites;
sin exportación, Web, dispositivo ni escucha de audio. El informe distingue
calidad visual, integridad de recursos, limpieza posible y propuestas futuras.

# Estado visual anterior — 14/10/2026

Cómic postapocalíptico integrado: cuatro civiles, 56 apariencias de máquinas,
660 recursos visuales verificados. Cuerpos de 256 px y acciones de 384 px con
poses sostenidas; primeros planos estáticos HD y partículas detrás. Los bancos
originales, frames de tiempo y derivados se distinguen en la documentación.
[Arte, pruebas actuales y límites](../art_direction/postapocalyptic/README.md).
88/88 suites locales sin fallos; render nativo aislado a 1280×720. Sin exportar
ni certificar Web/dispositivo o escucha de audio. Las cifras inferiores son
históricas y no validan esta entrega.

## Estado anterior sketchbook — 14/10/2026

Cuatro héroes sketchbook, diez acciones de doce poses; detalle base de 256 px,
acciones adicionales de 384 px. Las variantes de equipo reutilizan dibujos con
tintes discretos, sin piezas superpuestas. Héroes: 1108 comprobaciones locales;
herrería: 8220, sin fallos. [Conversión, procedencia y límites](../art_direction/migration/README.md).
La documentación siguiente describe entregas anteriores.

## Actualización de pulido — 07/10/2026

[Implementación actual, assets, reglas y validación](../polish_2026_10/README.md).
La documentación y resultados anteriores se conservan como historial.

# Actualización — 07/10/2026

Los héroes **durante la batalla** ahora usan [actores detallados de 256 px](../combat_depth_2026_10/README.md),
con doce poses por acción, más tres ataques nuevos por héroe de 384 px.
Las nuevas capas de equipo distinguen forma de arma/armadura en niveles 1–3.
Los seis sprites clásicos y las variantes de equipo
de esta guía siguen usándose fuera de batalla. No se presentan las pruebas
históricas siguientes como validación de la entrega nueva.

# Actores con mayor detalle — 16/09/2026

Actualización 17/09/2026: la [herrería](../forge/README.md) añade 96 atlas de equipo
(16 por héroe), de 128 px por cuadro, reutilizando las animaciones existentes.
Los atlas de esta guía se conservan como referencia y para aventuras anteriores.
La normalización de altura de las variantes usa `data/forge_visuals.json`.

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

## Reposo estable, salida lenta y cenizas — 18/09/2026

Los seis actores usan `presentation/hero_idle.gd`: congela el cuadro 0 del
reposo y aplica `assets/shaders/hero_idle.gdshader`. El shader desplaza levemente
regiones laterales de capa/ropa y mano/arma; mantiene zona central del torso,
cabeza y pies sin escalado/traslación del actor. Es deformación localizada de
una pose, no nuevos cuadros dibujados ni articulaciones independientes. Los
atlas previos se conservan para acciones y compatibilidad. El helper detecta
cambios de atlas de herrería y desactiva la deformación durante otras acciones.
La selección frontal del campamento ya era estática y se conserva.

`combat_effects.gd`: salida victoriosa en 2,5 s (antes 1,25), segundo héroe con
desfase de 0,12 s, conservando desplazamiento y pasos procedurales.

`enemy_sprite.gd` delega muerte en `presentation/enemy_ash.gd`: disolución
ascendente con ruido, borde de brasa y partículas de ceniza. El shader
`assets/shaders/enemy_ash.gdshader` normaliza el cuadro actual del atlas.
Dura 1 s más 0,3 de cola; al terminar el sprite queda oculto, también al
reconstruir un enemigo ya caído. No queda cuerpo tumbado. Los héroes caídos
conservan su animación/cuerpo y la recuperación anterior. Reglas y guardado
siguen precediendo a la presentación. Shaders y partículas hechos en código,
sin nuevos assets generados ni modificación de atlas.

Validación actual: `test_actor_motion.gd` renderizado sin fallos (seis héroes
con equipo nivel 3, reposo fijo, retorno desde ataque y cenizas); 498
comprobaciones de enemigos, 18 de presentación y 10626 de recursos de herrería
aprobadas en headless. Capturas locales revisadas; comparación de dos instantes
confirma movimiento visible en los seis héroes. Capturas temporales eliminadas.
Sin exportación APK/Web, emulador ni dispositivo físico.

## Carrera con sprites dedicados — 18/09/2026
La salida victoriosa sustituye el movimiento procedural de pose fija por
ocho cuadros `run` por héroe. Se conservan tiempos de salida y flujo de
resultados. [Assets, alcance y pruebas actuales](../running/README.md).

## Peso de texturas — 22/09/2026

Compresión selectiva, límites de resolución y exclusiones auditadas: [informe](import_optimization/README.md). Texturas incluidas estimadas de 236,54 a 96,19 MiB; sin exportación.
