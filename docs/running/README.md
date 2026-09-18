# Carrera de los seis héroes — 18/09/2026

Cada héroe dispone de ocho cuadros de carrera hacia la derecha, en un atlas
RGBA de 1024×128 (ocho celdas de 128×128). Ciclo a 10 FPS, con contacto,
recogida y avance de piernas, movimiento de brazos, capa/cabello y ropa.
Armas y escudo limitan el balanceo del brazo que los sostiene. La pierna
visible alterna extensión/flexión; las túnicas dejan ver la zancada.

## Activación

La salida tras ganar una batalla usa `run` en lugar de desplazar una pose
idle con seno y rotación del cuerpo. Se conserva duración 2,5 s para el primer
héroe y 2,62 s para el segundo. Ambos salen por la derecha. Un compañero caído
se recupera antes de salir, como en el flujo previo. No cambia combate,
recompensas, guardado, velocidad de ataques ni poses de reposo.

## Archivos

- `assets/heroes/running/<hero>.png`: seis atlas finales, aproximadamente 804 KiB juntos.
- `docs/running/sources/<hero>.png`: seis hojas seleccionadas de imagegen, 4×2.
- `docs/running/<hero>.json`: prompts exactos y procedencia de la generación inicial.
- `*-arms-correction.json`: iteración de guerrero, maga y clériga para hacer
  más visible el balanceo de brazos; fuentes originales conservadas en las
  rutas de generación indicadas, última versión seleccionada en `sources/`.
- `scripts/import_running.gd`: recorte y escalado nearest reproducible, sin
  repintar o fabricar poses. Referencia de escala por clase, pies en y=120
  y pequeña elevación en fases intermedias. Conserva transparencia original.
- `src/presentation/hero_run.gd`: registro de cuadros, inicio/restauración y escala.
- Los seis `*_sprite.gd` registran `run` y su ID de héroe.
- `hero_equipment.gd` conserva el atlas de carrera independiente al sustituir
  las filas de acciones por equipo. No intenta leer columnas 6/7 del atlas de herrería.
- `combat_effects.leave_room` reproduce el ciclo mientras desplaza al héroe.

El shader de reposo se desactiva durante `run`. El tamaño se ajusta a la
silueta del equipo actual; detener la carrera restaura escala y posición.
Esta tanda tiene **un diseño de carrera por héroe**, compartido entre niveles
de herrería. No incluye 96 variantes de carrera de armas/armaduras: los
assets de equipo siguen en reposo y acciones anteriores y sus estadísticas
no cambian. Crear esas variantes visuales queda como ampliación separada.

## Regeneración y pruebas

```
./scripts/run.sh --headless --script scripts/import_running.gd
./scripts/run.sh --headless --editor --quit
./scripts/run.sh --script tests/test_running.gd
```

Validación local Linux/llvmpipe: 181 comprobaciones de ocho cuadros distintos,
transparencia, escala, bucle, reposo desactivado, regreso, combinación con
herrería y salida completa. Inspección visual de fuentes y cuadros en escenario
con el tamaño de combate. `test_combat_presentation.gd`: 18 comprobaciones;
`test_forge_assets.gd`: 12450 comprobaciones, sin fallos. Se corrigió el hash
usado por el test nuevo antes de la ejecución final. Diff e importación correctos.
No se exportó ni se probaron Web/Android. Las capturas de revisión son temporales.
