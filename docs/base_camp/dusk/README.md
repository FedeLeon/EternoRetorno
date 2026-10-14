# Campamento al atardecer — 13/10/2026

Rediseño del exterior con grafito y lápices de colores: negro/gris/violeta,
trazos buscados, tramado irregular y acentos ámbar. El sol baja detrás de las
montañas; el lago y las ruinas quedan al fondo. La ilustración ocupa el espacio
debajo de la barra superior, para que el sol no quede tapado por el menú.
La fogata iluminada organiza los caminos y permanece despejada de carteles.

## Distribución e interacción

| Lugar | Ubicación | Estado |
| --- | --- | --- |
| Mercado | Arriba a la izquierda | Solar 1, construible |
| Herrería | Abajo a la izquierda | Solar 3, construible |
| Iglesia | Arriba a la derecha | Solar 4, construible |
| Expediciones | Centro inferior, debajo de la fogata | Solar 2, construible |
| Refugio | Entre el mercado y la fogata | Permanente |
| Proyectos | Abajo a la derecha | Permanente |
| Aventuras | Arco del extremo derecho | Acceso a nueva/continuar aventura |
| Entrenamiento | Botón cuadrado inferior izquierdo | Muñeco dibujado |

El paisaje no contiene solares ni edificios construibles pintados. Los solares
son cutouts independientes: se omiten al construir y aparecen los edificios
según el perfil guardado. Se conservan IDs, costes, contratos, mejoras y guardados.
Los carteles están separados y dentro de la vista; los edificios construidos
reutilizan la máscara alfa de clic existente.

## Assets y animación

Diez PNG en `assets/base_camp/dusk/`: fondo, seis edificios, muñeco, solar y
atlas de fuego. El atlas tiene 24 cuadros de 256×256, seis columnas y cuatro
filas, a 12 FPS; `data/camp_fire_dusk.json` registra la base de cada llama para
evitar saltos de apoyo. `campfire.gd` admite atlas, velocidad y estilo por
instancia; selección/descanso conservan su configuración anterior.

`assets/shaders/camp_dusk.gdshader` limita el movimiento a árboles laterales
y lago lejano, con una pequeña variación de luz sobre el suelo de la fogata.
La llama usa filtrado lineal y las chispas son trazos pequeños.

Arte generado con **image_gen.imagegen integrado**; el aspecto de dibujo manual
no implica autoría humana. [Prompts completos](prompts.json),
[fuentes, hashes y normalización](sources.json). Las tres fuentes originales
están en `sources/`, excluidas de exportación como el resto de `docs/`.
El atlas arquitectónico tiene espaciado irregular: el importador recorta por
siluetas medidas, en lugar de dividir celdas que cortarían tejados o puertas.
Mantiene proporciones, alfa y márgenes de 16 px, sin repintar las imágenes.

```sh
.tools/Godot_v4.7.2-stable_linux.x86_64 --headless --path . --script scripts/import_dusk_camp.gd
.tools/Godot_v4.7.2-stable_linux.x86_64 --headless --editor --path . --import
```

## Código y validación actual

- `ui/screens/base_camp_screen.gd`: composición y zonas interactivas, sin reglas.
- `ui/screen_backgrounds.gd`: fondo y shader; mantiene `DayCampBackground` como
  nombre interno compatible, aunque la escena ahora sea crepuscular.
- `campfire.gd`: reproducción configurada por la pantalla, con valores previos
  como predeterminados para las otras vistas.
- `tests/test_camp_plot_ground.gd`: construcción, desaparición de solares,
  edificios permanentes, 24 cuadros y carteles visibles/separados/clicables.
- `tests/test_base_camp.gd`: clics por cartel y regiones animadas ajustadas al
  nuevo dibujo; nueva/continuar aventura y cancelación conservan estado.

Pruebas actuales sin fallos: campamento 34 headless y 38 con ventana;
construcción/disposición 95 con ventana; herrería UI 96, expansión UI 33 y
selección alrededor de fogata 35 headless. Revisión visual local a 1280×720
de los solares, edificios parciales y campamento completo. Las capturas son
evidencia temporal en `artifacts/camp_dusk/`, sin exportación.

Los tests headless de campamento y selección informan objetos/recursos
pendientes al cierre; las pruebas con ventana no los informan. El driver local
Mesa/llvmpipe avisa que no puede cambiar V-Sync. No se exportó ni se verificó
Web, emulador o dispositivo físico.

Pendiente fuera de este cambio: convertir interiores y selección/descanso a
la misma dirección visual. Los assets de esas vistas no se sustituyen aquí.
