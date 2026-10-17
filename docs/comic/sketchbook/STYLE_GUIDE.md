# Guía común de arte sketchbook

> Dirección histórica, sustituida el 17/10/2026. Para cualquier asset nuevo usar
> la [guía vigente de cómic y recorte blanco](../../comic_rebuild_2026_10_17/STYLE_GUIDE.md).
> Este documento conserva la procedencia de las ilustraciones anteriores.

## Reglas para cualquier asset nuevo

- Grafito y lápices de colores: contornos buscados, líneas dobles, tramado que
  sigue los materiales y pigmento irregular. Conservar imperfecciones legibles.
- Negro, gris y violeta dominantes; piel/cabello y detalles funcionales pueden
  conservar acentos propios. Siluetas claras y masas oscuras suficientes.
- En escenas completas, papel discreto bajo el dibujo; en sprites y primeros
  planos, fondo transparente y textura solo dentro de las formas dibujadas.
- Armas, escudos y efectos comparten el trazo. Chispas, energía y humo pueden
  verse como marcas rápidas de lápiz; evitar brillo plástico o exceso de bloom.
- Cada héroe conserva rostro, edad aproximada, peinado, vestuario y arma entre
  poses. Mauro siempre tiene rostro humano visible, sin máscara ni pico.
- Diseñar primero para tamaño real de uso: no convertir iconos pequeños en
  ilustraciones saturadas de detalles ni fondos en ruido que tape la interfaz.
- Reservar zonas tranquilas en fondos para cartas, barras, textos y botones.
- Animación: encuadre común, apoyo/registro consistente, anticipación e impacto
  reconocibles, recuperación; evitar cambios involuntarios de escala.

## Referencias aceptadas

`assets/heroes/identity/sketchbook.png`, `rogue_unmasked.png` y
`portraits/<hero>.png`. El rostro nuevo de Nicolás tiene el visor levantado.
La versión enmascarada de Mauro en la hoja antigua no es referencia válida
para su cara; usar su cuerpo/retrato independiente.

## Alcance

Este criterio se aplica a todo el juego, incluyendo mazmorras, enemigos y
cinemáticas. Las fuentes anteriores se reemplazan por conjuntos completos
verificados, sin usar un filtro general de papel como sustituto del rediseño.
Las fuentes generadas conservan prompt/procedencia; se distingue siempre el
aspecto manual buscado de la generación mediante ImageGen.

## Cartas: ilustración mínima — decisión del 14/10/2026

Las cartas deben tener poco detalle y un motivo central que explique su efecto.
No requieren un retrato ni al héroe completo. Priorizar objetos o gestos simples
(espada, escudo, frasco, venda, cristal, trazos de impactos) con una a tres formas
principales, silueta legible y fondo oscuro despejado. Conservar grafito/lápices,
trazo imperfecto, gris/violeta; verde para veneno y rojo para curación/sangre.
Evitar paisajes, escenas narrativas, filigranas, armaduras complejas, bloom y
partículas que llenen la imagen. El texto de Godot explica los valores exactos;
no dibujar números, rótulos ni explicaciones dentro de la ilustración.
[Motivos por carta, prompts e integración](../../cards/minimal/README.md).
