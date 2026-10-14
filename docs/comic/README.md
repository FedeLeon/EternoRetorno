# Primeros planos de combate

## Estado actual — 14/10/2026

Los cuatro héroes muestran **una ilustración estática de ataque y una de defensa**,
transparentes, en estilo cómic a lápiz. El personaje permanece quieto y las
partículas/energía se mueven detrás. Se mantiene el encuadre inferior izquierdo.
[Assets nuevos, prompts, limpieza y validación](static/README.md).

`hero_cut_in.gd` selecciona `assets/comic/static/<hero>_<action>.png`.
`comic_cut_in.gd` comparte presentación con enemigos, cuyos atlas/poses siguen
activos. No se retiran las animaciones de los actores normales del escenario.
Los combos conservan una presentación por golpe y las defensas su receptor real.

## Documentación histórica

Las etapas de [movimiento](motion/README.md), [HD](hd/README.md),
[fluidez](smooth/README.md) y [primer sketchbook](sketchbook/README.md) conservan
prompts y decisiones. Sus atlas, fuentes PNG y montadores animados de héroes se
retiraron el 14/10; los comandos de esas etapas ya no describen el flujo actual.
