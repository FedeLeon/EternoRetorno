# Accesos laterales del mapa — 15/10/2026

Tres ilustraciones individuales de cómic americano, transparentes, tinta negra,
colores vivos y contorno marfil. Recursos nuevos compartidos por mapa y caminos:

| Botón | Ilustración | Asset |
| --- | --- | --- |
| Grupo | Dos supervivientes civiles, ropa violeta/naranja y caras visibles | `assets/map/sidebar/group.png` |
| Mazo | Tres cartas físicas con marco metálico y rayo cian | `assets/map/sidebar/deck.png` |
| Caminos / Mapa | Plano plegado con ruta naranja bifurcada y nodos cian | `assets/map/sidebar/paths.png` |

`map_group_drawer.gd` usa imágenes de 64×64 en posiciones equivalentes y rótulos
centrados debajo a y=70. El tercer acceso mantiene su alternancia «Mapa» /
«Caminos» según la vista y los mismos callbacks. Grupo conserva su panel,
componentes y diálogos; Mazo mantiene la vuelta a la vista anterior.

## Fuentes y preparación

Herramienta integrada **image_gen.imagegen**, una generación por asset.
[jobs.json](jobs.json) conserva los prompts completos, rutas originales/destino,
herramienta y hashes; `jobs/<id>.json` guarda cada registro individual.
`sources/` contiene los originales sin editar, **1254×1254 RGBA** con alfa 0–255.

El importador existente `scripts/import_map_comic_icons.gd` ahora acepta
`--sidebar`: valida el conjunto de tres fuentes antes de reemplazar PNG,
recorta margen alfa, ajusta proporcionalmente a 240 px y centra en un lienzo
transparente de **256×256**. Modo por defecto: las seis ilustraciones de sala,
sin cambio de contrato. Las tres nuevas texturas finales suman unos **318 KiB**.

El inventario postapocalíptico registra hashes y procedencia. Tipo derivado
`map_sidebar_illustration` excluido del flujo de creación de vectores; las rutas
nuevas tampoco pertenecen a la lista del importador de SVG. No hay cambios en
reglas, generación de caminos ni guardados.

## Validación actual

- Mapa **141/0** y caminos **153/0**, ambos nativos en X11 aislado, Audio Dummy.
- Capturas revisadas: `artifacts/map/group-open.png` y
  `artifacts/paths/floor_3_3.png`; panel abierto, rótulos y tres iconos visibles.
- Auditoría: **683 recursos activos válidos, cero pendientes/desajustes**.
- Avisos de recursos al cerrar las pruebas, sin errores de script/aserciones.
  Sin exportar ni probar Web/dispositivo físico.
