# Apariciones de ataque en cómic — 18/09/2026

Cada héroe tiene una ilustración estática propia en primer plano, tomada de los
concepts individuales del usuario. Se conservan la transparencia RGBA y el contorno blanco originales.
Las líneas de velocidad se dibujan detrás de la ilustración.
La hoja `conceptosAtaques.png` es referencia de dirección artística; esta primera
versión usa una pose por héroe, no las tres variantes de la hoja.

## Comportamiento

- Cartas aceptadas con daño o veneno: aparición abajo a la izquierda sobre la escena, entrada lateral, líneas de velocidad del
  color del héroe, leve acercamiento y salida por transparencia en 0,72 segundos.
- Luego continúa la animación del actor y la reacción del objetivo.
- Curación, consumibles y turno enemigo conservan la presentación previa.
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

Poses diferentes para ataques especiales, viñetas de sinergia y variantes de
armamento de herrería. Hoy cada héroe usa su concept aportado, independientemente
del nivel de equipo. El efecto no consume números aleatorios de la aventura.

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
