# Revisión de animaciones y selección — 14/10/2026

## Escenarios y escala del combate — 15/10/2026

[Distribución actual](../battle_effects/README.md): barras elevadas, actores
más grandes y estados/intenciones debajo de los pies, con nombres enemigos
en inspección al tocar. La escala se mantiene uniforme y se limita a la altura
disponible; la retaguardia ya no desplaza el personaje hacia arriba. Las raíces
decorativas siguen el nuevo suelo.

Corregido el civil gigante pintado en `forest/combat_glade.png`: escenario
industrial vacío de cómic con suelo continuo. Fuente generada conservada en
`docs/art_direction/postapocalyptic/sources/forest__combat_glade.png`, salida
activa 1280×720 y cola/registro/hashes actualizados para no revertir la edición.
[Prompt y herramienta](industrial_background_fix.json). El encuadre por mazmorra
coloca la unión pared/suelo detrás de los actores, especialmente en la tercera.

## Rayos enemigos hasta los bordes — 15/10/2026

`enemy_cut_in.gd` activa también `full_view_rays`, reutilizando el alcance
calculado por `hero_comic_fx.ray_reach`. El lienzo compartido ya ocupa toda la
pantalla; los rayos parten del lado derecho y sus extremos quedan fuera de la
vista, como en los héroes. Se conservan imagen estática, borde, color, partículas,
duración, preferencias de destellos/efectos y entrada sin bloquear. No requiere
assets nuevos ni modifica reglas o guardados.

`test_enemy_cut_in.gd` comprueba lienzo completo y alcance en 16 direcciones
desde el origen derecho real para cada apariencia, además de transparencia,
posición estática y finalización. La validación anterior de héroes de la sección
siguiente se conserva como evidencia de su entrega original.

Validación de esta extensión: primeros planos de los 56 enemigos **sin fallos
en render nativo aislado** a 1280×720; captura actual de `crypt_lancer` revisada
en `artifacts/combat/enemy-comic.png`. Regresión actual de héroes **260/0
headless**. Audio Dummy; sin exportar ni probar Web/dispositivo.

## Rayos de primeros planos hasta los bordes — 15/10/2026

Los rayos de luz detrás de los ataques y defensas de los cuatro héroes ahora
atraviesan la vista completa, en vez de terminar a una distancia proporcional
al recorte del personaje. El lienzo `HeroLights` ocupa toda la superposición y
`hero_comic_fx.ray_reach()` calcula la longitud desde el origen hasta la esquina
más lejana, con margen y compensación por la fase más corta de crecimiento.
Ambos vértices exteriores quedan fuera de pantalla, evitando puntas/cortes
visibles dentro de la escena.

`hero_cut_in.gd` activa `full_view_rays`; la extensión posterior a enemigos se
documenta arriba. El valor predeterminado del componente sigue siendo local.
Se conservan el dibujo estático, encuadre,
partículas, arcos defensivos, color, opacidad, duración, orden detrás del héroe,
preferencias de efectos y entrada sin bloquear. No se modifican assets/prompts,
reglas ni guardados.

Validación actual: `test_hero_cut_in.gd` **260/0 nativo aislado**, ocho acciones
(cuatro héroes × ataque/defensa), lienzo completo, longitud en 16 direcciones
para cada caso desde el origen real, imagen quieta y finalización única.
Capturas de ataque de Nicolás y defensa de Inés revisadas en
`artifacts/comic_static/`. Regresiones headless: imágenes estáticas **33/0**;
primeros planos enemigos **sin fallos**. Audio Dummy, sin exportar ni probar
Web/dispositivo.

## Carrera de victoria con tamaño y suelo estables — 15/10/2026

`hero_run.gd` separa la salida de actores HD de los clásicos: los primeros
inician `play_once("run")` en su propio controlador, cancelando acciones
anteriores. Ya no reciben ajustes de posición/escala basados en celdas clásicas
de 128 px y alturas de personajes anteriores.

La carrera dibujada era más pequeña que el reposo: por ejemplo, Nicolás pasaba
de 183 px de altura opaca a 141–145 px. Se calcula una escala proporcional única
para la secuencia con la altura de reposo y la mediana de los cuadros actuales;
se conserva la variación natural del paso sin deformar cada cuadro. Resultado
cacheado por `SpriteFrames`, con caché acotada. Los clásicos con equipo usan
la misma medición de su arte activo, conservando su restauración de estado.

`detailed_hero._place()` centra la carrera y compensa su base alfa por cuadro
para mantener los pies en `size.y`, con escala exterior/pivote inalterados. El
callback de cuadro solo interviene en `run`, conservando guardia y acciones.
La traslación de salida sigue siendo horizontal, de 2,5–2,62 s. No se modifican
PNG, fuentes/prompts, reglas, premios, equipamiento ni guardados.

Validación de este cambio:

- Nueva `test_victory_running.gd`: **258 comprobaciones / 44 fallos antes**;
  después **364/0 headless y 348/0 nativo aislado**. Los conteos de muestreo
  varían con los tiempos de reproducción. Incluye los 12 cuadros de los cuatro
  héroes, transición desde guardia, restauración de reposo y victorias reales
  con dos parejas, línea de pies y tamaño durante el recorrido, estado resuelto
  sin cambios. Capturas de ambas parejas a mitad de salida revisadas en
  `artifacts/victory-running/`.
- Regresiones headless: carrera clásica **93/0**, héroes detallados **1121/0**,
  guardia **906/0** y cuerpo a cuerpo **1728/0**.
- Audio Dummy. Avisos de recursos al cerrar, sin errores de script/aserciones.
  No se exportó ni se validó en Web o dispositivo físico.

## Tamaño estable de enemigos y contraataques — 15/10/2026

Se corrigieron dos causas comprobadas del encogimiento:

- `src/enemy_sprite.gd`: una medida de 128 px puede regresar como 127,99998 px
  por las transformaciones del contenedor. El `floor` recalculaba escala 0,25
  en lugar de 0,5 al iniciar un ataque/contraataque. `_place()` redondea las
  medidas a milésimas de píxel antes de calcular los escalones de escala;
  conserva el tamaño previsto y el pivote del actor.
- La fuente `enemies__animations__flying_1` tiene filas de alturas diferentes.
  El recorte automático seleccionaba fragmentos del supervisor para el sabueso;
  su cuadro de contacto medía solo un 60 % de la altura de reposo. Se reempacaron
  `flying_1`, `flying_6`, `crypt_wolf` y `bandit_7` y sus retratos HD desde la
  fuente original, sin generar arte ni cambiar identidades/estadísticas.
  `docs/art_direction/postapocalyptic/actor_layouts.json` conserva separadores
  revisados y hash de la fuente. Importador versión 6 para esa hoja; resto en 5.
  El argumento `--job=enemies__animations__flying_1` permite repetir solo esa
  importación; una segunda ejecución integra cero recursos. Hashes y métricas
  en `assets.json` y `data/enemy_pose_sizes.json` actualizados.

Regresión: `test_enemy_pose_sizes.gd` detectó el cuadro defectuoso antes del
arreglo (**1091 comprobaciones, 1 fallo**); ahora **1147/0 headless**, incluidos
los 56 atlas, medidas subpíxel, pies, reacción y cenizas. Nueva prueba
`test_enemy_counter_size.gd`: combo real de tres golpes y tres contraataques
para las cuatro máquinas de esa hoja, tamaño de cada pose y estado ya resuelto
sin modificaciones: **400/0 headless y 410/0 nativo aislado**. Las cantidades de
comprobaciones varían con los cambios de cuadro de reposo. Capturas nativas de
los cuatro contactos en `artifacts/enemy-counter/`; sabueso y supervisor
revisados visualmente; también se revisaron ambos drones. Regresiones adicionales
headless: enemigos **1450/0**, cuerpo a cuerpo **1726/0**, presentación **46/0** y
movimiento de actores **sin fallos**. Estas pruebas mantienen avisos de recursos
al cerrar, sin errores de script/aserciones. Auditoría de arte: **680 recursos, 140 fuentes, sin
pendientes**. Audio Dummy; no exportado ni validado en Web/dispositivo.

## Guardia intermitente de héroes — 15/10/2026

Los cuatro actores detallados de batalla alternan reposo estable con un gesto
breve de guardia: manos/brazos y arma, flexión leve y retorno. Se reutilizan los
dibujos del atlas `assets/heroes/detail/<hero>_idle.png`, con secuencias propias
en `presentation/hero_guard_idle.gd`; no se generan nuevos PNG ni se modifican
fuentes/prompts, proporciones, escala o equipo.

- Primera pausa de 2,8–4,39 s según héroe; gestos de 2,4–2,64 s y pausas sucesivas
  de 4,2–6,8 s. Variación determinista de presentación, sin consumir RNG jugable.
- Secuencias de ida/vuelta sobre poses dibujadas; fundido de 80 ms entre cuadros.
  El offset compensa la base alfa de cada cuadro: botas en la misma línea,
  sin trasladar ni comprimir el cuerpo completo.
- Ataque, defensa, reacción, habilidad, carrera y caída interrumpen el gesto.
  Al regresar/revivir se recupera cuadro 0 y una pausa. El registro de revisiones
  de acciones sigue evitando que una acción antigua sobrescriba una nueva.
- Solo `detailed_hero.gd` usa este controlador. Los retratos, primeros planos
  estáticos, personajes sentados y actores clásicos no cambian.

Validación actual: `test_hero_guard_idle.gd` **906/0**, nativo aislado, con los
cuatro héroes, capturas y avance a intervalos reales de 0,1 s; pies, escala,
pausas, interrupción, carrera y caídos cubiertos. `test_detailed_heroes.gd`
**1121/0** y `test_polish_motion.gd` **356/0**, headless, sobre poses/acciones y
equipamiento. Capturas de reposo/guardia revisadas. Audio Dummy; el test de
pulido conserva avisos históricos por cargar PNG como Image, sin errores de
script ni aserciones. Sin exportar ni probar Web/dispositivo.

## Alcance y problemas encontrados

Se revisó la cadena activa de presentación: poses detalladas, atlas clásicos,
carrera, ataques cuerpo a cuerpo, proyectiles, primeros planos, reacciones,
corrosión, disolución, descarte, bloqueo y transición del turno. Inventario de
96 hojas activas y 928 cuadros de héroes/enemigos en `atlas_audit.json`.
Las comprobaciones técnicas de cuadros no sustituyen ver todos los encuentros
jugando; las capturas locales indicadas en `validation.json` son la revisión visual.

- Las fuentes de poses no tienen todas seis columnas por fila: Profesora tiene
  7/7/6/4; Carpintero 6/6/6/5. Las otras dos tienen 6/6/6/6, con orden de acciones
  distinto del supuesto. El corte fijo podía mostrar fragmentos de botas de otra
  fila, usar una caída como reacción o una pose especial como carrera.
- `pose_layouts.json` registra distribución y asignación semántica revisadas de
  las cuatro fuentes ImageGen existentes. Extracción geométrica con separadores
  adaptativos y encuadre de la silueta principal; no se redibujan las fuentes.
  Se vuelve a generar todo derivado detallado, clásico, carrera y equipo para
  conservar las rutas, las dimensiones de cuadros, UIDs y las bases 240/368/120.
  El banco del Carpintero tiene 23 dibujos: la celda de reserva se rellena con
  reposo; ninguna secuencia depende de una pose ausente.
- En la revisión del 14/10, `detailed_hero.gd` mantenía el reposo en cuadro 0;
  desde el 15/10 intercala los gestos breves descritos arriba.
  Carrera a 10 FPS. Una acción interrumpida no devuelve a reposo una acción nueva.
- Se reconstruyen también las 56 hojas de enemigos y sus 56 imágenes de
  reposo con encuadre de silueta principal, eliminando fragmentos de otras filas.
  Métricas por cuadro recalculadas desde las hojas nuevas.
- Enemigos con filtro lineal, acorde al arte cómic; conservan correcciones de
  tamaño por cuadro, reacciones verdes/rojas y disolución sin resolver daño otra vez.
- Selección: dos personajes por lado, pies en la misma línea de suelo, imágenes
  recortadas por alfa y zona de toque que incluye toda la figura. El descanso
  comparte el encuadre proporcional mediante `seated_hero_art.gd`.
- Primeros planos: rayos radiales amplios, halo, chispas escalonadas y arcos de
  protección detrás del personaje. Ilustración sin movimiento ni cambio de pose;
  escenario visible, sin panel opaco. Colores por héroe, menor cantidad en calidad
  reducida e intensidad vinculada a la preferencia de destellos.

## Archivos y procedencia

`hero_comic_fx.gd`, `detailed_hero.gd`, `enemy_sprite.gd`, `selection_screen.gd`,
`rest_screen.gd`, `seated_hero_art.gd`, posiciones de preparación en `main.gd`.
Importación: `sketchbook_sheet_packer.gd`, `import_sketchbook_actors.gd -- --comic`,
`import_postapocalyptic_art.gd -- --actors-only`; después
`audit_enemy_pose_sizes.py` y `audit_battle_atlases.py`.
Fuentes/prompts ImageGen existentes en `docs/art_direction/postapocalyptic/`;
registro de procesamiento versión 5 en `assets.json`, con hash de pose_layouts.
Rayos/partículas son geometría nativa animada, sin nuevas imágenes generadas.

## Validación y límites

Ver `validation.json` y el historial para resultados de esta revisión.
Render local aislado con llvmpipe y audio Dummy. Sin exportar ni probar Web,
GPU física, sonido audible o dispositivo móvil. Se conservan partidas y reglas.

## 15/10/2026 — Guardia continua y golpes propios

[Refinamiento de combate](../combat_refinement/README.md): 12 bancos nuevos de
héroes (12 poses cada uno), seis enemigos/jefes con ocho dibujos propios y
tiempos por perfil. Primeros planos estáticos conservados; nuevos importadores
respetados por los anteriores mediante `fluid_revision`. Fuentes y prompts
en `docs/combat_refinement/`; validación actual en ese documento.
