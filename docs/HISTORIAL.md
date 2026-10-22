# Historial vigente

Esta página registra el mantenimiento de la documentación y sistemas actuales.
Los registros extensos de diseños reemplazados se consultan en Git; no se
mantienen como manuales alternativos dentro de `docs/`.

## 22/10/2026 — Anuncio de victoria sobre la batalla

VICTORIA y K.O. superpuestos en el centro, con letras de pincel inspiradas en el
título inicial, colores distintos y flotación suave. Aparece tras el último impacto
y antes de las recompensas; fuentes y prompts conservados. Revisión visual nativa
y comprobaciones locales correctas; pruebas temporales retiradas.

## 22/10/2026 — Ataques enemigos más legibles

Primer plano de ataque de 0,72 a 0,92 s y pausa de 0,18 s tras cada impacto.
Mayor duración también sin primeros planos; conserva la velocidad configurable.
Comprobación nativa de tiempos y pruebas locales de secuencia y primeros planos
correctas; pruebas temporales retiradas.

## 21/10/2026 — Robots destruidos permanecen en batalla

56 dibujos propios de máquinas desarmadas, con cables y piezas rotas sobre el suelo
y chispazos intermitentes. Escala estable al reconstruir la vista y restauración al
revivir. Fuentes y prompts conservados; revisión visual nativa, 520 controles
temporales y 105 suites locales correctas, sin exportar APK.

## 21/10/2026 — Campamento sin dibujos de solares

Edificios sin construir muestran solo el fondo y conservan la zona clickeable de
construcción. Retirado el bloque informativo inferior del laboratorio. Revisión
visual nativa y 375 controles locales correctos; pruebas temporales retiradas.

## 21/10/2026 — Pantalla completa en celular

Lienzo ajustado al ancho y alto disponibles y Android de borde a borde, manteniendo
el modo inmersivo. Revisión nativa en cuatro formatos y 140 controles locales
correctos; sin exportar APK ni validar en dispositivo físico.

## 20/10/2026 — Robots que desprenden piezas al recibir daño

Chapas, tornillos y cables saltan, rebotan y permanecen junto al robot durante el
combate, incluso al consultar mazo/bolsa. Acumulación acotada y modo de efectos
reducidos; sin alterar los cuerpos estáticos ni las reglas de daño. Revisión visual
nativa y 105 suites locales correctas; pruebas temporales retiradas.

## 20/10/2026 — Condiciones tras la primera victoria

Interferida y Peligrosa requieren ganar con Sin condición. Bloqueo en interfaz y
reglas; desbloqueo permanente con reconocimiento de victorias anteriores, sin
alterar aventuras activas. Revisión visual local y 105 suites correctas.

## 20/10/2026 — Héroes más grandes en la selección

Ilustraciones sentadas ampliadas aproximadamente un 16 %, con el mismo apoyo y
rótulos; áreas de selección adaptadas. Revisión visual local y 139 controles correctos.

## 20/10/2026 — Encuentros como viñetas de cómic

Globos integrados al escenario, opciones de papel con iconos propios y resultado
visible tras confirmar el guardado. Entradas y foco animados, efectos anclados al
arte vigente y modo de efectos reducidos. Fuentes SVG y procedencia conservadas.
105 suites locales correctas y revisión visual de 18 encuentros; sin prueba web/celular.

## 20/10/2026 — Tres entradas y más rutas en el mapa

La aventura abre el mapa con tres batallas iniciales y conexiones distintas;
35 salas por mazmorra. Menú elevado y bloque inferior eliminado. Los guardados
anteriores conservan sus rutas. Revisión visual nativa, generación en 150 mapas y
105 suites locales correctas; algunas pruebas avisan recursos retenidos al cerrar.

## 20/10/2026 — Documentación y pruebas mínimas

Preferencia guardada en `AGENTS.md`: resúmenes cortos tipo commit, arquitectura
breve solo cuando cambie y eliminación de las pruebas nuevas tras pasar.

## 20/10/2026 — Globos de cómic en edificios

Asset SVG blanco con tinta negra y texto oscuro; diálogos arriba a la derecha del
encargado, adaptados a galería/detalle. Fuente y procedencia conservadas. Revisión
visual de cuatro edificios y 171 comprobaciones locales correctas; avisos al cierre.

## 20/10/2026 — Aviso de expediciones legible

Estado del contrato dentro de un panel con fondo y marco; aventura en curso
identificada con icono de advertencia. Revisión visual nativa y 33 pruebas sin fallos.

## 20/10/2026 — Bloque informativo del refugio

Botón de vínculos centrado junto a sus textos en un panel oscuro con marco.
Revisión visual nativa y 109 comprobaciones sin fallos; sin prueba en celular.

## 20/10/2026 — Instrucción de selección centrada

Instrucción y contador de héroes reunidos en un marco superior centrado con el
asset compartido del juego. Revisión visual nativa y 24 comprobaciones sin fallos.

## 20/10/2026 — Cabecera uniforme del mercado

Mercado integrado en la cabecera compartida de edificios: mismo marco, altura,
título y contador de celdas. Verificación local 43/0 headless y nativa; revisión
visual correcta. Sin prueba en celular; avisos de retención al cierre conservados.

## 20/10/2026 — Mapa vertical desplazable

- `map_screen.gd` conserva el fondo y reemplaza la presentación comprimida en
  espiral por `MapScroll/Route`, un lienzo vertical de unas cuatro pantallas.
  Salas de 72 px, jefe de 88 px arriba de todo y separación de 156 px por etapa.
  Caminos curvos de mayor contraste, disponibles en cian y recorridos diferenciados.
- `vertical_map_layout.gd` obtiene profundidad y carriles del grafo existente;
  admite guardados anteriores sin etapa o coordenadas. Solo calcula presentación:
  no altera contenido, conexiones, encuentros, guardados ni RNG de la aventura.
- Al abrir, enfoca la posición del grupo; los dos retratos acompañan la sala
  actual. Desplazamiento vertical con rueda/barra del contenedor, recorte del
  contenido y cabecera/estado/menú lateral fijos. Se conserva elección de salas,
  grupo, mazo, regreso a caminos y transición tras vencer al jefe.
- Validación posterior: **105/105 suites headless aprobadas**. Mapa vertical
  24813/0 headless y nativo aislado (30 mazmorras, orden ascendente, separación,
  jefe superior, guardados antiguos, rueda real, foco y conservación de estado).
  Interacción del mapa 141/0 headless y nativo: selección, panel lateral, mazo,
  objetivos deshabilitados y transiciones. Contenido 2793/0 y repositorio sin
  errores; diff y enlaces documentales correctos.
- Revisadas capturas inferior, intermedia, superior y sala actual con X11/Mesa
  llvmpipe, audio Dummy. Prueba nativa de interacción avisa 8 objetos/2 recursos
  retenidos al cerrar. No se declara ausencia general de fugas ni validación en
  navegador, pantalla táctil/dispositivo físico o exportación APK.
  Evidencia en `artifacts/vertical_map/` y `artifacts/map/`.

## 20/10/2026 — Retirada de proyectos y mascotas de aventura

- Eliminados el edificio/entrada de proyectos, su pantalla y reglas. Retirados
  reservas/descuentos del mercado, renovación de provisiones y reconocimiento
  pagado de salas, incluidos sus controles y transacciones. Las compras normales,
  expediciones, reserva de cartas en combate y demás edificios se conservan.
- Eliminados selector, resumen y entrada de HUD de mascotas, catálogo y pasivas;
  `new_run` vuelve a recibir únicamente pareja, semilla, equipo y piso inicial.
  El perro y el gato de `camp_companions.gd` conservan íntegros sus assets y
  animaciones ambientales. No se retocó el balance de dificultad.
- `content_migration.gd` elimina campos retirados del perfil/aventura, persiste
  también limpiezas exclusivas del run y no reinicia una aventura válida. Conserva
  moneda, equipo, cartas, vida, mano y RNG del combate actual; los turnos y combates
  siguientes ya no conceden pasivas de mascotas.
- Retirados dos assets activos de proyectos, sus imports y sus fuentes/jobs
  exclusivos de ambas generaciones; colas, manifiesto, índice de bordes y política
  de retirada actualizados. Se conservaron fuentes compartidas y animales del
  campamento. Eliminadas pruebas exclusivas de funciones retiradas y adaptadas
  regresiones vigentes; nueva prueba de compatibilidad y ausencia de controles.
- Validación final local: **104/104 suites headless aprobadas**; retirada y guardados
  24/0 headless y nativo aislado, animales ambientales 54/0. Revisión de capturas
  de campamento, selección, componentes y combate con X11/Mesa llvmpipe y audio
  Dummy. Contenido 2793/0, 360 cuerpos estáticos válidos, 112 primeros planos
  enemigos válidos y 950 recursos visuales con procedencia vigente. Repositorio,
  enlaces documentales y diff sin errores. Evidencia en
  `artifacts/retired_projects_pets/`, regresión final en `regressions_final/`.
- 47 suites registran avisos de retención al cierre; prueba nativa de retirada
  20 objetos/5 recursos. No se declara ausencia general de fugas. Sin navegador,
  dispositivo físico, escucha ni exportación APK.

## 19/10/2026 — Orientación y distribución del campamento

- Mercado y taller reflejados horizontalmente mediante `TextureRect.flip_h` en
  `base_camp_screen.gd`, mirando hacia el centro. `building_hotspot.gd` refleja
  también el muestreo de su máscara alfa para mantener accesos precisos.
- Intercambiados laboratorio y proyectos: proyectos arriba a la derecha y
  laboratorio abajo a la derecha, incluido su solar sin construir. Rótulos arriba
  de ambos edificios para evitar superposición. Se conservan IDs, construcción,
  funciones, guardados y assets originales; no se modificó la dificultad.
- Validación posterior: suelo/accesos 326/0 headless y nativo aislado; expansión
  del campamento 33/0 headless. Revisadas capturas de solares y campamento
  construido con X11/Mesa llvmpipe. Repositorio sin errores y diff sin espacios
  inválidos. Evidencia en `artifacts/camp_rearrange/` y `artifacts/camp_dusk/`.
- El cierre headless de suelo/accesos avisa 22 objetos/5 recursos retenidos;
  no se declara ausencia general de fugas. Sin navegador, dispositivo físico ni
  exportación; no se repitió la batería completa para este cambio visual.

## 19/10/2026 — Rivales con tarjetas y héroes del entrenamiento

- Reemplazados los tres desplegables de rivales por botones en
  `training_config_dialog.gd`. Cada botón abre `training_enemy_picker.gd`, una
  galería desplazable con nombre y PNG estático del enemigo descubierto.
- Elegir una tarjeta regresa al borrador y conserva daño, bloqueo y opciones.
  Volver desde la galería cancela esa elección; cada espacio se puede vaciar.
  Aplicar mantiene el contrato existente y sin rivales sigue disponible el maniquí.
- `training_screen.gd` reutiliza las tarjetas grandes de los edificios, dos por
  fila, conservando la selección máxima de dos héroes y el botón Entrenar.
  Se reutilizan assets existentes; no cambian reglas, descubrimientos ni guardados.
- Prueba nueva 25/0 headless y nativo aislado: imágenes, enemigos descubiertos,
  borrador, cancelación, limpieza de espacio, Aplicar, perfil y pareja de héroes.
  Regresiones locales: profundidad de combate 48/0 y pulido de interfaz 13/0.
  Contenido 2794/0 y repositorio sin errores; capturas de héroes, galería y
  configuración revisadas en `artifacts/training_picker/`.
- X11/Mesa llvmpipe, audio Dummy; sin navegador, dispositivo físico ni exportación.
  Al cierre headless del selector se registran 46 objetos/7 recursos retenidos y
  en profundidad 26/5; no se declara ausencia de fugas. No se repitió toda la suite.

## 19/10/2026 — Taller centrado en equipo y regreso cuadrado

- `forge_screen.gd` reemplaza la figura del héroe en el detalle por dos paneles
  de arma/armadura con los assets HD existentes de `assets/forge/badges/`.
  Presenta nivel actual, beneficio actual/siguiente y coste o estado máximo.
- Fundición trasladada al detalle del héroe, debajo del equipo y a la derecha:
  `forge_material_display.gd` recibe su rectángulo de colocación. La galería no
  muestra fundición y el diálogo del herrero queda libre en ambas vistas.
  Se conservan receta, depósito compartido, precios, niveles y transacciones.
- `header_back_button.gd` usa tamaño fijo cuadrado de 44×44 en (24,20), icono
  de 24 px, marco compartido y márgenes simétricos propios para todos los estados.
  Se conserva la navegación y la restricción de no retroceder fases confirmadas.
- Validación posterior a estos cambios: taller 124/0 y regreso 252/0, headless y
  nativo aislado X11/Mesa llvmpipe. Revisadas capturas del detalle, galería y
  configuración. Contenido 2794/0, repositorio sin errores y diff sin espacios
  inválidos. No se repitió la regresión completa de 104 suites para estos cambios.
- El cierre nativo del taller avisa 8 objetos/2 recursos retenidos; regreso
  16/4. Sin validación web, dispositivo físico, escucha ni exportación APK.
  Evidencia en `artifacts/forge/review_*`, `artifacts/forge/detail-*` y
  `artifacts/header_back/`.

## 19/10/2026 — Primeros planos enemigos propios de ataque y defensa

- Revisados los 56 primeros planos anteriores: algunos incluían supervivientes
  ajenos, fragmentos de otros personajes o máquinas distintas; todas las defensas
  reutilizaban el ataque. Sustituidos por 112 PNG individuales de 768×512, dos por
  máquina, cubriendo las 57 definiciones de enemigos. Solo aparece la máquina;
  estética cómic, alfa real y contorno claro, sin animación corporal.
- `data/enemy_visuals.json.foreground` declara ambas acciones. El selector de
  `enemy_cut_in.gd` rechaza identidades/acciones desconocidas sin fallback antiguo.
  Se conservan duración, luces, partículas y encuadre inferior derecho.
- Fuentes, prompts exactos de ImageGen, referencias de reposo y aprobación manual
  en `art_sources/enemy_cutins_2026_10_19/`. Importación geométrica reproducible,
  manifiesto de procedencia y borde pintado actualizados. Retirados los 56 PNG
  antiguos y sus imports; regeneradores respetan la política de retirada.
- Añadidas auditoría `audit_enemy_cutins.py` y prueba de 112 recursos/57 enemigos;
  adaptados validadores de contenido, consumidores visuales y formaciones.
- Durante la regresión se corrigió la recuperación de contraataques que recibía
  una referencia de primer plano ya liberada. Separación de efectos bajo vida
  aumentada de 4 a 8 px para evitar invadir el escudo activo, conservando su centro.
  No cambian reglas, recompensas, IDs ni guardados.
- Validación final local: 104/104 suites headless; primeros planos 1350/0
  headless y nativo aislado; efectos 1029/0 en ambos. Revisión manual de 14 láminas
  (112 dibujos contra sus modelos), ocho capturas de batalla y dos vistas de
  estados apilados. Contenido 2794/0, diez pruebas Python correctas, 360 cuerpos
  estáticos válidos, 952 recursos con procedencia y repositorio sin rutas rotas.
- X11/Mesa llvmpipe y audio Dummy; sin navegador, emulador, dispositivo físico ni
  exportación. La regresión final registra avisos de retención en 44 suites; no se
  declara ausencia de fugas. Evidencia en `artifacts/enemy_cutins_review/`.

## 19/10/2026 — Acciones de héroes con calidad equivalente al reposo

- Sustituidas veinte ilustraciones de ataque, defensa, habilidad, daño y derrota
  por dibujos HD nuevos de Bruno, Mara, Ciro y Alma. Estética cómic, herramientas
  y ropa civiles, alfa real y recorte claro; cuatro reposos actuales conservados.
- Cuatro fuentes originales de ImageGen, prompts, referencias y geometría en
  `art_sources/hero_actions_hd_2026_10_19/`. Extracción por silueta conectada,
  reducción común por personaje, sin ampliación de bancos antiguos ni nuevos
  reproductores. PNG individuales de 512×512 y pies sobre el mismo suelo.
- Actualizados catálogo estático, extracción, procedencia y borde pintado;
  regeneradores preservan los nuevos recursos y el índice. No se alteran reglas,
  IDs/UIDs, guardados ni duración/sincronización de acciones y primeros planos.
- Nueva prueba `test_hero_actions_hd.gd`: detalle nativo, transparencia, poses,
  anclaje, ausencia de animación corporal y conservación de estado/RNG.
- Validación local: calidad HD 152/0 headless y 152/0 nativo aislado; ocho
  capturas de ataque/defensa revisadas con X11/Mesa llvmpipe. Actores estáticos
  1626/0, sincronización 93/0, corte de impacto 21/0 y flujo de tres mazmorras
  48/0 headless. Contenido 2568/0, 360 PNG válidos y procedencia de 896 recursos
  vigente. Fuentes, referencias de reposo y enlaces sin errores.
- Avisos al cierre: HD, sincronización y flujo headless 4 objetos/1 recurso cada
  uno; impacto 12/3. La revisión nativa finalizó sin esos avisos; no se infiere
  ausencia general de fugas ni rendimiento web. Evidencia en
  `artifacts/hero_actions_hd/`. Sin exportación, navegador o dispositivo físico.

## 19/10/2026 — Icono de mazo compartido entre batalla y mapa

- `combat_hud.gd` reutiliza `assets/map/sidebar/deck.png` en el botón de mazo
  de la cabecera. Mantiene tamaño, posición, explicación y apertura de la vista.
- Validación local: HUD 112/0 headless, referencias sin errores y comprobación
  de que mapa/batalla comparten el mismo PNG. Evidencia en `artifacts/deck_icon/`.
  Sin nueva revisión visual, exportación o prueba web/dispositivo.

## 19/10/2026 — Corte de luz y chispas al golpear máquinas

- Añadido `presentation/hit_slash.gd`, superposición de cómic de 0,42 s sobre la
  silueta del enemigo. Corte diagonal con núcleo claro y chispas; acento azul al
  bloquear, cálido al recibir daño. Dirección alternada por golpe y destino propio
  para ataques de área. Las cifras permanecen por encima.
- Integración en `impact_feedback.gd`, sin animar el cuerpo ni recalcular daño,
  modificar guardados o consumir RNG de aventura. Un nodo de dibujo por impacto,
  sin nuevas texturas, partículas GPU ni generación de imágenes. Efectos reducidos
  usa la mitad de chispas; destellos en cero desactiva la luz.
- Nueva prueba `test_hit_slash.gd`: posición, capas, vida útil, bloqueo, área,
  preferencias, cuerpo estático y conservación de estado/RNG.
- Validación local: impacto 21/0 headless y 21/0 nativo aislado, capturas de
  daño/bloqueo revisadas bajo X11/Mesa llvmpipe; posición de cifras 68/0 y
  sincronización de héroes 93/0 headless. Referencias y contenido 2568/0.
  Las suites registran avisos al cerrar: impacto final 12 objetos/3 recursos,
  cifras 26/6 y sincronización 4/1; no se declara ausencia de fugas. Evidencia
  en `artifacts/hit_slash/`. Importación local sin errores. Sin exportación,
  prueba web, emulador o dispositivo físico.

## 19/10/2026 — Poses de héroes sincronizadas con su primer plano

- Ataque y defensa conservan su PNG durante la vida real del primer plano y
  restauran reposo al finalizar; también liberan la pose si el efecto se retira.
  Los golpes múltiples y de área conservan orden y sincronización por golpe.
- Retirada la guardia adicional posterior al primer plano del héroe que ya realizó
  la acción. Las reacciones de otros receptores de bloqueo se conservan.
- Ajustados `hero_attack_playback.gd`, `card_impacts.gd` y `combat_flow.gd`;
  resolución, checkpoint, preferencias de velocidad y guardados conservados.
- Nueva regresión `test_hero_pose_sync.gd` para los cuatro héroes, ataque, defensa,
  carta mixta, varios golpes, área, velocidad doble, primeros planos desactivados,
  retiro temprano y protección contra callbacks de acciones anteriores.
- Validación local headless: sincronización 93/0, flujo estático 48/0 y
  presentación de combate 46/0; contenido 2568/0 y referencias sin errores.
  Sincronización y presentación registran al cerrar cuatro objetos y un recurso
  retenidos; no se declara ausencia de fugas. Evidencia en `artifacts/hero_pose_sync/`.
  Sin nueva revisión nativa, exportación, navegador, emulador o dispositivo físico.

## 19/10/2026 — Escudo de bloqueo activo ampliado

- Indicador de batalla ampliado de 26 a 32 px para héroes y enemigos. Silueta
  oscura más ancha, borde claro conservado y cifra centrada dentro del cuerpo.
  Posición ajustada para no invadir la tira de estados; snapshot de disolución
  conserva el mismo dibujo y alineación. Generadores SVG y procedencia actualizados.
- Validación: HUD 112/0 headless y disolución 5/0; referencias sin errores y
  procedencia vigente de 896 recursos. Revisión visual local del bloqueo de dos
  cifras. Recorrido nativo: 113/0 antes de quedar bloqueado al cerrar; proceso
  aislado interrumpido, sin declarar salida nativa correcta. Logs y capturas en
  `artifacts/block_size/` y `artifacts/hud/`. Sin exportaciones ni prueba web.

## 19/10/2026 — Documentación centrada en el proyecto actual

- Sustituido el índice acumulativo por guías de juego, combate, campamento,
  interfaz, narrativa, arte, audio, arquitectura, recursos y validación.
  Los 142 documentos anteriores se consolidan en 12 guías. Se retiran o reemplazan
  920 archivos anteriores y se trasladan 2299 archivos útiles de producción;
  aproximadamente 99 MB descartados, sin contar el material trasladado como liberado.
- Retirados documentos de esqueletos, reposos animados, carreras, estilos anteriores,
  migraciones completadas e informes históricos de limpieza/pruebas.
- Separadas fuentes, prompts, licencias y procedencia útiles en `art_sources/`;
  referencias de importadores y auditores actualizadas. Los originales y los
  assets finales conservan sus bytes. Guardados e IDs de juego sin cambios.
- Informes nuevos dirigidos a `artifacts/`. La política de recursos retirados tiene
  su archivo propio y ya no depende de una limpieza fechada. Presets actualizados
  para excluir la nueva carpeta de producción, sin ejecutar una exportación.
- Validación de esta reorganización: enlaces locales y rutas documentadas correctos;
  auditoría de referencias sin errores; contenido 2568/0, dibujos estáticos 360/0,
  cartas 96 recursos/88 ilustraciones únicas sin errores. Procedencia visual de
  896 recursos vigente, incluidos 1256 hashes de fuentes/antecedentes y 11 enlaces
  de generación. Sintaxis de 27 herramientas Python y 19 GDScript sin errores.
- Godot headless con datos temporales: actores estáticos 1626/0, flujo de combate
  48/0 y acceso a fuentes/política de retiradas 4/0. Sin avisos de retención en
  estas tres ejecuciones; no constituye una auditoría general de memoria.
  Evidencia en `artifacts/docs_cleanup/`. Sin nueva regresión completa, revisión
  visual, escucha, exportación, navegador, emulador ni dispositivo físico.

## Criterio para próximas entradas

Registrar fecha, comportamiento afectado, archivos relevantes y pruebas realmente
realizadas. Actualizar la guía correspondiente para que describa el estado final;
no añadir a ella una cronología de implementaciones ya sustituidas. Diferenciar
siempre headless, revisión visual, escucha, navegador y dispositivo físico.
