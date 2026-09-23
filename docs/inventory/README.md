# Fondo compartido de mazo y bolsa

23/09/2026: `assets/inventory/background.png`, generado con image_gen para ambas
vistas. Archivo original conservado, sin retoques; prompt y procedencia en
`prompt.json`. Estética oscura de piedra, cuero, cartas y bolsa en los extremos,
con centro despejado para contenido interactivo.

`src/ui/components/inventory_background.gd` crea una textura de fondo de
1280×720 con cobertura proporcional e ignora eventos de ratón. Se utiliza en
`main.deck_view` (solo consulta, no mejora de cartas) y `items_screen.gd` antes
de los controles. Sin cambios en reglas ni guardados.
Importación según política existente de fondos: Lossy 0,85, límite 1280 px.

Validación: ambas vistas renderizadas localmente a 1280×720; cartas, objetos y
cantidades legibles. Prueba headless de bolsa sin fallos y `git diff --check`.
Sin exportación ni validación web/móvil.

## Galería vertical del mazo — 23/09/2026

`src/ui/screens/deck_screen.gd` compone ahora la consulta del mazo; `main.deck_view`
delega la presentación y conserva la ruta independiente de mejoras de cartas.
Se elimina la marca «Eterno Retorno» y el botón Menú: «Volver» ocupa la esquina
superior derecha y retorna a la vista de origen. Los contadores tienen un panel
oscuro fino. Las cartas pasan de 224×244 a 224×336, en cinco columnas con paso
vertical 352; el scroll ocupa hasta el borde inferior (548 px de altura).

Validación local renderizada a 1280×720: proporciones y texto revisados;
comprobadas las 20 cartas, ausencia de marca y Menú, panel de contadores y retorno
al combate. `git diff --check` limpio. Sin exportar.
