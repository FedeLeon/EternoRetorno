## Engranaje de configuración — 15/10/2026

La pantalla inicial usa un [engranaje ilustrado de cómic](settings/README.md),
con transparencia y arcos/chispas cian. Reutiliza el efecto periférico de Terminar
turno, conservando botón, posición y acceso a las opciones.

## Electricidad de Terminar turno — 15/10/2026

`presentation/end_turn_electricity.gd` añade arcos cian con halo y chispas
alrededor del aro mecánico existente. El centro queda libre para el texto;
`end_turn_button.gd` adjunta una capa transparente a la entrada, sin cambiar
el PNG, forma circular, área de clic ni callback de turno.

El efecto cesa al deshabilitarse el botón y respeta intensidad de destellos
(cero lo desactiva) y efectos reducidos (1 arco/4 partículas frente a 3/12).
Ligero realce al apuntar o enfocar, sin sonidos nuevos. Geometría nativa,
sin nuevos assets rasterizados, RNG jugable ni cambios de reglas/guardado.

Validación actual: HUD **113/0** con render nativo aislado y captura revisada;
distribución y clic de combate **41/0 headless**. Audio Dummy; avisos de recursos
al cerrar distribución, sin errores de script/aserciones. Sin exportar ni
probar Web/dispositivo físico.

## Mazo y bolsa tecnológicos — 15/10/2026

Registro de batalla: libreta tecnológica con espiral y lápiz, nuevo asset
`assets/ui/journal.svg` generado desde `hud_navigation_icons.py`. Se ubica en
el HUD en **962/8, 46×48**, entre bolsa y Menú. El contador de bolsa se acomoda
sin cruzarse con la libreta. Ya no hay botón «Registro» sobre el escenario.
Tooltip y acción conservan el nombre «Registro del combate»; misma lectura
desplazable, estado vacío y bloqueo durante acciones. Solo se habilita en combate,
no aparece como acción sin conexión en recompensas. Sin cambio de reglas/guardado.

Validación actual: HUD **113/0** con render nativo aislado y captura revisada;
posición, contador, apertura/lectura y bloqueo durante acción verificados.
Auditoría **668 hashes válidos**. Audio Dummy, avisos de recursos al cerrar;
sin errores de script/aserciones, exportación ni prueba Web/dispositivo.

Mazo usa tres cartas superpuestas con placa eléctrica; bolsa una mochila de
suministros con cierres, metal y luces cian. Se sustituyen `assets/ui/deck.svg`
y `assets/dungeon/bag.png`, compartidos por los accesos existentes sin cambiar
acciones ni tamaños. Procedencia y selección de objetivos por fotos en
[Bolsa de objetos](../objects/README.md).

## Actualización de pulido — 07/10/2026

[Implementación actual, assets, reglas y validación](../polish_2026_10/README.md).
La documentación y resultados anteriores se conservan como historial.

# Botones y preparación de aventura — 17/09/2026

## Limpieza del 23/09/2026

Se retiraron los cuatro PNG restantes del estilo de madera, el marco de modal anterior, `end_turn.png` y `heart.svg`, sin consumidores actuales. Se conservan el estilo oscuro activo y `end_turn_round.png`.
Véase el [inventario de limpieza](../cleanup/2026-09-23.md).

## Comportamiento actual

- Tema compartido de botones de acción con marco de hierro oscuro y oro.
  Estados normal, hover, pulsado y desactivado; foco visible para teclado.
- Se aplica por herencia a botones comunes, incluidos Menú, Volver, compras,
  navegación y diálogos. Se conservan los assets específicos ya existentes del
  inicio y terminar turno, las cartas y las zonas invisibles de actores/iconos.
- Selección de personajes y de reliquia comparten la barra superior del campamento,
  cada una con su título y Menú. El saldo de almas sigue siendo exclusivo del campamento.
- Selección: Volver regresa al campamento. Panel inferior ornamental para el
  contador y los nombres de la pareja. Elegir reliquia tiene botón con gema celeste
  y permanece desactivado hasta elegir dos héroes.
- Reliquias: fichas algo más altas para mantener el texto dentro del marco.
  Se conserva la elección única para ambos héroes y el guardado de preparación.

## Archivos y recursos

`src/ui/components/button_skin.gd` instala el tema y sus estados. Usa regiones
sobre los PNG originales y ajusta los bordes del botón común por nueve secciones.
`preparation_header.gd` comparte la barra de campamento/selección/reliquias.
`src/ui/screens/selection_screen.gd` contiene ahora la presentación antes alojada
 en `main.gd`; los callbacks del controlador mantienen reglas y persistencia.

Assets generados mediante **imagegen integrado**, sin CLI:

- `assets/ui/buttons/button.png`: marco reutilizable para acciones.
- `assets/ui/buttons/relic_button.png`: acción Elegir reliquia con gema.
- `assets/ui/buttons/party_panel.png`: panel inferior de pareja.

Textos añadidos por Godot para mantener legibilidad y traducción. PNG fuente
intactos, importación limitada a 512 px. [Prompts completos](prompts.json) y
[archivos de origen](sources.json). Las regiones omiten el margen transparente
sin modificar las imágenes originales.

## Validación

Godot local: selección 47, equipamiento 12, campamento 33 e interfaz general 271,
sin fallos. Revisión renderizada a 1280×720 de selección y equipamiento, incluidos
texto, marco, pareja elegida y transición a aventura. Capturas temporales retiradas.
Sin exportación APK/Web ni pruebas nuevas en navegador, emulador o dispositivo físico.

## Navegación de reliquias (17/09/2026)

Nuevos assets `assets/ui/buttons/back_party.png` (flecha dorada) y
`assets/ui/buttons/start_adventure.png` (portal celeste), aplicados en la elección
circular de reliquia. PNG originales intactos, regiones en `button_skin.gd`.
Generados con imagegen integrado: [prompts](relic-navigation-prompts.json),
[fuentes](relic-navigation-sources.json). Sustituye las fichas descritas arriba;
ver [estado actual de reliquias](../objects/README.md).

## Estilo actual: tablones y cabeceras (17/09/2026)

Esta revisión reemplaza el estilo metálico de los botones de texto por madera
oscura con herrajes. Incluye inicio, navegación, compras, acciones de preparación
 y diálogos; Menú utiliza su propio cartel con anillas. Cartas, iconos sin fondo
 y el botón circular de terminar turno mantienen sus diseños específicos.
Las tres barras de campamento/personajes/reliquias usan un marco de hierro y oro,
con margen interior para que el título no pise las filigranas.
Títulos y cuerpos de diálogos generales centrados; los tesoros ya usaban centrado.

Assets generados mediante imagegen integrado, originales conservados e importación
limitada a 512 px:

- `assets/ui/buttons/wood_button.png`: tablón compartido.
- `assets/ui/buttons/wood_menu.png`: cartel específico de Menú.
- `assets/ui/buttons/header_frame.png`: marco de la cabecera.

[Prompts completos y procedencia](wood-assets.json). Regiones y estados en
`button_skin.gd`, cabecera en `preparation_header.gd`, centrado en `dialog_view.gd`.
Los assets anteriores quedan como fuentes históricas; las acciones de preparación
usan ahora la madera compartida para mantener coherencia.

Pruebas locales de esta revisión: campamento 33, selección 47, equipamiento 46,
inicio/opciones 13 e interfaz general 271; sin fallos. Revisión renderizada de
cabeceras, selección y modal del arco en Linux a 1280×720. Capturas temporales
eliminadas. Sin exportar APK/Web ni validar en navegador, emulador o Android físico.

## Centrado de Menú — 18/09/2026

El estilo `wood_menu` usa márgenes superior/inferior de 8 px, eliminando el
desplazamiento hacia abajo causado por 16/4. Revisado en combate renderizado
Linux 1280×720; se aplica al estilo compartido de barras superiores.

## 18/09/2026 — Salir y engranaje de opciones en inicio

«Salir del juego» reemplaza a Opciones en la columna de botones principales.
Opciones pasa a un botón cuadrado de 70×70 en la esquina superior derecha,
sin texto visible, con engranaje metálico y tooltip. `assets/ui/settings.svg`
se dibujó en código siguiendo la paleta oscura/dorada de la interfaz.
`ui/components/title_actions.gd` compone ambas acciones; `main.gd::home` delega.
La salida realiza checkpoint y cierra la aplicación nativa. En Web muestra
un cuadro indicando que se puede cerrar la pestaña, sin intentar cerrarla.

Validación local Linux/llvmpipe: `test_title.gd`, 13 comprobaciones aprobadas
más clic final en Salir que termina el proceso con código 0. Se comprobaron
opciones, volumen, persistencia, pantalla completa, navegación/continuación.
Revisión visual 1280×720; captura temporal eliminada. Importación y diff
correctos. Rama Web sin ejecutar en navegador; no se exportó.

## Flechas gráficas para Web — 18/09/2026

`assets/ui/arrow_left.svg` y `arrow_right.svg`: assets vectoriales originales,
dibujados en código con contorno oscuro, dorado y bordes escalonados. No hubo
generación con IA ni fuentes externas. Sustituyen flechas Unicode de navegación
en Aventuras, Elegir reliquia, Saltar recompensa, Bajar por la escalera,
Volver e Inicio. No dependen de glifos ni fuentes de respaldo del sistema.

`button_skin.arrow` usa el icono nativo de Button, heredando estados y sin
interceptar clics. `plaque_arrow` centra texto e icono en el cartel del arco.
Los textos y tooltips quedan sin flechas Unicode. No cambian las acciones.

## Flecha junto a Volver — 22/09/2026

`button_skin.arrow` dibuja la flecha de «Volver» a 8 px del texto nativo
centrado, calculando su ancho con la fuente actual. Conserva los colores de
interacción y toda el área pulsable. Las otras flechas no cambian.
Revisión local renderizada del menú a 1280×720, sin errores.
Sin exportación ni validación Web/móvil en este cambio.

## Estética vigente — 23/09/2026

La interfaz usa negro carbón y metal gris con matiz violeta, siguiendo el inicio.
Reemplaza visualmente los tablones/marcos dorados descritos en entradas anteriores.
[Assets, integración y validación](dark/README.md).

## Botones compactos legibles — 23/09/2026

Los botones y carteles pequeños usan `DarkSkin.button`: fondo oscuro uniforme,
borde de 2 px pegado al perímetro y esquinas de 3 px. El centro queda libre de
ornamentos para no interferir con los textos. Conservan sus estados de hover,
pulsado, deshabilitado y foco. `ButtonSkin.style` retorna `StyleBox` para admitir
ambos estilos; `header_frame` y `party_panel` siguen usando el asset ornamental,
al igual que los paneles grandes y modales mediante `DarkSkin.frame`.

Revisión visual local del campamento a 1280×720: carteles, Refugio y botón Menú
legibles; marco superior conservado. `git diff --check` sin errores.
Sin exportar ni verificar web/móvil.

### Refinamiento de bordes — 23/09/2026

Los botones compactos ahora usan un SVG de borde metálico biselado con pequeños
remaches, manteniendo libre el centro. Modales y cuadros emergentes usan otro
SVG de contorno fino sin ornamentos invasivos. Implementación y procedencia:
[marcos oscuros](dark/README.md#marcos-contenidos-y-botones-metálicos--23092026).

### Separación del botón Menú — 23/09/2026

En encabezados de preparación/campamento y combate, Menú mide 102×40 y queda
centrado con mayor separación del marco. El botón Campamento del encabezado
compartido conserva su ancho y adopta también la altura de 40 px.

### Volver sin flecha — 23/09/2026

El helper común `main.button` deja de aplicar icono a «Volver», incluyendo
navegación y modales. Se elimina el dibujo especial de su flecha en `button_skin`.
Las variantes «Volver a héroes/personajes/campamento» ya eran solo texto.
Se conserva `arrow_left.svg` porque sigue usándose en Inicio.
Prueba local headless de bolsa sin fallos (incluye regreso); búsqueda de usos y
`git diff --check` limpio. Sin nueva revisión visual ni exportación.
