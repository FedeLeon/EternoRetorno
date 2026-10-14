> **Sustitución del 14/10/2026:** el catálogo activo se rediseña con
> [88 ilustraciones minimalistas individuales](../minimal/README.md).
> Esta página conserva la integración y procedencia de las tandas anteriores;
> el atlas básico y las ilustraciones detalladas anteriores dejan de ser el arte
> activo al publicar el manifiesto nuevo. Los IDs y el componente compartido continúan.

# Ilustraciones minimalistas de cartas

## Fuentes y estilo

La plantilla del usuario conserva ahora únicamente las primeras cuatro filas
en `assets/cards/art/originals.png`: Carpintero, Constructora, Boticario y
Profesora. Tiene cinco columnas; sus 20 recortes AtlasTexture mantienen las
coordenadas originales. Se retiraron las filas de los personajes eliminados.

Las 40 ilustraciones individuales del catálogo inicial ampliado conservan sus
prompts y procedencia. Las ampliaciones posteriores se documentan en sus
carpetas propias. La galería HTML muestra únicamente el elenco actual y ajusta
su recorte CSS a la altura nueva de la plantilla. No se genera arte nuevo para
este cambio. [Inventario y pruebas](../../cleanup/2026-10-13.md).

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

## Ampliación de apoyo — 22/09/2026

Se incorporan 24 ilustraciones individuales adicionales con la misma referencia
y paleta; ahora hay 84 imágenes individuales y 30 regiones del concepto inicial.
[Prompts, procedencia, galería y pruebas](../support/README.md). Cada PNG nuevo
se reduce a 512 px de ancho antes de importarlo; las fuentes quedan en documentación.
