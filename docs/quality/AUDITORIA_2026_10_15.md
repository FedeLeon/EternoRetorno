# Auditoría del juego — 15/10/2026

## Alcance y resultado

Revisión del código, catálogos, recursos, importadores, exportación configurada,
pruebas y una muestra renderizada de vistas. Es un diagnóstico: no se cambian
reglas, ilustraciones, guardados ni archivos de exportación, ni se borran recursos.
Los cambios previos del espacio de trabajo se conservan.

La base actual es amplia y las regresiones pasan. La prioridad propuesta es
profundizar identidad, claridad y calidad de las acciones existentes antes de
aumentar otra vez el volumen de contenido. Esto es una recomendación de diseño;
las pruebas automáticas no miden si la experiencia resulta divertida.

## Inventario actual

| Sistema | Catálogo comprobado |
| --- | --- |
| Héroes | 4: Nicolás, Inés, Mauro y Vera |
| Cartas | 88, con 88 ilustraciones distintas |
| Parejas | 6 sinergias y seis grupos de cuatro eventos de pareja |
| Mazmorras | 3: Red de mantenimiento, Cinturón industrial y Central del Reinicio |
| Enemigos | 57 definiciones y 56 apariencias; 20/22/18 candidatos comunes por mazmorra, con solapamiento |
| Reliquias | 33 |
| Encuentros | 19 |
| Contratos | 19 activos, no los 30 de la propuesta original |
| Especializaciones | 8, dos por héroe |
| Logros | 28 activos, incluidos 5 secretos |
| Cinemáticas | Introducción, cuatro héroes y tres jefes |

Ya existen arrastre de cartas, reserva de una carta, mejoras, vínculos,
entrenamiento, contratos, proyectos, bestiario, inventario, tutorial, controles
de teclado/mando en combate y opciones de accesibilidad/efectos. Las siguientes
propuestas deben ampliar esos sistemas, no crear versiones paralelas.

## Validación de esta revisión

- `python3 scripts/run_regressions.py --jobs 6 --output artifacts/audit-2026-10-15/regressions`:
  **98/98 suites**, sin errores de script ni aserciones fallidas. Incluye la
  validación Python del catálogo. Perfiles aislados; sin tocar partidas reales.
- `audit_content.py`: **1510 comprobaciones / 0 errores**.
- `audit_postapocalyptic_art.py`: **683 recursos PNG/SVG con hashes y fuentes
  válidos**, 140 trabajos originales completos, sin pendientes en esa cola.
  Este inventario no demuestra alcanzabilidad runtime ni calidad artística.
- `audit_battle_atlases.py`: **96 hojas / 928 cuadros**, sin cuadros vacíos o
  diminutos según su umbral. Repetir cuadros es válido para sostener poses y no
  equivale a tener 928 dibujos originales.
- `audit_pixel_cards.py`: **96 recursos**, 88 ilustraciones únicas, sin errores.
- Render nativo aislado, Godot 4.7.2, X11/Mesa llvmpipe, 1280×720, audio Dummy:
  `test_whole_game_polish.gd` **125/0** y `test_building_galleries.gd` **84/0**.
  Se revisaron capturas actuales de combate contra dron, mapa, opciones, mercado
  y detalle de especializaciones. Evidencia en `artifacts/whole-game/` y
  `artifacts/building_interiors/`; resultados headless en el directorio anterior.
- **35 de las 98 suites** emiten avisos de objetos vivos al salir. También las
  dos comprobaciones nativas: 4 objetos/1 recurso y 24 objetos/5 recursos.
  No se interpreta esto como una fuga demostrada durante una partida; requiere
  diagnóstico con ejecución prolongada, ciclos de apertura/cierre y `--verbose`.

No se hizo una partida humana completa, escucha de la mezcla, perfilado de FPS,
prueba de navegador, exportación, emulador ni dispositivo físico. No se atribuyen
al código actual resultados de `TestWeb`, que es una exportación independiente.

## Mejoras prioritarias y assets

### 1. Diferenciar las acciones de cada héroe

Los PNG `assets/heroes/actions/<héroe>_thrust.png` y `_sweep.png` son idénticos
por SHA-256 para **los cuatro héroes**. Es una reutilización explícita:
`scripts/import_sketchbook_actors.gd` toma las claves de `attack` para ambas.
`detailed_hero.gd` los carga como acciones diferentes. No son archivos muertos.

Crear poses realmente distintas para estocada/barrido, adaptadas a herramienta,
escudo, corrosión y equipo eléctrico; mantener silueta, proporción y apoyo en el
suelo. Evitar volver a animar los primeros planos: siguen siendo imágenes
estáticas con efectos, como pidió el usuario. Priorizar estas ocho variantes
antes que regenerar todos los assets otra vez.

Los enemigos tienen cuatro poses originales en bancos que se distribuyen sobre
ocho cuadros. Conviene mejorar anticipación/impacto/recuperación de los más
frecuentes y jefes, con un piloto por familia y revisión visual, antes de pedir
más cuadros para todos. El auditor de atlas no detecta fragmentos de dibujos
vecinos ni problemas de silueta: añadir revisión de componentes aislados por
cuadro, con excepciones para proyectiles/partículas legítimos.

### 2. Hacer visible la identidad de las seis parejas

Las seis recetas actuales consumen dos cartas concretas y ofrecen daño, bloqueo,
curación o corrosión. La interfaz de `synergy_view.gd` las comunica mediante
botones y ayudas de texto. Propuesta: una acción cooperativa distintiva por
pareja, con una condición fácil de entender y anticipación visible en la mano.
Ejemplos para prototipar, no reglas ya implementadas:

- Nicolás + Inés: preparar una cobertura que permita un golpe seguro.
- Mauro + Vera: marcar una máquina y sobrecargarla al aplicar corrosión.
- Inés + Mauro: desviar un ataque hacia una trampa corrosiva.

Crear seis emblemas de pareja y un efecto compartido breve de conexión. Medir
frecuencia de activación y comprensión antes de aumentar sus números.

### 3. Claridad y jerarquía visual

Las galerías actuales ocupan correctamente el bloque derecho; el laboratorio
deja libres ilustración, texto y botón. Conservar ese patrón. En combate la mano
concentra bastante textura, marcos y símbolos: reforzar el contraste de selección,
objetivo y coste disponible antes de añadir más ornamentos.

El mapa muestra destinos disponibles iluminados y rutas futuras tenues. Evaluar
con jugadores nuevos un encuadre que destaque los próximos dos pasos y el jefe,
conservando la vista completa disponible. No reemplazar otra vez la navegación
sin comprobar qué les cuesta entender.

El visor de logros reutiliza imágenes de **512×512**; es correcto funcionalmente,
pero no aprovecha el original para contemplar detalles en pantalla grande.
Preparar versiones HD bajo demanda si esa galería se vuelve una función central,
sin aumentar todas las texturas del juego.

### 4. Sonido e identidad del mundo

El sistema ya tiene contextos, variantes, mezcla, limitador y opciones; no hace
falta otro gestor. Revisar mediante escucha real si golpes, bloqueo metálico,
corrosión y electricidad se distinguen, y si la música deja oír la acción.
Priorizar firmas sonoras breves para las seis parejas y las familias de máquinas.
Los identificadores históricos `magic`, `goblin`, etc. no prueban por sí solos
que un sonido sea incorrecto: comprobar el audio antes de retirarlo.

### 5. Calidad técnica y pruebas

- Investigar los avisos al cierre de UI con `--verbose` y aperturas repetidas;
  separar fixtures que quedan vivos de retenciones en ejecución normal.
- Actualizar `audit_visual_contact_sheets.py`: todavía lee un inventario fechado
  el 13/10 y aplica clasificaciones de estilo anteriores. Usar el catálogo actual
  con fecha y distinguir «inventariado», «usado» y «revisado visualmente».
- Actualizar `test_web_performance.cjs`: navega por coordenadas fijas anteriores
  a la reubicación del botón Aventuras. Confirmar el estado alcanzado en cada
  escenario para que un clic errado no produzca una medición con nombre falso.
- La arquitectura está separada en unas **200 unidades GDScript / 10.649 líneas**.
  `main.gd` tiene 530 líneas y `game.gd` 378, con responsabilidades ya delegadas.
  Extraer navegación/controladores cuando se modifiquen, no fragmentar por tamaño
  sin necesidad. Consolidar contratos de diccionarios de combate y sus recibos
  al ampliarlos; conservar IDs y resolución/guardado anterior a los efectos.
- Usar la telemetría local existente (`combat_telemetry.gd`) para comparar seis
  parejas: victorias, turnos, daño recibido y cartas ofrecidas/elegidas/no usadas.
  Los 55 patrones enemigos exactos distintos no demuestran 55 experiencias
  tácticas diferentes; comparar roles y decisiones que provocan.

## Limpieza y tamaño: qué se puede afirmar

Medición local aproximada, anterior a las capturas de esta auditoría:

| Carpeta | Tamaño | Interpretación |
| --- | ---: | --- |
| `assets` | 349,0 MiB | Fuentes runtime e importaciones; no equivale al PCK |
| `docs` | 942,8 MiB | Incluye originales y procedencia; excluida en presets |
| `.godot` | 159,9 MiB | Caché regenerable e ignorada |
| `artifacts` | 207,3 MiB | Capturas/logs ignorados; crecerá al probar |
| `.tools` | 5749,2 MiB | Herramientas locales ignoradas |
| `TestWeb` | 235,4 MiB | Exportación manual ignorada; no modificada |

Los presets usan `all_resources` y excluyen documentación, tests, scripts,
artefactos y TestWeb. Un asset obsoleto dentro de `assets` puede seguir entrando
en una exportación aunque ningún código lo cargue. Hay **18 grupos de archivos
idénticos**, con un ahorro teórico de **4,86 MiB** si se unifican todas sus copias;
parte son alias necesarios para rutas/variantes. No representa una reducción
medida de descarga o memoria GPU.

Candidatos concretos para una limpieza separada:

| Candidato | Evidencia y tratamiento necesario |
| --- | --- |
| `assets/map/group_tab.png` | Sustituido en runtime por `assets/map/sidebar/group.png`; sigue en cola de derivados e importador/optimizador. Retirar coherentemente asset, importación, trabajo e inventario; conservar procedencia. |
| `assets/ui/map.svg` | Sin referencia literal en `src/data/scripts/tests`; sigue inventariado. Confirmar que no lo resuelve un generador dinámico antes de retirarlo. |
| Copias de fuego y equipos base | Hashes iguales en `camp/fire-natural.png` y `base_camp/dusk/fire.png`, y héroes base/variantes `w0_a0`; ambos pueden tener consumidores activos. Unificar rutas primero. |
| Audio hover | Archivo y entradas `ui_hover`/`hover` aún existen, aunque el enlace de botones solo conecta `pressed`. Revisar todos los eventos dinámicos y la reproducción desde `prepare_audio.py` antes de eliminar. |
| Inventarios/capturas antiguos | No hay capturas ni bytecode versionados detectados; las capturas locales ya están ignoradas. Mantener una ventana de evidencia reciente y borrar históricos solo tras revisar qué se necesita conservar. |

Todos los GDScript de `src` aparecen referenciados por ruta en el corpus revisado;
esto descarta un primer conjunto de archivos huérfanos, pero **no demuestra que
todas las funciones y ramas sean alcanzables**. No se encontró una eliminación
masiva de código segura en esta revisión. Los importadores con nombre sketchbook
siguen procesando el arte de cómic actual: no borrarlos por su nombre. Las 98
suites actuales pasan y cubren regresiones útiles; no retirarlas por antigüedad.

## Qué agregar después

1. **Primera aventura guiada con decisiones reales:** enseñar objetivo, bloqueo,
   reserva y una sinergia en momentos concretos. Ampliar el tutorial existente.
2. **Acciones cooperativas por pareja:** probar primero una pareja y una pelea
   diseñada para ella; completar las otras cinco si el resultado es claro/divertido.
3. **Identidad civil en encuentros:** reparar con Nicolás, improvisar cobertura
   con Inés, recuperar reactivos con Mauro y descifrar órdenes con Vera; ventajas
   y costes alternativos, evitando convertir una pareja en llave obligatoria.
4. **Máquinas con relaciones tácticas:** extender a encuentros comunes algunas
   ideas ya presentes en los jefes: un relé que sostiene otra unidad, una cámara
   que marca o un suministro que pueda interrumpirse. Reutilizar modelos antes
   de ampliar el catálogo de enemigos.
5. **Consecuencias visibles del Retorno:** pequeños cambios en diálogos y escenas
   según decisiones y parejas, con una pista persistente sobre la máquina central.
6. **Resumen que enseñe:** ampliar el historial actual con qué combo funcionó,
   qué cartas casi no se usaron y qué causó la derrota, usando métricas locales.
7. **Sesiones observadas con jugadores nuevos:** anotar dónde dudan, cuándo usan
   su primera sinergia y qué creen que hace la reserva. Balancear a partir de eso.

Orden sugerido: diagnóstico de retenciones y herramientas → acciones visualmente
distintas → piloto de pareja + primera aventura → pruebas humanas → expansión.
No se propone una cuarta mazmorra o más héroes como siguiente prioridad.
