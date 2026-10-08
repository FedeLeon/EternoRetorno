## Actualización de pulido — 07/10/2026

[Implementación actual, assets, reglas y validación](../polish_2026_10/README.md).
La documentación y resultados anteriores se conservan como historial.

# Mapa de aventura — 16/09/2026

## Presentación inicial (histórico; ver actualizaciones al final)

- Fondo propio de piedra oscura, bordes dorados envejecidos y detalles violetas.
- Seis iconos interactivos: espadas (combate), santuario (encuentro), cofre,
  calavera (élite), fogata (descanso) y puerta del guardián.
- Las salas disponibles tienen un anillo dorado; la actual tiene un marcador.
  Visitadas y pendientes mantienen tonos diferentes. Solo se pueden tocar las
  conexiones que devuelve `Game.available_nodes()`.
- Se conserva el nombre de la cripta; se retiran «ETERNO RETORNO» y el subtítulo
  sobre el piso y las conexiones. Semilla disponible como tooltip del mapa.
- Héroes del lateral con área visual de 152×128 frente a la anterior de unos
  92×80, nombre y PV. Esta escala solo cambia el mapa.
- Reliquia inicial visible con su icono, nombre, alcance y efecto. También se
  muestran las encontradas, y equipos personales de partidas antiguas.
  Lista desplazable para evitar desbordamientos; Fénix conserva el estado por héroe.
- Mazo accesible con `assets/ui/deck.svg` (tres cartas), sin botón textual.
- Escalera disponible únicamente después de vencer al jefe.

## Organización

`src/ui/screens/map_screen.gd` recibe una instantánea de nodos, conexiones
habilitadas, héroes y reliquias. Emite peticiones de sala, menú, mazo y escalera.
No calcula recompensas ni modifica o guarda la aventura.
`src/main.gd::map_view()` conecta estas señales a las acciones existentes.
`equipped_relics()` comparte la preparación de datos entre mapa y HUD de combate.
No se cambian IDs, grafo, semilla ni formato de guardado.

`assets/map/background.png` y `nodes.png` son los originales finales utilizados
por el juego; el atlas se divide en tres columnas y dos filas en ejecución.
No se guardan copias redundantes. [Prompts y procedencia](prompts.md).

## Validación de esta entrega

- `tests/test_map.gd`: 21 comprobaciones renderizadas en Linux/llvmpipe a 1280×720.
  Incluye reliquias actuales y legadas, mazo por clic, entrada por icono, rechazo
  de sala inaccesible, bifurcaciones y escalera condicionada al jefe.
- `tests/test_hud.gd`: 92 comprobaciones headless, sin fallos tras compartir datos
  de reliquias.
- Revisión visual del mapa con dos héroes y reliquias inicial/hallada. Capturas
  temporales en `artifacts/map/`, eliminadas tras revisar.
- Importación y `git diff --check` correctos. Sin APK ni pruebas en Android.

## Almas (actualizado 17/09/2026)

Retirado el saldo del mapa: solo es visible en campamento y edificios.

## Título centrado (17/09/2026)

«La cripta de los ecos» se centra horizontalmente dentro del bloque izquierdo
(ancho 770 px), no respecto de toda la pantalla. Verificado que el mapa actual
no muestra saldo ni icono de almas; su eliminación ya estaba implementada.
Prueba local renderizada `test_map.gd`: 21 comprobaciones sin fallos y revisión
visual a 1280×720. Captura temporal retirada; sin exportar APK/Web.

## Mapa completo y grupo desplegable — 18/09/2026

El mapa ocupa 1280×720. Se reutiliza la zona izquierda del fondo existente
a todo el ancho, sin división fija, y se amplía horizontalmente el recorrido.
El título queda centrado en la vista completa. IDs, rutas y disponibilidad
de salas permanecen intactos.

`src/ui/components/map_group_drawer.gd` presenta héroes/PV, equipo mejorado,
reliquias iniciales y halladas y acceso al mazo. Comienza cerrado; la pestaña
se desliza con el panel desde la derecha hacia la izquierda en 0,28 s y permite
cerrarlo nuevamente. El panel intercepta clics sobre las salas que cubre;
el menú superior permanece accesible. No guarda estado ni modifica la aventura.

Pestaña: `assets/map/group_tab.png`, icono de tres aventureros sobre tablón
generado con image_gen integrado. [Prompt y procedencia](group-tab.json).

Validación actual: `test_map.gd`, 25 comprobaciones sin fallos; apertura/cierre,
intercepción de clics, acceso al mazo, rutas, jefe y reliquias legadas.
Revisión renderizada Linux a 1280×720, panel abierto/cerrado. Capturas temporales
eliminadas. Sin exportar APK/Web ni verificar en dispositivo.

## Papiro y recorrido ampliado — 18/09/2026

Nuevas aventuras: 28 salas y 18 salas por ruta, con cinco bifurcaciones de
tres opciones que vuelven a unirse (243 rutas completas). Distribución:
13 combates normales, cuatro eventos, dos tesoros, seis descansos, dos élites
y guardián. El primer élite es opcional; todas las rutas pasan por el segundo,
un descanso final y el guardián. Hay combates dobles en salas 11 y 16; los
otros normales tienen un enemigo. Los descansos compensan la duración adicional.

En esta etapa, `data/dungeon_floor1.json` definía tipos, conexiones, posiciones y
cantidad de enemigos. Se retiró el 07/10 por estar sustituido por
`data/dungeons.json` y `rules/dungeon_generator.gd`. `dungeon.gd` genera encuentros
con la semilla y guarda las posiciones
en cada nodo. Aventuras antiguas conservan su grafo de 12 salas; los nodos sin
posición usan las coordenadas legadas. No se migra una aventura en curso.

Fondo de papiro y seis iconos minimalistas de tinta sepia/pixel art en
`assets/map/minimal/`, generados con image_gen integrado.
[Prompts y procedencia](minimal-assets.json). El mapa mantiene pestaña de grupo,
menú, acceso a salas disponibles y escalera habilitada tras ganar al guardián.

Validación local: reglas generales 155, recorrido/compatibilidad 66, mapa UI 41,
tesoro 22 y tesoro UI 8, sin fallos. Se verifican las 243 rutas y el guardado
legado. Simulación de 45 aventuras: 41 victorias; las 15 parejas ganan al menos
una, usando mazo inicial y omitiendo recompensas. No equivale a una validación
manual exhaustiva del balance. Revisión visual Linux 1280×720; sin exportar
APK/Web ni probar en dispositivo. Capturas temporales eliminadas.

## 18/09/2026 — Título enmarcado y columna lateral fija del mapa

El título centrado reutiliza `assets/ui/buttons/header_frame.png` con fondo
oscuro y letras doradas. La columna derecha ocupa 84 px y toda la altura;
reutiliza el mismo marco girado y el icono existente `assets/map/group_tab.png`.
El botón Grupo permanece fijo y abre/cierra el panel hacia la izquierda.
La columna intercepta clics y reserva espacio para futuras pestañas; Menú
permanece accesible a su izquierda. El recorrido se comprime horizontalmente
solo al dibujarlo para evitar que la columna tape salas o textos.

Archivos: `src/ui/screens/map_screen.gd` y
`src/ui/components/map_group_drawer.gd`. No cambian nodos ni coordenadas guardadas.
No se generaron nuevos assets. `test_map.gd` adaptado a la pestaña fija:
41 comprobaciones aprobadas con render Linux/llvmpipe a 1280×720;
revisión visual abierto/cerrado y `git diff --check` sin problemas.
Capturas temporales eliminadas; sin exportación ni prueba en dispositivo.


## 18/09/2026 — Salas sin rótulos y fichas de papiro

Se eliminan los nombres/números debajo de cada sala y los nombres de tipo del
tooltip: este solo informa disponibilidad, visita o sala actual. Los iconos
permiten descubrir los encuentros jugando. Los círculos se reemplazan por
`assets/map/minimal/room_papyrus.png`, papiro cuadrado de 96×96 con transparencia,
dibujado a 56×56 y teñido para contrastar con el fondo. Disponible: tinta intensa;
pendiente: tinta atenuada; actual: papiro verdoso. Hover/foco aclaran la ficha.

La flecha actual usa `current_room.svg`, sin glifos Unicode. Es hija de la ficha,
con el mismo centro horizontal que su icono; no depende de métricas de fuente.
Presentación en `src/ui/screens/map_screen.gd`; no cambian rutas, IDs ni guardados.
[Prompt, fuente y procesamiento](room_papyrus.json); original en
`docs/map/sources/room_papyrus.png`, fuera de los recursos finales.

Validación de este cambio: `tests/test_map.gd`, **101 comprobaciones sin fallos**,
ejecutadas localmente con render Linux/llvmpipe. Revisión visual a 1280×720 de
la sala actual, papiros y ausencia de rótulos. Capturas temporales eliminadas.
Sin exportación ni prueba Web/Android.


## 18/09/2026 — Grupo compacto y mazo en la barra lateral

Retirado «EL GRUPO». Las reliquias se presentan en una grilla de iconos de 64 px,
sin efecto permanente a la vista. Las reliquias halladas antiguas sin icono en el
catálogo conservan su nombre como acceso visible. Al tocar una se reutiliza
`relic_popover.gd` con nombre, alcance y efecto, anclado encima del acceso.
Tocar otra cambia el detalle; repetir, tocar fuera, desplazar la lista o cerrar
Grupo lo cierra. Escape también cierra el detalle.

Mazo usa el asset existente de tres cartas como segundo acceso fijo debajo de
Grupo en `SideRail`, disponible con el panel abierto o cerrado. Se retira el
acceso inferior y el contador del panel; la cantidad permanece en su tooltip.
Cambios de presentación en `map_group_drawer.gd`, sin reglas ni guardados.

Validación actual: `test_map.gd`, 105 comprobaciones sin fallos en Linux con
render llvmpipe; clics de detalle, cambio/cierre de reliquia, navegación al mazo,
rutas y panel. Revisión visual local a 1280×720. Sin exportar ni probar Web o
Android; capturas temporales retiradas.


## 18/09/2026 — Resplandor de ubicación e inicio

`map_screen.gd` dibuja un halo dorado detrás del papiro de la sala actual.
Antes de entrar en la primera sala (current < 0), ilumina la entrada disponible.
Pulsa entre 72 % y 100 % de opacidad cada 1,1 s, sin apagarse ni requerir hover.
El papiro destacado es más luminoso; se conserva la flecha de ubicación.
Efecto procedural con StyleBoxFlat, sin nuevos recursos raster ni reglas de juego.
El halo ignora el ratón; el panel de Grupo queda por encima.

La comprobación renderizada detectó además un cierre inconsistente de reliquias:
map_group_drawer.gd ahora usa la posición del evento de clic, transformada al
canvas, en lugar del cursor global para decidir si el clic fue fuera del cuadro.
Validación final: test_map.gd, 109 comprobaciones sin fallos, render local Linux.
Revisión visual del inicio a 1280×720; capturas retiradas. Sin exportar Web/APK.

## Pisos aleatorios — 22/09/2026

Cada piso nuevo conserva 28 salas: 13 combates, 6 descansos, 4 encuentros,
2 tesoros, 2 élites y 1 guardián. Cambian la distribución de tipos, conexiones,
anchos de las bifurcaciones, posiciones y enemigos con la semilla. Se mantienen
hasta tres opciones por bifurcación y un recorrido serpenteante legible. Todas
las salas son accesibles y ninguna termina en un callejón sin salida. El primer
élite está en una rama opcional; el segundo precede obligatoriamente al guardián.
No se visitan las 28 salas en un único recorrido.

El nombre depende del piso. Al vencer al guardián de la cripta, la salida lleva
al bosque conservando el grupo y sus adquisiciones. Las partidas ya guardadas
conservan exactamente su grafo y su final anterior de un piso. Las cifras de
caminos de las secciones históricas describen el mapa fijo anterior.

Pruebas actuales: 200 mapas (100 semillas por piso), determinismo, inventario de
salas, accesibilidad, ausencia de ciclos, variación y posiciones dentro del mapa.
`test_forest.gd`: 20.414 comprobaciones; `test_map.gd`: 109 comprobaciones
renderizadas. Revisión visual local del mapa del bosque a 1280×720.

## 30/09/2026 — Resplandor de todas las salas disponibles

Cada destino disponible tiene un halo verde animado detrás de su cuadrado de
papiro, también en bifurcaciones de dos o tres opciones. Pulsa suavemente entre
45 % y 100 % de opacidad, con 1,1 segundos por transición, sin apagarse ni
requerir hover. La sala actual conserva el halo dorado y la flecha de ubicación.
Las salas sin acceso no se iluminan. Al reconstruir el mapa tras avanzar se
actualizan los destinos a partir de `available`, sin cambiar rutas ni guardados.

Se reutiliza el efecto procedural `add_room_glow` de `map_screen.gd`: no se
agregan imágenes. El halo ignora entradas y se dibuja detrás del botón, con el
panel de grupo por encima. `test_map.gd` verifica los destinos iluminados,
colores distintos, orden de dibujo y variación temporal de la opacidad.

Validación de este cambio: **141 comprobaciones sin fallos** tanto headless como
con render Linux/llvmpipe. Revisión visual a 1280×720 de la bifurcación iluminada.
Sin exportación ni pruebas Web/Android nuevas.

## Recorrido en espiral — 08/10/2026

Los tres pisos nuevos disponen sus 28 salas siguiendo una espiral: entrada
exterior arriba a la izquierda, vuelta por el perímetro y tramo interior hasta
el guardián central. Las trece etapas conservan bifurcaciones de hasta tres salas,
el élite temprano opcional y el élite tardío obligatorio. Cambian la geometría y
sus caminos dibujados; la disponibilidad continúa dependiendo del grafo.

- `src/map_geometry.gd`: centros/ramales de la espiral, separación de 70 px,
  variación de hasta 3 px por eje y curvas Bézier limitadas al área del mapa.
  Geometría pura, compartida entre generador y presentación.
- `rules/dungeon_generator.gd` almacena coordenadas y la marca opcional
  `layout: spiral` en los nodos nuevos. Mantiene inventario de salas, elección
  aleatoria de rutas/enemigos y restricciones de etapa.
- `ui/screens/map_screen.gd` dibuja 17 puntos por conexión curva y aplica la
  misma compresión horizontal a salas/caminos para dejar libre la columna derecha.
  Conserva brillo, marcador, botones, pestañas y escalera.
- Guardados previos mantienen coordenadas, conexiones y rectas; los mapas antiguos
  de doce salas siguen usando su fallback. No se regeneran encuentros al cargar.
  La espiral aparece al crear una aventura o generar el siguiente piso.
- No se crearon assets ni se modificaron reglas de daño, recompensas o persistencia.

Validación actual local Godot 4.7.2:

- `test_spiral_map.gd`: 170.458 comprobaciones sobre 300 mapas (100 por piso),
  determinismo, centro del guardián, límites, tarjetas sin solapamiento, etapas,
  acceso a todos los nodos y extremos/límites de curvas; caminos antiguos rectos.
- Regresiones headless: formaciones 43.678, bosque/progresión/guardado 24.616 y
  mazmorra/compatibilidad legada 66; sin fallos funcionales.
- `test_map.gd`: 141 comprobaciones gráficas nativas; clics, bloqueo de salas,
  grupo, mazo, reliquias, brillo/marcador y escalera. La prueba de interceptación
  del grupo ahora localiza una sala realmente cubierta, sin depender de un ID.
- Recorrido gráfico de los tres pisos y capturas `artifacts/spiral-map/floor-*.png`
  revisadas a 1280×720 en Linux/Mesa/llvmpipe. El controlador informa que no admite
  cambiar VSync. Sin exportación ni pruebas Web/emulador/dispositivo físico.

## Espiral ordenada — 08/10/2026

Capas alineadas en una vuelta exterior y retorno interior; ramas nuevas ordenadas
sin conexiones entre carriles opuestos. El último tramo curva por debajo de las
ramas interiores. Caminos futuros tenues, recorrido realizado más oscuro y
salidas actuales resaltadas. Mapas guardados conservan salas/conexiones/posiciones
en disco; UI adapta solo una copia de las espirales antiguas. Mapas de doce salas
siguen como antes. [Archivos y pruebas actuales](../presentation_refinements/README.md).
