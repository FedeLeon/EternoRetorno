# Cartas por héroe

**Actualización:** la distribución vigente se describe en
[Combate de mazmorra](../dungeon/README.md). Ahora se roban seis cartas,
la mano se asoma desde abajo y las ilustraciones se reservan vacías.
La explicación y galería siguientes conservan el diseño de la etapa inicial.

Marcos derivados del concepto `cartas.png` mediante imagegen. Guerrero rojo,
guardiana verde azulado, pícaro verde, maga violeta, clériga dorada y explorador
azul. El pistolero del concepto se adapta al pícaro existente.

`generated-frames.png` conserva la generación original. `scripts/import_cards.gd`
recorta los seis marcos y los escala con vecino más cercano a 96 × 144 en
`assets/cards/`. La generación no entregó transparencia exterior: se usan
recortes rectangulares del marco, sin el fondo de presentación.

`src/main.gd::card_panel` comparte el diseño entre mano, mazo, mejoras y
recompensas. Los nombres, costes y efectos son texto de Godot, calculados desde
los datos reales. Las ilustraciones reutilizan poses de los sprites existentes
según ataque, protección, curación y veneno. No se alteran reglas ni valores.

La mano tiene más altura y los paneles de combatientes son más compactos.
Más de cinco cartas permiten desplazamiento horizontal. El contorno dorado
indica selección; las cartas no disponibles aparecen atenuadas.

Validación local, Godot 4.7.2 Compatibility:

- `tests/test_cards.gd`: 30 cartas normales y mejoradas; texto sin recorte,
  clic sobre ilustración, objetivo y carta sin energía. Genera `gallery.png`.
- `tests/test_ui.gd`: límites de etiquetas y selección de pareja.
- `tests/test_equipment_ui.gd`: preparación, consumibles y mano de siete cartas.
- `tests/test_warrior.gd`: regresión de animaciones de combate.

La galería y la mano ampliada se revisaron renderizadas en Linux. Sin compilación
de APK ni pruebas nuevas en dispositivo Android.

## Iconos de tipo — 16/09/2026

Coste gráfico movido a la esquina superior izquierda. La esquina superior derecha
muestra espada para daño/veneno, escudo para bloqueo y ambos en cartas mixtas.
Cartas de curación pura no reciben un icono ofensivo/defensivo incorrecto.
`src/ui/components/card_type_icons.gd` compone estos indicadores en mano, mazo,
recompensas y colección a través del constructor compartido de cartas. Los títulos
en cartas estrechas usan tamaño 12 para conservar la lectura con ambos márgenes.

## Mano en abanico — 16/09/2026

La mano de combate se distribuye en arco suave: cartas de 174 px separadas
128 px (46 px de superposición), rotación progresiva de −8° a +8° y centro
más alto. Al tocar una carta se endereza, sube y se amplía a 218 px para leerla.
Se mantiene desplazamiento horizontal si la mano crece por robo adicional.
`src/ui/components/hand_layout.gd` calcula solo presentación; mazo, recompensas
y colección conservan sus disposiciones anteriores.

Validación actual: `test_combat_layout.gd`, ocho comprobaciones renderizadas
sin fallos; selección por ratón sobre carta rotada, carta elevada visible,
fin de turno y navegación. Abanico y carta seleccionada revisados en escritorio.
Capturas temporales retiradas; sin APK ni validación Android.
