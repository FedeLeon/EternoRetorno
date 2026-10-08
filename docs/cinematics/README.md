# Cinemáticas y pulido integral — 08/10/2026

## Entrega

Diez **cinemáticas ilustradas**, con cámara lenta, partículas discretas,
subtítulos, música y controles para continuar, pausar/reanudar u omitir.
No son videos prerenderizados: combinan ilustraciones y presentación en tiempo real.

- Inicio: «El fuego nos reúne», al pulsar Iniciar juego por primera vez.
- Personajes: una historia para cada uno de los seis héroes, al comenzar la
  primera aventura que los incluye. Se muestran las dos historias en secuencia.
- Guardianes: «Los ecos se apagan», «La raíz se libera» y «Después del último fuego».
  Aparecen tras una victoria confirmada, antes de continuar con las recompensas.
- **Historias**, en Inicio, permite volver a ver las escenas. Los finales quedan
  ocultos hasta vencer a su guardián; las historias de héroes pueden consultarse libremente.
- Opciones → **Cinemáticas automáticas** permite desactivarlas; la galería sigue
  disponible y vencer al jefe sigue descubriendo su final.
- Espacio/Enter/A avanza; Escape/B omite; P pausa. También hay botones táctiles.
- «Menos partículas y luces» detiene el movimiento de cámara y elimina partículas.

## Persistencia y responsabilidades

`data/cinematics.json` contiene textos, duración, colores, arte y contexto sonoro.
`src/presentation/cinematic_player.gd` presenta el relato sin cambiar perfiles,
mazos, vida, daño ni premios. `src/ui/cinematic_navigation.gd` coordina entradas,
restaura interacción/audio y registra descubrimientos. La galería vive en
`src/ui/screens/cinematics_screen.gd`; el orquestador añade solo sus puntos de entrada.

Las claves opcionales `profile.cinematics_seen`, `run.cinematics_seen` y
`settings.auto_cinematics` tienen valores compatibles con guardados anteriores.
No cambió la versión del guardado, los IDs ni los recorridos guardados.
El final del jefe se registra en la aventura **antes** de animar; cerrar el juego
no repite el reparto de premios ni la escena al reanudar. Las historias personales
se marcan al finalizar/omitir, también desde la galería. Desactivar las automáticas conserva el descubrimiento
al vencer a un jefe. Partidas históricas que ya pasaron esa recompensa no reciben
premios ni reproducciones retroactivas.

## Arte y audio

- Cuatro fondos originales generados con la herramienta integrada **image_gen.imagegen**,
  habilidad [imagegen](/home/fede/.codex/skills/.system/imagegen/SKILL.md): inicio,
  cripta, bosque y fortaleza. Finales en `assets/cinematics/`, 1280×720.
- Seis retratos en `assets/cinematics/portraits/`, extraídos del cuadro 5 de los
  ataques HD existentes. Sin cargar seis atlas completos en la galería.
- [Prompts exactos](prompts.json), [procedencia de fondos](sources.json) y
  [regiones/procedencia de retratos](portraits.json). Fuentes originales en `sources/`
  con `.gdignore`; no se incluyen en las exportaciones.
- Dos arreglos ambientales locales Ogg: `cinematic_intro.ogg` (40 s) y
  `cinematic_return.ogg` (36 s). Mezclan músicas/ambientes **CC0 existentes** con
  filtros, entrada/salida y normalización. No son composiciones o voces generadas por IA.
  [Autores y procedencia](../audio/sources.json).
- Música de guardianes desde el inicio del combate, recuperación del contexto al
  salir de cada escena, limitador de picos y reducción temporal de música de 3 dB
  en golpes fuertes. Recupera el volumen elegido por el usuario; no cambia preferencias.
- Voces de efectos saturadas reutilizan la más antigua, en lugar de cortar siempre
  la primera. Se conserva la preferencia de **ningún sonido al pasar el mouse**.

## Otras mejoras de la entrega

- [Seis enemigos nuevos](../enemies/cinematic_expansion/README.md), cada uno con
  ocho poses dibujadas y ataque HD transparente hacia la izquierda.
- Enemigos con reposo desfasado y estela breve al terminar el golpe, sin modificar
  escala del actor o reglas de daño; conservación de la corrección de tamaño por pose.
- Ambiente de combate: polvo en cripta, motas/hojas en bosque y brasas en fortaleza,
  detrás de los actores y fuera de la franja de cartas.
- Impactos locales: chispas, arco de escudo para bloqueo y onda de golpes fuertes;
  respetan opciones de efectos y no añaden sacudidas globales.
- Mensajes de acciones con fondo legible y desaparición gradual, separados del pie
  de pantalla y las cartas. Galería con fondo ilustrado y finales por descubrir.

## Revisión integral y límites

[Análisis por sistema](AUDITORIA.md) registra qué se revisó, qué se cambió y
qué aspectos requieren pruebas de publicación, dispositivos o balance real.
Los resultados locales de esta entrega se detallan allí; no se exportó el juego.

## Secuencias de imágenes — 08/10/2026

21 ilustraciones nuevas: un plano propio por capítulo, tres en introducción y
dos por héroe/guardián. Sustituyen los retratos fijos durante la reproducción,
con fundidos pausables de 0,55 s y cámara suave. Efectos reducidos mantienen
cambio de imagen sin movimiento/fundido. La galería usa la imagen de cada historia.
Prompts/fuentes en `film/`; runtime en `assets/cinematics/shots/`.
[Mediciones, decisiones y pruebas actuales](../presentation_refinements/README.md).
