# Historial de desarrollo

Registro consolidado el **15/09/2026** a partir de los cambios de esta sesión y
la documentación del repositorio. El orden refleja las etapas de trabajo;
no se atribuyen horas ni fechas de compilación que no estén verificadas.

## Prototipo inicial

- Godot, un piso de 12 salas en espiral, seis clases y selección de dos héroes.
- Mazo compartido, turnos, enemigos con intención, recompensas, eventos y descanso.
- Caída individual, recuperación al ganar, derrota conjunta y desbloqueos.
- Guardado atómico de perfil y aventura; semilla y estado aleatorio persistidos.
- El informe original registra exportación e instalación en emulador Android;
  no hubo prueba en teléfono físico. [Informe histórico](VALIDACION.md#informe-histórico-del-prototipo-inicial).

## Personajes y animaciones

- Integración progresiva de guerrero, guardiana, pícaro, maga, clériga y explorador
  a partir de los conceptos aportados por el usuario.
- Sprites de 64 × 64, animaciones de reposo, acciones, daño, caída y recuperación.
- Corrección del salto vertical al final del reposo del guerrero mediante alineación
  de la silueta de los pies, documentada en su importador y pruebas.
- Las acciones se resuelven y guardan antes de presentar las animaciones.

## Selección y campamento previo

- Fondo nocturno, personajes de frente alrededor de fogata animada, brillo y chispas.
- Campamento base con arco para preparar la aventura, cuatro solares y refugio.
- Solares y refugio informan sobre funciones futuras; todavía no conceden ventajas.
- Visitar el campamento o cancelar preparación conserva la aventura activa.

## Equipamiento y consumibles

- Decisión del usuario: ocho reliquias disponibles; una distinta por héroe.
- Decisión del usuario: implementar también los ocho consumibles desde esta etapa.
- Preparación guardada, efectos pasivos durante la aventura y bolsa compartida.
- Valor de prototipo: una unidad inicial de cada consumible por aventura nueva.
- Compatibilidad con aventuras anteriores sin otorgar equipamiento retroactivo.
- [Efectos y comprobaciones de esta etapa](objects/README.md).

## Diseño de cartas

- Marcos por clase: rojo, turquesa, verde, violeta, dorado y azul.
- El pistolero del concepto se adaptó al pícaro; se agregó el marco de guardiana.
- Coste, nombre y descripción dibujados desde los datos reales del juego.
- Inicialmente se usaron poses de héroes como ilustración. La última revisión
  las reemplaza por espacios vacíos con márgenes para imágenes futuras.

## Pantalla inicial

- Asset del usuario como splash de arranque y fondo del menú.
- Botones generados de iniciar/continuar y opciones; acceso al campamento y colección.
- Volumen y pantalla completa para escritorio guardados en el perfil.
- 31 comprobaciones locales en esta etapa, revisión visual; sin nueva APK.

## Biblioteca de enemigos

- 56 sprites transparentes desde siete plantillas. Seis se usan en la primera cripta:
  murciélago, lancero, chamán de ceniza, baba ácida, guardián élite y autómata jefe.
- Otros 50 reservados para futuros pisos. Variantes similares se conservan separadas.
- Animaciones procedurales del sprite completo: reposo, flotación, ataque, daño y caída.
- Se mantienen IDs de encuentros, estadísticas y compatibilidad del guardado.
- Ajustes de recorte de armas y línea de suelo; pruebas de héroes adaptadas a la
  secuencia ataque enemigo → reacción del héroe.
- 1.132 comprobaciones locales en esa etapa, más revisión visual; sin nueva APK.

## Última revisión del combate

- Fondo de mazmorra derivado del concepto; héroes y enemigos sobre el suelo.
- Eliminados recuadros de personajes, «VS», marca del juego y texto de instrucciones.
- Barra superior con sala, mazo, bolsa con icono, menú y turno a la derecha.
- Energía abajo a la izquierda. Seis cartas por turno, sustituyendo las cinco iniciales.
- Mano parcialmente visible; tocar eleva y amplía una carta. Costes sin solaparse;
  desplazamiento para manos mayores y posición de desplazamiento conservada al seleccionar.
- Espacio vacío para imagen y bloque de descripción con márgenes.
- 584 comprobaciones locales: lógica 137, interfaz 121, cartas 243, equipamiento 64,
  interfaz de equipamiento 11 y distribución 8. Las 45 simulaciones terminaron en
  victoria; esto no sustituye pruebas de dificultad con jugadores.
- Revisión de capturas de combate y carta elevada. Sin APK ni nueva prueba Android.
- [Detalle y capturas](dungeon/README.md).

## Organización de documentación

- Índice general, estado actual, pendientes e historial consolidados.
- README principal actualizado y validación Android marcada como histórica.
- Pauta de mantenimiento en `AGENTS.md`: documentar cambios y pruebas, mantener
  decisiones y no exportar APK salvo pedido explícito.
- Cambio documental; revisión de enlaces locales, sin ejecutar juego ni compilar.

## Arquitectura y mantenimiento del código

- Documentadas responsabilidades actuales, dependencias y estructura objetivo
  en [ARQUITECTURA.md](ARQUITECTURA.md).
- Identificados `main.gd` (887 líneas) y `game.gd` (493) como archivos a dividir
  progresivamente; pautas para pantallas, componentes, presentación y reglas.
- Registrados contratos de guardado, IDs/UIDs, fuentes de datos y organización
  de assets, además del orden propuesto de extracción y sus comprobaciones.
- Pautas añadidas a `AGENTS.md` para aplicarlas en trabajos posteriores.
- Esta entrega documenta la arquitectura; no mueve archivos de juego ni ejecuta
  la refactorización propuesta. Validación de enlaces y formato, sin APK.

## 16/09/2026 — Reliquias en barra, orbe y cifras reutilizables

- Eliminado nombre de sala; reliquias personales a la izquierda de la barra,
  sin recuadro. Sus descripciones identifican al héroe portador.
- Bolsa como asset interactivo sin texto ni marco, conservando navegación.
- Orbe celeste con energía disponible y dígitos 0–9 transparentes reutilizables.
  Integrados también en turnos y costes de cartas, con soporte de varias cifras.
- Extraídos `combat_hud.gd` y `number_view.gd` a componentes de interfaz que no
  dependen de reglas ni persistencia. Actualizado el mapa de arquitectura.
- Assets, prompts y pruebas descritos en [HUD](hud/README.md).
- Revisión visual en Linux y 452 comprobaciones locales de HUD, distribución,
  cartas, interfaz y bolsa sin fallos. Sin APK ni prueba Android.

## 16/09/2026 — Héroes y enemigos más grandes en batalla

- Duplicado el tamaño visual de todos los actores durante combate, con pivote
  inferior para conservar la altura de los pies y el escenario sin cambios.
- Ampliadas las zonas de selección hacia arriba y elevadas las intenciones;
  barras de vida y nombres mantienen su ubicación.
- Tamaños de otras pantallas y reglas de juego conservados.
- Pruebas locales de distribución y animaciones; revisión visual del combate.
  Sin exportar APK ni probar Android. [Detalle](dungeon/README.md).


## 16/09/2026 — Una reliquia previa y bloqueo con escudo

- La pareja elige una sola reliquia y un portador. Cambiar la elección sustituye
  la anterior; se puede transferir al compañero. Ocho opciones y efectos intactos.
- Regla validada en `game.gd`; las aventuras guardadas mantienen su equipamiento.
  Preparaciones antiguas con dos asignaciones requieren una nueva elección.
- Extraída la pantalla a `src/ui/screens/equipment_screen.gd`.
- Nuevo `block_indicator.gd`: escudo reutilizado del atlas de objetos y número
  gráfico junto a él, bajo la vida de héroes vivos y enemigos.
- Actualizados README, arquitectura, objetos y HUD. Futuras reliquias de alcance
  grupal consumirán la misma elección; no se agregaron efectos nuevos.
- Pruebas locales: equipamiento 70, interfaz 11, HUD 76 y distribución 8,
  **165 sin fallos**. Interfaz de equipamiento y HUD renderizados en escritorio;
  capturas revisadas. Sin APK, emulador ni dispositivo físico.

## 16/09/2026 — Energía animada, actores reducidos y descripción de reliquia

- Movimiento suave tipo fuego celeste dentro de la esfera con un shader propio;
  se reutiliza el asset y se mantienen quietos el marco y los dígitos.
- Héroes y enemigos al 50 % del tamaño anterior, conservando la línea del suelo.
- Modal de reliquia reemplazado por cuadro pequeño bajo el icono, sin botones.
  Cierra al pulsar fuera, repetir el icono o usar Atrás.
- Componente nuevo `relic_popover.gd`; HUD gestiona su ciclo visual.
- Verificaciones: HUD headless 85 y distribución 8 sin fallos; HUD de escritorio
  86 sin fallos, incluyendo cambio entre fotogramas del orbe. Capturas revisadas.
- Documentación de HUD, mazmorra y arquitectura actualizada. Sin APK ni Android.

## 16/09/2026 — Selección directa de reliquia para ambos héroes

- Retirados los botones de portador. Una única elección beneficia a ambos.
- Efectos y descripciones compartidos; energía del Anillo sin duplicarse,
  Fénix independiente por héroe y Orbe para ataques de cualquier clase.
- Guardado `team_relic`, compatibilidad con aventuras personales anteriores,
  preparación y único icono del HUD actualizados.
- Archivos: game.gd, main.gd, equipment_screen.gd, equipment.json y pruebas.
- Validación: equipamiento 90, interfaz 11, HUD 85 sin fallos. Selección renderizada
  y revisada en escritorio. Documentación actualizada; sin APK ni Android.

## 16/09/2026 — Tamaño y separación del indicador de bloqueo

- Escudo de bloqueo más grande: se omite el margen transparente del atlas y
  se muestra en 32×32 manteniendo proporciones.
- Número más cerca del escudo, con ancho ajustado a los dígitos, para ambos bandos.
- Archivo: `src/ui/components/block_indicator.gd`; documentación del HUD actualizada.
- HUD de escritorio: 86 comprobaciones sin fallos y captura revisada visualmente.
  Sin cambios en reglas, sin exportar APK ni probar en Android.

## 16/09/2026 — Actores +25 % e indicadores de estados activos

- Escala de combate de 1 a 1,25 para héroes y enemigos, con pivote en el suelo.
- Escudo y número solo con bloqueo positivo. Veneno reemplaza el texto por una
  calavera verde propia y número, solo con acumulaciones positivas.
- Nuevo componente `status_effects.gd` para ambos bandos; campos ausentes se
  interpretan como cero y actores caídos no muestran estados.
- Asset vectorial `assets/ui/poison.svg`; sin cambios de reglas ni guardado.
  Veneno aliado probado mediante estado de prueba, no una nueva mecánica.
- Importación correcta; HUD renderizado 91 y distribución headless 8 sin fallos.
  Captura de combate revisada. Documentados arquitectura, HUD y mazmorra.
  Sin APK ni pruebas en emulador/dispositivo Android.

## 16/09/2026 — Destello rojo aliado y vida descendente

- Héroes de todas las clases reciben destello rojo con su reacción de daño,
  restaurando el color. Enemigos mantienen rojo al impacto, también al morir.
- Contadores y barras bajan un punto por paso hasta la vida confirmada; la
  transición de pantalla espera la finalización, incluida muerte/derrota.
- Extraído `src/ui/components/health_bar.gd`; coordinación en `main.gd`.
  Daño y guardado siguen ocurriendo antes de la animación.
- Pruebas: guerrero renderizado 62 y distribución headless 8 sin fallos.
  Secuencias de enteros en ambos bandos, color, guardado, acciones duplicadas,
  muerte, recuperación y derrota. Captura de daño revisada en escritorio.
- Documentados HUD y arquitectura. Sin APK ni pruebas en Android.

## 16/09/2026 — Icono de mazo y ampliación de iconos superiores

- Botón de texto «Ver mazo» sustituido por tres cartas superpuestas; asset
  vectorial propio `assets/ui/deck.svg`, tooltip y navegación conservados.
- Reliquias y bolsa un 25 % más grandes (gráfico 48→60 px) en la misma barra.
- Actualizados `combat_hud.gd`, prueba HUD y documentación del sistema.
- Importación y HUD de escritorio: 93 comprobaciones sin fallos; captura revisada.
  Sin exportar APK ni probar en Android.


## 16/09/2026 — Actores con mayor detalle y movimientos de la cripta

- Seis héroes (210 cuadros) y vistas frontales a 128×128, desde fuentes originales.
  Compensada la escala para conservar tamaño y suelo; diseños y acciones intactos.
- Los 56 enemigos, incluidos los 50 reservados, reimportados a 128×128.
- Seis ciclos nuevos con imagegen, ocho poses por enemigo activo: aleteo,
  ondulación, pasos mecánicos/esqueléticos, capa y llama; fuentes y prompts guardados.
- Ataques procedurales diferenciados: picado, salto, estocada, conjuro y golpes.
- Nuevo importador de ciclos y vista previa independiente; galería PNG y vídeo
  en `docs/quality/`. Documentados organización, procedencia y reproducción.
- Última batería headless: seis héroes 410 + enemigos 498 + selección 47 =
  **955 comprobaciones sin fallos**. Importación y diff-check correctos.
  Galería/combate renderizados en escritorio; vista conjunta revisada.
- No se exportó APK ni se probó rendimiento en Android.

## 16/09/2026 — Dos escenarios y cofres interactivos

- Incorporadas cripta con vitrales y acueducto subterráneo para combates, alternados por semilla/sala sin consumir RNG de reglas. Capturas y prompts en `docs/treasure/`.
- Nuevas aventuras con bolsa vacía; los cofres entregan un consumible. Inventarios antiguos conservados.
- Cofre en primer plano con seis poses, modal de premio y 15 % de trampa. Decisión inicial: 4 PV por héroe vivo, mínimo 1 PV; también concede el objeto.
- Extracción terminada: reglas en `src/rules/treasure.gd`, pantalla en `src/ui/screens/treasure_screen.gd`, selector visual en `src/ui/components/battle_background.gd`. `main.gd` coordina señales; `game.gd` resuelve y guarda antes de animar. Arquitectura e índice actualizados.
- Resultado y daño persistidos antes de la animación; reanudación muestra premio pendiente sin repetirlo. Reliquias pendientes de tesoros antiguos respetadas.
- Pruebas locales: tesoros 22, juego 137 (45/45 simulaciones de las 15 parejas), equipamiento 90, interfaz de equipamiento 12, HUD 92, interfaz de tesoros renderizada 8; sin fallos. `git diff --check` correcto. Apertura y Continuar accionados por entrada de ratón; capturas de cofre/trampa y ambos fondos revisadas en escritorio.
- Sin APK, emulador ni dispositivo físico. Pendiente balance humano de disponibilidad de objetos y daño.

## 16/09/2026 — Limpieza de recursos y salidas de pruebas

- Retirados 243 archivos, 61 023 157 bytes (~58,2 MiB): atlas de actores de 64 px reemplazados, sus metadatos, capturas/vídeos/logs acumulados, dos fuentes descartadas y herramientas obsoletas de capturas/ADB. Inventario completo en `docs/LIMPIEZA.md`.
- Conservados 28 originales gráficos necesarios para importadores, prompts, 56 enemigos actuales (incluidos futuros pisos), pruebas funcionales y metadatos de recursos activos.
- Eliminadas siluetas provisionales de actores de `src/pixel_art.gd` y fallback antiguo de `main.gd`. Se conserva el fondo procedural utilizado por otras pantallas y su UID. Sin cambios de reglas, IDs ni guardados.
- Capturas de tests y preview redirigidas a `artifacts/`, ignorada por Git/Godot y excluida de exportación. Helper `tests/artifacts.gd`; los PNG de esta comprobación se borraron después de revisarlos.
- Validación actual: 19 suites headless, 1717 comprobaciones sin fallos; juego simulado 45/45 victorias. Además, enemigos (498) y tesoros UI (8) ejecutados renderizados en Linux/llvmpipe; galería y combate revisados. No se suman estas repeticiones al total headless. Importación, referencias literales de recursos y `git diff --check` correctos.
- Sin APK ni pruebas Android. El recorrido ADB antiguo no corresponde al flujo actual y se retiró: deberá reemplazarse al volver a probar en Android.

## 16/09/2026 — Acceso principal al campamento en el inicio

- Campamento pasa del lateral al centro, debajo de Continuar aventura y encima
  de Opciones, con el asset y dimensiones de botón principal.
- Cambio localizado en `src/main.gd::home()`; navegación y partida conservadas.
- `tests/test_title.gd`: 13 comprobaciones renderizadas sin fallos; revisado
  visualmente a 1280×720. `git diff --check` correcto. Capturas temporales borradas.
- Sin compilación APK ni validación Android.

## 16/09/2026 — Mapa ilustrado e información del grupo

- Nuevo fondo e iconos de combate, encuentro, tesoro, élite, descanso y jefe,
  generados con imagegen. Prompts en `docs/map/prompts.md`; assets en `assets/map/`.
- Héroes más grandes junto a PV; reliquia inicial y halladas visibles; compatibilidad
  con equipo personal antiguo. Icono de tres cartas para abrir mazo.
- Retirados título Eterno Retorno y subtítulo del piso en esta pantalla.
- Pantalla extraída a `src/ui/screens/map_screen.gd`; datos de reliquias compartidos
  entre mapa y combate. Sin cambios de grafo, reglas ni guardado.
- Pruebas actuales: mapa 21 renderizadas y HUD 92 headless, sin fallos. Mapa revisado
  visualmente en Linux a 1280×720. Capturas temporales eliminadas; diff correcto.
- Sin APK ni pruebas Android.

## 16/09/2026 — Intenciones gráficas, tipos de carta y salida de combate

- Intenciones con espada/daño, escudo/bloqueo y retratos de los objetivos; ambos
  retratos en ataques de área. Sin nombres de objetivo ni intención de actores caídos.
- Cartas con coste a la izquierda y espada/escudo a la derecha; ambas marcas para
  cartas mixtas. Icono de espada SVG propio; escudo y retratos reutilizados.
- Destello blanco breve al atacar. Victoria: salida de ambos héroes hacia la
  derecha, con carrera procedural, después de impactos/PV y antes de recompensas.
  Derrota no sale. Estado persistido antes de presentar los efectos.
- Nuevos componentes: `enemy_intent.gd`, `card_type_icons.gd`,
  `presentation/combat_effects.gd`. Documentación de HUD/cartas/arquitectura actualizada.
- Pruebas: presentación 10 renderizadas, cartas 243, UI 121 y layout 8 headless,
  sin fallos. Intenciones y cartas revisadas visualmente a 1280×720; salida fuera
  de pantalla y ausencia de salida en derrota comprobadas por test. No se revisó
  una nueva animación dibujada cuadro a cuadro: se reutilizan sprites con movimiento.
- `git diff --check` correcto; capturas temporales eliminadas. Sin APK ni Android.

## 16/09/2026 — Cartas de combate en abanico

- Mano parcialmente superpuesta con centro elevado, arco suave y rotación ±8°.
- Selección endereza, eleva y amplía la carta; continúa el scroll para manos grandes.
- Cálculo visual separado en `hand_layout.gd`; sin cambios de reglas o cartas
  en otras pantallas. Actualizada documentación de cartas y arquitectura.
- `test_combat_layout.gd`: ocho comprobaciones renderizadas sin fallos; abanico
  y carta seleccionada revisados visualmente. Capturas eliminadas después de revisar.
- `git diff --check` correcto. Sin exportar APK ni probar Android.

## 16/09/2026 — Cartas completas y PV encima de los actores

- Mano elevada con textos completos; abanico más suave (±3°, paso 160 px).
  Se mantiene elevación y ampliación al seleccionar, y scroll para manos grandes.
- PV encima de héroes/enemigos; estados e intenciones arriba de los PV.
  Eliminados nombres de héroes en combate; nombre enemigo sobre su intención.
- Terminar turno a la izquierda, encima de energía, sin tapar cartas ni actores.
- Actualizados `main.gd`, `hand_layout.gd` y documentación de cartas/mazmorra.
- Layout: 33 comprobaciones renderizadas; UI: 121 headless; sin fallos.
  Revisión visual local y diff correctos. Capturas retiradas después de revisar.
- Sin exportación Web/APK ni pruebas en navegador o Android.

## 16/09/2026 — Nombre de carta debajo del coste y tipo

- Eliminada la etiqueta del héroe de las cartas; el nombre de carta ocupa esa fila.
- Espada/escudo junto al número de coste, ambos horizontales en cartas mixtas.
- Constructor compartido y componente de iconos actualizados; sin cambios de reglas.
- Layout: 33 comprobaciones renderizadas; UI: 91 headless, sin fallos.
  Revisión visual local correcta; capturas temporales eliminadas y diff correcto.
- Sin exportación Web ni APK.

## 16/09/2026 — Seleccionar cartas sin energía suficiente

- Cartas de la mano siempre seleccionables para inspección; apariencia atenuada
  si no son jugables. Objetivos y motor siguen validando coste y energía.
- `main.gd` y documentación de cartas actualizados. Regresión en layout:
  selección con energía cero, rechazo sin mutar aventura y deselección.
- 36 comprobaciones headless sin fallos; diff correcto. Sin exportar Web/APK.

## 16/09/2026 — Halo de objetivo, botón ilustrado y accesos juntos

- Flecha de objetivo sustituida por resplandor dorado pulsante detrás del sprite;
  solo objetivos válidos, oculto al resolver la acción.
- Asset propio para Terminar turno integrado con texto nativo y estados visuales.
  Prompt/procedencia conservados en docs/hud/end-turn-prompt.md.
- Iconos de mazo y bolsa contiguos en la barra superior, 12 px entre controles.
- Componentes de presentación separados y documentación actualizada.
- Layout: 38 comprobaciones renderizadas; HUD: 92 headless, sin fallos. Selector
  de estados del test corregido para excluir intenciones. Revisión visual local
  a 1280×720; capturas temporales retiradas; diff correcto.
- Sin exportación Web/APK ni pruebas Android/navegador.

## Mercado, almas y 60 cartas nuevas (16/09/2026)

- 10 cartas nuevas por clase: 90 en total. Nuevos mazos iniciales más modestos;
  no se reemplazan cartas de aventuras ya guardadas. Catálogo completo en
  `docs/cards/CATALOGO.md`; datos adicionales incorporados por el generador.
- Solar 1: construir mercado por 300 almas; seis categorías de héroes y seis
  cartas comprables por categoría. Compra permanente que habilita recompensas,
  sin añadir cartas directamente al mazo. Interior nuevo con mercader generado
  mediante imagegen; prompt y procedencia en `docs/market/prompts.md`.
- Almas por victoria: 30 normal, 80 élite y 150 jefe. Saldo permanente visible en
  campamento, mapa, combate y mercado. Se conceden 5.000 almas de prueba una vez
  por perfil; configurable en `data/progression.json`.
- Economía separada en `src/rules/camp_progression.gd`; pantalla nueva de mercado
  y extracción del campamento a `src/ui/screens/base_camp_screen.gd`.
  Migración aditiva; saldo y recompensa se guardan juntos antes de animar.
- Inclusión `data/*.json` en preset Web para los catálogos/configuración.
- Actualizadas dos expectativas antiguas de pruebas: carta sin energía sigue
  seleccionable y la moneda mejora cartas del portador cuando son ofrecidas,
  sin depender del resultado exacto de una semilla con el catálogo anterior.
- Pruebas actuales locales: reglas 137, progresión 795, mercado UI 34,
  campamento 19, equipamiento 90, cartas 544, mapa 21, HUD 92, UI 271,
  distribución de combate 38 y tesoros 22; sin fallos. Simulaciones: 42/45
  victorias, al menos una por cada una de las 15 parejas.
- Revisión renderizada del interior en Linux; capturas temporales eliminadas.
  Importación Godot sin errores. Sin exportación APK/Web ni validación nueva
  en navegador, emulador o teléfono. Balance humano, otros edificios, venta de
  consumibles y mejoras de héroes permanecen pendientes.

## Sinergias de cartas entre héroes (16/09/2026)

- Variante aplicada: dos cartas reutilizables por clase, 12 participantes del
  catálogo existente y un especial por cada una de las 15 parejas. Se usan
  cartas de recompensa, manteniendo modestos los mazos iniciales.
- Botón Combinar al reunir ambas en mano; coste 2, consume ambas cartas, permite
  elegir enemigo y conserva el turno. ENLACE identifica las cartas; pistas y
  previsualización muestran efectos. Se conserva el juego individual.
- Mejoras, bonos de ataque y veneno contemplados; se exige que ambos héroes
  estén vivos. Resolución y guardado antes de animar; sin migración de partidas.
- Recetas en data/synergies.json, reglas en card_synergies.gd y presentación en
  synergy_view.gd. Documentación completa en docs/synergies/README.md.
- Pruebas locales: sinergias 481, UI con clics 11, reglas generales 137,
  cartas 568, distribución 38, equipamiento 90 y progresión 795, sin fallos.
  Interior de combate revisado renderizado, capturas temporales eliminadas.
  Sin APK/Web exportada ni pruebas Android/navegador. Balance humano pendiente.

## Ilustraciones minimalistas para las 90 cartas (16/09/2026)

- Integradas las 30 ilustraciones de `conceptoCartasImagen.png` como regiones
  de un atlas original sin editar. Generadas 60 ilustraciones individuales con
  imagegen integrado, una por cada carta nueva, siguiendo siluetas y paletas
  de la referencia. Prompts y fuentes por ID en `docs/cards/art/`.
- `data/card_art.json` asigna imágenes; `ui/components/card_art.gd` carga y
  reutiliza texturas. Mano, mazo, mejoras y recompensas utilizan la fábrica
  compartida. El mercado incluye miniaturas. ENLACE lleva placa de contraste.
- Márgenes y proporción conservados; corrección del tamaño mínimo de TextureRect
  antes de cargar imágenes. Importación de conceptos nuevos limitada a 512 px
  en el juego, conservando PNG originales de mayor resolución.
- Galería HTML local filtrable por héroe en `docs/cards/art/galeria.html`.
  Se preservan IDs, efectos, sinergias y guardados; no cambió el balance.
- Pruebas locales: arte 571, cartas 544, distribución 38, mercado 34, UI 271,
  sinergias 481 y progresión 795; sin fallos. Revisión renderizada de las seis
  clases, combate normal/seleccionado y mercado. Capturas temporales eliminadas.
- Sin exportación APK/Web ni validación nueva en Android o navegador del juego.

## Inicio de aventuras con 20 cartas (16/09/2026)

- Cada héroe aporta 10 cartas: cuatro copias de su ataque básico, cuatro de su
  defensa básica y dos cartas modestas distintas, una copia de cada una.
  La pareja empieza con 20; se conservan 6 robos por turno y 3 de energía.
- Actualizados `scripts/create_content.py` y `data/content.json`. No cambian
  efectos, IDs ni la carga de aventuras existentes; no se reconstruyen sus mazos.
- Pruebas locales headless: reglas 155, progresión 819 y distribución de combate
  38, sin fallos. Las 15 parejas completan al menos una simulación; 42/45
  victorias en total. Se verifican repeticiones, básicos, caída y recuperación.
- Documentación de cartas, mercado e inicio actualizada. Sin exportación APK/Web
  ni nueva revisión visual, emulador o dispositivo físico para este cambio de datos.

## Campamento, navegación y marcos de diálogo (17/09/2026)

- Barra superior con «El Campamento, un lugar al que volver...», icono de alma,
  dígitos existentes y Menú. Retirada la barra inferior. Saldo visible únicamente
  en campamento y mercado; se siguen concediendo almas al ganar combates.
- Arco de piedra abre Continuar aventura, Nueva aventura y Volver; continuar
  queda desactivado sin partida. Confirmar/cancelar conserva el flujo de guardado.
- El mercado construido aparece sobre el solar 1 y todo el edificio es pulsable.
- Generados edificio, alma celeste y marco ornamental mediante imagegen integrado.
  Prompts y procedencia en `docs/base_camp/`; marco aplicado a diálogos y tesoros,
  con márgenes ajustados para el contenido de la recompensa y trampas.
- Extraídos `dialog_view.gd`, `modal_frame.gd` y `soul_counter.gd`: presentación
  reutilizable, sin reglas económicas ni persistencia. Formato de guardado intacto.
- Pruebas locales: campamento 33, mercado 34, HUD 92, mapa 21, tesoros 22,
  tesoro UI 8 e interfaz general 271, sin fallos. Revisados campamento construido,
  menú del arco, confirmación, mercado y recompensa/trampa renderizados en Linux.
  Capturas temporales retiradas. `git diff --check` correcto.
- Sin exportar APK/Web ni validar en navegador, emulador o dispositivo físico.

## Botones y barras de preparación (17/09/2026)

- Generados tres assets: botón común de hierro/oro, botón de reliquia con gema
  celeste y panel inferior ornamental. Prompts y fuentes en `docs/ui_buttons/`.
- Tema heredado por botones comunes; conservados los diseños específicos de
  inicio, turno, cartas y zonas interactivas sin fondo. Estados hover, pulsado,
  desactivado y foco de teclado mantienen su respuesta.
- Selección y equipamiento comparten barra superior con campamento y muestran
  su título. Campamento en selección se renombra Volver; nuevo panel para pareja
  elegida y asset de Elegir reliquia. Sin cambio de reglas o formato de guardado.
- Extraída selección de `main.gd`; componentes `preparation_header.gd` y
  `button_skin.gd` centralizan presentación. Ajustados márgenes de fichas de reliquia.
- Validación local: selección 47, equipamiento 12, campamento 33 e interfaz 271,
  sin fallos. Revisión renderizada Linux de selección/equipamiento. Capturas
  temporales eliminadas y diff sin errores de espacios. Sin exportar APK/Web;
  sin nueva validación en navegador, emulador o dispositivo físico.

## Reliquias circulares y navegación propia (17/09/2026)

- Ocho reliquias grandes sin recuadros, en círculo. Centro con selección actual.
  Tocar abre nombre y efecto en el marco ornamental compartido; confirmar elige,
  cancelar conserva la anterior. Se mantiene una reliquia para ambos héroes.
- Conservada barra superior y creados assets propios para Volver a personajes
  e Iniciar aventura. Prompts y fuentes en `docs/ui_buttons/relic-navigation-*.json`.
- Presentación en `equipment_screen.gd`, coordinación en `inspect_equipment`;
  sin cambios de reglas económicas, IDs ni formato de guardado.
- Pruebas locales: equipamiento UI 14, interfaz general 271; sin fallos. Revisión
  renderizada de círculo y diálogo a 1280×720. Capturas retiradas; diff limpio.
  Sin exportar APK/Web ni comprobar en emulador, dispositivo físico o navegador.

## Título del mapa centrado (17/09/2026)

- Centrado el título dentro del bloque de recorrido de 770 px en `map_screen.gd`.
- Confirmado en código y vista renderizada que no se muestran almas en el mapa;
  el saldo ya estaba retirado. No se modificó la economía ni el guardado.
- Pruebas locales de mapa: 21 sin fallos. Revisión visual Linux a 1280×720,
  captura temporal eliminada. Sin exportación APK/Web ni prueba Android/navegador.

## Vida elevada, abanico y turno circular (17/09/2026)

- Vida de ambos bandos elevada, intenciones enemigas a 3 px encima de sus barras;
  estados activos separados. Verificado HUD sin almas, ya retiradas anteriormente.
- Abanico con inclinación máxima de 7°, curva de 18 px y base 14 px más baja.
  Solo se recorta parte del borde inferior; selección conserva elevación y lectura.
- Nuevo asset circular de terminar turno a la derecha de las cartas, con hit testing
  circular y estados visuales. Prompt/fuente en `docs/hud/end-turn-round.json`.
- Pruebas locales de distribución 38, HUD 92 e interfaz general 271 sin fallos, revisión visual Linux
  normal/seleccionada a 1280×720. Capturas temporales retiradas. Sin exportación
  APK/Web ni pruebas en navegador, emulador o dispositivo físico.

## Selección inmediata y descripción exterior de reliquias (17/09/2026)

- Tocar selecciona y guarda la reliquia compartida directamente. Descripción
  ornamental persistente en el lateral exterior del círculo, sin modal ni botones
  de confirmación. Tocar otra reemplaza selección y descripción; fondo no la cierra.
- `equipment_description.gd` separa presentación y ubicación del cuadro; retirado
  `inspect_equipment`. Guardado y reglas reutilizados sin modificar su formato.
- Equipamiento UI: 46 comprobaciones locales sin fallos, cubriendo las ocho
  reliquias y límites del cuadro. Interfaz general: 271 sin fallos. Revisados ambos
  laterales renderizados en Linux. Capturas temporales eliminadas. Sin exportar
  APK/Web ni pruebas nuevas en navegador, emulador o dispositivo físico.

## Marcos superiores, tablones y diálogos centrados (17/09/2026)

- Marco ornamental compartido en campamento, personajes y reliquias. Margen
  del título ajustado para despejar las esquinas del asset.
- Generados tablón común, cartel Menú y marco superior; fuentes y prompts en
  `docs/ui_buttons/wood-assets.json`. Aplicados tablones a botones generales,
  inicio y acciones de preparación. Menú consistente en mapa, combate y tesoro.
- Títulos y cuerpos de modales centrados en el constructor común; tesoros ya
  centrados. Preservados iconos, cartas y terminar turno circular.
- Pruebas locales: campamento 33, selección 47, equipamiento 46, inicio 13 y
  UI general 271, todas sin fallos. Revisión visual Linux de cabeceras y modal
  del arco; capturas temporales retiradas. Diff limpio. Sin exportar APK/Web,
  ni nuevas pruebas en navegador, emulador o dispositivo físico.

## Centro del círculo sin textos (17/09/2026)

- Retiradas las etiquetas centrales de `equipment_screen.gd`; se conserva el
  cuadro exterior con nombre y efecto y la selección inmediata persistente.
- Revisión del código y `git diff --check`; sin prueba visual nueva ni exportación
  APK/Web para esta eliminación de etiquetas.

## Selección de reliquia sin subtítulo (17/09/2026)

- Eliminada la indicación «Elegí una sola reliquia para ambos héroes…» de
  `equipment_screen.gd`. Sin cambios de comportamiento.
- Revisión del código y `git diff --check`; sin prueba visual nueva ni exportación APK/Web.

## Corrección de letras al rotar cartas (17/09/2026)

- Texto de cartas con MSDF y filtro lineal, aislado en `card_typography.gd`.
  Corrige el muestreo nearest heredado, conservando abanico, tamaños y pixel art.
- Pruebas locales: distribución 38 e interfaz general 271 sin fallos. Revisión
  visual Linux a 1280×720, capturas temporales retiradas. Sin exportar APK/Web
  ni comprobar esta revisión en navegador, emulador o dispositivo físico.

## Actores mayores y datos enemigos con contraste (17/09/2026)

- Enemigos +25 % sobre escala previa. Héroes con altura visible común usando
  la guardiana ampliada un 25 % como referencia; compensación de los sprites
  menores, escalado uniforme y pies anclados. Sin modificar atlas o animaciones.
- Placas oscuras semitransparentes para nombre e intención de enemigos.
- Nuevos componentes `combat_actor_scale.gd` y `combat_backplate.gd`.
- Distribución 38 y HUD 92 locales sin fallos tras actualizar la expectativa
  anterior de escala. Revisión visual de los seis héroes en Linux a 1280×720;
  capturas retiradas. Sin exportar APK/Web ni validar en navegador/Android.

## Mercado con retratos y cartas completas (17/09/2026)

- `market_screen.gd`: imagen frontal de cada héroe en su selector, catálogo de
  dos cartas completas por fila y botón de compra con precio debajo de cada una.
- Reutilizada la fábrica `main.gd::card_panel`, con opción de valores base para
  que el catálogo no herede bonificaciones de una aventura activa. Sin cambios
  de precios, reglas de compra, IDs ni guardados.
- Mercado renderizado local: 34 comprobaciones; interfaz general headless: 271;
  todas sin fallos. Revisada captura del interior y retirada. Sin exportar APK/Web
  ni comprobar este cambio en navegador, emulador o dispositivo físico.

## Herrería en solar 3 y equipo permanente (17/09/2026)

- Construcción por 400 almas, edificio visible e interior con herrero; seis
  categorías con vista previa. Tres niveles independientes de arma y armadura
  por héroe, a 150/300/600 almas por rama: +1 fuerza o +2 bloqueo por nivel.
- Perfil conserva compras; cada nueva run toma una instantánea. Las aventuras
  anteriores mantienen estadísticas y aspecto. Compras duplicadas o sin saldo
  rechazadas; derrota no elimina el equipo permanente.
- Generados con image_gen integrado edificio, interior y 96 atlas (3.360 cuadros),
  cubriendo equipo inicial y todas las combinaciones. Prompts y fuentes en
  `docs/forge/`; importador reproducible, métricas de altura y caché de ocho variantes.
- Nuevos módulos de reglas, navegación, pantalla y presentación; main conecta
  callbacks. Apariencia actual en combate, mapa y recompensas; perfil en herrería.
  Hit testing por alfa y prioridad del cartel vecino evitan tapar el mercado.
- Pruebas locales: herrería/reglas 330, assets/animaciones 10.626, herrería/UI 46;
  reglas generales 155, progresión 819, campamento 33, UI 271, HUD 92,
  distribución 38 y mapa 21, sin fallos. Revisión visual Linux de las seis galerías,
  interior, edificios, mapa y seis héroes con equipo máximo en combate.
- Capturas temporales retiradas; documentación y procedencia conservadas. Sin
  exportar APK/Web ni verificar en navegador/emulador/dispositivo físico.

## Carteles del campamento — 17/09/2026

- Paneles de `main.gd::camp_hotspot` con el tablón de madera compartido.
- `base_camp_screen.gd`: edificios construidos rotulados «Mercado» y «Herrería»,
  sin «Entrar»; se preservan las zonas de clic existentes.
- Prueba local renderizada `test_forge_ui.gd`: 46 comprobaciones, cero fallos;
  campamento revisado visualmente a 1280×720. Capturas temporales retiradas.
- Sin exportaciones APK/Web ni validación en dispositivo.

## Cartas según concepto y saldo de pruebas — 18/09/2026

- Seis marcos nuevos con emblemas; verde adaptado al pícaro y turquesa con
  escudo para la guardiana. Coste superior derecho y pastilla inferior derecha
  de espada/escudo; ilustraciones y efectos existentes conservados.
- Presentación extraída de main a `ui/components/card_view.gd`. Assets y
  prompts en `assets/cards/frames/` y `docs/cards/frames/provenance.json`.
- Saldo del perfil local fijado en 100.000 almas mediante ejecución explícita
  de `scripts/set_test_souls.gd`; aventura conservada y lectura posterior
  verificada. No modifica saldos de partidas Web ni reinicia el saldo al abrir.
- Validación actual: distribución 38, presentación 10 y mercado 34, sin fallos.
  Revisión visual Linux de combate, mercado y seis clases. Capturas retiradas.
  Sin compilar/exportar APK/Web ni probar en dispositivo.

## Cartas que se convierten en cenizas — 18/09/2026

- Desintegración procedural del contenido completo al jugar una carta; borde
  de brasa y cenizas ascendentes. También para ambas cartas de una sinergia.
- Componente `presentation/card_ash.gd` y shader `assets/shaders/card_ash.gdshader`;
  integración posterior a resolución/guardado, sin alterar daño ni descarte.
- Presentación renderizada: 12 comprobaciones sin fallos y captura intermedia
  revisada en Linux. Capturas temporales eliminadas. Sin exportar APK/Web.

Prueba adicional headless: 14 comprobaciones sin fallos, incluyendo consumo
y animación de ambas cartas de sinergia, rechazo sin energía y limpieza del efecto.

## Mano más separada y pastilla izquierda — 18/09/2026

- Paso de cartas 160 px en lugar de 132, zona de mano ampliada y extremos
  elevados ligeramente para ver costes y pastillas dentro de la pantalla.
- Pastilla de espada/escudo en borde inferior izquierdo; dígitos del coste
  sobre el solapamiento. Archivos: `hand_layout.gd`, `card_type_icons.gd`,
  `card_view.gd` y coordinación en `main.gd`.
- Distribución: 38 comprobaciones sin fallos y revisión visual Linux 1280×720.
  Capturas eliminadas. Sin exportar APK/Web ni probar en dispositivo.

## Carta seleccionada sin recuadro — 18/09/2026

`src/ui/components/card_view.gd` usa estilos vacíos en todos los estados del
botón para retirar el rectángulo amarillo exterior, incluido el foco.
Se conservan el marco ilustrado, el tamaño ampliado y la elevación al seleccionar.
Validación actual: 38 comprobaciones de distribución sin fallos y revisión
renderizada de la carta seleccionada en Linux a 1280×720. Capturas temporales
eliminadas; sin exportar APK/Web ni verificar en dispositivo.

## Menú por encima de la mano — 18/09/2026

`dialog_view.gd` coloca el diálogo completo, incluido el oscurecimiento, en
z absoluto 200, por encima de cartas seleccionadas (10), dígitos y efectos
del combate (hasta 100). No cambia la selección al abrir/cerrar el menú.
Validación local actual: 41 comprobaciones de distribución sin fallos; incluye
abrir el menú con carta seleccionada, bloqueo de clics sobre la carta y Volver
conservando la selección. Revisión renderizada Linux a 1280×720; capturas
temporales eliminadas. Sin exportar APK/Web ni probar en dispositivo.

## Edificios sin recuadro y cartel del mercado arriba — 18/09/2026

`main.gd::camp_hotspot` usa StyleBoxEmpty para normal, hover, pulsado, foco
y deshabilitado, retirando el rectángulo amarillo sobre los edificios.
La opción `caption_above` coloca el tablón encima y extiende hacia arriba
el área de clic. `base_camp_screen.gd` la activa para el mercado construido;
el solar sin construir conserva el cartel inferior. El mercado queda rotulado
sobre el tejado y separado de la herrería. Se conserva el asset de madera.

Validación actual: `test_forge_ui.gd`, 46 comprobaciones sin fallos, incluyendo
clics en ambos carteles. Revisión visual Linux a 1280×720. Capturas temporales
eliminadas. Sin exportar APK/Web ni probar en dispositivo.

## Preparación sin selección anterior y Valhalla — 18/09/2026

- Nueva aventura vacía pareja/reliquia; borrador legado retirado sin cambiar
  partidas activas. Preparación en memoria y retorno interno conservado.
- Héroes elegidos con resplandor detrás, sin rectángulo; barra inferior sin nombres.
- Fondo de reliquias Valhalla e icono de puerta en Iniciar aventura, generados
  con image_gen. Assets en `assets/equipment/`, prompts en `docs/equipment/`.
- Campamento 47 y equipamiento UI 48 comprobaciones sin fallos; revisión visual
  Linux 1280×720. Capturas temporales retiradas. Sin exportar APK/Web ni dispositivo.

## Mapa completo y pestaña del grupo — 18/09/2026

- Fondo y recorrido ampliados a toda la vista. Información del grupo extraída
  a `map_group_drawer.gd`, panel deslizante desde el borde derecho, cerrado
  inicialmente, con PV, reliquias y mazo.
- Asset de pestaña con tres aventureros en `assets/map/group_tab.png`; generado
  con image_gen, procedencia y prompt en `docs/map/group-tab.json`.
- Pruebas del mapa: 25 sin fallos; revisión visual Linux abierto/cerrado.
  Capturas temporales retiradas. Sin exportar APK/Web ni probar en dispositivo.

## Primera mazmorra extendida sobre papiro — 18/09/2026

- 28 salas, cinco bifurcaciones de tres caminos y 243 rutas de 18 salas.
  13 combates, cuatro eventos, dos tesoros, seis descansos, élite opcional,
  segundo élite obligatorio y guardián. Ajustados descansos y encuentros
  dobles tras detectar derrotas excesivas de algunas parejas en el recorrido largo.
- Grafo/posiciones/encuentros declarados en `data/dungeon_floor1.json`;
  nuevas posiciones guardadas por nodo y fallback para aventuras de 12 salas.
- Papiro e iconos sepia minimalistas en `assets/map/minimal/`, generados con
  image_gen. Prompts y procedencia en `docs/map/minimal-assets.json`.
- Pruebas finales: reglas 155, recorrido/guardado legado 66, mapa 41, tesoros 22
  y tesoro UI 8, sin fallos. Simulaciones: 41/45 victorias, al menos una por
  cada pareja. Revisión visual Linux 1280×720; sin exportar APK/Web ni dispositivo.

## Limpieza y arquitectura — 18/09/2026

- Retirados 15 archivos obsoletos (~8,6 MiB): mapa anterior, botones reemplazados
  y metadatos de imágenes Web exportadas. Conservadas pruebas útiles y fuentes.
- Extraídos `ui/screens/combat_screen.gd`, `ui/combat_flow.gd` y `rules/items.gd`;
  `main.gd` baja a 702 líneas y `game.gd` a 550. Interfaces y guardado conservados.
- Arquitectura actual abreviada; narrativa anterior en `architecture/EVOLUCION.md`.
  Pendiente continuar extrayendo pantallas y reducir dependencia del controlador.
- Presets excluyen recursos de desarrollo; `TestWeb/.gdignore` evita reimportarlos.
- Validación de este cambio: importación local y 30/30 pruebas automatizadas;
  revisión visual local de reliquias/cenizas. Capturas temporales eliminadas.
  Sin exportar APK/Web ni probar emulador/dispositivo.
- [Inventario, criterios y próximos pasos](cleanup/2026-09-18.md).

## Primeros planos de ataque — 18/09/2026

- Seis concepts individuales integrados sin editar en `assets/comic/`.
- `presentation/hero_cut_in.gd`: viñeta breve con movimiento, líneas de velocidad
  y color por héroe; invocada desde `ui/combat_flow.gd` tras confirmar el ataque.
- Reglas, guardados y sprites conservados. Defensa/curación y sinergias mantienen
  sus efectos previos. Una pose por héroe; equipo de herrería no cambia esta imagen.
- Pruebas locales de ciclo de vida y presentación de combate; revisión visual
  local. Sin APK/Web ni dispositivo. [Detalle y procedencia](comic/README.md).

## Cómic transparente y ajuste de cartas — 18/09/2026

- Apariciones sin banda ni oscurecimiento, ancladas abajo a la izquierda sobre
  escenario y HUD. `presentation/hero_cut_in.gd` conserva duración y capas.
- Centro del coste específico por marco en `card_view.gd`; pastilla e iconos
  agrandados en `card_type_icons.gd`. Sin cambios de reglas o guardado.
- Prueba renderizada de los seis cómics y anclaje; 41 comprobaciones de layout
  aprobadas; revisión visual de galería de seis clases y cómic sobre mazmorra.
  Capturas temporales retiradas. Sin exportar APK/Web ni probar dispositivo.

## Recompensa y contadores del mazo — 18/09/2026

- Contadores retirados del escenario y trasladados al visor del mazo en combate.
- Pantalla `ui/screens/reward_screen.gd` extraída: cartas de 414 px de alto, sin
  héroes animados encima, barra superior compartida y fondo oscuro con energía.
- Asset `assets/reward/background.png` generado con imagegen; prompt/procedencia
  en `docs/reward/background.json`. Bolsa vuelve a la recompensa con texto Volver.
- Prueba renderizada de recompensa sin fallos y 41 comprobaciones de layout
  aprobadas; inspección visual local. Sin exportación ni pruebas en dispositivo.

## Defensas en cómic — 18/09/2026

- Generados seis PNG transparentes con poses defensivas propias de cada héroe
  y su arma/escudo, usando el ataque existente como referencia de identidad.
- Integrados en cartas de bloqueo sin daño/veneno; cartas mixtas conservan ataque.
  Mismo primer plano inferior izquierdo y resolución/guardado antes de animar.
- Recursos en `assets/comic/defense/`; prompts exactos en `docs/comic/defense.json`.
- Sin exportación APK/Web ni prueba en dispositivo.

Validación actual: prueba renderizada local de las 12 apariciones (ataque y
defensa de seis héroes), anclaje y limpieza sin fallos; 17 comprobaciones de
presentación de combate aprobadas. Inspección visual de los seis assets y
del guerrero defensivo sobre la mazmorra. Sin APK/Web ni dispositivo.

## Ataques enemigos en cómic — 18/09/2026

- Seis assets transparentes nuevos en `assets/comic/enemies/`, orientados hacia
  la izquierda, con prompts/procedencia en `docs/comic/enemies.json`.
- Animación común extraída a `comic_cut_in.gd`; adaptadores de héroes y enemigos
  conservan catálogo separado y entrada desde lados opuestos.
- Recibo transitorio `resolved_enemy_attacks` evita ataques visuales no ejecutados
  por veneno, bloqueo puro o derrota anticipada. Guardado y reglas conservados.
- Prueba renderizada de los seis enemigos y regresión de héroes aprobadas;
  revisión visual de assets y lancero sobre escenario. Sin APK/Web ni dispositivo.

Validación final de esta integración: 18 comprobaciones de presentación
aprobadas, incluido primer plano del ataque letal; 155 comprobaciones de
reglas aprobadas (41/45 victorias simuladas entre las 15 parejas). El último
ataque sigue mostrándose aunque la derrota haya limpiado el estado del combate.

## Bloqueo junto a la vida — 18/09/2026

- `status_effects.gd` coloca el bloqueo activo a la izquierda de la barra de vida
  con escudo de 32 px y dígitos de 18 px (antes 24). `combat_screen.gd` proporciona
  la posición relativa a cada barra; veneno permanece arriba. Solo aparecen
  valores positivos en unidades vivas.
- `enemy_intent.gd`: espada, escudo de bloqueo previsto y retrato del objetivo,
  en ese orden. El escudo previsto añade `assets/ui/block_up.svg`, flecha verde
  ascendente dibujada en SVG para reutilizar el escudo existente. Número de 18 px.
  La intención de ataque conserva su tamaño; intenciones sin daño no muestran espada.
- `block_indicator.gd` comparte dimensiones configurables y flecha opcional.
- `button_skin.gd`: márgenes verticales simétricos (8/8) para centrar Menú
  en todas las barras que utilizan el tablón compartido.
- No cambian valores de bloqueo, reglas, estados ni guardado.

Revisión visual local de combate a 1280×720 y prueba HUD renderizada: 93
comprobaciones aprobadas. Sin exportación APK/Web ni dispositivo.

## Icono de enlace y acabado de cartas — 18/09/2026

Se elimina la etiqueta ENLACE de encima de la ilustración. `card_view.gd` detecta
si la carta participa en alguna receta y pasa esa información a
`card_type_icons.gd`: añade `assets/ui/chain.svg` al final de la pastilla inferior,
junto a espada/escudo, ampliando la pastilla. El tooltip conserva las combinaciones.

`presentation/card_finish.gd` añade resplandor dorado discreto a los enlaces y
un barrido de reflejo a todas las cartas del componente compartido (combate,
recompensas, mercado, mazo). Shaders en `assets/shaders/card_link_glow.gdshader`
y `card_sheen.gdshader`; se enmascaran con la transparencia del marco. Los
efectos no capturan eventos ni cambian textos/reglas. Cadena SVG y shaders
creados en código, sin generación de imágenes adicional.

Cada carta utiliza un RNG visual independiente: primera espera entre 0,8 y
7 segundos, barrido de 0,85 s y siguientes pausas entre 4 y 11 s. No hay
disparo global sincronizado; coincidencias casuales pueden ocurrir. Al
reconstruir la vista se crean temporizadores nuevos. No consume RNG de partida
ni requiere persistir estados decorativos; se libera junto con la carta.

Validación de este cambio: 19 comprobaciones de sinergia UI renderizada y
18 de presentación de combate headless aprobadas. Incluyen cadena/resplandor,
ausencia de etiqueta, temporizadores distintos, inicio/reprogramación del
barrido y conservación del RNG de juego. Revisión visual local de cartas de
enlace en combate. Sin exportación APK/Web ni prueba en dispositivo.

## Reposo estable, salida lenta y cenizas — 18/09/2026

Los seis actores usan `presentation/hero_idle.gd`: congela el cuadro 0 del
reposo y aplica `assets/shaders/hero_idle.gdshader`. El shader desplaza levemente
regiones laterales de capa/ropa y mano/arma; mantiene zona central del torso,
cabeza y pies sin escalado/traslación del actor. Es deformación localizada de
una pose, no nuevos cuadros dibujados ni articulaciones independientes. Los
atlas previos se conservan para acciones y compatibilidad. El helper detecta
cambios de atlas de herrería y desactiva la deformación durante otras acciones.
La selección frontal del campamento ya era estática y se conserva.

`combat_effects.gd`: salida victoriosa en 2,5 s (antes 1,25), segundo héroe con
desfase de 0,12 s, conservando desplazamiento y pasos procedurales.

`enemy_sprite.gd` delega muerte en `presentation/enemy_ash.gd`: disolución
ascendente con ruido, borde de brasa y partículas de ceniza. El shader
`assets/shaders/enemy_ash.gdshader` normaliza el cuadro actual del atlas.
Dura 1 s más 0,3 de cola; al terminar el sprite queda oculto, también al
reconstruir un enemigo ya caído. No queda cuerpo tumbado. Los héroes caídos
conservan su animación/cuerpo y la recuperación anterior. Reglas y guardado
siguen precediendo a la presentación. Shaders y partículas hechos en código,
sin nuevos assets generados ni modificación de atlas.

Validación actual: `test_actor_motion.gd` renderizado sin fallos (seis héroes
con equipo nivel 3, reposo fijo, retorno desde ataque y cenizas); 498
comprobaciones de enemigos, 18 de presentación y 10626 de recursos de herrería
aprobadas en headless. Capturas locales revisadas; comparación de dos instantes
confirma movimiento visible en los seis héroes. Capturas temporales eliminadas.
Sin exportación APK/Web, emulador ni dispositivo físico.

## Bolsa circular — 18/09/2026

La bolsa dispone los ocho objetos en un círculo de radio 190 px. Cada icono
permanece consultable incluso con cero unidades y muestra debajo la cantidad
real mediante `number_view.gd`. La barra superior comparte el marco de preparación.

Al tocar un objeto se selecciona y abre un cuadro anclado fuera del círculo,
con nombre, efecto y acciones Consumir por objetivo válido (o un único botón
para objetos de equipo). Si no hay unidades, objetivo o combate activo, la
acción queda deshabilitada y explica el motivo. Tocar otro icono reemplaza el
cuadro. No hay modal que bloquee la consulta del resto de objetos.

`ui/screens/items_screen.gd` recibe catálogo, inventario y acciones;
`ui/components/item_popover.gd` dibuja el cuadro. `ui/items_navigation.gd`
consulta objetivos y llama a `game.use_item`, que sigue validando, resolviendo
y guardando. `main.gd::items_view` ahora delega. Tras consumir vuelve al combate;
Volver respeta la fase actual, incluida una recompensa pendiente. Reglas y
formato de guardado no cambian. Se reutilizan atlas, dígitos y marco existentes.

Validación actual: `test_bag_ui.gd` renderizado sin fallos (ocho posiciones,
consulta con cero, cantidades, cuadros exteriores, consumo único, bloqueo
fuera de combate y retorno a recompensa); 48 comprobaciones de equipamiento
UI y prueba de recompensa aprobadas en headless. Revisión Linux 1280×720;
captura temporal eliminada. Sin exportación APK/Web ni prueba en dispositivo.


## 18/09/2026 — Explicaciones de combate, contraataques y golpes separados

Se añadieron cuadros pequeños al tocar bloqueo activo de héroes/enemigos e
intenciones de ataque, bloqueo y contraataque. Nuevo icono vectorial de espada
con flecha de retorno; procedencia en `docs/hud/README.md`.
Tres enemigos alternan turnos de contraataque de 4 por impacto recibido.
Los golpes múltiples ahora muestran ataques y reducciones de vida separados;
el bloqueo se actualiza en cada impacto. Caer interrumpe la secuencia y puede
resolver derrota. Se preservan guardado previo a efectos e IDs.

Reglas extraídas a `rules/card_hits.gd`, reproducción a
`presentation/card_impacts.gd`; mapa de arquitectura y reglas de enemigos
actualizados. Sinergias provocan una respuesta contra el primer héroe de receta.
Balance de frecuencia/daño pendiente de partidas humanas.

Validación local actual: `test_counter.gd` sin fallos (3×5/3×4,
absorción por bloqueo, interrupción por muerte, derrota y tres escalones
visuales de vida); `test_hud.gd`: 107 comprobaciones headless sin fallos,
incluidos clics reales en los cinco tipos de indicadores; reglas generales:
155 comprobaciones, 42/45 simulaciones ganadas; sinergias: 481 comprobaciones;
presentación: 18 comprobaciones, repetidas tras el ajuste final del escudo.
Las pruebas generales y de sinergias se ejecutaron antes de ese ajuste visual,
sin cambios posteriores en sus reglas. Importación del editor completada.
Revisión visual pendiente: no se dispone de xvfb-run en este entorno.
Sin exportación APK/Web ni prueba en dispositivo.

## 18/09/2026 — Título enmarcado y columna lateral fija del mapa

El título centrado reutiliza `assets/ui/buttons/header_frame.png` con fondo
oscuro y letras doradas. La columna derecha ocupa 84 px y toda la altura;
reutiliza el mismo marco girado y el icono existente `assets/map/group_tab.png`.
El botón Grupo permanece fijo y abre/cierra el panel hacia la izquierda.
La columna intercepta clics y reserva espacio para futuras pestañas; Menú
permanece accesible a su izquierda. El recorrido se comprime horizontalmente
solo al dibujarlo para evitar que la columna tape salas o textos.

Archivos: `src/ui/screens/map_screen.gd` y
`src/ui/components/map_group_drawer.gd`. No cambian nodos ni coordenadas guardadas.
No se generaron nuevos assets. `test_map.gd` adaptado a la pestaña fija:
41 comprobaciones aprobadas con render Linux/llvmpipe a 1280×720;
revisión visual abierto/cerrado y `git diff --check` sin problemas.
Capturas temporales eliminadas; sin exportación ni prueba en dispositivo.

## 18/09/2026 — Cruz roja para cartas de sanación

`src/ui/components/card_type_icons.gd` añade una cruz roja cuando `heal > 0`
a la pastilla inferior compartida de combate, mazo, mercado y recompensas.
Las cartas mixtas conservan espada/escudo y los enlaces conservan la cadena;
la pastilla adapta su ancho. Asset nuevo `assets/ui/heal.svg`, vector dibujado
en código con contorno claro y sombreado escalonado siguiendo los iconos
existentes; sin generación de imágenes ni cambios de reglas.

Validación local headless: `test_cards.gd`, 544 comprobaciones sin fallos;
importación del editor y `git diff --check` correctos. Sin revisión visual
manual de este cambio ni exportación.

## 18/09/2026 — Espada y calavera para cartas de veneno

La pastilla inferior incorpora espada seguida de calavera verde cuando
`poison > 0`, incluso sin daño directo. Se reutiliza `assets/ui/poison.svg`,
el mismo icono del estado de veneno en combate. El componente compartido
`src/ui/components/card_type_icons.gd` conserva los demás iconos y adapta
el ancho en combate, mazo, mercado y recompensas. Sin cambios de reglas
ni assets nuevos.

Validación local headless: `test_cards.gd`, 544 comprobaciones sin fallos;
`git diff --check` correcto. Sin revisión visual manual ni exportación.

## 18/09/2026 — Equipo mejorado en el HUD de combate

Armas y armaduras con nivel 1–3 aparecen después de las reliquias en la barra
superior del combate y de su recompensa. Cada icono lleva el nivel con los
dígitos existentes; al tocarlo abre el cuadro compartido con héroe, nivel y
bonificación de fuerza por golpe o bloqueo en cartas defensivas. Se conserva
el cierre por segundo toque, toque exterior y Volver. Los niveles 0 no aparecen.

Se muestran los valores de `run.heroes[].forge`, aplicados al inicio de la
aventura, sin recalcular desde el perfil ni modificar partidas en curso.
`src/presentation/equipment_badges.gd` prepara descripciones y texturas;
`combat_hud.gd` presenta reliquias y equipo en la misma fila, ajustando
separación si fuera necesario. Las pantallas de combate/recompensa suministran
la instantánea. La interfaz no concede mejoras ni guarda.

Assets nuevos: `assets/forge/icons/`, 21 SVG transparentes dibujados en código
como extensión de los iconos vectoriales existentes: seis armas (espada,
escudo de guardiana, dagas, báculo arcano, báculo sagrado y arco) y armadura,
cada una en tres niveles con metales y gemas distintos. Son iconos de HUD;
los atlas de personajes conservan su arte actual. Sin generación de imágenes.

Validación actual: `test_forge_ui.gd`, 97 comprobaciones renderizadas locales
sin fallos, incluyendo los cuatro equipos de cada pareja, apertura/cambio de
cuadro, héroe/nivel y bonos +3/+6; `test_hud.gd`, 107 headless sin fallos.
Importación y `git diff --check` correctos. Revisión visual Linux 1280×720;
capturas temporales eliminadas. Sin exportación ni prueba en dispositivo.

## 18/09/2026 — Regreso al campamento desde la barra de herrería

La herrería muestra únicamente «Campamento» como acción de navegación en la
barra superior: reemplaza «Menú» y elimina «Volver al campamento» inferior.
Mantiene marco y almas, desplazando el contador para dar espacio al botón.
`preparation_header.gd` admite una etiqueta opcional; las demás pantallas
conservan «Menú» por defecto. `forge_screen.gd` conecta la acción de regreso;
se retira el callback de menú sin uso en `forge_navigation.gd`.

Validación local headless: `test_forge_ui.gd`, 97 comprobaciones sin fallos,
incluido clic en Campamento superior y retorno. `git diff --check` correcto.
Sin revisión visual manual de este cambio ni exportación.

## 18/09/2026 — Vista previa y confirmación de mejora de cartas

En el descanso, tocar una carta sin mejorar selecciona una copia mejorada
para mostrar sus valores y un resplandor. Solo hay una seleccionada; tocar
otra restaura la anterior. El botón inferior «Mejorar» empieza deshabilitado
y confirma la selección. Volver descarta la vista previa. Cartas ya mejoradas
no son seleccionables. Previsualizar no cambia el mazo, consume el descanso
ni guarda; confirmar llama a `game.rest(false, index)`, que valida y guarda.

Se extrae `src/ui/screens/card_upgrade_screen.gd` con selección local y copia
del mazo; `main.gd::deck_view` delega el modo de mejora. Se reutilizan marcos,
shader de resplandor y botón de madera existentes, sin assets nuevos.

Validación: prueba dedicada por clics para botón inicial, selección/cambio,
valores mejorados, mazo intacto en vista previa, carta ya mejorada bloqueada
y confirmación de una única instancia. Revisión visual Linux 1280×720;
HUD: 107 comprobaciones headless sin fallos tras la extracción del modo de
mejora. `git diff --check` correcto. Captura temporal eliminada. Sin exportar.

## 18/09/2026 — Categorías visuales de héroe en herrería

La columna de selección reutiliza miniatura frontal, nombre y marco del color
de cada clase del mercado. Se extrae `ui/components/hero_category.gd` para
que ambas tiendas compartan la presentación; IDs y callbacks se conservan.
La vista previa animada de equipo aumenta un 25 % (área de 124 a 155 px),
reposicionada en la esquina derecha del bloque sin tapar textos ni compras.
Se reutilizan `assets/cards/<hero>.png` y el atlas frontal; sin assets nuevos.

Validación actual: herrería renderizada en Linux 1280×720, 97 comprobaciones
sin fallos; mercado headless, 34 sin fallos. Revisión visual del interior con
las seis categorías y personaje ampliado; `git diff --check` correcto.
Capturas temporales eliminadas. Sin exportación ni prueba en dispositivo.

## 18/09/2026 — Menos texto en la bolsa

Retirados «No tenés unidades» del cuadro de objeto y «Tocá un objeto para ver
su efecto» del pie de la vista. Las cantidades permanecen exclusivamente en
los dígitos bajo cada icono. Consumir sigue deshabilitado cuando no hay stock.
Archivos: `ui/components/item_popover.gd` y `ui/screens/items_screen.gd`.
Validación local headless: `test_bag_ui.gd` sin fallos y `git diff --check`
correcto. Sin revisión visual manual ni exportación.

## 18/09/2026 — Sustitución del arte de equipo del HUD

Los 21 SVG simples de armas/armadura se reemplazan por PNG transparentes de
128×128 en `assets/forge/icons/`. Tres niveles para cada arma (espada violeta,
escudo turquesa, dagas verdes, báculo azul, báculo sagrado y arco azul) y tres
armaduras comunes. Metal desgastado, grabados, gemas y acabados progresivos
siguen el pixel art detallado de las reliquias. Dígitos y cuadros siguen siendo
componentes de interfaz; no se pintan números ni marcos sobre los assets.

Generados con image_gen integrado, usando `assets/objects/icons.png` como
referencia estilística; edición posterior mediante la misma herramienta para
extraer fondo transparente. Prompts completos, fuentes y procedencia:
`docs/forge/hud-icons.json`; cuatro hojas finales en `hud-sources/`.
`scripts/import_equipment_icons.gd` recorta celdas y normaliza la silueta a
112 px dentro de un lienzo de 128 px, preservando alfa; ignora alfa residual
inferior a 0,25 solo para calcular los límites del recorte. No recalcula reglas.
`presentation/equipment_badges.gd` carga PNG. SVG sustituidos eliminados.

Validación: 21 PNG comprobados por tamaño, canal alfa, transparencia de borde
y contenido; importación Godot y diff sin errores. Prueba de herrería/HUD
renderizada local con 97 comprobaciones aprobadas; revisión visual de iconos
y cuadro de efecto en combate. Sin exportación ni dispositivo físico.
Capturas temporales eliminadas; fuentes y prompts se conservan.

## 18/09/2026 — Bloqueo de héroes encima de la vida

Solo en héroes, escudo y número de bloqueo activo vuelven a la fila encima
de la barra de vida. Sin veneno se centran; con veneno se distribuyen ambos
indicadores sin solaparse. Los enemigos conservan sus posiciones anteriores.
Se mantiene la consulta al tocar y la ocultación cuando no hay bloqueo.
`combat_screen.gd` aporta posiciones de héroes; `status_effects.gd` admite
una posición opcional del veneno sin alterar el valor predeterminado.

Validación: `test_hud.gd` renderizado, 108 comprobaciones sin fallos,
incluyendo posición, ausencia de solapamiento, clics y ocultación. Revisión
visual Linux 1280×720; captura temporal eliminada. Sin exportación.

## 18/09/2026 — Ambientación animada del campamento diurno

El fondo diurno usa `assets/shaders/camp_day.gdshader`: brisa suave localizada
en las copas laterales, ondulación/reflejos del lago, flujo discreto de la
cascada izquierda y oscilación/brillo de las llamas centrales. Máscaras suaves
por coordenadas y color limitan el movimiento sobre la ilustración original.
No es animación esquelética ni un nuevo atlas; no se modifica el PNG fuente.
Edificios, carteles, interfaz y zonas interactivas conservan sus posiciones.
Solo se aplica a `base_camp`; el fondo nocturno de selección no cambia.

`main.gd::background` asigna el material al nodo `DayCampBackground`. Efecto
puramente visual mediante tiempo de shader, sin RNG de juego ni persistencia.
No se generan assets con IA: shader escrito en código y fondo existente.

Validación local Linux/llvmpipe 1280×720: `test_base_camp.gd`, 37 comprobaciones
sin fallos. Comparación de cuadros separados por 0,45 s confirma cambio de
píxeles en follaje, agua y fuego, con una región del suelo idéntica; conserva
pruebas de solares, refugio, arco y regreso/continuación. Revisión de captura
renderizada; captura temporal eliminada. No implica revisión temporal manual
exhaustiva ni validación de rendimiento Web/Android. Sin exportación.

## 18/09/2026 — Salir y engranaje de opciones en inicio

«Salir del juego» reemplaza a Opciones en la columna de botones principales.
Opciones pasa a un botón cuadrado de 70×70 en la esquina superior derecha,
sin texto visible, con engranaje metálico y tooltip. `assets/ui/settings.svg`
se dibujó en código siguiendo la paleta oscura/dorada de la interfaz.
`ui/components/title_actions.gd` compone ambas acciones; `main.gd::home` delega.
La salida realiza checkpoint y cierra la aplicación nativa. En Web muestra
un cuadro indicando que se puede cerrar la pestaña, sin intentar cerrarla.

Validación local Linux/llvmpipe: `test_title.gd`, 13 comprobaciones aprobadas
más clic final en Salir que termina el proceso con código 0. Se comprobaron
opciones, volumen, persistencia, pantalla completa, navegación/continuación.
Revisión visual 1280×720; captura temporal eliminada. Importación y diff
correctos. Rama Web sin ejecutar en navegador; no se exportó.


## 18/09/2026 — Tres poses ofensivas nuevas por héroe y combos por golpe

Generados 18 PNG RGBA (1536×1024), tres por cada uno de los seis héroes,
en `assets/comic/attacks/`. Referencia: cómic original de cada héroe; prompts,
fuentes y destinos individuales en `docs/comic/attacks/`. Poses diferentes de
arma/escudo y efectos del color propio, con transparencia real. Se conserva
la original como cuarta pose; rotación visual por héroe sin RNG de aventura.

El recibo de `rules/card_hits.gd` incorpora `hit_index`.
`presentation/card_impacts.gd` reproduce una viñeta distinta por golpe real,
con impacto, descenso de vida y contraataque intercalados. `combat_flow.gd`
evita la viñeta introductoria adicional. Dos/tres golpes producen dos/tres
viñetas salvo interrupción por muerte; varios objetivos no duplican la viñeta
del mismo índice. Se conserva resolución y checkpoint antes de animar.

Validación local: importación Godot y `git diff --check` correctos. Prueba
renderizada Linux/llvmpipe `test_hero_cut_in.gd`: cuatro poses por héroe,
rotación sin repetición, defensa, carga, anclaje y limpieza sin fallos.
`test_counter.gd` renderizada: combos de dos/tres apariciones distintas,
vida 95/90/85, tres contraataques, bloqueo y muertes sin fallos. Se corrigió
la reconexión del observador del test al reconstruir la pantalla para el
segundo combo. `test_combat_presentation.gd` headless: 18 comprobaciones
aprobadas, incluyendo rechazo, victoria, derrota, defensa y sinergia.
Revisión visual de los 18 assets y captura del guerrero sobre la mazmorra;
transparencia RGBA comprobada. Capturas temporales eliminadas. No se exportó
APK/Web ni se probó en dispositivo físico; rendimiento de esos destinos pendiente.

## 18/09/2026 — Sincronización visual del bloqueo al terminar turno

Confirmado que `_start_turn` ya descarta el bloqueo sobrante de ambos héroes;
se mantiene el bloqueo nuevo que pueda conceder una reliquia. No se modificó
el balance ni la persistencia. `combat_flow.gd` actualiza el escudo y número
al terminar las animaciones enemigas mediante `card_impacts.update_block`,
sin esperar a reconstruir la pantalla tras las reacciones finales.
Prueba adicional de reglas: el bloqueo de ambos héroes vence también cuando
el enemigo no ataca. Validación headless local de reglas y presentación;
sin revisión visual ni exportación para este ajuste.

## 18/09/2026 — Selección correcta para ataques a todos los enemigos

Corregido `game.valid_targets`: `all_enemies` devuelve enemigos vivos en lugar
del dueño de la carta. `ui/screens/combat_screen.gd` ilumina y habilita los
objetivos enemigos para cartas individuales y de área; los héroes solo se
habilitan para efectos aliados. Tocar cualquier enemigo vivo confirma el
ataque sobre todos. No cambia el daño ni los guardados.

Validación local Linux/llvmpipe: `test_cards.gd`, 557 comprobaciones sin fallos,
incluidos clics sobre cada uno de dos enemigos, daño a ambos, halos enemigos,
héroes deshabilitados, enemigos muertos excluidos y cartas sin energía.
`test_game.gd` headless: 156 comprobaciones sin fallos. Captura de galería
generada por el test eliminada; sin revisión visual manual ni exportación Web.

## 18/09/2026 — Assets de flechas en navegación

Sustituidas las flechas Unicode de botones y del cartel Aventuras por dos
assets SVG dorados originales (`assets/ui/arrow_left.svg`, `arrow_right.svg`).
Procedencia: dibujo vectorial en código, sin IA. `button_skin.gd` concentra
iconos nativos de Button y composición del cartel; `main.gd` y pantallas de
mapa, selección, recompensa y mejora usan textos sin flechas tipográficas.
Sin cambios a navegación o guardados.

Importación y diff correctos. Validación local Linux/llvmpipe: campamento
37 comprobaciones sin fallos y revisión visual del cartel, ajustando el
centrado conjunto de texto e icono. Mapa headless: 41 comprobaciones sin
fallos. Búsqueda de flechas Unicode en src/data sin coincidencias. Sin
exportación ni prueba en navegador; requiere volver a exportar para Web.

## 18/09/2026 — Corazones en barras de vida

Nuevo asset original vectorial `assets/ui/heart.svg`, dibujado en código.
`ui/components/health_bar.gd` lo coloca a la izquierda dentro de las barras
de héroes y enemigos, con espacio reservado para evitar solapar los números.
No altera valores, animaciones ni selección de objetivos.
Importación y diff correctos. `test_hud.gd` renderizado: 108 comprobaciones
sin fallos; revisión visual de ambos bandos. Capturas temporales eliminadas.
Sin exportación ni prueba Web/dispositivo para este cambio.

## 18/09/2026 — Refugio: retratos cómic y preparación del mazo

Nuevo interior de carpa generado con imagegen (cama, equipaje, mapas y faroles),
en `assets/refuge/interior.png`, con prompt/procedencia en `docs/refuge/interior.json`.
Galería de seis retratos ampliados de los cómics existentes, sin duplicar sus
assets. Tocar un héroe abre cuatro cartas completas con cantidad de copias.

Se permite intercambiar hasta dos básicas desde el reparto original: 2–6
ataques y defensas complementarias hasta ocho, más dos cartas de clase fijas.
Guardar y restaurar original con confirmación explícita; borradores locales,
configuración gratis y persistente por héroe. Cada nueva aventura conserva
20 cartas; la run actual y sus mejoras no se modifican. Guardados anteriores
sin configuración usan el mazo original.

Módulos nuevos de reglas, navegación, pantalla y retratos descritos en la
arquitectura y `docs/refuge/README.md`; `main.gd` solo conecta acceso/regreso.
Validación local Linux/llvmpipe: test_refuge 159 comprobaciones, inspección de
galería/editor; test_game 156 y test_base_camp 33 headless, sin fallos. Importación
y diff correctos. Capturas de esta tarea eliminadas. Sin exportación ni prueba
Web/Android. Balance exhaustivo de las distribuciones queda para playtesting.

## 18/09/2026 — Alineación de 5 y 6 en números gráficos

Analizado el canal alfa de los diez assets 32×48: 5 y 6 tienen márgenes
internos diferentes. `ui/components/number_view.gd` compensa la posición
vertical según la escala efectiva para compartir la línea de base. Se aplica
a almas, costes y otros contadores sin cambiar valores ni imágenes.
Validación renderizada Linux/llvmpipe de 85260 y 1234567890 a tamaños 36/48,
revisión visual y diff correctos. Script/captura temporales eliminados;
sin exportación ni prueba Web para este ajuste.

## 18/09/2026 — Ocho sprites de carrera por héroe

Seis hojas generadas con imagegen tomando los atlas existentes como referencia
de identidad y estilo. Corrección adicional de brazos en guerrero, maga y
clériga. Fuentes y prompts en docs/running; importador reproducible de recorte,
alineación y reducción a 128 px. Seis atlas finales suman aproximadamente
804 KiB; fuentes grandes excluidas por el preset de exportación.

Nuevo helper hero_run registra y reproduce `run`. Los seis actores lo incorporan;
hero_equipment preserva el atlas independiente. La salida victoriosa usa estos
cuadros en lugar del rebote/rotación de pose fija; mantiene 2,5/2,62 s y resolución
previa al efecto. Un diseño de carrera por héroe, compartido por los niveles de
equipo: las variantes visuales de carrera por herrería quedan pendientes.

Validación local Linux/llvmpipe: test_running 181 comprobaciones y revisión
de cuadros en escenario; test_combat_presentation 18 y test_forge_assets 12450
headless, sin fallos. Importación y diff correctos. Corregido un uso inválido
de hash en la primera ejecución del test nuevo. Capturas temporales eliminadas.
Sin exportación ni pruebas Web/Android.


## 18/09/2026 — Papiros para las salas del mapa

- Retirados rótulos de sala y tipos de encuentro en tooltips.
- Nuevo asset cuadrado de papiro transparente; reemplaza los círculos y conserva
  los estados disponible/actual/pendiente.
- Flecha gráfica centrada sobre la sala actual, sin depender de la fuente.
- Cambios en map_screen.gd y test_map.gd; prompt/procedencia en docs/map.
- Validación local renderizada: 101 comprobaciones sin fallos y revisión visual.
  Capturas retiradas; sin exportar ni verificar Web/Android.


## 18/09/2026 — Reliquias desplegables y acceso lateral al mazo

- Grupo sin título «EL GRUPO» y con detalles de reliquia al tocar cada acceso,
  reutilizando el cuadro de diálogo existente.
- Mazo movido al segundo item de la barra derecha, debajo de Grupo.
- map_group_drawer.gd y test_map.gd; documentación en docs/map/README.md.
- 105 comprobaciones locales renderizadas sin fallos y revisión visual.
  Sin exportación Web/APK ni validación en dispositivo.


## 18/09/2026 — Ignorar TestWeb en Git

- `.gitignore`: exclusión completa de `/TestWeb/`.
- Retirados sus diez archivos del índice, sin borrarlos del disco.
- Documentado el despliegue manual en `docs/LIMPIEZA.md`.
- Verificados índice vacío para esa carpeta y exclusión de los archivos locales.
  Sin commit, push ni exportación.


## 18/09/2026 — Inicio y sala actual iluminados

- Halo dorado persistente con pulso suave detrás de la sala actual y, antes
  del primer encuentro, de la entrada disponible. Papiro destacado más luminoso.
- Ajuste del cierre de detalles de reliquias para usar la posición del clic.
- Documentado en docs/map; prueba renderizada local: 109 comprobaciones aprobadas.
  Revisión visual del inicio, sin exportación ni pruebas Web/Android.


## 22/09/2026 — Fondo para estados de héroes

Bloqueo y veneno sobre la vida reutilizan combat_backplate.gd: fondo oscuro
al 65 %, con esquinas suaves. status_effects.gd recibe show_backplates desde
combat_screen.gd solo para héroes. El fondo se oculta con el indicador y no
intercepta clics. Enemigos sin cambios.

Validación: test_hud.gd, 108 comprobaciones aprobadas con render Linux/llvmpipe
y revisión visual a 1280×720. Capturas retiradas. Sin exportación Web/APK.


## 22/09/2026 — Descanso junto a la fogata

- Nuevo fondo de mazmorra oscura con fogata central, seis poses sentadas con
  transparencia y barras de vida encima de los dos héroes de la aventura.
- Dos tarjetas ilustradas: recuperar 30 % de vida y mejorar una carta.
  La mejora se deshabilita si no quedan cartas elegibles.
- Pantalla extraída a rest_screen.gd; main.gd conecta sus señales a las reglas
  existentes, sin cambiar curación, guardado ni consumo del descanso.
- Nueve assets generados con image_gen integrado, fuentes/prompts en docs/rest
  y finales optimizados en assets/rest. Importador scripts/import_rest.gd.
- 37 comprobaciones de descanso aprobadas con render local y prueba headless
  de mejora sin fallos. Revisión visual de los seis héroes en tres parejas.
  Capturas retiradas, sin exportar Web/APK ni modificar guardados reales.


## 22/09/2026 — Selección de héroes sentados junto al fuego

- Reutilizadas las seis poses del descanso; orientación hacia la fogata y fila
  superior separada de los personajes inferiores.
- Nueva llama de ocho cuadros 128×128 generada con image_gen integrado. Prompts,
  fuente e importador documentados en docs/camp.
- Luz cálida animada compartida entre selección y descanso, sin deformar héroes.
- Pruebas renderizadas: selección 66 y descanso 37, sin fallos. Revisión visual
  y comparación de fotogramas. Capturas retiradas; sin exportar Web/APK.


## 22/09/2026 — Fogata diurna con atlas detallado

base_camp_screen.gd reutiliza campfire.gd y fire-128.png: ocho fotogramas a
9 FPS, chispas y resplandor, anclados en (643, 396) a escala 0,62 sobre la
fogata del fondo. No se duplican assets. El shader camp_day conserva el viento
y el agua; se retira su deformación anterior de la llama.

Validación local renderizada: test_base_camp.gd, 37 comprobaciones sin fallos
y revisión visual a 1280×720. Capturas temporales retiradas; sin exportar.


## 22/09/2026 — Tarjetas de héroes en mercado y herrería

- Galería inicial de seis tarjetas comic reutilizadas del refugio. Al elegir,
  se oculta y se presenta el bloque de compras o mejoras de ese héroe.
- Volver a héroes y Atrás restauran la galería; Campamento sale del edificio.
- Componente building_hero_picker compartido; retirado hero_category sin usos.
- Pruebas: mercado 49 y herrería 110 renderizadas; campamento 33 headless,
  sin fallos. Revisión visual local y capturas retiradas. Sin exportación.


## Puesto de expediciones e Iglesia — 22/09/2026

- Solar 4: puesto construible por 500 almas; treinta contratos, uno activo por aventura,
  tres ofertas persistentes que se renuevan sin repetir las anteriores al finalizar.
  Quince parejas, seis victorias por héroe y nueve objetivos de progreso.
- Contadores de combate/élites/guardián, combates sin bajas, cofres y mejoras de descanso;
  liquidación única junto al fin de aventura y conservación del resultado.
- Solar 2: Iglesia por 600 almas; galería de seis retratos compartida y dos especializaciones
  por héroe. Requieren victoria completa con ese héroe y compra de 450 almas. Una activa,
  intercambio gratuito, snapshot para próximas aventuras y migración de victorias retenidas.
- Veintidós assets generados: dos edificios transparentes, dos interiores, seis ilustraciones
  de contratos y doce de especializaciones. Fuentes/prompts conservados en docs; finales
  reducidos con importador Godot. No se agregaron fuentes a la exportación.
- Pantallas/controlador/reglas/datos separados; resultado final extraído de main.gd.
  Estructura y decisiones en ARQUITECTURA.md y docs/expeditions, docs/church.
- Pruebas actuales: expansión 192/192, UI 30/30 renderizada localmente; juego 156/156,
  progresión 819/819, campamento 33/33. Revisión visual 1280×720 y ajuste de posiciones,
  ilustraciones sin recortar los rostros. Capturas temporales eliminadas después de revisar.
  Sin APK/Web, emulador ni dispositivo físico. Balance pendiente de partidas reales.


## Mercado y Herrería: tarjetas a la derecha — 22/09/2026

- Galería de seis héroes en tres filas de dos tarjetas, con retratos compactos
  y encuadres individuales. Quedan visibles el mercader y el herrero.
- Se extendieron los componentes compartidos `building_hero_picker.gd` y
  `refuge_portrait.gd`; ambas pantallas activan la nueva variante.
- Pruebas renderizadas actuales: Mercado 49/49, Herrería 110/110; revisión
  visual local 1280×720. Capturas retiradas; sin APK/Web ni pruebas móviles.


## Reliquias de élite: veinte nuevos efectos y assets — 22/09/2026

- Se amplió el catálogo de aventura de 4 a 24 reliquias, conservando IDs y
  efectos anteriores. Cada élite concede una aleatoria no poseída en esa aventura.
- Veinte efectos nuevos de cartas, bloqueo inicial/por turno, curación tras
  victoria, vida máxima y robo inicial; reglas separadas en `run_relics.gd`.
- Recibo persistente `run.reward_relic`: icono, nombre y efecto a la izquierda
  de la elección de cartas. La concesión precede a la UI y sobrevive a recarga
  o salto de carta. Reliquias halladas visibles en HUD y Grupo con popover.
- Veinte iconos generados con imagegen, transparentes, finales 192×192; 833049
  bytes de PNGs. Fuentes y prompts en docs/relics; importador propio y catálogo
  en data/elite_relics.json. Arquitectura e índice actualizados.
- Validación actual: reliquias 134/134, juego 156/156, equipamiento 90/90,
  expansión 192/192, mapa 109/109 (también renderizado). Recompensa renderizada
  sin fallos; revisión visual de pantalla y veinte iconos. Importación y diff
  sin errores; capturas retiradas. Sin exportar ni validar en Web/APK/dispositivo.


## Cartas no utilizadas en cenizas al finalizar turno — 22/09/2026

- `combat_flow.gd` reutiliza la animación de cartas jugadas sobre toda la mano
  saliente al terminar el turno. Captura los índices antes del descarte y robo;
  la acción se resuelve y guarda antes de presentar los efectos.
- La mano siguiente aparece tras terminar las animaciones. Se conserva el
  bloqueo de entrada durante la secuencia y se admite una mano vacía.
- Presentación de combate: 25/25 comprobaciones con render local y revisión
  visual de las cenizas de seis cartas. `git diff --check` sin errores.
  Capturas temporales retiradas; sin exportación ni pruebas móviles/web.

## Pisos aleatorios y bosque — 22/09/2026

- Aventuras nuevas con cripta y El Bosque de las Raíces, 28 salas por piso.
  Se conserva la cantidad de cada tipo, variando conexiones, tipos, posiciones
  y encuentros según el RNG guardado. Primer élite opcional y segundo obligatorio.
- Más combates dobles y triples, con triples en tramos tardíos. Siete enemigos
  forestales activos: tres goblins comunes, lobo, jabalí, oso élite y jefe goblin.
  Ajuste de posiciones y HUD para tres enemigos dentro de 1280×720.
- 17 assets: dos escenarios de batalla, descanso forestal, siete atlas de ocho
  poses y siete ataques transparentes en primer plano de derecha a izquierda.
  Fuentes/prompts/importador en `docs/forest/` y `scripts/import_forest.gd`.
- Separación: `rules/dungeon_generator.gd` construye el grafo;
  `rules/dungeon_progression.gd` cambia de piso; `game.gd` confirma y guarda.
  Catálogos `data/dungeons.json` y `data/forest_enemies.json`. Sin migrar ni
  regenerar mapas antiguos; conservan su final de un piso. Contratos y victoria
  de especialización se liquidan al final del bosque para aventuras nuevas.
- Pruebas locales sin fallos: generación/transición 20.414 (200 mapas), interfaz
  forestal 36 renderizadas, enemigos 631, reglas generales 142, mazmorra 66,
  tesoros 22, mapa 109 renderizadas, tesoro UI 8, reliquias 134, campamento 192
  y equipo 90. Importación y `git diff --check` correctos.
- Revisión visual local de mapa, grupos de tres, ataques transparentes y descanso.
  Capturas temporales retiradas. No se exportó Web/APK ni se probó en dispositivo.
- Pendiente: balance con partidas humanas. Bot simple: 15 victorias en 45
  aventuras; no compra ni incorpora premios. Se adapta su prueba anterior de
  victorias mínimas por pareja al nuevo recorrido de dos pisos, manteniendo
  la comprobación de terminación. Detalle en `docs/forest/README.md`.

## 24 cartas de apoyo y debilitamiento — 22/09/2026

- Cuatro cartas por héroe, catálogo total 114 y mercado con 60 cartas (10 por
  héroe). Precios nuevos de 160–240 almas. Compra permanente que habilita
  recompensas; no altera mazos iniciales, cartas anteriores ni guardados existentes.
- Fuerza temporal +25% de daño, debilidad -25% al ataque normal de la próxima
  acción y fractura -25% al bloqueo actual y a su siguiente ganancia. No se
  acumulan; porcentajes mejorados del 35%. Contraataque conserva cuatro por golpe.
- Nuevas opciones de curación para guerrero, guardiana, maga y explorador, además
  de clériga. Se respetan objetivos vivos y límite de vida máxima.
- `data/support_cards.json`, `rules/combat_modifiers.gd` y componente visual
  `combat_modifier_badges.gd` separan catálogo, reglas y presentación. Estados
  opcionales guardados durante combate; intenciones enemigas muestran los valores
  efectivos. Pastillas con símbolos de fuerza, debilidad y fractura.
- 24 ilustraciones únicas generadas con imagegen integrado, finales de 512 px en
  `assets/cards/art/`. Fuentes, prompts y procedencia en `docs/cards/support/`;
  importador `scripts/import_support_cards.gd`. Galería HTML local y catálogo
  de precios/efectos. Ningún arte anterior reemplazado.
- Ajustes de títulos largos y texto en las cartas nuevas, verificados en cuatro
  tamaños, normales/mejoradas. Se mantiene el espacio original de la ilustración.
- Pruebas locales sin fallos: apoyo 1.922, UI de apoyo 609 renderizadas (incluye
  clic real en indicador), arte 715, progresión 989, mercado UI 49, cartas UI 701,
  reglas generales 142, enlaces 481, reliquias 134 y equipo 90.
- Revisión visual Linux/llvmpipe 1280×720: las seis galerías, mano de combate,
  explicación de estados y mercado. Capturas temporales retiradas. Importación y
  `git diff --check` correctos. No se exportó Web/APK ni se probó en móvil.
- Pendiente: balance mediante partidas humanas; las pruebas técnicas no lo certifican.

## Más variedad de enemigos en la primera mazmorra — 22/09/2026

- Incorporados desde los conceptos existentes cuatro esqueletos (guerrero,
  arquero, escudero y berserker) y dos elementales (roca y sombra). La cripta
  pasa de cuatro a diez tipos comunes, conservando su élite y guardián.
- Grupos comunes de dos y tres con tipos distintos; escudero desde etapa 2,
  berserker desde 4 y elementales desde 5. No se cambia el recorrido guardado:
  la variedad aparece al generar una aventura nueva. Bosque sin cambios.
- Seis atlas nuevos de ocho poses (cuatro de reposo y cuatro de ataque),
  compatibles con daño y muerte en cenizas existentes; seis ilustraciones
  transparentes para ataques en primer plano de derecha a izquierda.
- Assets generados con imagegen integrado a partir de los diseños existentes.
  Se corrigió el espaciado de las fuentes para evitar armas que invadieran
  cuadros vecinos. Prompts, fuentes y procedencia en
  `docs/enemies/crypt_expansion/`; finales en `assets/enemies/animations/` y
  `assets/comic/enemies/`.
- Reglas en `data/crypt_enemies.json`, configuración progresiva en
  `data/dungeons.json` y registro visual compartido. Se extrajo
  `scripts/enemy_art_import.gd` para ambos importadores de enemigos; comparación
  de píxeles contra un atlas previo del bosque correcta. Arquitectura actualizada.
- Pruebas locales sin fallos: variedad de cripta 5.161, enemigos 745, generación
  de mazmorras 20.414, reglas generales 142 y mazmorra 66. Importación y
  `git diff --check` correctos.
- Revisión renderizada Linux/llvmpipe a 1280×720 de poses, seis ataques en
  primer plano y grupo mixto de tres. Capturas temporales retiradas. No se
  exportó Web/APK ni se probó en dispositivo físico. Balance humano pendiente;
  el bot simple terminó 45 aventuras con 19 victorias, sin certificar balance.

## Más variedad en la segunda mazmorra — 22/09/2026

- Se añaden goblins lancero, bombardero, saqueador y jinete; murciélago gigante
  y cuervo carroñero. Bosque con once tipos comunes, oso élite y Gorvak; total
  de 25 enemigos activos entre ambos pisos.
- Grupos comunes de tipos distintos usando la configuración del generador
  existente. Bombardero desde etapa 2 y jinete desde etapa 4. Mapas ya guardados
  intactos; nuevos bosques, incluidos los generados al descender desde una
  cripta en curso, reciben esta variedad.
- Seis atlas con cuatro poses de reposo y cuatro de ataque, y seis ataques
  transparentes en primer plano desde la derecha hacia la izquierda. Conservan
  el diseño de los sprites existentes. Se corrigió espaciado de cuatro fuentes
  para evitar que lanzas o alas invadieran otras celdas.
- Arte generado con imagegen integrado. Fuentes, prompts y procedencia en
  `docs/forest/expansion/`. Importador `import_forest_expansion.gd` reutiliza el
  empaquetador compartido. Datos en `forest_enemies.json` y `dungeons.json`;
  presentación en los registros existentes, sin nuevas responsabilidades en main.
- Pruebas locales sin fallos: mapas/bosque 24.615, reglas generales 142, enemigos
  859 (headless), interfaz del bosque 146 (renderizada Linux/llvmpipe 1280×720).
  Importación y `git diff --check` correctos. Revisadas las seis hojas, los seis
  ataques en primer plano y un grupo mixto de jinete/murciélago/cuervo.
- Capturas temporales retiradas. No se exportó Web/APK ni se probó en móvil.
  Balance humano pendiente: el bot simple completó 45 simulaciones, 17 victorias;
  no incorpora premios y no certifica equilibrio.

## Secuencia de descarte y acciones enemigas — 22/09/2026

- Al terminar turno, se espera a que desaparezcan todas las cartas en cenizas
  antes de reproducir reacciones y acciones enemigas. Las cartas jugadas
  individualmente conservan su presentación anterior.
- Cada enemigo muestra primero su bloqueo activo, con una pausa de 0,30 s si
  gana bloqueo, y luego ataca. Defensa sola no dispara animación de ataque.
- Recibo transitorio `resolved_enemy_blocks` en `game.gd` registra únicamente
  acciones ejecutadas. Indicador oculto a cero en `status_effects.gd` permite
  mostrar ganancias sin reconstruir la escena. Guardado previo a animaciones
  y cálculo de combate intactos; sin cambios al formato de partidas.
- Prueba renderizada local `test_turn_sequence.gd`: 98 comprobaciones sin fallos
  (incluye observaciones por cuadro). Reglas generales 142 sin fallos y
  contraataques sin fallos. `git diff --check` correcto. No se exportó Web/APK
  ni se probó en dispositivo físico. Documentación en `docs/hud/README.md`.

## Terminar aventura desde pausa — 22/09/2026

- Opción «Terminar aventura» durante una run activa, con confirmación y retorno
  directo al campamento. Cancelar conserva la partida; ir al inicio permite
  continuar como antes.
- Cierre sin victoria reutilizado mediante `game.end_adventure()`: liquidación
  del contrato según progreso, tres ofertas nuevas, selección liberada y guardado.
  Conserva almas/mejoras permanentes y evita repetir la liquidación.
- Navegación separada en `ui/pause_navigation.gd`, sin ampliar main con diálogos.
- Prueba local renderizada `test_end_adventure.gd` sin fallos: botones reales,
  cancelación, cierre, retorno, persistencia, ofertas distintas, nueva selección
  e idempotencia. Regresión `test_camp_expansion.gd` sin fallos. No se exportó
  Web/APK ni se validó en dispositivo físico.

## Ataques de héroes con cuadros dibujados — 22/09/2026

- 24 hojas transparentes: cuatro variantes por héroe y cuatro cuadros por ataque
  (96 dibujos). Espadas, escudos, dagas, arco y poderes cambian de pose.
- Reproducción de 0,72 s por secuencia; primer plano inferior izquierdo sobre
  el nivel, con rotación entre golpes y sin modificar resolución o guardado.
- Atlas opcional en `comic_cut_in.gd`, selección en `hero_cut_in.gd` e importador
  con recorte común para conservar posiciones relativas. Prompts, referencias,
  fuentes y correcciones de separación en `docs/comic/motion/`.
- Revisión de las 24 hojas y capturas renderizadas de los seis héroes sobre
  la mazmorra: transparencia y colocación comprobadas. Capturas temporales
  eliminadas; se conservan fuentes y assets finales.
- Validación local: importación sin errores; movimiento 1421 comprobaciones
  sin fallos; viñetas de héroes, enemigos y contraataques sin fallos; presentación
  de combate 25 comprobaciones sin fallos. Se actualizó la espera de una prueba
  antigua de ataque enemigo al orden vigente (primero cenizas de la mano).
- `git diff --check` correcto. Sin exportación Web/APK ni prueba física.

## Flecha de Volver junto al texto — 22/09/2026

- Ajuste compartido en `ui/components/button_skin.gd`: flecha de «Volver»
  junto a la palabra, con separación de 8 px, en lugar del borde izquierdo.
- Verificación visual local del menú a 1280×720 y ejecución sin errores;
  `git diff --check` correcto. Captura temporal retirada, sin exportar Web/APK.

## Elegir mazmorra al iniciar para pruebas — 22/09/2026

- Selector Cripta/Bosque tras elegir reliquia, con aviso de retirada y Volver.
  No altera la aventura hasta confirmar. Interfaz temporal separada.
- Inicio con héroes, reliquia y mazo iniciales; guardado compatible.
- `test_development_start.gd` sin fallos: botones, cancelación, ambos destinos,
  entrada al bosque, estado inicial, guardado y piso inválido.
  `test_forest.gd`: 24615 comprobaciones sin fallos. Revisión visual local
  del diálogo y diff correcto. Sin exportar Web/APK ni validar en móvil.
