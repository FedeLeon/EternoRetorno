# Ilustraciones minimalistas de cartas — 14/10/2026

## Dirección aprobada

Las cartas representan su efecto con pocos elementos y poco detalle. No necesitan
mostrar al héroe: una espada, un escudo, una venda, un frasco, un cristal o unos
trazos de acción bastan. Se conservan el dibujo irregular de grafito/lápices,
fondo de papel gris violeta oscuro, siluetas claras y acentos funcionales:
verde para veneno, rojo para curación/sangre y violeta para energía/protección.
Sin paisajes, retratos, escenas narrativas, filigranas ni adornos dominantes.
Es un estilo visual dibujado a mano, generado mediante `image_gen.imagegen`;
no una afirmación de autoría manual de las imágenes.

## Alcance e integración completada

88 ilustraciones individuales instaladas, 22 por cada protagonista, con un motivo
propio elegido según el nombre y los efectos reales de la carta. Las variaciones
de número/potencia se distinguen con símbolos/trazos sencillos; el texto de la
carta sigue siendo la fuente exacta de sus valores.

- `motifs.json`: decisión visual para cada ID activo.
- `queue.json`: las 88 instrucciones completas y datos de referencia.
- `sources/`: originales de la herramienta; el montaje no inventa dibujos.
- `assets.json`: hashes y procedencia de los recursos finalmente instalados.
- `scripts/import_minimal_cards.gd`: recorte geométrico centrado sin deformación,
  salida de 512×288 y publicación conjunta de `data/card_art.json`.
- `previous_mapping.json`: correspondencia anterior, como registro de sustitución.
- `scripts/review_minimal_cards.py`: hojas de contacto desechables en `artifacts/`;
  nunca modifica el arte del juego.

Se reutiliza `src/ui/components/card_art.gd`, compartido entre mano, mazo,
mercado, mejoras y recompensas; no se agregan pantallas ni una segunda ruta de
render. Se conservan IDs, cartas, balance, costes, marcos y guardados. Las
ilustraciones mejoradas conservan su imagen. Originales/prompts en `docs/`
quedan excluidos de la exportación por la configuración existente.

## Sustitución y revisión

Se retiraron 69 imágenes runtime anteriores y sus imports, con comprobación de
referencias actuales en código, datos, escenas y recursos. `removed.json` registra
rutas, tamaños y hashes. Se mantienen las fuentes históricas en documentación;
los importadores antiguos se retiraron y la cola activa omite las cartas sustituidas.
El catálogo nuevo contiene 88 imágenes diferentes y ocupa aproximadamente 12 MiB
en PNG runtime (no es una medición de exportación).

Tres dibujos de protección de grupo se regeneraron porque sus marcas de compañeros
parecían criaturas: ahora usan escudos simples. Los PNG rechazados se retiraron en la limpieza posterior;
las instrucciones y hashes anteriores permanecen en el historial de procedencia.

[Galería completa](galeria.html), con filtros por héroe y cartas de apoyo.
Las galerías anteriores de arte/apoyo redirigen a esta versión.

## Validación local de esta entrega

- Importación y verificación sintáctica Godot 4.7.2: finalizadas sin errores de script.
- `test_card_art.gd`: 529 comprobaciones, sin fallos; 88 IDs, carga/caché, dimensiones
  y uso compartido de ilustraciones sin interceptar clics.
- `test_support_cards_ui.gd`: 409 comprobaciones sin fallos en X11 aislado,
  Compatibility/Mesa llvmpipe y audio Dummy; cartas normales/mejoradas, tamaños,
  efectos y compra. Al salir reporta 20 instancias ObjectDB/5 recursos vivos:
  pendiente de liberación de la prueba, no fallo de sus aserciones.
- `preview_cards.gd`: captura local de los ocho ejemplos básicos dentro de sus
  marcos, revisada visualmente. Revisión de las 88 ilustraciones en ocho hojas
  de contacto, incluidas las tres correcciones de protección de grupo.
- Auditoría de contenido: 1502 comprobaciones, cero errores. Inventario global:
  636 imágenes actualizadas con hash coincidente, cero imágenes activas pendientes.
- Galería y manifiesto: 88 imágenes diferentes, 512×288, una por ID activo.

Pruebas nativas fuera de pantalla para no interferir con la partida del usuario.
Sin exportación Web/APK, recorrido manual completo ni prueba de dispositivo.
Reiniciar la ejecución tras la importación para renovar las cachés de texturas
si la partida estaba abierta durante el cambio.
