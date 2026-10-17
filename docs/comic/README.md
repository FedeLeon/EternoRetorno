# Primeros planos de combate

## Renovación de cómic — 17/10/2026

Todos los primeros planos de héroes y enemigos fueron redibujados con tinta,
color plano, tramas y recorte blanco. Siguen siendo estáticos, con rayos y
partículas en movimiento y panel oblicuo detrás; conservan encuadre y duración.
Los recursos que ya tienen el borde pintado omiten el contorno adicional del shader.
[Fuentes, arquitectura y validación actual](../comic_rebuild_2026_10_17/README.md).

## Estado actual — 14/10/2026

Los cuatro héroes muestran **una ilustración estática de ataque y una de defensa**,
transparentes, con tinta negra, cel shading y colores vivos. El personaje permanece quieto y las
partículas/energía se mueven detrás. Se mantiene el encuadre inferior izquierdo.
[Dirección actual, fuentes y pruebas](../art_direction/postapocalyptic/README.md).

`hero_cut_in.gd` selecciona `assets/comic/static/<hero>_<action>.png`.
`comic_cut_in.gd` comparte presentación con enemigos, que también muestran una ilustración estática por máquina. Los atlas de los actores del escenario conservan sus poses; no se retiran las animaciones de los actores normales del escenario.
Los combos conservan una presentación por golpe y las defensas su receptor real.

## Documentación histórica

Las etapas de [movimiento](motion/README.md), [HD](hd/README.md),
[fluidez](smooth/README.md) y [primer sketchbook](sketchbook/README.md) conservan
prompts y decisiones. Sus atlas, fuentes PNG y montadores animados de héroes se
retiraron el 14/10; los comandos de esas etapas ya no describen el flujo actual.
