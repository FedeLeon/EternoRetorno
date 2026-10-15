# Revisión completa y limpieza — 14/10/2026

Se revisan las rutas de presentación, reglas y datos de las vistas del juego;
se ejecutan regresiones de combates, las tres mazmorras, edificios, logros,
encuentros, cofres, inventario, mazos, mejora de cartas, contratos, especializaciones,
cinemáticas y guardados. Las pruebas automatizadas no equivalen a una partida
humana completa ni certifican el navegador o un dispositivo móvil.

## Correcciones verificables

- **Ataques preparados:** el enemigo conserva su estado previo al golpe mientras
  actúa. Después se reproduce el ataque preparado y recién entonces se disuelve
  si murió. La presentación reutiliza resultados ya guardados, sin resolver daño
  otra vez. El relé de reactivación del jefe puede revivirlo tras ese golpe, con
  recibo de reactivación en la misma secuencia; no se convierte en cenizas vivo.
- **Varias cartas preparadas:** recibos con `action_index` transitorio distinguen
  acciones aunque repitan héroe/índice de golpe. Cada carta muestra su primer plano.
- **Contraataques:** incluyen daño absorbido, PV perdidos y bloqueo restante por
  impacto, y reutilizan la presentación normal de impacto/defensa/caída. El daño
  base sigue siendo 4; armadura y bloqueo siguen las reglas existentes.
- **Reconocimiento:** tras pagar 20 celdas permanece en la vista de mapa que el
  jugador estaba consultando; no lo devuelve automáticamente a Caminos. Sin
  avanzar de sala, vuelve a deshabilitarse al reconocer todas las opciones.
- **Colección:** el total visible de logros se obtiene del catálogo activo, en
  lugar del antiguo 30 fijo; los 28 actuales y los cinco secretos no cambian.
- **Sonido de objetos:** curación/reactivación identifica `effect`, no un campo
  inexistente `heal`. Se conserva el resto de efectos de audio.
- **Textos:** condición Interferida coherente con preparación/resumen, nombre del
  componente equipado para evitar muerte y sujeción/relé tecnológicos en el jefe.

`tests/test_game_review.gd` reproduce golpe preparado letal, varias preparaciones,
reactivación del jefe, contraataque absorbido y reconocimiento. Las regresiones
existentes conservan cobertura de batallas, turnos, sinergias, efectos, guardado,
cartas, eventos, tesoros, progresión y las seis parejas. No se borran suites útiles
por antigüedad.

## Limpieza con evidencia

[Inventario de archivos retirados](deleted_files.json) conserva ruta/tamaño/hash.
[Recursos y trabajos archivados](retired_resources.json) conserva procedencia de
los recursos sustituidos. [Alcanzabilidad del código](code_reachability.json).

- 18 imágenes runtime sustituidas: 15 iconos antiguos de equipo, puerta de inicio,
  esfera de energía y antigua moneda. Shader de esfera, tipografía Cinzel sin uso,
  su licencia y archivos de importación/UID asociados retirados.
- Sus 18 trabajos derivados y fuentes SVG se retiran de las colas actuales para
  que un importador no vuelva a crearlos.
- Nueve herramientas exclusivas de la estética anterior, cuyos originales ya
  fueron sustituidos, y UIDs asociados. Los importadores de actores y derivados
  vigentes conservan sus nombres/rutas, pero eliminan el modo de estética anterior.
  La reproducción de un héroe actual produce los mismos bytes que antes.
- Fuentes bitmap históricas sustituidas de migración, ilustraciones mínimas,
  primeros planos, retratos e interiores/campamento antiguos. Se contrastan con
  todos los `source`/`inputs_sha256` y trabajos originales actuales antes de borrar.
  Se mantienen prompts y metadatos JSON, licencias vigentes, conceptos de enemigos,
  fuentes actuales y recursos condicionales de retratos y enemigos.
- Capturas/registros antiguos de pruebas y bytecode regenerable; evidencia de esta
  revisión separada en `artifacts/game-review/`. TestWeb, herramientas instaladas,
  exportaciones y partidas reales no se modifican.

Se retiraron 3.371 archivos, **1.328.169.819 bytes (1,24 GiB)** del workspace,
principalmente originales gráficos históricos y artefactos de pruebas. No representa
un ahorro equivalente de exportación: `docs/` y `artifacts/` ya se excluían.
Los 189 módulos actuales de `src/` tienen consumidor alcanzable desde la entrada;
se conservan API públicas, callbacks y módulos que siguen funcionando.

## Validación y pendientes

- **90/90 suites headless** en la última versión; 1.510 comprobaciones de
  contenido y ocho pruebas negativas del validador sin errores.
- **12 suites nativas** aprobadas; colección repetida con total dinámico 42/0 y
  casos de batalla/mapa 16/0. La suite de pulido navega 36 vistas.
- 54 aventuras simuladas de seis parejas: bot básico 3/18 victorias; bot de
  decisiones 14/18 sin equipo y 13/18 con equipo nivel 1. Las diferencias de
  decisiones/RNG no prueban que mejorar equipo empeore el juego; quedan como
  datos para pruebas de balance con personas.
- 30 ciclos Campamento → Colección → Mercado → Campamento, 90 reconstrucciones:
  62 nodos antes/después y cero huérfanos, esperando los fundidos de audio antes
  de comparar. Esta comprobación no demuestra ausencia de fugas de recursos.
- 667 hashes vigentes correctos, cero referencias runtime a los assets retirados;
  importador actual reconstruye un héroe sin cambiar sus bytes y generador nativo
  produce los mismos 102 símbolos actuales en una comparación sin escribir.

Resultados detallados en `validation.json` e historial. Render local aislado
Xephyr/llvmpipe, perfil temporal y audio Dummy. Se revisan capturas nuevas de
pantallas, incluyendo colección, especializaciones, encuentros y bolsa.

Los avisos de recursos al cerrar 36 suites se registran; no se presentan
como ausencia demostrada de fugas. La simulación automática de balance tiene
estrategias limitadas y no justifica cambiar estadísticas sin pruebas con personas.
No se exporta ni se prueba Web/Android/GPU física en esta revisión.
