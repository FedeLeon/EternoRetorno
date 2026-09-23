# Campamento de selección

## Limpieza del 23/09/2026

La fogata activa usa `assets/camp/fire-natural.png` (24 cuadros). Se retiraron `fire-64.png`, `fire-128.png`, `fire-detailed.png` y el importador antiguo. Las descripciones anteriores se conservan como historial y procedencia.
Véase el [inventario de limpieza](../cleanup/2026-09-23.md).

> **Actualización 16/09/2026:** los actores ahora usan cuadros de **128×128**,
> reimportados desde las fuentes originales. Se mantienen tamaño en pantalla,
> diseños y alineación. Ver [calidad actual, archivos y pruebas](../quality/README.md).
> Las medidas de 64 px y comprobaciones que siguen documentan la versión inicial.


Pantalla de elección ambientada en el concept `campamento.png` del usuario.
Fondo sin textos incrustados ni llama fija, seis vistas frontales alrededor de
la fogata, etiquetas de nombre, función y vida y selección de dos personajes.
La descripción completa se conserva en el tooltip de cada personaje.

## Recursos

- `assets/camp/background.png`: fondo de campamento adaptado a horizontal.
- `assets/camp/front-64.png`: seis vistas frontales de 64 × 64 para selección.
  El combate conserva sus sprites y animaciones anteriores.
- `assets/camp/fire-64.png`: seis cuadros de llama, 9 FPS en bucle.
- `src/campfire.gd`: animación, resplandor y 16 chispas pequeñas que ascienden
  y pierden opacidad. No utiliza el generador aleatorio de la aventura.
- `scripts/import_camp.gd`: recorte y escalado nearest reproducibles de las
  fuentes `front-source.png` y `fire-source.png`, conservando transparencia.

Las imágenes se generaron con imagegen integrada; prompts en `prompts.md`.
Los personajes frontales son poses estáticas; la fogata y las chispas se animan.

## Validación local

`./scripts/run.sh --script tests/test_camp.gd`: 47 comprobaciones sin fallos.
Comprueba movimiento de fuego, las 15 parejas mediante eventos de entrada,
límite de dos, deselección e inicio de aventura. Capturas reales en esta carpeta:
`camp-first.png`, `camp-second.png`, `camp-selected.png`.
La prueba de interfaz usa las nuevas posiciones del campamento.
No se compiló APK ni se probó este cambio en Android.

## Barra y acciones (17/09/2026)

Selección usa ahora `selection_screen.gd` y la barra común del campamento con
«Elegí tus personajes · El fuego nos reúne». Volver lleva al campamento.
Panel inferior y botón de reliquia con assets nuevos: [botones](../ui_buttons/README.md).

## Preparación nueva y selección con resplandor — 18/09/2026

Cada entrada a Nueva aventura comienza sin pareja ni reliquia. `open_selection`
limpia las variables de preparación y elimina el borrador legado del perfil,
sin alterar la aventura activa. Elegir héroes/reliquia ya no guarda un borrador;
volver desde reliquias conserva la pareja de esta preparación en memoria.

`selection_screen.gd` reemplaza el borde amarillo por el shader compartido
de `target_glow.gd`, detrás del héroe elegido. La barra inferior conserva
el contador y los botones, sin repetir nombres. Los nombres debajo de cada
héroe y su marca de selección permanecen.

Prueba local renderizada: campamento 47 comprobaciones, incluidas las 15 parejas;
reliquias 48, incluido descarte del borrador legado y retorno a personajes,
sin fallos. Revisión visual Linux 1280×720. Sin exportar APK/Web ni dispositivo.


## 22/09/2026 — Héroes sentados y luz de fogata

La selección reutiliza los seis PNG de `assets/rest/`, sin duplicarlos. Los
personajes de la derecha se invierten para mirar hacia el centro. Se mantiene
el halo de selección, los nombres, funciones y PV. La fila superior sube 30 px
para no solaparse con las poses inferiores. El atlas frontal sigue usándose en
categorías e intenciones de combate; no fue retirado.

`assets/camp/fire-128.png` contiene ocho fotogramas de 128×128, reproducidos a
9 FPS por `src/campfire.gd`; reemplaza visualmente la llama de seis cuadros de
64 px. Conserva resplandor y chispas. Generado con image_gen integrado:
[Prompt y procedencia](fire-detailed.json), fuente en `sources/fire-detailed.png`.
`scripts/import_campfire.gd` transforma la grilla 4×2 en una tira de ocho cuadros,
sin recortes individuales que cambien el anclaje de las llamas.

`src/presentation/firelight.gd` aplica `assets/shaders/firelight.gdshader` sobre
los sprites sentados, en selección y descanso. La luz cálida fluctúa con el
tiempo y recorre suavemente su superficie; conserva alfa, orientación y color
del personaje. No deforma la figura ni consume aleatoriedad del juego.

Validación actual: `test_camp.gd`, 66 comprobaciones renderizadas aprobadas;
`test_rest.gd`, 37 aprobadas. Revisión visual Linux a 1280×720. Comparación de dos
fotogramas: variación visible en llama y sprites de guerrero/guardiana.
Capturas retiradas; sin exportación Web/APK ni pruebas en dispositivo físico.
