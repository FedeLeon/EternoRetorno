# Combate: poses, parejas y práctica guiada

Implementado el **15/10/2026**. Mantiene la dirección de cómic americano
postapocalíptico, los cuatro civiles y los primeros planos estáticos con efectos.

## Guardia y golpes de los cuatro héroes

- Cuatro atlas nuevos de guardia: **12 dibujos distintos por héroe**, en bucle
  continuo de 2,4–2,91 segundos, con ritmo desfasado por personaje. Brazos,
  herramientas, respiración, pelo y ropa cambian en los dibujos. Una transición
  de 120 ms suaviza cada cambio; no se estira/deforma el cuerpo mediante escala.
- Ocho atlas nuevos de golpes, **12 poses propias por acción**: estocada y barrido
  de Nicolás; empujón de escudo y golpe de palanca de Inés; puñalada y doble corte
  de Mauro; descarga dirigida y abanico eléctrico de Vera. Ya no comparten imágenes.
- Se conserva el tamaño de celda (256 para guardia, 384 para variantes), IDs y
  escala proporcional común por banco. Pies en 240/368, con corrección de la
  línea opaca durante la guardia. Ataque, carrera y caída interrumpen la guardia.
- `hero_guard_idle.gd` controla el ciclo; `detailed_hero.gd` conserva prioridades
  y transiciones. No se regeneraron ni animaron los primeros planos estáticos.

## Seis parejas con decisiones propias

Los valores base, coste de 2 y recetas permanecen. Cada aventura **nueva** tiene
`pair_tactics_version = 1`; una aventura guardada sin esa versión conserva los
efectos anteriores. IDs de cartas/héroes y guardado siguen siendo compatibles.

| Pareja | Sinergia | Interacción adicional condicionada |
| --- | --- | --- |
| Nicolás + Inés | Corte a cubierto | Si ambos ya tienen bloqueo, interrumpe el contraataque antes del golpe. |
| Nicolás + Mauro | Incisión asistida | Si el objetivo ya tiene corrosión, ignora su bloqueo. |
| Nicolás + Vera | Puente de tensión | Elimina hasta 8 de bloqueo del objetivo antes del daño. |
| Inés + Mauro | Cortina reactiva | Si algún aliado ya tiene bloqueo, reduce 25% el daño de la intención del objetivo este turno. |
| Inés + Vera | Jaula de Faraday | Interrumpe el poder especial o contraataque anunciado antes de golpear. |
| Mauro + Vera | Reacción en cadena | Si el objetivo ya tiene corrosión, propaga 3 a los otros enemigos vivos. |

Cada pareja tiene un emblema original con sus herramientas y colores. Solo las
**dos instancias concretas** que pueden combinarse y pagarse llevan el emblema
pulsante. El botón explica la condición y, al ejecutar, una conexión de luz y
partículas une a los héroes. Con tres enemigos, el botón pasa al espacio libre
sobre la energía para no cubrir objetivos. Con uno/dos conserva el espacio central.

Reglas en `pair_tactics.gd` y `synergy_actions.gd`; elegibilidad en `card_synergies`.
Interfaz en `synergy_view`/`synergy_readiness`, efecto en `pair_link_fx`. Resolver y
hacer checkpoint sigue precediendo a la animación. Sin RNG de juego en los efectos.

## Primera aventura: aprender jugando

La última página de la introducción ofrece **Practicar**. También se accede desde
el tutorial existente en opciones. La práctica usa la pareja elegida y controles
reales, en cinco pasos con avance condicionado a la acción:

1. Jugar una defensa sobre su dueño y conseguir al menos 6 de bloqueo.
2. Terminar turno y observar absorción y desaparición del bloqueo.
3. Guardar una carta boca abajo; recuperarla sigue siendo posible.
4. Terminar turno y verla regresar de frente en la nueva mano.
5. Combinar las dos cartas marcadas y elegir el maniquí.

Usa un `Game` temporal sin guardado, tres de energía, daño de práctica 6 y objetivo
fijo. La aventura, mano, vida, premios y RNG originales no se modifican. Finalizar
restaura la misma instancia original y guarda solo la finalización del tutorial;
salir también restaura la aventura. Hay reinicio para recuperarse de errores y
reposición de cartas en el paso de sinergia. No añade recompensas al juego real.

`guided_lessons.gd` prepara/evalúa ejercicios; `guided_practice_navigation.gd`
coordina el aislamiento y las vistas, reutilizando combate y reserva existentes.
El entrenamiento libre sigue siendo independiente.

## Enemigos y jefes

Seis bancos renovados, **ocho dibujos distintos** cada uno (cuatro de reposo y
cuatro de ataque): sonda de conductos (`crypt_bat`), operario perforador
(`crypt_lancer`), recolector armado (`goblin_0`), guardián del subsuelo
(`crypt_automaton`), supervisor del cinturón (`goblin_7`) y ARCA (`flying_3`).

`enemy_motion.gd` diferencia anticipación, golpe, pausa de impacto y recuperación
según masa/arma/movimiento; los tres jefes tienen una preparación más larga.
Cada pose clave tiene un intervalo visible. Sin cambios de escala del actor;
conserva las correcciones medidas por dibujo y el retorno al suelo. Los demás
enemigos reutilizan sus dibujos con los tiempos ajustados a su perfil. Los
primeros planos enemigos siguen siendo estáticos.

## Assets y procedencia

- `jobs.json`: prompts exactos, referencias anteriores, herramienta y originales
  externos de los **12** bancos de héroes; copias conservadas en `sources/`.
- `enemy_jobs.json`: los mismos datos para **6** bancos enemigos.
- Total: **192 dibujos nuevos**, 12 atlas de héroes, 6 atlas enemigos y 6 retratos
  enemigos derivados del primer frame. Se reemplazan los recursos activos.
- `scripts/import_fluid_actors.gd` / `import_expressive_enemies.gd`: empaquetado
  geométrico reproducible, alfa, proporciones y baselines; sin dibujar por código.
- `scripts/synergy_emblems.py`: arte vectorial original de los 6 emblemas.
- `docs/art_direction/postapocalyptic/assets.json`: hashes y procedencia vigentes.
  Los importadores anteriores respetan `fluid_revision` y no pisan estos bancos.
- `scripts/audit_enemy_pose_sizes.py` mide las correcciones actuales; auditoría
  de atlas mantiene 96 hojas / 928 frames (los reemplazos no cambian el formato).
- Fuentes/documentación siguen excluidas de exportación por los presets actuales.

## Validación

Comprobaciones realizadas con Godot 4.7.2 local, audio Dummy y datos de prueba:

| Comprobación | Resultado |
| --- | --- |
| Auditoría de contenido | 1.510 comprobaciones / 0 errores |
| Atlas de batalla | 96 hojas, 928 frames / 0 errores |
| Procedencia/dirección visual | 689 recursos validados; 0 hashes inválidos y 0 pendientes de la cola existente |
| Repetición de ambos empaquetadores | 24 PNG activos idénticos por SHA-256 |
| Corrida general headless | 101/102 suites aprobadas antes de corregir el ejercicio de Inés |
| Parejas, condiciones y práctica de bloqueo para las seis parejas, después de corregir | 82/0 headless |
| Sinergias base, atomicidad y persistencia después de corregir | 200/0 headless |
| Práctica completa después de corregir | 14/0 headless y 14/0 nativo aislado |
| Guardia continua, 12 dibujos distintos, suelo y prioridades | 910/0 headless y 910/0 nativo aislado |
| Variantes de golpes y marcos | 356/0 nativo aislado |
| Seis enemigos renovados, tres mazmorras y control con tres objetivos | 99/0 headless y 99/0 nativo aislado |

La suite restante de la corrida general encontró que Inés usa defensas de
objetivo aliado, no de objetivo propio. Se amplió la selección del ejercicio a
aliado/todos los aliados y se comprobó que **cada una de las seis parejas puede
jugar realmente su defensa y preparar su sinergia**. Los resultados 82/0, 200/0
y 14/0 son posteriores a esa corrección; no se presenta 101/102 como una corrida
completa sin fallos. No quedan fallos funcionales conocidos de esta revisión.

Revisión visual de las capturas actuales: cuatro guardias, estocadas/barridos,
anticipación/impacto de los seis enemigos, tres escenarios, disposición con tres
enemigos y práctica de bloqueo/sinergia. Los nuevos bancos no muestran las placas
rectangulares de fondo de sus predecesores. Una ejecución nativa de guardia perdió
la conexión con Xephyr al correr junto a otra; se repitió sola y completó 910/0.
Algunas suites UI mantienen avisos de objetos/recursos al cerrar el motor; no se
confunden con aprobación de aserciones ni con validación Web.

Capturas y logs desechables en `artifacts/combat_refinement/`, fuera de Git.
Sin exportación, prueba Web ni dispositivo físico. Queda pendiente ajustar el
balance de los bonos según partidas reales; estas pruebas verifican las reglas,
compatibilidad y presentación, no sustituyen esa evaluación de dificultad.
