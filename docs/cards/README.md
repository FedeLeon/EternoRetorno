# Cartas por héroe

**Contenido actual:** 90 cartas, 15 por héroe. [Catálogo](CATALOGO.md) y
[progresión del mercado](../market/README.md). Se añadieron 60 cartas y se
redujo la potencia del mazo inicial sin modificar partidas ya iniciadas.

**Actualización:** la distribución vigente se describe en
[Combate de mazmorra](../dungeon/README.md). Ahora se roban seis cartas,
la mano se asoma desde abajo y las ilustraciones se asignan por ID de carta.
[Ilustraciones minimalistas: fuentes e integración](art/README.md).
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

## Mano completa visible — 16/09/2026

Reemplaza los valores del abanico anterior: cartas de 174×278, paso de 160 px,
rotación ±3° y arco de 8 px. La mano empieza alrededor de y=420, con todos los
bordes y textos dentro de la pantalla. Seleccionar mantiene la elevación
(y=358), endereza y amplía a 218 px. El scroll conserva manos con robo adicional.
El botón Terminar turno ocupa el lateral izquierdo sobre la energía.

## Cabecera reorganizada — 16/09/2026

La fila superior muestra coste y, a su derecha, espada/escudo. Las cartas mixtas
muestran ambos iconos en horizontal. El nombre de la carta ocupa la antigua fila
del nombre del héroe, sobre la ilustración. Se elimina la etiqueta del héroe en
la cara de la carta; el dueño se conserva en datos, color y tooltip.
Cambio en el constructor compartido `main.gd::card_panel()` y
`card_type_icons.gd`, por lo que aplica también a mazo y recompensas.
Validación actual: layout 33 renderizadas, UI 91 headless, sin fallos. La cuenta
UI baja al retirar una etiqueta por carta. Revisión visual local a 1280×720;
capturas temporales retiradas. Sin exportación Web/APK.

## Inspección sin energía — 16/09/2026

Toda carta en la mano se puede seleccionar, levantar y volver a bajar aunque
no alcance la energía. Conserva el aspecto atenuado si no se puede jugar.
Seleccionar no gasta energía: `valid_targets()` no habilita objetivos y
`play_card()` rechaza la acción si el coste supera la energía disponible.
Cambio de presentación en `main.gd`, sin modificar reglas.
Validación: layout headless, 36 comprobaciones sin fallos, incluyendo selección
con energía cero, intento de jugar sin cambios de estado y deselección.
Sin exportación Web/APK ni nueva revisión visual.

## Enlaces entre héroes

Doce cartas de recompensa (dos por clase) llevan ENLACE. Conservan sus efectos
individuales y pueden consumirse junto a una carta de su compañero para un
ataque especial. [Las 15 combinaciones y reglas](../synergies/README.md).

## Mazo inicial de 20 cartas

Cada héroe aporta 10: cuatro copias de su ataque básico, cuatro de su defensa
básica y una de cada una de sus otras dos cartas iniciales modestas. Todas
cuestan 1 de energía. Las cartas de mercado, victoria y ENLACE se siguen
consiguiendo después. Se mantienen seis cartas robadas por turno y tres de
energía. Solo cambia el inicio de nuevas aventuras; las guardadas conservan
sus instancias. La fuente es `scripts/create_content.py` y su catálogo generado.

## Texto legible en cartas inclinadas (17/09/2026)

`ui/components/card_typography.gd` aplica una copia compartida de la fuente
integrada de Godot con MSDF y filtrado lineal a las etiquetas de cada carta
(nombre, descripción y ENLACE). Se evita heredar nearest del arte pixelado al
rotar letras pequeñas. No cambia la fuente global, los marcos, las ilustraciones,
los dígitos gráficos, tamaños ni el abanico. Se usa la fábrica común de cartas.

Referencia: https://docs.godotengine.org/en/stable/classes/class_fontfile.html
Validación local: distribución 38 e interfaz 271, sin fallos. Revisión renderizada
Linux a 1280×720 de texto inclinado. Capturas temporales eliminadas. Sin exportación
APK/Web; legibilidad en navegador y dispositivos aún no comprobada en esta revisión.
