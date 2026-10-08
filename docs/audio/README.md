## Actualización de pulido — 07/10/2026

[Implementación actual, assets, reglas y validación](../polish_2026_10/README.md).
La documentación y resultados anteriores se conservan como historial.

# Audio — 05/10/2026

## Alcance

Primera selección de 48 audios descargados con licencia CC0: cinco músicas,
cuatro ambientes y 39 efectos. Recursos finales Ogg Vorbis en `assets/audio/`,
7,37 MiB en total. Todo se reproduce localmente, sin descargar nada durante
la partida. Esta selección se puede reemplazar conservando los IDs del catálogo.

| Contexto | Música | Ambiente y efectos propios |
| --- | --- | --- |
| Inicio, opciones y colección | Dark Intro — Nikke | Viento suave |
| Campamento y preparación | A Small Fire Will Do — Cal McEachern / Trex0n | Fogata, aves y viento |
| Mercado | Continúa el tema del campamento | Monedas y manipulación de objetos |
| Herrería | Continúa el tema del campamento | Fuego y golpes de martillo |
| Iglesia | Continúa el tema del campamento, más bajo | Viento tenue y campanas ocasionales |
| Refugio | Continúa el tema del campamento | Fuego y tela |
| Expediciones | Continúa el tema del campamento | Viento y papeles |
| Descanso | Tema tranquilo del campamento | Fogata y sonido de curación/mejora |
| Mapa y salas de la cripta | Dungeon Ambience — yd | Cueva con viento y gotas |
| Mapa y salas del bosque | Forest Ambience — TinyWorlds | Aves y viento |
| Combate | Heartfelt Battle, sección loop — request | Armas, hechizos, impactos, bloqueos y criaturas |
| Recompensa | Continúa batalla con menor volumen | Aviso de victoria |
| Victoria / derrota | Campamento / inicio | Efecto de resultado |

Botones compartidos y botones creados directamente por las pantallas tienen
sonido solo al pulsarlos, incluidos cofres y encuentros. Pasar el mouse
por los botones no reproduce efectos. Hay efectos
para selección y uso de carta, descarte en cenizas, cada golpe de un combo,
contraataques, defensa, veneno, curación, muerte, compras, mejoras y consumibles.
Los esqueletos usan sonidos secos de huesos; goblins y bestias, voces de criatura;
elementales, magia; bandidos, armas. Son aproximaciones iniciales que se pueden
ajustar después de escucharlas jugando.

## Organización y comportamiento

- `src/audio/audio_manager.gd`: nodo persistente bajo el controlador. Buses
  Music, Ambience y SFX enviados a Master; doce voces reutilizables para efectos.
- `src/audio/screen_audio.gd`: selecciona contexto a partir de pantalla, piso y
  sala. Abrir bolsa o mazo conserva la música de la aventura.
- `src/audio/battle_audio.gd`: selección de efectos por héroe/acción y familia
  visual del enemigo. `combat_flow.gd` y `card_impacts.gd` lo invocan al presentar
  acciones ya resueltas y guardadas. No calcula daño ni modifica partidas.
- `data/audio.json`: rutas, variantes, ganancias y contextos. Para reemplazar un
  sonido basta actualizar su ruta; para modificar cuándo suena, editar el contexto
  o el evento correspondiente. No hace falta cambiar IDs de héroes ni cartas.
- `src/ui/screens/options_screen.gd`: pantalla extraída de `main.gd`, con volumen
  general, música, efectos/ambiente y pantalla completa.

La música cambia con fundido de 0,7 s. Reconstruir una vista, comprar o elegir
otro héroe no reinicia la pista. Entrar en un edificio conserva el reproductor
del campamento y cambia los ambientes. Los sonidos ocasionales usan tiempos de
5–11 s y un RNG propio que no consume la secuencia aleatoria del juego.

Los valores `music_volume` y `sfx_volume` se agregan al diccionario de opciones
existente; valores predeterminados 0,75 y 0,85. `volume` sigue siendo general.
Los guardados anteriores funcionan sin migración y conservan su volumen previo.

## Procedencia y preparación

`sources.json` registra autor, página, URL de descarga, archivo dentro del paquete,
licencia, hashes originales/finales y procesamiento de **cada archivo**.
`licenses/` conserva las páginas fuente verificadas al descargar. No se añadieron
paquetes completos, previews ni WAV pesados a los recursos del juego.

Fuentes principales:

- Kenney: [Interface Sounds](https://kenney.nl/assets/interface-sounds),
  [RPG Audio](https://kenney.nl/assets/rpg-audio) e
  [Impact Sounds](https://kenney.nl/assets/impact-sounds).
- rubberduck: [80 CC0 RPG SFX](https://opengameart.org/content/80-cc0-rpg-sfx).
- Música: [Dark Intro](https://opengameart.org/content/dark-intro),
  [A Small Fire Will Do](https://opengameart.org/content/a-small-fire-will-do-calming-loop),
  [Heartfelt Battle](https://opengameart.org/content/heartfelt-battle-loopable-fantasy-stringspianohorn),
  [Dungeon Ambience](https://opengameart.org/content/dungeon-ambience) y
  [Forest Ambience](https://opengameart.org/content/forest-ambience).
- Ambientes: [Fireplace Sound loop — PagDev](https://opengameart.org/content/fireplace-sound-loop),
  [wind whoosh loop — SketchMan3](https://opengameart.org/content/wind-whoosh-loop),
  [Ambient Bird Sounds — isaiah658](https://opengameart.org/content/ambient-bird-sounds) y
  [Loopable Dungeon Ambience — JaggedStone](https://opengameart.org/node/29778).

Reproducción de la preparación, con Python 3 y ffmpeg instalados:

```sh
python3 scripts/prepare_audio.py
./scripts/run.sh --headless --editor --import
```

El script verifica CC0 en las páginas y conserva solo los archivos seleccionados.
Normaliza volumen con ffmpeg (música −22 LUFS, ambientes −25, efectos −18;
pico objetivo −2 dBTP), 44,1 kHz, estéreo para música y mono para efectos/ambientes.
Vorbis calidad 4 para música y 3 para el resto. Los loops se activan en las copias
de streams que usa el gestor; los efectos de una sola ejecución no se repiten.

## Validación y pendientes

Cambio de botones del 05/10/2026: eliminada la conexión de audio a `mouse_entered`
y su temporizador; se conserva `pressed`. Prueba headless de audio posterior:
78 comprobaciones sin fallos. Sin nueva revisión auditiva, prueba Web o exportación.

Resultados de la integración anterior (previos a quitar el sonido de hover):

- Prueba de audio: 78 comprobaciones headless y 79 nativas, sin fallos. Verifica
  los 48 streams, continuidad musical, limpieza de canales, volúmenes y guardado,
  bolsa real durante combate, botones y sonidos individuales por golpe de combo.
- Regresiones locales: mercado 61, herrería 110, inicio 11 comprobaciones;
  secuencia de turno, contraataques y mejora de cartas sin fallos;
  iglesia/expediciones 39 comprobaciones sin fallos. Los tests que instancian audio
  liberan la pantalla y esperan al mezclador antes de cerrar.
- Captura nativa del mezclador en `artifacts/audio/mix.wav`: señal real, pico
  máximo −3,37 dBFS, sin saturación en ese recorrido. Revisión visual local de
  opciones a 1280×720 en Compatibility/Mesa llvmpipe. Esto verifica reproducción
  y mezcla; no sustituye una evaluación auditiva por altavoces.
- Los 48 hashes y rutas del manifiesto coinciden con los recursos finales.
  No se exportó ni se probó en navegador, emulador o dispositivo físico.

La selección auditiva final queda a criterio del usuario.

En Web puede ser necesario un primer clic/toque para habilitar audio, por las
políticas de autoplay del navegador; ver
[documentación de Godot](https://docs.godotengine.org/en/stable/tutorials/export/exporting_for_web.html#audio).
No se usan efectos de audio de Godot en runtime, lo que evita depender de esos
efectos en el modo Sample de Web. La grabación del mezclador pertenece solo al test
nativo y no forma parte del juego.

## Silencio en Web: canales dinámicos — 05/10/2026

Reproducido con el `TestWeb/` exportado por el usuario en Chromium local: los
48 recursos y el catálogo están incluidos, AudioContext está `running`, los
volúmenes no están muteados y el mezclador entrega cero. Por tanto, el caso
observado no se explica por la restricción de autoplay.

La ruta Sample de Godot 4.7.2 recibe `-1` desde `AudioServer.add_bus()`, pero su
`Bus.addAt(-1)` mueve el nuevo canal mediante índices negativos. Master deja de
estar primero, los envíos quedan desalineados y forman un circuito sin salida.
Fuentes del motor: [AudioServer.add_bus](https://github.com/godotengine/godot/blob/4.7.2-stable/servers/audio/audio_server.cpp)
y [Bus.addAt/move de Web](https://github.com/godotengine/godot/blob/4.7.2-stable/platform/web/js/libs/library_godot_audio.js).

El gestor ahora crece la lista con `AudioServer.set_bus_count(bus_count + 1)`
antes de nombrar cada canal. Esa ruta crea canales al final sin mover Master.
Mantiene Sample, los mismos volúmenes, pistas y fundidos; no fuerza Stream ni
requiere threads o cabeceras nuevas del servidor.

### Comprobación y reproducción

`tests/test_web_audio.cjs` usa una exportación existente servida por HTTP y
Playwright. Intercepta `index.js` **solo en memoria durante la prueba** para
comparar la ruta original con la operación equivalente a `set_bus_count`.
No exporta, no escribe en `TestWeb/` y no valida un nuevo paquete del proyecto.
Genera el informe `artifacts/audio/web_bus_probe.json`.

```sh
python3 -m http.server 8766 --bind 127.0.0.1 --directory TestWeb
# En otra terminal, con Playwright disponible en node_modules/NODE_PATH:
node tests/test_web_audio.cjs
```

Resultado: la ruta original entrega cero; la corregida entrega señal no nula,
Master conserva salida al navegador y los otros tres canales apuntan a Master.
Las pruebas del código actualizado también pasan: 78 comprobaciones headless y
79 nativas, sin fallos. Sin evaluación por altavoces ni nueva exportación.

Para incorporar la corrección, el usuario debe volver a exportar y subir todos
los archivos generados, incluidos `.pck`, `.js`, `.wasm` y los dos worklets de
audio. Después recargar sin caché. El clic inicial puede seguir siendo necesario
por la política de autoplay. Si persiste, comprobar volumen del juego/pestaña y
los errores o respuestas 404 de la consola/red del navegador.

## Ampliación del 07/10/2026

Fortaleza reutiliza música de cripta con ambiente de fuego/viento. El nuevo control ambiental multiplica el nivel previo de efectos para conservar preferencias anteriores; no se descargaron músicas nuevas en esta entrega.

[Reglas, assets y pruebas actuales](../expansion_2026_10/README.md).

## Mezcla y cinemáticas — 08/10/2026

Dos arreglos ambientales CC0 de fuentes ya presentes: inicio (40 s) y retorno
(36 s), en `assets/audio/music/cinematic_*.ogg`; procedencia en `sources.json`.
Guardianes usan música propia desde el principio; sus finales y las historias
tienen contextos diferenciados. Limitador de picos y reducción suave de 3 dB de
música al impactar, con recuperación del volumen del usuario; voces saturadas
reutilizan la más antigua. Nada de sonido por hover.

[Implementación y pruebas locales](../cinematics/README.md). No se escuchó ni
validó esta entrega en Web o dispositivo físico; los recursos y la reproducción
local se verificaron automáticamente.

## Choques contra bloqueo — 08/10/2026

Dos nuevos impactos metálicos CC0 de Kenney: `metal_clash` y `metal_clash_2`,
con filtro, realce de agudos y resonancia corta. `shield_impact` usa estas variantes
tanto para bloqueo completo como parcial; sin absorción conserva `flesh_impact`.
Procedencia/hashes en `sources.json`, originales en `metal/sources/` con `.gdignore`.
Catálogo actual: ocho músicas/arreglos, cuatro ambientes y 41 efectos.
[Validación nativa y detalles](../presentation_refinements/README.md).
