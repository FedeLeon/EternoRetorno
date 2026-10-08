# Campamento previo a la aventura

Estado actual: **30/09/2026**. Las secciones fechadas conservan el historial de cambios.

## Navegación e interfaz

- Barra superior: «El Campamento, un lugar al que volver...», almas con icono
  y números gráficos existentes, y botón Menú para regresar al inicio.
- No hay barra inferior. Tocar el arco de piedra abre Continuar aventura,
  Nueva aventura y Volver. Continuar queda desactivado si no existe una run.
- Nueva aventura pide confirmación cuando hay otra activa. Cancelar conserva
  la partida; la sustitución solo ocurre al iniciar la nueva pareja.
- El saldo de almas solo se muestra en el campamento y dentro de sus edificios.
  Se siguen concediendo almas al ganar combates, sin mostrar saldo ni premio
  de almas en combate, mapa o recompensa.
- El solar 1 permite construir el [mercado](../market/README.md) por 300 almas.
  Una vez construido muestra el edificio; tocarlo abre el mercado. La construcción
  y el saldo son persistentes.
- El solar 3 permite construir la [herrería](../forge/README.md) por 400 almas.
  Su edificio abre mejoras independientes de arma y armadura para cada héroe.
  El solar 2, centrado debajo de la fogata, permite construir Expediciones;
  el solar 4, abajo a la derecha, permite construir la Iglesia.

## Archivos y assets

- `src/ui/screens/base_camp_screen.gd`: escenario, barra y zonas interactivas.
- `src/ui/components/soul_counter.gd`: icono y dígitos, sin reglas económicas.
- `src/ui/components/dialog_view.gd`: presentación de diálogos con acciones.
- `src/ui/components/modal_frame.gd`: marco compartido de diálogos y tesoros.
- `src/main.gd`: conecta acciones y mantiene la navegación y confirmaciones.

El fondo `assets/base_camp/background.png` deriva del original del usuario
`campamentoConstruccion.png`; el 30/09 se editó para trasladar el solar de
Expediciones (la versión previa permanece en Git). Assets generados con imagegen integrado:

- `assets/base_camp/market_building.png`: edificio aislado para el solar 1.
- `assets/forge/building.png`: herrería aislada para el solar 3; [procedencia](../forge/building.json).
- `assets/ui/soul.png`: alma celeste con fondo transparente.
- `assets/ui/modal_frame.png`: marco ornamental de hierro y oro, interior oscuro.

Prompts completos en [assets-2026-09-17.json](assets-2026-09-17.json), procedencia
por archivo en [sources-2026-09-17.json](sources-2026-09-17.json).
El pequeño cuadro anclado de reliquias conserva su presentación independiente.

## Validación de este cambio

Pruebas locales Godot: campamento 33, mercado 34, tesoro UI 8, HUD 92,
mapa 21, reglas de tesoro 22 e interfaz general 271; todas sin fallos.
Campamento, arco, confirmación, mercado y recompensa de tesoro revisados
renderizados en Linux a 1280×720. Capturas temporales eliminadas tras revisar.
Sin exportar APK/Web ni probar este cambio en navegador, emulador o dispositivo físico.

La barra superior usa ahora el [marco ornamental compartido](../ui_buttons/README.md)
y Menú un cartel de madera (17/09/2026). Los textos de los modales están centrados.

## Carteles de madera — 17/09/2026

Los carteles del campamento reutilizan `assets/ui/buttons/wood_button.png`
mediante `button_skin.gd`, aplicado al panel de `main.gd::camp_hotspot`.
Mercado y Herrería construidos muestran solamente su nombre, sin «Entrar».
Se conservan las áreas interactivas y la prioridad del cartel del mercado.
Procedencia del asset compartido: [wood-assets.json](../ui_buttons/wood-assets.json).

Validación de este ajuste: `test_forge_ui.gd`, 46 comprobaciones sin fallos,
incluyendo clics en ambos carteles. Revisión visual del campamento en Linux
a 1280×720. Sin exportar APK/Web ni probar en dispositivo.

## Edificios sin recuadro y cartel del mercado arriba — 18/09/2026

`main.gd::camp_hotspot` usa StyleBoxEmpty para normal, hover, pulsado, foco
y deshabilitado, retirando el rectángulo amarillo sobre los edificios.
La opción `caption_above` coloca el tablón encima y extiende hacia arriba
el área de clic. `base_camp_screen.gd` la activa para el mercado construido;
el solar sin construir conserva el cartel inferior. El mercado queda rotulado
sobre el tejado y separado de la herrería. Se conserva el asset de madera.

Validación actual: `test_forge_ui.gd`, 46 comprobaciones sin fallos, incluyendo
clics en ambos carteles. Revisión visual Linux a 1280×720. Capturas temporales
eliminadas. Sin exportar APK/Web ni probar en dispositivo.

## 18/09/2026 — Ambientación animada del campamento diurno

El fondo diurno usa `assets/shaders/camp_day.gdshader`: brisa suave localizada
en las copas laterales, ondulación/reflejos del lago, flujo discreto de la
cascada izquierda y oscilación/brillo de las llamas centrales. Máscaras suaves
por coordenadas y color limitan el movimiento sobre la ilustración original.
No es animación esquelética ni un nuevo atlas; no se modifica el PNG fuente.
Edificios, carteles, interfaz y zonas interactivas conservan sus posiciones.
Solo se aplica a `base_camp`; el fondo nocturno de selección no cambia.

`main.gd::background` asigna el material al nodo `DayCampBackground`. Efecto
puramente visual mediante tiempo de shader, sin RNG de juego ni persistencia.
No se generan assets con IA: shader escrito en código y fondo existente.

Validación local Linux/llvmpipe 1280×720: `test_base_camp.gd`, 37 comprobaciones
sin fallos. Comparación de cuadros separados por 0,45 s confirma cambio de
píxeles en follaje, agua y fuego, con una región del suelo idéntica; conserva
pruebas de solares, refugio, arco y regreso/continuación. Revisión de captura
renderizada; captura temporal eliminada. No implica revisión temporal manual
exhaustiva ni validación de rendimiento Web/Android. Sin exportación.

## Refugio funcional — 18/09/2026
La carpa abre la galería de seis héroes y el editor de cartas iniciales,
reemplazando el aviso de mejoras futuras. La preparación se aplica solo a
nuevas aventuras. [Reglas, assets y pruebas](../refuge/README.md).


## 22/09/2026 — Fogata diurna con atlas detallado

base_camp_screen.gd reutiliza campfire.gd y fire-128.png: ocho fotogramas a
9 FPS, chispas y resplandor, anclados en (643, 396) a escala 0,62 sobre la
fogata del fondo. No se duplican assets. El shader camp_day conserva el viento
y el agua; se retira su deformación anterior de la llama.

Validación local renderizada: test_base_camp.gd, 37 comprobaciones sin fallos
y revisión visual a 1280×720. Capturas temporales retiradas; sin exportar.


## Nuevos solares — 22/09/2026

Solar 4: [Iglesia](../church/README.md), 600 almas, dos especializaciones por héroe.
Solar 2: [Puesto de expediciones](../expeditions/README.md), 500 almas, treinta contratos.
Ambos edificios usan assets transparentes y carteles de madera. Sus zonas de toque
respetan la silueta y dejan pasar los clics hacia los carteles vecinos. Construcción,
precios y compras se validan en reglas y se guardan desde `game.camp_action`.
Pruebas y procedencia de arte detalladas en los documentos de cada edificio.

## Intercambio de iglesia y expediciones — 22/09/2026

Iglesia pasa al solar 4 (abajo a la derecha) y Expediciones al solar 2
(arriba a la derecha). Cambian juntos edificio, cartel y acción de acceso o
construcción. Los IDs de perfil se conservan: ninguna construcción, mejora
o contrato se pierde, sin migración de partidas.

`test_camp_expansion_ui.gd`: 30 comprobaciones headless aprobadas con las
nuevas ubicaciones; conserva pasos de clic de carteles vecinos. Diff correcto.
Sin exportación ni revisión visual en navegador/dispositivo en este cambio.

## Separación de carteles — 23/09/2026

El cartel del Mercado construido baja 20 px y Aventuras se desplaza 90 px a la
derecha, sin mover edificios. `camp_hotspot` admite un desplazamiento opcional
del cartel y amplía el área pulsable para incluirlo; la geometría publicada en
`caption_rect` sigue sirviendo para evitar interferencias entre edificios.
El botón Menú superior pasa a 102×40, centrado verticalmente con más espacio
respecto del marco (también en el HUD de batalla).
Revisión renderizada local a 1280×720 con todos los edificios construidos;
prueba headless de expansión: 36 comprobaciones sin fallos. Sin exportar.

## Fuego detallado de 16 cuadros — 23/09/2026

`campfire.gd` usa `assets/camp/fire-detailed.png`, generado con fondo transparente
real, cuadrícula 4×4 y 16 poses. Original 1254×1254 conservado, importación sin
pérdida y sin reducir el atlas. Prompt y procedencia en `fire-detailed.json`.
Las regiones usan límites enteros para repartir los 1254 px entre cuatro celdas.
La base de la llama se compensa por cuadro (±1 px), excluyendo pequeñas chispas
sueltas de la medición. Ciclo de 1,6 s a 10 cuadros/s, frente a 8/9 s del anterior.
El pulso ambiental baja de 7 a 2,4 rad/s y su variación de 15 % a 8 %.
El componente compartido aplica el nuevo fuego en todas sus vistas consumidoras.

Validación local: ejecución renderizada de 150 frames, con los 16 cuadros de fuego
observados; captura del campamento diurno revisada para transparencia, tamaño y
apoyo en la fogata. `git diff --check` sin errores. Sin exportación ni validación
web/móvil. Assets anteriores conservados como fuentes históricas.

## Fuego natural, rediseño completo — 23/09/2026

Reemplazo visual activo: `assets/camp/fire-natural.png`, creado de cero con
image_gen y una segunda pasada para transparencia. Procedencia y prompts en
`fire-natural.json`. Atlas de 1536×1024, 6×4 celdas de 256 px, 24 cuadros;
importación sin pérdida y tamaño original para preservar las regiones.

La silueta utiliza lenguas finas separadas, zonas transparentes, raíces azuladas
suaves y una base irregular de brasas. Sustituye el fuego anterior de contorno
compacto. `campfire.gd` reproduce a 14 fps (ciclo de unos 1,71 s), con offsets de
base medidos por cuadro; conserva la luz suave. Las chispas procedurales pasan
de 16 originales / 8 actuales, y son menores (1–2 px), con menor opacidad.
El cambio se comparte entre campamento y selección de héroes.

Validación local: atlas RGBA, 68,1 % de píxeles completamente transparentes;
ejecución renderizada durante 2,2 s con los 24 cuadros observados, y revisión de
captura del campamento para integración sin recuadro y apoyo de brasas.
`git diff --check` limpio. Sin exportación ni prueba web/móvil. El atlas anterior
queda conservado, pero ya no es el utilizado por el componente.

## Expediciones debajo de la fogata — 30/09/2026

El solar 2 se traslada al centro inferior. El fondo editado elimina el solar
anterior junto al arco y recupera allí el terreno y el camino; dibuja el nuevo
solar debajo de la fogata y desplaza la carreta fuera de él. Se conservan las
posiciones de la fogata, carpa, arco, otros solares y máscaras de viento/agua.

`base_camp_screen.gd` mueve edificio, cartel y zona de clic. El edificio reutiliza
`assets/expeditions/building.png`, ahora en `Rect2(480, 422, 320, 190)`; el solar
sin construir y su cartel también usan el centro inferior. No se cambia el ID
`expeditions`, el número de solar, las construcciones ni los contratos guardados.

Edición con **image_gen integrado** sobre `assets/base_camp/background.png`;
[prompt y procedencia](expeditions-relocation.json). Se conserva el UID y la
importación a 1280 px con calidad 0,85. El original generado se copia al proyecto.

Validación actual: `test_camp_expansion_ui.gd` (39 comprobaciones) y
`test_base_camp.gd` (37), sin fallos con renderizado local X11/Compatibility.
Clics reales en los carteles de construcción, Expediciones y Aventuras; revisión
visual a 1280×720 tanto vacío como con los cuatro edificios construidos.
La prueba de campamento también verifica viento, agua y fuego. Importación sin
errores y `git diff --check` limpio. Sin exportar ni probar Web/Android.

## Ocultar solares construidos — 30/09/2026

Los bordes de piedra, estacas y rectángulos de tierra desaparecen al construir
cada edificio. Los solares vacíos conservan su dibujo original. También se aplica
a edificios ya construidos al abrir una partida anterior, sin reconstruirlos.

`assets/base_camp/built_ground.png` es una versión del terreno sin marcas,
editada con image_gen integrado a partir del fondo actual. [Prompt y procedencia](built-ground.json).
El fondo original se mantiene. `camp_day.gdshader` mezcla el terreno nuevo solo
en las regiones construidas, con transición de 12 px; `base_camp_screen.gd` le
entrega cuatro indicadores desde la instantánea del perfil. No cambia posiciones,
carteles, zonas de clic, reglas de construcción ni guardados. Agua, árboles y
fogata conservan sus animaciones.

Importación del nuevo fondo a 1280 px y calidad 0,85, registrada en
`scripts/optimize_texture_imports.py`. Un recurso adicional compartido por las
cuatro construcciones, sin crear fondos para cada combinación posible.

Validación actual: `test_camp_plot_ground.gd`, 30 comprobaciones renderizadas
sin fallos; compras mediante la API pública y comparación de regiones de solares
vacíos/construidos. Revisión visual local de estados parciales y completos a
1280×720. Regresiones: campamento 37 comprobaciones renderizadas, expansión 39
headless, sin fallos. Importación y `git diff --check` limpios. Sin exportación
ni nueva validación Web/Android.

## Taller permanente y accesos — 08/10/2026

Proyectos tiene un pequeño edificio permanente a la derecha de la fogata, entre
Iglesia y Aventuras. Acceso gratuito sin construcción, con sus mejoras internas
y requisitos anteriores. Entrenamiento usa un botón cuadrado con el muñeco; se
retira Bestiario del campamento y queda en Inicio.
[Assets, prompts y pruebas actuales](../presentation_refinements/README.md).

## Tamaño y posición de edificios construidos — 08/10/2026

Expediciones baja 20 px y crece aproximadamente un 10 %: su área pasa a
`Rect2(464, 442, 352, 210)`, manteniendo el centro horizontal bajo la fogata.
Iglesia crece un 10 % y su centro se desplaza 21 px a la izquierda, con área
`Rect2(850, 350, 376, 238)`. Carteles y máscaras de clic se ajustan con los
edificios en `src/ui/screens/base_camp_screen.gd`. Los solares vacíos conservan
sus ubicaciones; se reutilizan assets y no se modifican guardados.

Validación actual: expansión de campamento, 39 comprobaciones, y campamento,
38 comprobaciones, sin fallos con renderizado local X11/Compatibility.
Revisión visual del campamento construido a 1280×720; carteles separados y
completamente visibles. La suite de campamento informa recursos pendientes al
cierre. Sin exportación ni pruebas Web/Android.
