# Eterno Retorno: civiles contra la máquina

[Menú lateral ilustrado](../../map/sidebar_icons/README.md): Grupo, Mazo y
Caminos/Mapa con tres generaciones individuales; inventario actual de
**683 recursos visuales activos**.

[Iconos ilustrados de mapa y caminos](../../map/comic_icons/README.md): seis
PNG transparentes generados individualmente, con fuentes/prompts y exclusión
del generador vectorial. Sustituyen los símbolos de sala de la etapa anterior.


[Perro y gato del campamento](../../base_camp/companions/README.md): dos hojas
ilustradas transparentes, ocho poses cada una, caminar/olfatear/comer y pausas.

Actualización de cartas del 15/10: [cuatro frentes/reversos de metal y papel y
88 ilustraciones de cómic minimalista](../../cards/pixel_retain/README.md).
Se conservan las identidades civiles; las ilustraciones usan fondos despejados
y formas planas. La reserva permite guardar una carta por turno.

Actualización 15/10: [28 ilustraciones individuales de logros y máscara secreta](../../collection/comic_illustrations/README.md)
generadas con la herramienta integrada, sustituyendo los pictogramas de esa
sección. Inventario tras los accesos laterales: **683 recursos visuales activos verificados**.
Los recuentos de la entrega original siguientes son históricos.

Nueva dirección solicitada el 14/10/2026. Sustituye el sketchbook medieval.
Las referencias del usuario orientan el lenguaje visual; no se copian personajes,
logotipos, trajes ni mundos de esas franquicias.

## Mundo y tono

Una red autónoma mantiene una ciudad arruinada en un ciclo de reinicio. Cuatro
vecinos salen del refugio a recuperar suministros y descubrir cómo detenerla.
No son supersoldados: trabajan, reparan y se protegen con lo que encuentran.
El fuego, los cuadernos y el trabajo compartido conservan la esencia del juego.

- Nicolás, Carpintero: camisa violeta, delantal y herramienta de sierra adaptada.
- Inés, Constructora: chaqueta de obra, trenza, chapa de señalización y palanca.
- Mauro, Boticario: rostro descubierto, chaqueta verde petróleo, botiquín,
  cuchillos utilitarios y ácidos de recuperación.
- Vera, Profesora: cuaderno, abrigo violeta y emisor electromagnético reparado
  con una antena, cables y una batería. Su conocimiento reemplaza la magia literal.

## Lenguaje visual

Cómic de acción: contornos negros decididos, sombras planas de cel shading,
siluetas expresivas, colores vivos y trama de impresión discreta. Negro y violeta
en sombras; cian/verde petróleo para electrónica y naranja óxido para herramientas.
Sin armadura medieval, filigranas góticas, runas, cetros ni paisajes de fantasía.
Los civiles se distinguen de las máquinas por sus caras y materiales reparados.

Primeros planos: una ilustración estática por acción, borde blanco fino en
personaje/arma y luces/partículas detrás. Héroes desde la izquierda y máquinas
desde la derecha; el escenario continúa visible.

## Traducción del mundo

| Sistema existente | Nueva ficción |
| --- | --- |
| Campamento | Refugio entre infraestructura abandonada |
| Mercado | Intercambio de suministros |
| Herrería | Taller de recuperación |
| Iglesia | Laboratorio comunitario de especialización |
| Expediciones | Puesto de radio y encargos |
| Refugio | Barracón y cuaderno de técnicas compartido |
| Cripta | Red subterránea de mantenimiento |
| Bosque | Cinturón industrial invadido por vegetación |
| Fortaleza | Central automatizada del reinicio |
| Criaturas | Drones, autómatas y maquinaria hostil de siluetas diversas |
| Reliquias | Componentes recuperados |
| Veneno / magia | Corrosivos / interferencia y descargas |

## Producción y compatibilidad

`jobs/` conserva prompts, referencias y procedencia de la herramienta integrada
`image_gen.imagegen`. `sources/` conserva originales; `queue.json` registra el
alcance para no confundir diseños preparados con recursos ya integrados.
Los IDs internos y estadísticas se conservan para no invalidar guardados.
Las pruebas previas al cambio no validan esta dirección nueva.

## Integración completada — 14/10/2026

La entrega original sustituyó 632 recursos. Con los [nuevos caminos](../../paths/README.md)
y la [hoja separada de llamas](../../base_camp/stable_fire/README.md),
con los [assets HD de preparación](../../preparation_assets/README.md),
la auditoría independiente confirma **660 PNG/SVG activos actualizados**, sin
recursos visuales de la dirección anterior ni hashes desactualizados. Son
recursos del juego, no un filtro colocado sobre ilustraciones medievales.

- Cuatro diseños maestros civiles y 140 trabajos de ilustración/bancos terminados.
  Los bancos generan cuerpos, variantes, retratos, cartas y máquinas con la misma
  identidad. `jobs/` conserva prompts completos, referencias, ruta original de la
  herramienta y estado; `jobs/history/` conserva las iteraciones descartadas.
- 126 diseños de interfaz nativos: 120 símbolos industriales, cuatro marcos de
  carta y dos superficies de mapa. Se prefirió geometría SVG exacta para reservar
  espacio a texto/coste y evitar retratos impresos dentro de un marco vacío.
  `vectors.json` y `vectors/` conservan esa procedencia; otros 19 SVG activos
  incorporan la misma paleta. No se atribuyen estos vectores a ImageGen.
- Cuatro protagonistas, 88 ilustraciones mínimas de cartas, 56 apariencias de
  máquinas para las 57 definiciones existentes y sus primeros planos estáticos.
- Campamento urbano al atardecer, ocho edificios/elementos, seis interiores,
  tres zonas, descansos, encuentros, inventario, colección, recompensas y
  17 planos de cinemáticas. El brasero usa 24 dibujos con reproducción a 12 FPS.
- Mercado, Taller, Laboratorio y refugio mantienen la galería de cuatro retratos
  a la derecha, en 2×2. Los retratos compactos se recortan proporcionalmente;
  las tarjetas altas conservan el cuerpo completo de cada civil.
- Veintiséis catálogos narrativos publicados: ARCA reinicia los sectores;
  componentes, celdas, corrosión y dispositivos electromagnéticos traducen la
  ficción. Se conservan IDs, UIDs, funciones, porcentajes, premios y guardados.
  El sonido de máquinas utiliza impactos/electrónica del banco existente;
  no se descargó una banda sonora nueva durante este rediseño.

### Poses y tiempos

Las cifras de reproducción no equivalen a dibujos originales por fotograma.
Cada héroe tiene 12 dibujos de reposo y un banco de 24 poses de acción. Los clips
conservan 12 fotogramas de tiempo, con poses sostenidas: ataques con cuatro poses
más retorno, seis fases distintas de carrera, protección/herida/caída/dispositivo.
Se normaliza la altura del banco respecto del reposo y se conserva el apoyo de
los pies (240/368 en las hojas detalladas; 120 en derivados pequeños).

Cada máquina usa cuatro poses dibujadas en una tira de ocho tiempos: reposo,
anticipación, contacto y recuperación. Los primeros planos de ambos bandos
usan una imagen completa, fondo transparente, borde blanco y partículas detrás;
no reproducen estas tiras ni deforman la imagen. Héroes: 0,96 s, escala 1,28,
esquina inferior izquierda; máquinas: 0,72 s, entrada visual desde la derecha.

### Archivos y reproducción de la producción

- `queue.json`, `heroes.json`, `machines.json`: alcance y diseños estables.
- `assets.json`: hash de cada recurso activo, fuente e inputs derivados.
- `scripts/import_postapocalyptic_art.gd`: bancos, recortes y recursos finales.
- `scripts/import_sketchbook_actors.gd -- --comic`: poses civiles, métricas y
  variantes; el nombre histórico del importador no indica estética sketchbook.
- `scripts/import_postapocalyptic_icons.gd`: SVG a PNG para rutas compatibles.
- `scripts/import_sketchbook_derivatives.gd -- --comic`: retratos y derivados.
- `scripts/stage_postapocalyptic_catalogs.py` y
  `scripts/publish_postapocalyptic_world.py`: ficción con comprobación de datos
  no visuales y bloqueo de publicación mientras falten recursos.
- `scripts/audit_postapocalyptic_art.py`: cobertura estricta de esta dirección.

Los maestros medievales retirados permanecen solo como archivo en `retired/`,
con inventario/procedencia; no son dependencias del juego. Los nombres internos
`warrior/guardian/rogue/mage`, `church`, `crypt`, etc. son claves compatibles,
no etiquetas visibles que vuelvan a presentar a los civiles como clases clásicas.

## Validación de esta entrega

[Informe de la entrega original](review/validation.json) y [cobertura actual](review/status.json).

- **Local headless:** 88/88 suites, sin fallos de aserción ni errores de scripts;
  1.502 comprobaciones de contenido sin errores. Las pruebas de arte verifican
  poses originales/tiempos de reproducción por separado. La cuenta de poses
  originales usa el PNG, evitando que la compresión con pérdida se confunda con
  dibujos distintos. Se probaron reglas, interfaz y persistencia existentes.
- **Auditoría:** 140/140 trabajos producidos, 632 hashes de recursos y sus inputs
  verificados, cero fuentes transparentes inválidas y cero recursos antiguos.
- **Render nativo local aislado, 1280×720:** Inicio, campamento, refugio, Mercado,
  Taller, Laboratorio, Expediciones, colección, tres mapas y tres batallas;
  ambas parejas para cubrir los cuatro civiles. Primeros planos de héroes:
  124 comprobaciones sin fallos; las 56 apariencias enemigas: cero fallos.
  Se revisaron suelo, encuadre, transparencia, caras y legibilidad. Capturas
  desechables en `artifacts/`, fuera de la documentación y de la exportación.
- Se corrigieron nombres heredados, gramática del Laboratorio/Taller y
  descripciones de cartas que invadían los iconos inferiores. Marco, títulos,
  números y descripción reservan áreas separadas; coste centrado igual en los
  cuatro marcos; tipografía SourceSans3 MSDF.
- **Límites:** 35 suites dejan avisos de recursos al cerrar; se registran y no se
  presentan como una ejecución libre de avisos. El render aislado usa llvmpipe,
  audio Dummy y perfil privado: no certifica rendimiento de GPU ni escucha.
  No se exportó el juego ni se probó navegador/Web, APK o dispositivo físico.

Reiniciar la ejecución del editor permite cargar los catálogos y texturas nuevas
sin conservar en memoria recursos de una sesión anterior.
