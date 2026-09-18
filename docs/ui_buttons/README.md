# Botones y preparación de aventura — 17/09/2026

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
