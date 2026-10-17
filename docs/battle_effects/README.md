## Objetivo junto al daño previsto — 17/10/2026

## Viñetas de combate — 17/10/2026

Actores, primeros planos y todos los iconos renovados con recorte blanco. Las
intenciones usan cartuchos oscuros de tinta/papel; conservan ataque/daño, objetivo,
bloqueo y estados al pie. Barras con borde de tinta y tonos planos, fuentes de
cómic y controles de energía/turno con centro limpio. La presentación mantiene
resolución, RNG y guardado; las métricas de las 56 hojas se recalcularon.
[Dirección, procedencia y validación vigente](../comic_rebuild_2026_10_17/README.md).

`enemy_intent.gd` ordena la fila como ataque + daño, retrato del héroe objetivo,
bloqueo previsto y contraataque. Si ataca a ambos héroes, aparecen ambos retratos
inmediatamente después del daño. La tira de estados permanece debajo; conserva
ancho total, centrado, colores de retrato, consultas y reglas.

Validación actual: HUD **113/0 nativo aislado**, captura
`artifacts/hud/combat.png` revisada; iconos/diálogos **883/0 headless**. Algunas
suites avisan de recursos retenidos al cerrar; sin exportar ni validar Web.

## Cables lineales sobre el suelo — 16/10/2026

La decoración de Cables de sujeción ya no muestra el PNG circular sobre el cuerpo.
`tactical_badges.enemy` crea `presentation/ground_cables.gd`: tres cables de tinta
oscura y metal, horizontales y con pequeñas descargas cian móviles. Banda de
200×8 px desde suelo−1, detrás del dibujo y antes del bloque de intenciones.
Sin círculos, texturas nuevas, nodos por chispa, reglas ni RNG. No captura clics.
Redibujo acotado a 30 Hz o 15 Hz con efectos reducidos.

`combat_screen` conserva el control de su visibilidad mediante la vida mostrada:
desaparece al caer la máquina; reconstruir la vista con `root_hp=0` no lo crea.
El icono, sus PV, explicación y absorción de golpes conservan el comportamiento.
El PNG anterior sigue en el inventario documental/importadores históricos, pero
ya no se utiliza como decoración de combate; no se realiza una limpieza general.

Validación de este cambio: `test_ground_cables.gd` **11/0 headless y 11/0 nativo
local aislado**; posición, capas, clics, animación, desaparición y ausencia de
mutaciones. Captura `artifacts/ground_cables/boss.png` revisada. Iconos de efectos
**883/0 headless**; distribución/inspección **184/0 headless**. Audio Dummy, Mesa/llvmpipe; avisos de recursos retenidos al
cerrar la prueba del efecto. Sin exportar ni validar Web/dispositivo físico.

## Ajuste de separación entre máquinas — 16/10/2026

Tras revisar el solapamiento señalado, la altura máxima pasa de suelo−66 a
suelo−90 (24 px menos, aproximadamente un 9% en la formación habitual).
Con varios enemigos el ancho máximo es 220 px, ajustado a columnas separadas
226/234 px; evita que las máquinas horizontales invadan el dibujo vecino.
Un enemigo solitario conserva hasta 440 px de ancho. El ajuste es proporcional:
los modelos anchos requieren más reducción que los verticales. Se mantienen
suelo, héroes, intenciones, barras superpuestas y ausencia de reducción trasera.

Archivos: `combat_actor_scale.gd`, `combat_screen.gd` y `test_enemy_presence.gd`.
La prueba añade comprobaciones de intersección horizontal de siluetas en las
formaciones de prueba. **547/0 headless y 547/0 nativo aislado**, con capturas
actuales de pareja y tres drones revisadas. Regresión completa posterior al ajuste:
**104/104 suites headless**, en `artifacts/enemy_presence/reduced_regressions`.
Los resultados de la sección anterior
corresponden al tamaño anterior. Audio Dummy; avisos de recursos al cerrar en
headless. Sin exportar ni validar Web/dispositivo. No cambia reglas ni guardados.

## Máquinas más imponentes — 16/10/2026

`combat_actor_scale.gd` mide y cachea el rectángulo opaco de reposo de cada banco
enemigo. Normaliza el dibujo con escala uniforme, en vez de conservar tamaños
accidentales de las fuentes. La altura disponible pasa de suelo−112 a suelo−66;
ancho máximo 320/400/500 px con tres/dos/un enemigo. Las máquinas anchas ganan
presencia por su envergadura, sin estirarlas verticalmente. La retaguardia ya no
reduce el dibujo: su protección e iconos siguen funcionando igual.

Las barras de vida y el bloqueo activo de ambos equipos se dibujan en capas
absolutas 30/31 sobre los personajes, permitiendo superponer vida y máquina sin
perder lectura. Los primeros planos y diálogos mantienen sus capas superiores.

`combat_layout.gd` baja el suelo entre 8 y 20 px en situaciones habituales;
con muchos efectos conserva el ajuste adaptativo. Suelo máximo 347, datos hasta
410 y carta ampliada desde 414. `enemy_intent.gd` usa una fila compacta de 34 px
en lugar de 38 sin achicar los iconos; filas adicionales mantienen su tamaño.
Los héroes conservan su normalización y desplazamiento relativo de 16 px.
No cambian cartas, reglas, objetivos de ataque, guardados ni RNG. No se generan
assets para este ajuste.

### Validación de este cambio

- `test_enemy_presence.gd`: **540/0 headless y nativo aislado**, incluye los
  56 bancos, límites/proporciones, escala estable entre poses, retaguardia y
  formaciones reales. La dimensión mayor supera en un 18% la altura de héroe
  de referencia, incluso en presupuesto de tres enemigos; no exige que un dron
  horizontal tenga la altura de una máquina erguida.
- `test_combat_floor_info.gd`: **184/0 headless y nativo aislado**; distribución,
  inspección, efectos, objetivos y carta ampliada. `test_hud.gd`: **112/0 headless**.
- Regresión completa actual: **104/104 suites headless**. Capturas revisadas en
  `artifacts/enemy_presence/formation_0.png`, `formation_3.png` y
  `artifacts/combat-floor/floor3-warrior-selected.png`.

Pruebas locales con Godot 4.7.2, audio Dummy y ventana aislada Mesa/llvmpipe.
Algunas suites avisan de recursos retenidos al cerrar, sin errores de aserción.
No se exportó ni se probó Web, emulador o dispositivo físico.

## Héroes ligeramente más abajo — 15/10/2026

Los dos héroes y sus iconos al pie bajan 16 px respecto del apoyo enemigo,
acercándolos a la mano. `combat_layout.hero_ground_for` limita ese desplazamiento
si hay muchas filas de efectos para no superar y=406 ni tapar la carta ampliada.
Ambos héroes comparten el desplazamiento; no cambian tamaño, barras, enemigos,
cartas o encuadre del fondo.

Validación actual: distribución/inspección **184/0 nativo aislado**, captura
de los héroes en escenario industrial revisada; estados **883/0 headless**.
Audio Dummy, avisos de recursos al cierre; sin exportar ni validar Web/dispositivo.

## Inspección compacta con iconos — 15/10/2026

`enemy_inspection` prepara filas de vida, bloqueo activo, rol, ataque, intención
de bloqueo, contraataque y estados, cada una con su icono vigente del combate.
Vida reutiliza el corazón existente; el rol protector/apoyo no se repite como
otra fila de efecto. Los datos siguen viniendo de intención efectiva/snapshot,
sin resolver reglas o guardar desde la vista.

`enemy_inspection_dialog.gd` presenta un marco centrado de **560 px de ancho y
hasta 440 px de alto**, frente al cuadro anterior de 860×550. La altura se ajusta
al contenido y la lista interna tiene scroll cuando hay muchos estados. Iconos
de 32 px, texto 18 px con ajuste de accesibilidad, nombre en el encabezado y
Volver al pie. Se atenúa menos la batalla, que permanece visible alrededor.
El diario y otros lectores conservan su componente anterior.

Validación posterior: distribución/inspección **184/0 nativo aislado** y
**184/0 headless**. Incluye tamaño máximo, icono por fila, datos de solo lectura,
ataques al seleccionar carta, muchos estados, texto grande, acceso al último
efecto y cierre. Capturas de inspección normal y lista larga revisadas en
`artifacts/combat-floor/`. Audio Dummy, avisos de recursos al cerrar, sin fallos
de script/aserciones. Sin exportar ni validar Web/dispositivo físico.

## Más espacio para los actores — ajuste posterior del 15/10/2026

Línea habitual de suelo a y=327 (24 px más abajo) e información hasta y=406.
La altura de héroes en una situación de una fila de efectos pasa de unos 191
a 215 px; la escala enemiga crece también y sigue limitada según la silueta.
Se conservan barras en y=78, apoyo común, adaptación para muchos estados y
encuadre del fondo ligado al suelo.

La mano normal sigue en su posición habitual. El contenedor y carta ampliada
empiezan en y=414: quedan 8 px libres después de la información. La ampliación
es de 202×302, conservando prácticamente la proporción anterior de 218×326,
y cabe completa en pantalla. `combat_layout` centraliza límite de información,
inicio de mano y tamaño ampliado; no cambia el arte o las reglas de cartas.

Validación posterior: distribución/inspección **132/0 nativo aislado**, tres
mazmorras, ambas parejas y tres enemigos, con capturas normal/seleccionada
revisadas. Estados apilados/diálogos **883/0 nativo aislado**, captura revisada.
Headless: distribución **41/0**, estados **883/0**, apoyo **665/0**
(incluye textos largos a 202×302) y HUD **112/0**. Se conservan avisos de recursos
al cerrar algunas suites; audio Dummy, sin exportar ni probar Web/dispositivo.
Los resultados generales de abajo corresponden a la entrega anterior.

## Distribución anterior de combate e inspección — 15/10/2026

Los nombres enemigos ya no tienen placa permanente sobre las barras. Tocar un
enemigo vivo sin carta/enlace seleccionado abre un diálogo con nombre, PV,
bloqueo, rol, intención efectiva y efectos. Con carta/enlace seleccionado, el
clic sigue aplicando la acción validada. `enemy_inspection.gd` es solo lectura;
reutiliza el diálogo desplazable y no modifica estado, RNG o guardado.

Barras a y=78, con bloqueo activo en su extremo izquierdo. Héroes con altura
objetivo de unos 196 px frente a los 165 anteriores; enemigos también amplían
su escala con límite según la silueta para no invadir las barras. Retaguardia
conserva reducción visual, sin elevar su apoyo respecto del suelo.

`combat_layout.gd` comparte línea de suelo y reserva una franja hasta y=382.
Intenciones y estados aparecen debajo de los pies; estados compactos de 32 px,
seis por fila, con cifras y cuadros explicativos conservados. Si hay varias
filas, adapta el espacio de todos los actores para evitar solapamientos.
`battle_effect_strip` conserva el formato de 40 px por defecto para otros usos.

La mano normal conserva sus posiciones visibles. Su contenedor empieza ahora
en y=390, dejando de interceptar clics sobre los efectos del suelo; la carta
seleccionada empieza en y=390 y sigue completa, de 326 px. Ni el scroll ni
las cartas cubren los diálogos de efectos.

El escenario de la captura era `assets/forest/combat_glade.png`, con un civil
gigante pintado dentro. Se reemplazó por un fondo industrial vacío, generado
con `image_gen.imagegen`, manteniendo ruta/importación y fuente actualizada.
Prompt/procedencia: [registro](../animation_review/industrial_background_fix.json),
[registro anterior](../animation_review/industrial_background_previous.json).
`battle_background.combat_rect` adapta el encuadre al suelo de cada mazmorra,
incluida la tercera, cuyo muro quedaba por delante de los pies con el layout nuevo.

Pruebas y capturas de esta entrega: `tests/test_combat_floor_info.gd` **114/0
nativo aislado** recorre tres mazmorras y ambas parejas, tres enemigos,
información de solo lectura, clics de ataque y geometría. Estados apilados y
sus clics: **883/0 nativo aislado**, además del recorrido visual de los tres
escenarios. Regresión general: 97/99 inicialmente; HUD **112/0** y sinergias
**19/0** tras actualizar expectativas de escala/coordenadas en esas dos suites.
Los 99 escenarios de suite quedan validados; se conservan los registros de
fallos iniciales y reejecuciones en `artifacts/combat-floor/`. Hay avisos de
recursos al cierre, sin errores de script/aserciones en la validación final.
Sin exportación ni cambios de reglas/guardados. Audio Dummy, sin validar
Web/dispositivo físico.

## Bloqueo activo oscuro — 15/10/2026

`assets/ui/block_active.svg` usa una silueta rellena en carbón `#111720` y un único
borde claro `#c8d3de`, de 1,5 unidades sobre viewBox 64 (aproximadamente 1 px en
batalla). Se retira el doble relleno claro y el dibujo interior para despejar
el fondo de la cifra. Aplica a héroes y enemigos mediante `BlockIndicator`.
Dimensiones, posición, números, explicación al tocar y disolución intactos.

Dibujo SVG nativo del sistema existente, reproducido por
`postapocalyptic_icons.active_block_svg`; el generador general conserva este
acabado. No requiere generación de imágenes ni cambia reglas/guardados.
Inventario de procedencia/hash actualizado, UID conservado.

Validación local: HUD **113/0 nativo**, con captura real revisada del bloqueo de
héroe/enemigo; disolución **5/0 headless**. Xephyr/llvmpipe y audio Dummy; avisos
de recursos al cerrar HUD, sin errores de script/aserciones. Sin exportar ni
probar Web/dispositivo. Los acabados grises mencionados abajo son históricos.

## Rostros de objetivo en intenciones — 15/10/2026

La intención enemiga usa los retratos HD existentes de
`assets/heroes/identity/portraits/<hero>.png`, dejando de recortar la cara desde
el sprite pequeño de cuerpo entero. `refuge_portrait.face_texture` centraliza
cuatro encuadres de cabeza, escalados respecto del lienzo de referencia 928×464.
No se modifican ni generan imágenes; las tarjetas grandes mantienen sus encuadres.

Cada objetivo tiene un marco de hasta 28×32, borde de 2 px y cara de hasta
24×28 centrada. Si coinciden ataque, bloqueo, contraataque y dos objetivos, la
separación baja de 30 a 29 px: la cara conserva la proporción de su textura y el
marco se ajusta a ella, sin deformarla ni salir de la columna. Colores compartidos con la identidad: Carpintero violeta `bd6be1`,
Constructora naranja `f0a657`, Boticario verde `69caa5`, Profesora cian `75d8e6`.
Separación adaptativa de hasta 30 px y ancho de intención recalculado; no cambian
daño, orden de acciones, objetivos válidos, diálogos ni guardados. Ataques de área
muestran ambos héroes vivos; los caídos no aparecen como objetivo.

Validación actual: presentación de combate **46/0 nativo**, iconos **883/0 headless**
y regresión general **94/94 suites** después del ajuste proporcional.
Se cubren los cuatro retratos, bordes, recortes dentro de fuente, proporciones,
ataques individuales/de área y exclusión de caídos. Capturas de ambas parejas
revisadas en render aislado; audio Dummy. Avisos de recursos al cerrar la suite
de presentación, sin errores de script/aserciones. Sin exportar ni probar Web/móvil.

> **Limpieza del 14/10/2026:** se retiraron los PNG fuente sustituidos/rechazados
> de esta etapa y sus importadores antiguos. Los prompts y registros se conservan
> como historial; las fuentes y herramientas del arte vigente permanecen intactas.
> [Inventario y validación actuales](../cleanup/2026-10-14.md).

## Primeros planos de héroes — 14/10/2026

Ataque y defensa usan una ilustración estática por héroe/acción; las marcas de
energía y partículas se dibujan detrás y el personaje no cambia de pose ni escala.
[Assets y pruebas actuales](../comic/static/README.md). Las animaciones normales
sobre el escenario y las reglas de efectos se conservan.

## Estética actual — 14/10/2026

Iconos de efectos redibujados a lápiz, con siluetas legibles, gris/violeta y
acentos semánticos; se mantienen sus diálogos y reglas. Partículas de impacto y
cenizas usan un trazo editable, sin destellos dorados dominantes. El veneno
conserva su parpadeo verde. [Assets y pruebas de integración](../art_direction/migration/README.md).

# Efectos de batalla con iconos

## Daño de veneno — 13/10/2026

Al terminar el turno, el enemigo parpadea verde por el daño de veneno;
los golpes normales conservan el rojo. La reacción espera a que se esfumen
las cartas y, si el veneno mata, precede a las cenizas sin otro destello rojo.

`game.gd` expone `resolved_poison_hits`, un recibo transitorio de vida y daño
real producido por `rules/combat_turns.gd`. `ui/combat_flow.gd` lo reproduce con
`enemy_sprite.gd` antes de las acciones enemigas, sin confundirlo con golpes
preparados ni modificar reglas, guardados o assets.

Pruebas actuales: `test_poison_feedback.gd`, 10 comprobaciones sin fallos tanto
headless como con ventana local (OpenGL/Mesa); `test_turn_sequence.gd`, 182,
y `test_combat_depth.gd`, 28, sin fallos headless. La prueba de veneno headless
informa cuatro objetos y un recurso pendientes al cierre; la misma prueba
con ventana no informa esos pendientes, solo la limitación de V-Sync del driver.
Sin exportación ni validación web/dispositivo de este cambio.

## Pixel art sencillo con volumen — 08/10/2026

Los 36 iconos actuales usan nuevas imágenes generadas individualmente con ImageGen
integrado: símbolos sólidos, sombras escalonadas, brillos discretos y textura
moderada. Se evita tanto el contorno vectorial plano como las ilustraciones
recargadas anteriores. Ataque usa espada; bloqueo previsto usa escudo, con su
flecha verde superpuesta por el componente; contraataque combina espada y escudo.
Los otros efectos mantienen símbolos y acentos de color propios.

Se conservan rutas, UIDs, lienzos transparentes de 128×128, iconos de 30/36 px,
filas completas y diálogos existentes. No cambia la lógica de combate ni los
guardados. Los originales están en `refined/sources/`, excluidos de exportación
por `docs/.gdignore` y los presets. [Prompts por icono](refined/prompts.json) y
[procedencia, hashes y normalización](refined/sources.json).

Regeneración del arte vigente (solo recorte alfa, ajuste proporcional y centrado):

```sh
.tools/Godot_v4.7.2-stable_linux.x86_64 --headless --path . --script scripts/import_battle_effects.gd
```

El punto de entrada delega a `scripts/import_refined_effect_icons.gd`. Los SVG y
el importador minimalista anterior se conservan como fuentes históricas; ejecutarlo
explícitamente restauraría el diseño anterior.

Los PNG de runtime suman **0,70 MiB**; los 25,32 MiB de originales documentales
quedan fuera de los presets exportables. No se midió un exportado nuevo.
Normalización: se descarta ruido alfa ≤0,01 del margen, se recorta el contenido,
se ajusta a 116 px con Lanczos y se centra en 128×128. Los originales permanecen
intactos; las importaciones conservan sus UIDs y compresión sin pérdida.

Validación de esta versión: importación y 883 comprobaciones con ventana local
Godot a 1280×720, sin fallos; revisión del catálogo a 36 px, tres enemigos,
estados aliados acumulados y guardianes. Los diálogos se abren mediante entrada
simulada y se comprueba que consultar no modifica estado ni RNG.
Regresiones headless actuales: HUD 103, soporte 609 y disposición 41, sin fallos
de aserciones. Las tres suites headless informan recursos pendientes al cierre;
la nativa solo informa la limitación de V-Sync del driver.
[Resultados actuales](refined/validation.json). No se exportó Web/APK ni se probó
navegador, emulador o dispositivo físico.

## Diseño vectorial anterior — 08/10/2026

Los 36 PNG de héroes/enemigos se sustituyen por símbolos originales dibujados
en código: siluetas simples, contorno oscuro, un color por efecto, sin texturas,
ornamentos ni brillos internos. Se conservan nombres, rutas, UIDs, transparencia
y lienzos de 128×128. El escudo gris activo ya utiliza una silueta vectorial simple.

La imagen de cada efecto crece de 32 a 36 px en celdas de 40 px; las intenciones
crecen de 26 a 30 px, con números separados. Bloqueo previsto conserva la flecha
verde superpuesta. Se muestran todos los estados activos, en cinco columnas y
tantas filas como hagan falta, sin desplazamiento ni límite de dos filas.
La vida y su escudo bajan juntos para reservar espacio. Los diálogos y acciones
especiales mantienen su funcionamiento, sin cambios de reglas o guardados.

Fuentes actuales: [SVG y procedencia](minimal/sources.json), excluidos del import
del juego mediante `.gdignore`. Regeneración:

```sh
python3 scripts/generate_minimal_effect_icons.py
.tools/Godot_v4.7.2-stable_linux.x86_64 --headless --path . --script scripts/import_minimal_effect_icons.gd
```

En esa versión `scripts/import_battle_effects.gd` delegaba al importador vectorial para evitar restaurar
por accidente las ilustraciones anteriores. Los originales de ImageGen y sus
prompts se conservan como procedencia histórica, no como fuentes activas.

Validación de esta versión: 883 comprobaciones de iconos/disposición/consulta
con ventana local Godot a 1280×720, incluidas filas completas, ausencia de
solapamiento con vida y casos acumulados de ambos bandos. Revisión visual del
catálogo, tres enemigos y estados acumulados. Regresiones headless: HUD 103,
cartas de soporte 609 y disposición de combate 41, sin fallos. HUD y disposición
avisan de recursos pendientes al cierre; no son fallos de aserciones.
Importación correcta; sin exportación ni validación Web/Android.

## Implementación y arte anteriores — 07/10/2026

Retaguardia, brasas y demás estados se presentan mediante iconos, sin carteles
sobre la mano de cartas. En enemigos aparecen debajo de ataque/bloqueo/contraataque,
entre el nombre y la vida; en héroes, sobre la vida. Los valores actuales se muestran
sobre cada icono cuando corresponden. El escudo gris de bloqueo activo permanece
en el extremo izquierdo de la barra, con su animación de cenizas.

## Catálogo y consulta

**36 assets transparentes nuevos**, en `assets/battle_effects/`, y títulos/textos
en `data/battle_effects.json`:

- Intenciones: ataque, bloqueo y contraataque; resurrección, brasas, prisión y carga.
- Formación/defensa: retaguardia, protector, raíces, placas y fuente del guardián.
- Comportamientos: sanador, caza de bestias, furia por caídos, segunda fase,
  emboscada e impulso maldito; tres modificadores de élite.
- Estados aliados/debilitamientos: fuerza, debilidad, defensa quebrada, veneno,
  potencia física/mágica, ataque preparado y concentración del vínculo.
- Tres maldiciones y cuatro combinaciones de reliquias.

Tocar un efecto abre su explicación particular y valores vigentes. Las intenciones
básicas y el bloqueo activo mantienen su cuadro pequeño anclado. Los nuevos estados
usan el modal del juego, con altura de texto calculada para evitar tocar los botones,
también con texto ampliado. La consulta no consume energía ni modifica estado/RNG.

Fuente, placas y prisión activa ofrecen la acción de **1 energía** dentro del diálogo;
la acción queda deshabilitada sin energía. También siguen disponibles los controles
de teclado/mando existentes. Desaparece el bloque central del objetivo del guardián.
La segunda fase se indica con su icono, sin añadir texto al nombre del enemigo.

Los iconos desaparecen al finalizar su efecto o caer la unidad. La cobertura se
muestra solamente mientras quede un protector vivo. Máximo de dos filas; más de
diez efectos permiten desplazamiento horizontal dentro de la misma zona. La barra
de vida baja lo necesario en los casos con dos filas. Registro conserva su botón.

## Arquitectura y compatibilidad

- `battle_effect_snapshot.gd`: instantánea de estados y descripciones; solo lectura.
- `battle_effect_strip.gd`: distribución, iconos, cantidades e inspección.
- `enemy_intent.gd`: intenciones compactas y retratos de objetivos; comparte la tira.
- `combat_modifier_badges.gd`: entrega descripciones/porcentajes a la instantánea.
- `status_effects.gd`: conserva únicamente el escudo activo y su interfaz de reproducción.
- `boss_objective.gd`: prepara acciones; Game conserva validación y checkpoint.
- `tactical_badges.gd`: decoración de raíces y apertura del registro.

No se cambia daño, duración, recompensas, IDs del contenido ni formato de guardado.
Campos opcionales ausentes no inventan estados. Los marcos y controles generales
mantienen sus estilos anteriores; se reutiliza `dialog_view.gd` con altura opcional.

## Arte y procedencia

ImageGen integrado, una generación por icono, sin API key y con alfa transparente.
Pixel art de fantasía oscura, plata envejecida, oro tenue y colores distintivos.
[Prompts completos](prompts.md) y [manifest con rutas/hashes](sources.json).
Los originales quedan en `sources/`, con `.gdignore`; los presets excluyen `docs/*`.

`scripts/import_battle_effects.gd` solo normaliza: recorte de alfa, ajuste proporcional
a 116 px y centrado en un lienzo transparente de 128×128. Los 36 PNG finales suman
**0,76 MiB**; importación sin pérdida, sin mipmaps y filtro nearest en los iconos.
Los 43 MiB de originales documentales no forman parte de los presets exportables.
No se midió el tamaño de un exportado nuevo.

## Pruebas realizadas

Diez suites locales headless, sin fallos de script/aserciones: iconos, HUD, soporte,
presentación, disposición de combate, cenizas de bloqueo, descuento de energía,
combate táctico, reglas de pulido y secuencia de turno. La nueva suite comprueba
assets/alfa, estados, consultas reales simuladas con ratón, ausencia de mutaciones,
interrupción/cobertura, desbordamiento, texto ampliado, acciones por energía y caída.

La misma suite pasa **233 comprobaciones** con ventana local de Godot 4.7.2,
Linux/Mesa/llvmpipe a 1280×720. Genera 16 capturas descartables en
`artifacts/battle_effects/`; revisión del catálogo, tres enemigos, guardianes,
modales, efectos acumulados y texto ampliado. Es entrada simulada en ventana local,
sin pruebas táctiles físicas. [Resumen verificable](validation.json).

Algunas suites headless siguen avisando de ObjectDB/recursos al cerrar; se registran
separados de errores de script/aserciones. El recorrido gráfico nuevo termina sin
esos avisos; el driver informa que no permite cambiar V-Sync.

**No se exportó Web/APK ni se probó navegador, emulador o dispositivo físico.**
