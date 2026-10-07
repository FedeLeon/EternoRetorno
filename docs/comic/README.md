# Apariciones de ataque en cómic — 18/09/2026

> Estado actual 05/10/2026: 30 secuencias de héroes de **16 cuadros HD**, luces
> y partículas. Ver [formato vigente](hd/README.md).
> Las secciones fechadas siguientes describen versiones históricas.

## Limpieza del 07/10/2026

Las seis defensas estáticas de `assets/comic/defense/` se retiraron por no tener
consumidores. El runtime usa `assets/comic/motion/<hero>_defense.png` para las
defensas y cuatro variantes animadas por héroe para los ataques. Se conservan
los treinta atlas, sus fuentes HD, retratos base y prompts. Las referencias
intermedias HD se pueden regenerar; véase la [auditoría](../cleanup/2026-10-07.md).

## Limpieza del 23/09/2026

Las 18 imágenes estáticas adicionales de `assets/comic/attacks/` se retiraron: el juego utiliza las 24 secuencias de `assets/comic/motion/`. Los retratos base se conservan para otras pantallas.
Véase el [inventario de limpieza](../cleanup/2026-09-23.md).

Cada héroe tiene una ilustración estática propia en primer plano, tomada de los
concepts individuales del usuario. Se conservan la transparencia RGBA y el contorno blanco originales.
Las líneas de velocidad se dibujan detrás de la ilustración.
La hoja `conceptosAtaques.png` es referencia de dirección artística. Cada héroe
dispone ahora de la pose original y tres variantes ofensivas nuevas.

## Comportamiento

- Cartas aceptadas con daño o veneno: aparición abajo a la izquierda sobre la escena, entrada lateral, líneas de velocidad del
  color del héroe, leve acercamiento y salida por transparencia en 0,72 segundos.
- Luego continúa la animación del actor y la reacción del objetivo.
- Curación y consumibles conservan la presentación previa.
  El turno enemigo usa las apariciones de ataque descritas abajo.
  Las cartas de bloqueo usan las ilustraciones defensivas descritas abajo.
  Las sinergias conservan sus animaciones conjuntas sin viñetas adicionales.
- Las reglas y el checkpoint se ejecutan antes del efecto. Una carta rechazada
  no crea viñeta. No modifica daño, energía, RNG ni guardados.
- El efecto no captura eventos; el flujo mantiene `combat_busy` hasta terminar.
  Capa 150: sobre cartas y bajo diálogos de capa 200. Se libera al terminar y
  pertenece a la pantalla, por lo que se elimina también al cerrar esa pantalla.

## Archivos

- `src/presentation/hero_cut_in.gd`: efecto visual autónomo; recibe un ID de héroe.
- `src/ui/combat_flow.gd`: invocación posterior a la resolución válida.
- `assets/comic/`: seis imágenes originales sin editar; filtro lineal para ilustración.
- [Procedencia y huellas SHA-256](procedencia.json): no hubo prompts ni generación nueva.

## Validación

Prueba local `test_hero_cut_in.gd`: seis imágenes, duración/finalización,
limpieza de nodos e ID inexistente; headless sin fallos.
`test_combat_presentation.gd`: 15 comprobaciones aprobadas; rechazo sin efecto y victoria confirmada antes
de animar, caída, salida de sala y sinergias. Revisión visual local del guerrero.
Sin exportación APK/Web ni prueba en dispositivo físico.

## Posibles ampliaciones

Viñetas de sinergia y variantes de armamento de herrería. Las poses actuales
no cambian con el nivel de equipo. El efecto no consume números aleatorios de la aventura.

## Superposición transparente — 18/09/2026

Retirados oscurecimiento, banda opaca y bordes. Solo se dibujan ilustración y
líneas de movimiento, dejando visible la mazmorra. La imagen se ancla al borde
inferior izquierdo, con ancho máximo del 62 % de la vista, sobre cartas y HUD.
Los diálogos conservan su prioridad de capa. El acercamiento pivota desde abajo
a la izquierda para no desplazar el punto de apoyo.

Validación de este ajuste: prueba renderizada local de los seis héroes, limpieza
y anclaje inferior izquierdo sin fallos; captura del guerrero sobre la mazmorra.
Sin exportación ni pruebas de dispositivo.

## Defensas por héroe — 18/09/2026

Seis imágenes nuevas en `assets/comic/defense/`, generadas con imagegen a partir
del cómic de ataque de cada héroe. [Prompts exactos, fuentes y destinos](defense.json).
PNG RGBA con transparencia real y contorno blanco, sin fondo añadido.

- Guerrero: parada con espada y energía violeta.
- Guardiana: escudo al frente y chispas doradas.
- Pícaro: dagas cruzadas con brillo verde.
- Maga: bastón y barrera de cristal azul.
- Clériga: arma sagrada y barrera de luz dorada.
- Explorador: arco cruzado en guardia y destello azul.

`hero_cut_in.play(parent, hero, kind)` admite `attack` y `defense`.
El flujo invoca defensa cuando la carta otorga bloqueo sin daño ni veneno;
las cartas mixtas conservan ataque (una sola aparición por carta). El héroe
mostrado es el dueño de la carta, incluso si protege a un aliado. No se activa
por recibir daño o por ganar bloqueo de reliquias. Las sinergias mantienen su
presentación conjunta anterior. Se conserva entrada inferior izquierda,
transparencia, duración de 0,72 s y guardado previo a los efectos.

Las ilustraciones no cambian por nivel de herrería. Son poses estáticas con
movimiento y efectos en Godot, igual que las apariciones ofensivas.

Validación actual: prueba renderizada local de las 12 apariciones (ataque y
defensa de seis héroes), anclaje y limpieza sin fallos; 17 comprobaciones de
presentación de combate aprobadas. Inspección visual de los seis assets y
del guerrero defensivo sobre la mazmorra. Sin APK/Web ni dispositivo.

## Enemigos de la primera mazmorra — 18/09/2026

Seis nuevos PNG RGBA transparentes en `assets/comic/enemies/`, generados con
imagegen. Cada sprite de `assets/enemies/hd/` sirve de referencia de identidad;
el cómic del guerrero solo como referencia de estilo.
[Prompts exactos, fuentes y destinos](enemies.json).

| ID visual | Ataque en primer plano |
| --- | --- |
| crypt_bat | Picado y colmillos, estela violeta |
| crypt_lancer | Estocada de lanza hacia la izquierda |
| crypt_shaman | Llamarada de ceniza desde el bastón |
| crypt_slime | Chorro de ácido verde |
| skeleton_6 | Corte de espada con estela azul |
| crypt_automaton | Puñetazo mecánico con chispas anaranjadas |

Entran desde la derecha, quedan anclados abajo a la derecha y atacan hacia
la izquierda. Ilustración estática animada por desplazamiento/acercamiento y
líneas de velocidad, durante 0,72 segundos. No oscurecen la mazmorra.

`comic_cut_in.gd` contiene la presentación común; `hero_cut_in.gd` y
`enemy_cut_in.gd` solo configuran catálogo, textura, color y dirección.
Se mantienen la API y las dos variantes de héroes, bajo la capa de diálogos.

El flujo espera cada aparición antes de la animación del sprite enemigo.
`game.resolved_enemy_attacks` es un recibo transitorio de índices realmente
ejecutados al resolver `end_turn`: no se guarda ni calcula daño. Esto evita
apariciones de enemigos muertos por veneno, intenciones de bloqueo sin daño o
enemigos cuyo turno se canceló al caer el equipo. El estado se resuelve y guarda
antes de las animaciones; recargar no repite ataques ni consume RNG visual.

Validación local: prueba renderizada de los seis enemigos, transparencia, entrada
hacia la izquierda, anclaje y limpieza; veneno, bloqueo puro y derrota antes
del segundo atacante sin fallos. Regresión de las 12 apariciones de héroes
aprobada. Revisión de los seis assets y captura del lancero sobre mazmorra.
Sin APK/Web, emulador o dispositivo físico.

Validación final de esta integración: 18 comprobaciones de presentación
aprobadas, incluido primer plano del ataque letal; 155 comprobaciones de
reglas aprobadas (41/45 victorias simuladas entre las 15 parejas). El último
ataque sigue mostrándose aunque la derrota haya limpiado el estado del combate.

## Variantes ofensivas y combos — 18/09/2026

18 PNG nuevos RGBA de 1536×1024 en `assets/comic/attacks/`, tres por héroe.
Se generaron individualmente con imagegen tomando el cómic original de cada
personaje como referencia. Prompts exactos y procedencia: [carpeta attacks](attacks/).

| Héroe | Variante 1 | Variante 2 | Variante 3 |
| --- | --- | --- | --- |
| Guerrero | Corte ascendente | Tajo descendente | Estocada |
| Guardiana | Embestida con escudo | Golpe ascendente de escudo | Golpe descendente |
| Pícaro | Estocada baja | Corte cruzado | Puñalada descendente |
| Maga | Lanza de hielo | Abanico de cristales | Orbe arcano |
| Clériga | Lanza sagrada | Arco de luz ascendente | Estallido de luz |
| Explorador | Disparo arrodillado | Disparo en salto | Abanico de flechas |

`hero_cut_in.gd` rota por héroe entre las tres variantes y la original, sin
consumir RNG de la aventura ni guardar esa elección visual. No se repiten
poses dentro de un combo de dos o tres golpes; la siguiente carta continúa
la rotación. Defensa conserva su ilustración propia.

`rules/card_hits.gd` añade `hit_index` al recibo transitorio existente.
`presentation/card_impacts.gd` muestra una viñeta por golpe realmente resuelto,
seguida por el sprite, el impacto y el descenso de vida. Los contraataques se
reproducen entre golpes. Si muere el objetivo o el atacante, no se inventan
golpes adicionales. En ataques de área, el mismo índice de golpe no repite
viñeta por cada objetivo. Se conserva el orden de resolución por objetivo.

`combat_flow.gd` omite la viñeta introductoria cuando hay recibos de impactos,
evitando una aparición extra. Veneno sin daño y defensa siguen mostrando una
aparición. Reglas, checkpoint y consumo de cartas siguen anteriores a toda
animación. Las sinergias mantienen su presentación previa.

Validación: importación local; revisión visual de los 18 PNG y comprobación
de transparencia real. Prueba de rotación de cuatro poses para los seis
héroes, carga, anclaje y limpieza; prueba de combos de dos y tres golpes con
poses distintas y reducciones de vida/contraataques separados. Resultados
concretos de ejecución en el historial. Sin exportación ni dispositivo físico.

## Movimiento de los ataques — 22/09/2026

Las 24 variantes ofensivas de héroes ahora disponen de secuencias de cuatro
cuadros, con movimiento dibujado de armas y lanzamiento de proyectiles.
[Assets, reproducción y procedencia](motion/README.md). La descripción anterior
de ilustraciones estáticas corresponde a la entrega previa.
