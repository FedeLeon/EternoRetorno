# Iconos de salas en cómic — 15/10/2026

Seis ilustraciones nuevas generadas **individualmente** con la herramienta
integrada `image_gen.imagegen`, fondo transparente real y borde marfil fino.
Tinta negra, metal usado y bloques de color del mundo de civiles contra máquinas.
Sustituyen los PNG obtenidos de los SVG geométricos; conservan rutas e IDs.

| ID | Ilustración | Recurso activo |
| --- | --- | --- |
| combat | Machete y caño cruzados, golpe rojo, empuñaduras naranja/violeta | `assets/map/minimal/combat.png` |
| rest | Tacho metálico con luz interior y tres brasas, sin llamas altas | `assets/map/minimal/rest.png` |
| event | Radio cian con bocadillo de interrogación | `assets/map/minimal/event.png` |
| treasure | Caja industrial dorada/violeta con cierre cian | `assets/map/minimal/treasure.png` |
| elite | Cabeza de máquina violeta con ojos ámbar | `assets/map/minimal/elite.png` |
| boss | Máquina pesada naranja con visor rojo y hombros anchos | `assets/map/minimal/boss.png` |

## Procedencia y preparación

[jobs.json](jobs.json) conserva los seis prompts completos, originales, destinos,
herramienta y hashes. `jobs/<id>.json` es el registro individual y `sources/`
conserva las seis imágenes originales de **1254×1254**, sin modificar sus píxeles.
No se usaron APIs externas ni bancos de imágenes.

`res://scripts/import_map_comic_icons.gd` valida todo el conjunto y sus hashes
antes de reemplazar recursos; recorta solo margen alfa, reduce proporcionalmente
por Lanczos y centra cada imagen en lienzo transparente **256×256**, con extensión
máxima del dibujo de 240 px. Los PNG finales suman aproximadamente 510 KiB.
Se conservan los UIDs/importadores y el límite previo de textura de 192 px para
estos iconos de interfaz; no se altera la configuración global de exportación.

El inventario postapocalíptico registra cada nueva fuente/generación. Las seis
entradas derivadas son `map_illustration`; se retiran del listado de rasterizado
vectorial para que sus herramientas no sobrescriban estas ilustraciones.
Los SVG antiguos quedan como fuentes históricas de la etapa anterior.

## Integración y validación

Mapa: iconos dentro de las salas de 56 px, con imagen de 48 px. Caminos:
ilustración principal en espacio cuadrado de 76 px, centrada sobre el rótulo,
y siguientes destinos de 36 px. Se usan los mismos seis recursos en las tres
zonas, sin cambiar destinos, conexiones, señales ni reglas.

- `test_map.gd`: **141/0 nativo aislado**.
- `test_paths.gd`: **153/0 nativo aislado**, tres zonas y de uno a tres caminos.
- Capturas actuales revisadas: `artifacts/map/initial.png` y
  `artifacts/paths/floor_3_3.png`. Los seis originales también revisados.
- Auditoría de arte: **680 recursos válidos, cero pendientes o desajustes**.
- Audio Dummy; avisos de recursos al cerrar, sin errores de script/aserciones.
  Sin exportar ni validar Web/dispositivo físico.
