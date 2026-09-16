# Ilustraciones minimalistas de cartas

## Fuentes y estilo

La plantilla del usuario `conceptoCartasImagen.png` se conserva sin editar en
`assets/cards/art/originals.png`. Tiene 5 columnas y 6 filas: guerrero,
guardiana, pícaro, maga, clériga y explorador. Cada fila sigue el orden de las
cinco cartas originales del catálogo. Los 30 recortes son AtlasTexture, sin
copiar cada panel a un archivo independiente. Se excluyen los separadores negros.

Las 60 cartas añadidas reciben ilustraciones individuales generadas con la
herramienta integrada imagegen, usando esa plantilla como referencia de estilo.
Siluetas simples, formas angulosas, fondo oscuro, un gesto luminoso y pocos
colores. Guerrero violeta, guardiana dorado/verde azulado, pícaro verde tóxico,
maga azul eléctrico, clériga dorado y explorador azul hielo. Los marcos existentes
conservan su color por clase. No se incorporan textos dentro de las imágenes.

Prompts completos por ID: [prompts.json](prompts.json). Procedencia de las 60
imágenes: [sources.json](sources.json), con el nombre del original de imagegen.
Las imágenes finales están en `assets/cards/art/<id>.png`, dentro del proyecto.
[Galería navegable y filtrable por héroe](galeria.html), sin conexión ni librerías
externas; abrir el HTML en un navegador local.

## Integración

- `data/card_art.json`: correspondencia explícita ID → textura/región.
- `src/ui/components/card_art.gd`: carga y caché, regiones del atlas y vista sin
  capturar eventos de ratón/táctiles. No calcula efectos ni modifica guardados.
- La fábrica compartida `main.gd::card_panel` coloca el arte dentro de
  `IllustrationSpace`, con margen interior y proporción conservada.
- Mano, recompensas, mazo y mejoras reutilizan esa fábrica. Las cartas mejoradas
  conservan la misma imagen; nombre, coste y efecto siguen siendo datos vivos.
- El mercado incorpora miniaturas del mismo componente a sus filas de compra.
- ENLACE se muestra en una pequeña placa oscura sobre el arte para legibilidad.
- Los PNG nuevos conservan la resolución del concepto; la importación Godot
  limita su lado mayor a 512 píxeles para el juego. La plantilla de 30 paneles
  conserva su resolución para que las coordenadas del atlas sean exactas.

No cambian IDs, mazos, balance, desbloqueos, sinergias ni formato de guardado.
Para añadir una carta futura: crear su ilustración y registrar su ID en el
manifiesto. No reutilizar la imagen de otra carta como sustituto silencioso.

## Revisión

Generación completada: 60 PNG nuevos y 30 regiones del concepto original.
Godot 4.7.2, Linux: 571 comprobaciones de asignaciones, regiones únicas, tamaño,
caché e interacción; cartas 544, distribución de combate 38, mercado 34,
UI 271, sinergias 481 y progresión 795; todas sin fallos.
Revisión visual renderizada de las seis galerías, mano normal/seleccionada y
mercado. Se corrigió el tamaño mínimo de TextureRect antes de cargar la textura,
para evitar que las imágenes ocuparan su tamaño original fuera del marco.
No se exportó APK/Web ni se probó esta entrega en Android o navegador del juego.
Las capturas de pruebas se guardan temporalmente en `artifacts/card_art/` y se
eliminan tras revisarlas. Las ilustraciones y sus prompts son recursos finales.
