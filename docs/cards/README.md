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
