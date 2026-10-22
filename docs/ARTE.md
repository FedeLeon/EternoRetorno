# Dirección de arte vigente

## Mundo y lenguaje visual

Cómic de resistencia civil en un mundo postapocalíptico de máquinas asesinas.
Tinta negra, sombras definidas, colores planos vivos y tramas discretas.
Bordes de viñeta y detalles de papel deben reforzar la composición sin invadir
texto, objetivos, caminos ni zonas de clic.

Los héroes son civiles con ropa de trabajo y armas improvisadas. Las máquinas
necesitan siluetas reconocibles y presencia amenazante, con tamaño limitado por
el espacio de la formación. El suelo y los estados deben permanecer claros.

## Paleta y contornos

- Mundo: negro, gris acero, violeta y azul petróleo; escenarios ligeramente
  oscuros y lúgubres para separar a los personajes del fondo.
- Identidades: Bruno violeta, Mara naranja, Ciro verde/teal, Alma cian/violeta.
- Figuras, herramientas e iconos: recorte blanco/marfil fino, manteniendo alfa
  real; no agregar un rectángulo opaco detrás del personaje.
- Información pequeña: siluetas simples y contrastadas. Los iconos de espada,
  escudo y estados deben poder reconocerse en su tamaño de interfaz.
- Bloqueo activo: interior oscuro y borde claro fino para conservar el número.

`data/comic_art.json` identifica recursos con borde ya pintado. El shader de
contorno es un respaldo; no prueba que se haya redibujado un asset.

## Personajes y primeros planos

Las poses de ataque, defensa, habilidad, daño y derrota de los cuatro héroes
tienen arte nuevo en alta definición. Comparten escala anatómica por personaje,
borde claro pintado y PNG individuales 512×512. Los originales de producción
permiten más detalle que los bancos reducidos antiguos; no se consideran una
mejora de calidad los reescalados que inventan píxeles sobre esos bancos.

Los cuatro héroes usan animación corporal mediante dibujos cuadro a cuadro;
los enemigos conservan una imagen por acción. No se añaden huesos ni
deformaciones para simular articulaciones. Se conserva el apoyo al cambiar cuadros.

### Criterio para animaciones de héroes en batalla

- Pies en las mismas posiciones sobre el suelo; escala y proporciones constantes.
- Muchos cuadros consecutivos con diferencias pequeñas y coherentes, sin saltos al
  cambiar de fila, invertir un ciclo o regresar a guardia.
- Gestos corporales legibles y contenidos, dibujados en brazos, cintura y equipo;
  evitar tanto poses casi inmóviles como cambios grandes entre cuadros. No resolver
  el movimiento desplazando, girando o deformando el recorte completo.
- Reposo lento: respiración y pequeños gestos propios del personaje; ciclo actual
  de 4,2 s. Ataque y defensa mantienen su duración y movimiento según la acción.
- Revisar en batalla el contacto con el suelo, continuidad y vuelta a reposo;
  conservar las acciones aprobadas al corregir otra secuencia.

Los primeros planos son recortes estáticos de ataque, defensa u otra acción,
con expresión y herramientas visibles. Sus luces y partículas son independientes,
con rayos que cubren el fondo sin cortarse al borde del recorte. El héroe se
encuadra abajo a la izquierda y el enemigo abajo a la derecha.

Los 112 primeros planos enemigos son dibujos independientes de ataque/defensa,
con alfa y borde claro pintado. Conservan chasis, sensores y herramientas del
modelo en batalla. La defensa retrae o protege con sus propias piezas; no añade
un héroe rival. Las 56 parejas fueron revisadas visualmente contra sus reposos.

## Cartas y tipografía

Se conservan los cuatro marcos y reversos de metal/papel restaurados, con las
ilustraciones actuales en cómic minimalista. La ilustración puede mostrar una
herramienta, gesto u objeto que represente el efecto sin incluir siempre al héroe.

Se usa Source Sans 3: cuerpo 550, encabezados 800 y cartas en negrita 700.
Las cartas evitan MSDF para conservar los glifos completos. Los números son
sencillos, con centro claro y detalle eléctrico cian discreto. Títulos, costes,
tipos y cantidades siguen siendo texto/controles del juego, no letras generadas
como parte del dibujo.

## Producción

Fuentes, prompts, referencias y geometría se conservan en `art_sources/`, junto
al registro de producción correspondiente. Las imágenes terminadas van a `assets/`.
Los catálogos y el manifiesto deben reflejar únicamente recursos integrados.

La dirección vigente reemplaza los estilos anteriores; no se conserva en `docs/`
una guía sketchbook o de animación esquelética como alternativa activa. Para
importación y procedencia, véase [Recursos](RECURSOS.md).
