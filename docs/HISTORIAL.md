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
