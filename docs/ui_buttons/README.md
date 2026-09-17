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
