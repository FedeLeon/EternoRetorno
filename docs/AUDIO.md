# Audio

## Reproducción

`src/audio/audio_manager.gd` administra reproducción y preferencias;
`screen_audio.gd` selecciona contexto de pantalla; `audio_mix.gd` aplica mezcla
y reducción temporal de música. `battle_audio.gd` traduce acciones confirmadas
a eventos. Los catálogos son `data/audio.json` y `data/battle_audio.json`.

La mezcla y las variaciones de sonido no consumen el RNG de la aventura. Los
clips de combate se preparan offline: no se genera PCM ni se sintetizan voces
durante una batalla.

## Combate

Hay perfiles de ataque, guardia y destrucción para los enemigos del catálogo;
se combinan sonidos mecánicos con características propias por modelo.
Los cuatro protagonistas tienen eventos de esfuerzo al atacar/defenderse.
El impacto contra bloqueo usa golpes de metal y resonancia corta, diferenciados
del daño recibido. Interfaz, cartas, objetos y transiciones conservan sus eventos.

Los recursos actuales incluyen música, ambiente, foley y clips cortos de combate.
Su cantidad y mapeo se consultan en los catálogos, sin confundir variantes de
procesamiento con interpretaciones o grabaciones completamente nuevas.

## Fuentes y licencia

- `art_sources/audio/sources.json`: procedencia de la selección base.
- `art_sources/audio/licenses/`: páginas de licencia y atribución conservadas.
- `art_sources/audio/combat_2026_10_18/`: tomas, licencias y procesamiento de combate.
- `art_sources/whole_game_polish/music_sources.json`: arreglos de grabaciones existentes.

`scripts/prepare_audio.py`, `prepare_combat_audio.py` y `prepare_dungeon_music.py`
son herramientas de preparación. Requieren sus dependencias locales y pueden
sobrescribir recursos; no son comandos de prueba ni se ejecutan para revisar docs.

## Comprobaciones

Las suites Godot verifican eventos y catálogo. En modo headless se usa audio
Dummy: aprobar esas pruebas no certifica la mezcla por escucha.

`tests/test_web_audio.cjs` requiere Playwright y un servidor HTTP con la
exportación web. Hay que iniciarlo antes de ejecutar la prueba y permitir la
interacción que desbloquea audio del navegador. No se exportó ni se ejecutó esa
prueba web en esta revisión documental.

La audición, el volumen relativo y el comportamiento en el navegador necesitan
validación específica; no se infieren de hashes de archivos ni de pruebas headless.
