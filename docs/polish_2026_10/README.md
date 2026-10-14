> **Limpieza del 14/10/2026:** se retiraron los PNG fuente sustituidos/rechazados
> de esta etapa y sus importadores antiguos. Los prompts y registros se conservan
> como historial; las fuentes y herramientas del arte vigente permanecen intactas.
> [Inventario y validación actuales](../cleanup/2026-10-14.md).

# Pulido visual y expansión táctica — 07/10/2026

Limpieza 08/10: se retiraron del runtime las 36 piezas de equipo superpuestas
y los tres dibujos antiguos de objetivos de jefe. El importador ya no los
regenera ni crea la hoja de contacto de pruebas. Sus hojas originales y el
manifest histórico se conservan como procedencia; los nueve iconos de reliquias,
las acciones dibujadas y los iconos actuales de efectos siguen activos.
[Inventario y validación](../cleanup/2026-10-08.md).

Actualización 08/10: elegir la reliquia exclusiva del guardián abre el mapa de
la siguiente mazmorra directamente, con recompensa y avance guardados juntos.
[Transición y validación actual](../forest/README.md#paso-directo-tras-la-reliquia-del-guardián--08102026).

Esta entrega aplica los 18 puntos propuestos. Las funciones están integradas en
el juego; las mediciones Web de esta carpeta corresponden al exportado anterior,
no a la nueva implementación. No se exportó ni publicó el proyecto.

## Cambios por recomendación

| Punto | Implementación y acceso |
| --- | --- |
| 1. Movimientos por carta | Tres acciones nuevas por héroe: estocada, barrido y golpe cargado, doce poses cada una. Área usa barrido; combos alternan acciones. Defensa, curación, veneno y preparación conservan acciones propias. |
| 2. Impactos | Recoil, pausas de golpes fuertes y cifras de impacto. Opciones independientes de pausa e intensidad; sacudidas desactivables. Escudo, vida y penetración tienen colores y sonidos distintos. |
| 3. Proyectiles | Flecha, poder o corte viaja desde el actor hasta su objetivo; la barra muestra cada impacto al llegar. Daño y guardado ya están confirmados. |
| 4. Equipo visible | Los niveles se consultan mediante iconos en el HUD y se reflejan con el shader del héroe. Corrección posterior del 07/10: se retiraron las piezas superpuestas sobre el actor porque duplicaban el equipo ya dibujado en cada pose. Los 36 assets generados se conservan como procedencia de la entrega original. |
| 5. Objetivos de guardianes | Cripta: romper fuente evita una resurrección. Bosque: liberar al compañero atrapado. Fortaleza: dos placas reducen daño; romperlas cancela el golpe cargado. Acción de objetivo cuesta 1 energía. |
| 6. Balance y observación | Métricas locales por carta, ofrecidas/elegidas, descarte sin usar, turnos, duración y PV finales; consultables en Colección → Últimos retornos → Ver. Eficiencia de ataques gratuitos nuevos mejora valor en vez de multiplicar golpes. Bot con decisiones legales y 90 aventuras; falta balance con jugadores humanos. |
| 7. Reliquias exclusivas | Nueve reliquias, tres por guardián. Después de elegir/rechazar la carta aparece una elección obligatoria de una reliquia. No aparecen en premios de élite, pactos ni cofres. La colección conserva las reliquias descubiertas, incluida la del último guardián; sus efectos son de la aventura actual. |
| 8. Cartas de riesgo | Seis cartas comprables, una por clase: sacrifican PV, bloqueo o una carta para ganar poder/energía. Costes extra se validan antes de consumir energía/cartas; el coste de PV nunca mata. |
| 9. Pactos y maldiciones | Una oferta explícita por piso: reliquia a cambio de deuda de sangre, carga sombría o cicatriz. Se puede rechazar. Limpiar consume un descanso o cuesta 35 almas ante el mercader. |
| 10. Desvíos de riesgo | Un combate opcional por piso: +20% PV, +2 daño; premio de poción y 20 almas. Cada acceso tiene camino alternativo. Al tocarlo se anuncia riesgo/premio antes de confirmar; funciona sin hover. |
| 11. Encuentros de parejas | Quince historias, una por pareja; preparación conjunta da bloqueo siguiente combate y potencia siguiente enlace, o descanso devuelve PV. Se reutilizan fondos y atmósfera existentes. |
| 12. Cooperación enemiga | Apoyo potencia bestias +3 daño durante la ronda; protector cubre arqueros; apoyo/protector cambia a ataque agresivo tras perder compañero. La cifra anticipada y el daño real usan la misma regla; matar al apoyo elimina el beneficio inmediatamente. |
| 13. Proyectos del campamento | Acceso desde campamento. Reservas: 350 almas, próxima carta -20. Red de suministros: 450, renovación del mercader por 25 una vez/piso. Exploración: 400, reconocimiento de salas disponibles por 20. |
| 14. Comparación de mazo | Refugio muestra guardado y borrador: ataques, defensas, curaciones y coste medio. Mantiene 10 cartas y aplica cambios a aventuras nuevas. |
| 15. Entrenamiento | Maniquí o hasta tres enemigos descubiertos, patrones reales o intención personalizada: daño, bloqueo, contraataque y ambos objetivos. Sandbox separado sin premio, guardado ni cambios del perfil/aventura real. |
| 16. Teclado y mando | Selección, objetivo, jugar, terminar turno, enlaces y acción del guardián reutilizan las mismas validaciones de tocar/arrastrar. Tutorial actualizado. |
| 17. Sonido | Grupos de sonido por material/acción reutilizan muestras CC0 existentes; nueva música de fase II del guardián. No hay sonido al pasar mouse. |
| 18. Rendimiento | Caché de actores limitada a la pareja; atlas compartidos por acción, regiones fijas y compresión 0,9 sin bajar resolución. Auditoría de imports, medición nativa y herramienta Web sobre exportaciones existentes. No se fusionan atlas gigantes sin evidencia. |

## Estética compartida

Botones y paneles tienen bordes finos de metal oscuro, detalles pequeños de oro
apagado e interiores despejados. Hover, pulsación, foco y deshabilitado se distinguen.
El cierre de canales de audio detiene y libera explícitamente sus streams antes de retirarlos.
Menús desplegables, barras de desplazamiento y sliders comparten el tema. Se
conserva el botón circular de terminar turno y los marcos de clase de las cartas.

Source Sans 3 con peso 550 para lectura y Cinzel 600 para títulos. Los ejes
OpenType usan el identificador numérico `wght` (2003265652) aceptado por Godot;
el nombre de cadena no aplicaba el peso. Las cartas mantienen su fuente MSDF
para texto rotado. Se ajustan descripciones largas y espacios del refugio,
selección e iglesia; el bestiario muestra números enteros en sus patrones.

## Controles

| Acción | Teclado | Mando |
| --- | --- | --- |
| Elegir carta | 1–9, izquierda/derecha | LB/RB |
| Cambiar objetivo | arriba/abajo o Tab | cruceta |
| Jugar | Enter | A |
| Terminar turno | Espacio | Y |
| Acción del guardián | O | X |
| Elegir enlace | L | pulsar stick izquierdo |
| Mazo / bolsa | J / B | botones superiores con foco |
| Menú / volver | Escape | Start / B |

## Datos, guardados y arquitectura

- 132 cartas, 22 por héroe, 78 comprables. Mazo inicial permanece en 20 instancias.
- 33 reliquias de aventura: las 24 anteriores y nueve exclusivas de guardianes.
- 28 encuentros definidos: diez anteriores, tres pactos y quince de pareja.
- Aventuras nuevas reciben `polish_version=1`; partidas antiguas mantienen sus
  objetivos/orden de recompensas original. `upgrade_rules=2` solo marca nuevas
  mejoras de descanso. Las mejoras ya guardadas conservan sus reglas anteriores.
- Costes extra, objetivos, maldiciones, proyectos y telemetría viven en `rules/`;
  efectos visuales no calculan daño ni escriben guardados. Game confirma acciones
  antes de animar; rechazos no cobran ni cambian la partida.
- `room_actions.gd` extrae reglas de tesoro/descanso/eventos/transición; fachada
  conserva API y checkpoint. `room_navigation.gd` extrae su composición visual.
- `main.gd` queda alrededor de 600 líneas, `game.gd` alrededor de 440. Siguen
  requiriendo extracción gradual; no se oculta ese acoplamiento con archivos mínimos.

## Arte y procedencia

33 generaciones integradas con la herramienta incorporada imagegen:
18 hojas de ataque (216 poses dibujadas), seis hojas de equipo, tres hojas de
reliquias/objetivos y seis ilustraciones únicas de riesgo. Importación produce
72 PNG finales: 18 atlas de ataque de 1536×1152 (celda 384, pies y=368),
36 piezas de equipo, nueve reliquias, tres objetivos y seis cartas de 448×288.
No se interpolan poses ni se duplican cuadros para inventar animaciones.

- [Solicitudes y referencias](jobs.json), [prompts individuales](prompts/),
  [procedencia y hashes](sources.json), [recortes finales](assets.json).
- `scripts/import_polish_assets.gd` recorta y normaliza con Godot; herramientas
  mecánicas en `sprite_sheet_tools.gd`. Fuentes intactas en `sources/`.
- Marcos: SVG nativos en `assets/ui/polished/`; geometría editable, sin ImageGen.
- Fuentes: [Source Sans 3](https://github.com/google/fonts/tree/main/ofl/sourcesans3),
  [Cinzel](https://github.com/google/fonts/tree/main/ofl/cinzel); OFL en `assets/fonts/`.
- Música: [Boss Battle Music](https://opengameart.org/content/boss-battle-music),
  Juhani Junkala/SubspaceAudio, CC0. Evidencia y hashes en
  [audio/sources.json](../audio/sources.json), licencia descargada en audio/licenses/.

`docs/`, `tests/`, `artifacts/` y `scripts/` siguen excluidos de los exportados;
las fuentes grandes de regeneración no se incluyen en el juego.

## Pruebas y límites

Resultados finales en [validation.json](validation.json), comandos y reportes
reproducibles debajo. Las comprobaciones headless no equivalen a revisión visual.
La revisión gráfica usa Godot local con Mesa/llvmpipe a 1280×720; no certifica
Android físico ni GPU móvil. Las simulaciones son decisiones automáticas, no
partidas humanas, y sus porcentajes no deben convertirse en ajustes globales sin
observar partidas reales. La telemetría no envía datos a servidores.

Regresión completa: 73 suites aprobadas, sin errores de script ni aserciones
fallidas. Reglas nuevas: 51 comprobaciones; movimiento: 528; interfaz nueva:
13 con 36 vistas y sin etiquetas que desborden su altura; colección: 43.
Las advertencias de objetos/recursos al cierre de algunas suites anteriores se
registran por separado; no se confunden con una prueba de pérdida de memoria
durante una partida. El recorrido gráfico nuevo y colección cierran sin ellas.

El bot obtuvo 31/45 victorias sin equipo y 39/45 con equipo nivel 1 usando las
mismas tres semillas por pareja, amuleto vital, premios, consumibles y mejoras
legales. Maga/explorador es la pareja más débil en esa política automática;
requiere partidas humanas antes de ajustar números generales.

Medición nativa de 3 segundos en un combate con tres enemigos a 1280×720:
p50 15,94 ms, p95 18,89 ms y p99 21,23 ms. Mesa/llvmpipe renderiza por software;
no son cifras de GPU móvil. Al final del recorrido de pantallas, Godot informa
60,73 MiB de memoria estática y 263,85 MiB de texturas, no memoria total del proceso.
PNG importados: 170,32 MiB; esa suma tampoco es el tamaño de un exportado.

El exportado Web existente del 05/10 cargó en 3,57 segundos por HTTP local,
sin errores JavaScript en Chromium/SwiftShader. Campamento, menú de aventura y
selección se comprobaron con capturas. Estos tiempos son del exportado anterior:
la entrega nueva sigue pendiente de exportación manual y revisión en navegador.

```bash
python3 scripts/run_regressions.py
DISPLAY=:0 ./scripts/run.sh --script tests/test_polish_ui.gd
DISPLAY=:0 ./scripts/run.sh --script tests/test_polish_motion.gd
./scripts/run.sh --headless --script tests/test_balance_polish.gd
python3 scripts/optimize_texture_imports.py --report
```

Web, **solo después de exportar manualmente** y servir por HTTP:

```bash
python3 -m http.server 8766 --directory TestWeb
NODE_PATH=/var/www/html/ImageGen/node_modules node tests/test_web_performance.cjs
```

`NODE_PATH` apunta a la instalación local disponible de Playwright; en otro equipo
se instala Playwright aparte. `WEB_PERF_URL`, `WEB_PERF_OUTPUT` y `WEB_PERF_BUILD`
permiten especificar servidor, reporte y fecha/revisión del exportado. La herramienta
no crea ni modifica exportaciones. Reporta carga, p50/p95/p99 de frames, recursos,
memoria JS si el navegador la expone y errores. Memoria JS no es VRAM ni RAM total.

## Corrección posterior: equipo duplicado sobre héroes — 07/10/2026

Las piezas modulares se dibujaban sobre el arma/armadura ya presentes en la pose,
con posiciones fijas que no coincidían con todas las siluetas. Se elimina su
instanciación en `detailed_hero.gd` y se retira `equipment_layers.gd`, sin otros
consumidores de ejecución. Arma, escudo y vestimenta quedan como están dibujados
en las animaciones. El shader de nivel, los iconos del menú superior, las mejoras
aplicadas al daño/bloqueo y los guardados se conservan.

Pruebas actuales: `test_detailed_heroes.gd`, 1662 comprobaciones headless;
`test_equipment_ui.gd`, 48 headless; `test_polish_motion.gd`, 534 con ventana local
Linux/Mesa/llvmpipe, seis héroes equipados en reposo, defensa y tres ataques.
Cinco capturas en `artifacts/polish/motion-*.png`; reposo y defensa revisados.
Sin fallos de script/aserciones. La suite UI conserva avisos de recursos al cerrar;
la ventana gráfica solo informa la limitación de V-Sync. Sin exportación ni prueba
nueva en navegador, emulador o dispositivo. Los resultados anteriores son históricos.

## Cifras de impacto más visibles — 07/10/2026

- `src/presentation/impact_feedback.gd`: números de 40 px (antes 17), contorno
  oscuro de 6 px y sombra; centrados sobre el objetivo y contenidos horizontalmente.
- El número permanece opaco 0,3 s y se desvanece durante 0,5 s mientras asciende.
  Bloqueo y penetración conservan colores propios y una leyenda secundaria pequeña.
  Presentación únicamente: sin cambios al daño calculado ni al guardado.
- Verificación actual: ventana local Godot 4.7.2/Mesa/llvmpipe, tres tipos de
  impacto simultáneos, tamaño/contorno/opacidad, límites horizontales, estado
  intacto y eliminación al terminar. Captura revisada:
  `artifacts/damage-feedback/visible-numbers.png`.
- Regresión headless `tests/test_energy_timing.gd`: 5 comprobaciones, 0 fallos;
  conserva avisos de recursos/instancias al cerrar. La ventana local solo informa
  que el controlador no admite cambiar VSync. Sin exportación ni validación Web,
  emulador o dispositivo físico.

## Aproximación para ataques cuerpo a cuerpo — 08/10/2026

- `presentation/melee_motion.gd` clasifica golpes con daño de guerrero, guardiana
  y pícaro como cercanos. Brote de peste permanece a distancia, al igual que arco
  y poderes de maga/clériga. El campo opcional de presentación `attack_delivery`
  permite precisar futuras cartas; curación, bloqueo y veneno sin daño no avanzan.
- `card_impacts.gd` mueve únicamente el actor junto al objetivo durante el golpe:
  entrada de 0,10 s, ataque existente y regreso de 0,12 s después de terminar la
  pose. Conserva escala, línea de pies, padre, índice y orden visual originales.
  Vida, estados y zonas táctiles permanecen en su sitio; no queda copia del héroe.
- HD se reproduce simultáneamente abajo a la izquierda, con su encuadre previo.
  En combos cada impacto conserva su pose/viñeta distinta; los ataques de área
  visitan sus objetivos. No se dibuja el antiguo proyectil de corte en golpes
  cercanos. Disparos/poderes conservan su reproducción a distancia.
- Daño, contraataques, energía y guardado continúan confirmados antes de la
  presentación. La aproximación no toca RNG ni calcula/aplica golpes.
  Respeta velocidad 1×/2× y la opción existente de reducir viñetas.
- Se reutilizan sprites, partículas y atlas HD existentes; no se generaron assets.

Validación actual: `test_melee_motion.gd`, ocho escenarios y 564 comprobaciones
nativas sin fallos en Godot 4.7.2/Linux/Mesa/llvmpipe. Espada, escudo, daga, combos
con dos/tres movimientos, área sobre tres enemigos, contraataque, 1×/2×, viñetas
reducidas, disparo/conjuro, pies/tamaño/HUD, regreso y estado confirmado intacto.
Capturas de `artifacts/melee/` revisadas (HD simultáneo y acercamiento sin HD).

Regresiones headless actuales sin fallos: contraataques, secuencia de turno 171,
cartas de soporte 1.922 y energía inmediata 5. Esta última conserva avisos de ocho
instancias/dos recursos al cerrar; la ventana nativa informa solamente que no puede
cambiar VSync. Sin exportación ni validación Web/emulador/dispositivo físico.

## Revisión posterior de posiciones — 08/10/2026

Mazo y mejora tienen cartas más verticales; las acciones quedan fuera de las
listas desplazables. Se reorganizaron vínculos, mercader y resumen final y se
separaron los avisos de edificios de las tarjetas de compra/mejora.
[Alcance, casos de texto grande y pruebas actuales](../ui_layout/README.md).
