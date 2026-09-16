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
