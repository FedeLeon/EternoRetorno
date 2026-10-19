# Historial vigente

Esta página registra el mantenimiento de la documentación y sistemas actuales.
Los registros extensos de diseños reemplazados se consultan en Git; no se
mantienen como manuales alternativos dentro de `docs/`.

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
