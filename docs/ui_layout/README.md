# Revisión de posiciones y legibilidad — 08/10/2026

## Alcance y decisiones

Se recorrieron localmente inicio, opciones, campamento y edificios, preparación,
colección, bestiario, mapas de los tres pisos, combate con tres enemigos,
mazo, bolsa, mercader, descanso, encuentros, recompensas y entrenamiento.
La revisión adicional cubre vínculos bloqueados/desbloqueados, decisiones sobre
cartas, mejora seleccionada, victoria/derrota y textos grandes (112 %).

Las vistas que ya eran legibles mantienen su composición. Cambios concretos:

| Vista | Ajuste y motivo |
| --- | --- |
| Ver mazo | Cartas de 224×368, filas de 384 px; más verticales y con separación para la pastilla inferior. |
| Mejorar carta | Cartas de 248×374 en cuatro columnas centradas, fondo de inventario existente y franja de acciones separada de la lista desplazable. Conserva preview y confirmación. |
| Retirar/transformar/intercambiar carta | Misma proporción y alineación de cuatro columnas; franja inferior con Confirmar y Continuar sin cambiar. |
| Vínculos | Volver al Refugio arriba a la derecha, lista más alta, títulos diferenciados, separación entre historia y selector; selector compacto de 510 px. Las tarjetas crecen con el diálogo. |
| Mercader errante | Icono de cada consumible, ofertas más altas y desplazables para descripciones largas; comprar conserva la posición. Más altura para la descripción de intercambio y controles alineados debajo. |
| Victoria y derrota | Fondo ilustrado existente del piso final, panel oscuro, cuatro estadísticas destacadas, detalles desplazables y navegación fija. Una aventura de un piso identifica su mazmorra correctamente. |
| Avisos de compras/mejoras | En mercado, herrería, iglesia, expediciones y mercader se ubican a la izquierda, junto al personaje; evitan cubrir tarjetas y acciones de la derecha. |
| Encabezados secundarios | Reservan espacio según el ancho del botón de navegación, evitando que el título use la zona del botón. |

No se generaron imágenes nuevas: se reutilizan los fondos de inventario y las
cinemáticas de cripta, bosque y fortaleza. Su procedencia sigue en
[cinemáticas](../cinematics/README.md) y [objetos](../objects/README.md).

## Archivos y separación

- `src/ui/screens/{deck,card_upgrade,event_cards,bonds,merchant,run_result}_screen.gd`:
  composición propia de cada vista.
- `src/ui/components/section_header.gd`: acción y ancho opcionales; menú anterior
  por defecto para conservar los otros consumidores.
- `src/ui/components/inventory_background.gd`: padre opcional para reutilizarlo
  dentro de la pantalla de mejora sin tapar sus controles.
- `src/ui/components/message_toast.gd`: posición según la vista.

No se ampliaron `main.gd` ni las reglas. No cambian IDs, formato de guardado,
costes, premios, objetivos válidos ni selección/confirmación de cartas.

## Validación de esta entrega

- Godot 4.7.2 local, render nativo Compatibility, Mesa llvmpipe, 1280×720.
- Recorrido nativo: **50 capturas de vistas/variantes**, **14 comprobaciones**
  aprobadas y ninguna expansión de altura de etiquetas por encima del espacio
  previsto. Incluye texto grande, vínculos con tres victorias, mejora seleccionada
  y resumen con 33 reliquias, doce desbloqueos y contrato.
- Dos capturas adicionales comprueban los avisos largos en mercado/mercader.
  Comprobación nativa de las ocho descripciones de consumibles con texto grande
  y de una compra real que conserva el desplazamiento del mercader.
- Inspección visual de capturas principales y casos modificados; los recortes
  de filas en los extremos de listas son el desplazamiento esperado.
- **7/7 suites headless aprobadas en esta entrega**: `test_card_upgrade`,
  `test_expansion_ui`, `test_equipment_ui`, `test_market_ui`,
  `test_adventure_expansion`, `test_collection_ui`, `test_game`.
- `git diff --check` aprobado. Las pruebas de mercado/equipamiento todavía
  emiten advertencias de recursos retenidos al cerrar; sus aserciones pasan.
- Diagnósticos locales ignorados: `artifacts/layout-review/`, con informe
  `ui-audit.json`, `regressions.json`, capturas y logs. No son recursos del juego.

La comprobación automática de alturas no prueba toda posible superposición.
Los cambios se revisaron visualmente en resolución de proyecto; no se exportó
Web/APK ni se validó navegador, emulador o dispositivo físico. Queda contrastar
el tamaño real de los controles en pantallas pequeñas cuando se pruebe allí.
