# Mapa de aventura — 16/09/2026

## Presentación actual

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

`data/dungeon_floor1.json` define tipos, conexiones, posiciones y cantidad de
enemigos. `dungeon.gd` genera encuentros con la semilla y guarda las posiciones
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
