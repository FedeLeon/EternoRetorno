# Reliquias equipables y consumibles

## Regla actual: una reliquia compartida (16/09/2026)

Campamento → dos personajes → elegir directamente una reliquia → iniciar.
No hay botones para asignar portador. Las ocho opciones están disponibles;
otra elección reemplaza la anterior y la interfaz exige exactamente una.

| Reliquia | Efecto compartido |
| --- | --- |
| Amuleto Vital | +10 vida inicial y máxima a cada héroe |
| Anillo del Vigor | +1 energía compartida en el primer turno, una sola vez por combate |
| Ídolo del Fénix | Una protección fatal por héroe y aventura, queda con 1 PV |
| Colmillo Envenenado | +2 acumulaciones en cartas que ya aplican veneno, de cualquier héroe |
| Orbe Arcano | +2 daño por impacto en cartas ofensivas de ambos, de cualquier clase |
| Botas del Viento | +3 bloqueo a cada héroe vivo al inicio del turno |
| Escudo del Peregrino | Reduce 2 de cada ataque recibido por cualquiera, antes del bloqueo |
| Moneda del Mercader | Mejora una carta por héroe representado en la oferta |

El alcance se guarda en `run.team_relic`; se copia el ID a cada
`hero.equipped_relic` para reutilizar las reglas por actor. Energía compartida
se aplica una sola vez. `phoenix_used` permanece independiente por héroe.
Preparación: `relics: {"team": id}`. Una preparación personal anterior se convierte
a compartida al abrir la selección; aventuras iniciadas conservan efectos
personales, sin recalcular vida. La API antigua por héroe sigue siendo compatible.
Las reliquias halladas dentro de la mazmorra conservan sus reglas anteriores.

Validación actual: equipamiento 90, interfaz 11 y HUD 85 headless, sin fallos.
Incluye las 15 parejas con bloqueo para ambos, efectos compartidos, energía sin
duplicación, Fénix por héroe y guardado. Selección renderizada en escritorio y
captura `loadout.png` revisada. Sin APK ni pruebas Android.

## Bolsa compartida

Las aventuras nuevas empiezan con la bolsa vacía. Cada cofre entrega una unidad
de un consumible aleatorio; consultar [Tesoros](../treasure/README.md).
Los inventarios de aventuras ya guardadas se conservan.
Se usan durante combate desde «Bolsa», eligiendo un objetivo válido. No cuestan
energía, se consumen una vez y no se reponen al cambiar de sala.

| Ítem | Efecto |
| --- | --- |
| Poción de Curación | Cura 12 PV a un aliado vivo |
| Frasco de Energía | +2 energía este turno |
| Pluma Fénix | Revive con 25 % de vida máxima, redondeando arriba; cartas inactivas al descarte |
| Tónico de Fuerza | +3 daño por impacto de cartas del aliado durante este turno |
| Veneno Concentrado | Aplica 6 acumulaciones a un enemigo |
| Elixir Arcano | +2 daño por impacto este turno, para maga o clériga |
| Brebaje de Agilidad | Roba 2 cartas; mano desplazable si supera seis |
| Bálsamo de Defensa | +12 bloqueo a un aliado hasta el siguiente turno |

Los potenciadores se acumulan con las reliquias y se limpian al comenzar otro
turno o terminar el combate. El veneno pierde una acumulación por turno como
antes. La Pluma requiere otro héroe vivo: la derrota de ambos sigue siendo
inmediata. Ídolo y Pluma son efectos distintos; revivir no restaura el Ídolo.

## Datos, arte y persistencia

- `data/equipment.json`: identificadores, iconos, efectos, valores y textos.
- `assets/objects/icons.png`: 16 iconos de 64 × 64, alfa real.
- `generated-sheet.png`: fuente creada con imagegen integrada desde las dos
  plantillas del usuario; prompt completo en `prompt.md`.
- `scripts/import_objects.gd`: recorte según los márgenes reales y escalado nearest.
- Estado por héroe: `equipped_relic`, `phoenix_used`, `turn_strength`, `turn_magic`.
- `run.inventory`: cantidades restantes, guardadas al resolver cada uso junto
  con mazo, RNG y efectos. `profile.preparation`: selección previa a la aventura.

Partidas antiguas continúan sin equipamiento ni consumibles retroactivos.
Iniciar una nueva aventura permite usar este contenido. No se necesita cambiar
la versión del archivo de guardado: los campos nuevos tienen valores opcionales.

## Validación histórica de la incorporación inicial

64 comprobaciones de reglas nuevas y 11 de interfaz, además de las pruebas
existentes de reglas (137), interfaz (121), personajes (404), selección (47) y
campamento base (19): 803 comprobaciones sin fallos.

Incluye las 15 parejas equipadas, efectos, objetivos inválidos, consumo único,
Fénix tras cargar y cambiar de combate, preparación persistida, cartas revividas,
recompensa pendiente mejorada, compatibilidad de guardados, limpieza de mejoras
temporales y navegación con eventos de entrada reales de Godot.

Capturas de escritorio: `loadout.png`, `bag.png`, `expanded-hand.png`.
No se compiló APK ni se probó este cambio en Android.


## Histórico: elección de portador y bloqueo gráfico (reemplazado por selección compartida)

La selección visual vive en `src/ui/screens/equipment_screen.gd`; recibe datos y
callbacks. `main.gd` coordina la sustitución, el guardado y la navegación.

`src/ui/components/block_indicator.gd` presenta bloqueo de héroes vivos y enemigos:
escudo de `assets/objects/icons.png` (índice 6, región 128,64 de 64×64) y
`NumberView`. Se reutiliza el arte del Escudo del Peregrino, sin generar ni
modificar imágenes. Se muestra también cero y el indicador no intercepta objetivos.

Validación actual: reglas de equipamiento 70, interfaz 11, HUD 76 y distribución
de combate 8: **165 comprobaciones locales sin fallos**. Incluyen las 15 parejas,
rechazo de dos reliquias distintas, transferencia, sustitución, persistencia,
compatibilidad de aventuras antiguas y bloqueo gráfico en ambos bandos.
Equipamiento y HUD también ejecutados con renderizado de escritorio; capturas
`loadout.png` y `../hud/combat.png` revisadas visualmente.
Sin exportar APK ni probar en emulador/dispositivo Android.

## Presentación de preparación (17/09/2026)

La elección de reliquia comparte la barra superior del campamento con título
propio. Botones y fichas usan el tema ornamental común; se conserva la selección
única para ambos héroes. Ver [botones y validación](../ui_buttons/README.md).

## Reliquias en círculo (17/09/2026)

La preparación muestra ocho iconos de 132×132 en un círculo de radio 190 px,
centrado en (640, 378). No hay fichas rectangulares ni descripciones alrededor.
El centro indica la reliquia elegida para ambos héroes. La barra superior conserva
el título y Menú, sin saldo de almas.

Tocar una reliquia la selecciona inmediatamente y muestra nombre y efecto en
un cuadro ornamental no modal hacia el exterior del círculo. Permanece visible
hasta elegir otra y no se cierra al tocar el fondo. La selección se guarda.
Iniciar aventura sigue desactivado mientras no haya una reliquia válida.

`equipment_screen.gd` calcula posiciones y emite `equip`; `main.gd` conecta la
selección a las reglas existentes. `equipment_description.gd` dibuja el cuadro
en el espacio lateral exterior, ajustando altura para no tapar la barra ni botones. Assets nuevos en
`assets/ui/buttons/back_party.png` y `start_adventure.png`, generados con imagegen
integrado. [Prompts](../ui_buttons/relic-navigation-prompts.json) y
[fuentes](../ui_buttons/relic-navigation-sources.json).

Validación local de esta revisión: equipamiento UI 14 e interfaz general 271,
sin fallos. Revisados círculo y diálogo renderizados en Linux a 1280×720.
Capturas temporales eliminadas. Sin exportación APK/Web ni pruebas Android/navegador.

Última revisión (17/09/2026): selección inmediata y cuadro persistente. Pruebas
locales de equipamiento UI 46 e interfaz general 271, sin fallos. Se verifican
las ocho posiciones, cambio de reliquia, persistencia al tocar fondo y ausencia
de modal. Revisión visual Linux de cuadros a derecha e izquierda; capturas retiradas.

### Centro despejado (17/09/2026)

El centro del círculo queda vacío: se retiraron el nombre, «Elegida para ambos»
y la indicación inicial. Nombre y efecto permanecen en el cuadro exterior de la
reliquia seleccionada. No cambia la selección compartida ni el guardado.

Retirado también el subtítulo «Elegí una sola reliquia para ambos héroes…»
(17/09/2026). Se conserva el título de la barra superior.

## Valhalla y preparación temporal — 18/09/2026

La selección de reliquias usa `assets/equipment/valhalla.png`: nubes, columnas
y ornamentos laterales. Iniciar aventura incluye `assets/equipment/door.png`
como icono de entrada de mazmorra junto al texto. Recursos creados con image_gen
integrado; [prompts y procedencia](../equipment/assets-2026-09-18.json).

La preparación ahora vive solo en memoria. Nueva aventura vacía pareja/reliquia
y retira `profile.preparation` antiguo; Volver a personajes conserva la elección
actual. Las aventuras guardadas conservan sus héroes y reliquia. Sustituye el
comportamiento histórico de restaurar el borrador descrito arriba.

Validación actual: reliquias UI 48 comprobaciones sin fallos, recorrido selección,
reliquia, retorno e inicio; revisión visual Linux del fondo y puerta. Campamento
47 comprobaciones sin fallos. Sin exportar APK/Web ni probar en dispositivo.

## Separación de responsabilidades — 18/09/2026

Los objetivos y efectos de consumibles viven ahora en `src/rules/items.gd`.
`game.gd` conserva la interfaz pública y guarda únicamente tras una aplicación
válida; no cambiaron valores ni formato de inventario.

Validación: batería local completa de 30 scripts aprobada.
[Detalle de la auditoría](../cleanup/2026-09-18.md).
