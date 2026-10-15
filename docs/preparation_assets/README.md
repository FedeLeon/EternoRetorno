# Assets de preparación y comienzo directo — 14/10/2026

## Celdas y componentes HD

`assets/ui/cell.png` representa la moneda como un cartucho recargable de metal,
terminales de latón, núcleo cian y cable violeta. El contador mantiene el mismo
saldo, números, tamaño y nombre interno; cambia su ilustración.

Los ocho componentes iniciales pasan del atlas de 64 px ampliado a ocho PNG
individuales de **512×512**, con transparencia, contorno de tinta y detalles de
metal reparado. No se amplían los antiguos 64 px para simular alta resolución.

| ID compatible | Ilustración |
| --- | --- |
| vital_amulet | Monitor vital, pantalla de pulso y protección médica |
| vigor_ring | Condensador de arranque, bobina y conductores |
| phoenix_idol | Relé de emergencia, fusible y alarma |
| poison_fang | Boquilla corrosiva con depósito y tubería |
| arcane_orb | Bobina amplificadora con núcleo electromagnético |
| wind_boots | Botas civiles reforzadas |
| pilgrim_shield | Placa de protección remachada |
| merchant_coin | Ficha metálica de intercambio |

Rutas: `assets/equipment/components/<id>.png`. `data/equipment.json` conserva
IDs, iconos numéricos, efectos y valores; añade `asset`. `RelicArt.texture`
resuelve el recurso individual también en HUD y mapa, con fallback del atlas
para otros objetos/guardados. Equipamiento presenta el PNG directamente con
filtro lineal; no toca la selección única, descripción o efectos compartidos.

## Inicio y opciones

- `assets/ui/play.svg`: símbolo nativo de play, usado en los dos botones de
  Iniciar aventura (componentes y confirmación de configuración). La puerta
  anterior deja de aparecer en esos botones.
- Dificultad: cuatro ilustraciones propias en `assets/run_setup/difficulty/`
  (`normal`, `return_1`, `return_2`, `return_3`), de seguridad a amenaza del reactor.
- Condición: tres en `assets/run_setup/conditions/` (`normal`, `tainted`,
  `dangerous`): brújula intacta, protección interferida y herramientas/alarma.
- «Profanada» se muestra como «Interferida», conservando el ID `tainted` y sus
  mismos efectos. No se cambia balance, desbloqueo, descripción mecánica ni premio.
- Todos los nuevos PNG tienen 512 px, transparencia y encuadre proporcional;
  filtro lineal y compresión 0,9 limitada a 512 px. Los dibujos mantienen el
  cómic postapocalíptico actual.

## Primera batalla y guardado

La entrada real de la interfaz `begin_on_floor()` crea la aventura y entra en
la sala 0 mediante **Game.enter_node(0)** antes de las cinemáticas de personajes.
Se genera y guarda el combate con vida, energía, mano, equipo e intenciones reales.
Al finalizar/omitir las cinemáticas se muestra directamente la batalla, sin mapa.
Reanudar esa partida tampoco regresa al mapa inicial ni vuelve a robar/entrar.

`Game.new_run()` conserva su API/estado inicial para herramientas, fixtures y
partidas anteriores; no se fuerza a entrar cuando solo se crea un modelo de run.
El selector temporal permite probar cualquiera de los tres pisos. La selección
se cancela sin abandonar la aventura anterior; las recompensas y Caminos de
pisos posteriores conservan sus flujos. No se añaden fases o flags de guardado.

## Procedencia y reproducción

Cinco generaciones con herramienta integrada **`image_gen.imagegen`**: celda,
dos bancos de cuatro componentes, banco de cuatro dificultades y banco de tres
condiciones. `jobs.json` y los cinco registros individuales conservan prompts,
referencia y ruta original de herramienta; `sources/` conserva originales RGBA.
Las imágenes generadas se inspeccionaron antes de integrarse.

`scripts/import_preparation_assets.gd` recorta las cuadrículas, ajusta cada dibujo
proporcionalmente a 512 px y registra hashes/fuentes. Actualiza también el catálogo
narrativo preparado para conservar su reproducibilidad. No dibuja objetos por
código ni altera valores mecánicos. Play es SVG nativo; fuente `play.svg`.

17 recursos nuevos (16 PNG y un SVG), 660 recursos visuales activos con hashes
verificados. Se conserva el atlas original, necesario para consumibles y otros
iconos; no se elimina al reemplazar solo sus ocho componentes iniciales.

## Archivos y validación actuales

- `equipment_screen.gd`: imágenes individuales y play.
- `soul_counter.gd`: nuevo cartucho de celdas y filtro lineal.
- `run_setup_screen.gd`: ilustraciones propias y play; selección de condiciones.
- `main.gd`: entrada transaccional de la primera batalla, antes de presentación.
- Política de importación y auditoría de referencias actualizadas.

[Resultados](validation.json). **89/89 suites headless**; render nativo aislado:
componentes/inicio **60/0**, configuración **30/0**. Las pruebas verifican resolución
real, ocho recursos directos, play, bloqueo de dificultades, selección exclusiva,
entrada ya visitada y reanudación del combate guardado sin doble entrada.
Auditoría de contenido y de arte sin errores; 660 hashes correctos.

Revisión visual de preparación, menú de configuración y contador del campamento
local a 1280×720, llvmpipe, audio Dummy, perfil privado. Capturas en `artifacts/objects/`,
`artifacts/run-setup/` y `artifacts/postapocalyptic/`, ignoradas por Git/exportación.
Avisos de recursos al cerrar algunas suites registrados. No se exportó ni se
certificó navegador/Web, rendimiento de GPU, escucha o dispositivo físico.
