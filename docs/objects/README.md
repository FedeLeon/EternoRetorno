# Reliquias equipables y consumibles

Flujo: campamento → elegir dos personajes → equipar una reliquia distinta a
cada uno → iniciar aventura. Las ocho están disponibles desde el principio.
Cambiar de personaje elimina su asignación. La preparación se guarda en el
perfil y las reliquias elegidas se copian a los héroes de la aventura.

## Valores iniciales de reliquias

| Reliquia | Efecto del portador |
| --- | --- |
| Amuleto Vital | +10 de vida inicial y máxima |
| Anillo del Vigor | +1 energía compartida al primer turno de cada combate, si está vivo |
| Ídolo del Fénix | Sobrevive a un golpe fatal con 1 PV, una sola vez por aventura |
| Colmillo Envenenado | +2 acumulaciones en cartas que aplican veneno |
| Orbe Arcano | +2 daño por impacto de cartas ofensivas de maga o clériga |
| Botas del Viento | 3 bloqueo al inicio de cada turno |
| Escudo del Peregrino | Reduce cada ataque enemigo en 2 antes de absorber bloqueo |
| Moneda del Mercader | Mejora una carta suya en cada oferta si aparece alguna |

Las cuatro reliquias de grupo que ya se encontraban en la mazmorra permanecen
con sus reglas anteriores; no ocupan estos espacios personales. No se han
añadido oro, tiendas, velocidad ni una estadística nueva de poder mágico.

## Bolsa compartida

Para esta primera versión, cada aventura nueva recibe una unidad de cada ítem.
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
| Brebaje de Agilidad | Roba 2 cartas; mano desplazable si supera cinco |
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

## Validación

64 comprobaciones de reglas nuevas y 11 de interfaz, además de las pruebas
existentes de reglas (137), interfaz (121), personajes (404), selección (47) y
campamento base (19): 803 comprobaciones sin fallos.

Incluye las 15 parejas equipadas, efectos, objetivos inválidos, consumo único,
Fénix tras cargar y cambiar de combate, preparación persistida, cartas revividas,
recompensa pendiente mejorada, compatibilidad de guardados, limpieza de mejoras
temporales y navegación con eventos de entrada reales de Godot.

Capturas de escritorio: `loadout.png`, `bag.png`, `expanded-hand.png`.
No se compiló APK ni se probó este cambio en Android.
