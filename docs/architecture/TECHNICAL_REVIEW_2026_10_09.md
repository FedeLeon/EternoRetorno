# Revisión técnica — 09/10/2026

## Diagnóstico y decisiones

Se revisaron entrada/UI, catálogos, resolución de combate, generación de pisos,
persistencia, presentación y herramientas de regresión. Las reglas ya tienen
colaboradores pequeños; se priorizaron fallos de recuperación y trabajo repetido
sobre cambios de carpetas o migraciones completas de escenas.

| Prioridad | Hallazgo | Cambio aplicado |
| --- | --- | --- |
| Alta | Tras recuperar `.bak`, el siguiente guardado copiaba el principal inválido encima del respaldo válido | Solo se respalda un principal con envoltorio válido; si la copia falla, no se reemplaza el principal |
| Media | Mismos JSON releídos/parses repetidos por edificios, pisos, actores y consultas | Caché central de fuentes con copias profundas para cada consumidor; diagnósticos de archivo/línea/tipo y reintentos de lecturas fallidas |
| Media | Nuevos IDs o recursos podían fallar recién al jugar | Validador previo a regresiones: sintaxis, claves duplicadas, expansiones, dueños/objetivos, mazos, encuentros, sinergias, arte y audio |
| Media | `game.gd` conservaba cálculos y ejecución de enlace junto a su API/guardado | Cálculos y sinergias extraídos a reglas; los checkpoints permanecen en la fachada |
| Media | Tema y widgets todavía se construían dentro del controlador principal | `ui_factory.gd` construye tema/labels/botones/paneles sin acceder a juego, navegación o persistencia |

## Estructura terminada

- `src/data/json_catalog.gd`: lectura/caché de JSON. Dos APIs tipadas (`dictionary`
  y `array`), invalidación explícita para herramientas y contador de lecturas.
  Datos cacheados nunca se entregan directamente; mutar un resultado no afecta
  otra partida. Los errores no se cachean. En desarrollo, reiniciar el juego o
  llamar `clear(path)` para recargar consumidores sin caché propia. Los que ya
  mantenían cachés estáticas requieren reinicio; no hay vigilancia en caliente.
- 17 módulos consumidores migrados, incluido `content.gd`. No se cambian los
  nombres/IDs ni el orden y la política de mezcla de expansiones.
- `rules/combat_stats.gd`: daño/absorción/revivir, energía y carta efectiva.
  `rules/synergy_actions.gd`: consumo de cartas, enlace, contraataque y final.
  Ambos reciben `game` para conservar los colaboradores existentes; no guardan.
- `ui/components/ui_factory.gd`: construcción visual independiente. Los helpers
  públicos de `main.gd` permanecen como delegaciones; el bloqueo de clics durante
  una animación sigue en el controlador. Estilos, fuentes, tamaños y textos iguales.
- `save_store.gd`: mismo formato versión 1, `.tmp` y sustitución por renombrado;
  conserva `.bak` al detectar principal inválido y limpia errores de lectura antiguos.
  `recovered_from_backup` indica recuperación; no añade datos al guardado.
- `scripts/audit_content.py`: validación sin leer perfiles. Comprueba referencias
  literales de `data/` y rutas dinámicas de animación/cut-in enemigo y arte de carta.
  No pretende probar todas las rutas dinámicas posibles del código.
- `scripts/run_regressions.py`: exige catálogo válido y pruebas del validador antes
  de abrir Godot; `--output` permite separar evidencia de distintas entregas.

`src/` pasa de **180 a 184 módulos**; `main.gd` baja de **593 a 549 líneas** y
`game.gd` de **442 a 369**. El siguiente archivo más grande tiene 182 líneas.
Son extracciones de responsabilidades, sin comprimir código para cumplir un límite.

## Compatibilidad y alcance

Resolución/guardado siguen ocurriendo antes de presentar animaciones. Se mantienen
semilla/estado RNG, cálculos de daño, coste de energía, IDs, rutas/UIDs anteriores,
recompensas y mapas ya guardados. No se borra ningún asset ni cambio de las entregas
anteriores. No se agregan assets, sonidos, estados de combate o dificultad nueva.

La mejora del respaldo protege la recuperabilidad; no revierte una acción en
memoria si falla el disco, ni incorpora un registro de transacciones distribuido.
El guardado ya comunica el fallo mediante `game.message`. Su validación sigue
siendo del envoltorio: una migración profunda de esquemas de partida queda pendiente.

## Verificación actual

Comandos locales (sin exportar):

```sh
python3 scripts/audit_content.py --output artifacts/technical/content.json
python3 tests/test_content_audit.py
.tools/Godot_v4.7.2-stable_linux.x86_64 --headless --path . --script tests/test_technical_integrity.gd
python3 scripts/run_regressions.py --jobs 3 --output artifacts/technical/regressions
DISPLAY=:0 .tools/Godot_v4.7.2-stable_linux.x86_64 --path . --script tests/test_polish_ui.gd
```

Resultados: **85/85 suites headless**, **28 comprobaciones de integridad**,
**1.858 validaciones de contenido**, **ocho pruebas negativas del validador**
y **13 comprobaciones nativas sobre 36 vistas**, sin fallos de script/aserciones.
La importación final y `git diff --check` pasan. Los avisos de recursos al cierre
se registran por separado; no hubo exportación ni pruebas Web/emulador/dispositivo.

Resultados finales y límites: [validation.json](technical_validation_2026_10_09.json).
La prueba de integridad usa nombres temporales asociados al PID bajo `user://`,
elimina sus fixtures y no lee/escribe la partida del usuario. Verifica recuperación
repetida, prioridad del principal, interrupción temporal, versión incompatible,
fallo de copia, aislamiento de copias y cacheo de pisos. El fallo de copia se induce
poniendo una carpeta donde iría `.bak`: el mensaje del motor es esperado en esa prueba.

El contador mide **una lectura para 1.001 consultas** de definición de piso. El
cronómetro compara el método anterior de lectura/parseo con el actual; es un
microbenchmark local, no evidencia de FPS, consumo de memoria o rendimiento Web.
El recorrido gráfico verifica 36 vistas, navegación/teclado/mando y enlaces reales;
no equivale a probar todos los tamaños táctiles ni a una partida humana completa.

## Recomendaciones siguientes, aún no implementadas

1. Extraer navegación/estado de selección de `main.gd` cuando se amplíen esas
   pantallas. Mantener métodos públicos mientras existan fábricas que dependen de `ui`.
2. Introducir snapshots tipados para pantallas de consulta y resultados de acciones;
   reducir el uso de diccionarios sin una migración masiva de guardados.
3. Añadir validación/migraciones explícitas del contenido interno de partidas,
   con fixtures de versiones históricas reales antes de cambiar la versión 1.
4. Medir cargas de atlas, FPS y memoria en Web y equipo objetivo; las fuentes JSON
   cacheadas no sustituyen el análisis de texturas, que dominan el peso del juego.
5. Diagnosticar propietarios de recursos al cierre de suites: varios avisos
   históricos siguen presentes; no se consideran solucionados por esta extracción.
6. Revisar balance con sesiones humanas y telemetría agregada. El autoplayer voraz
   de reglas sirve para detectar errores, no para certificar la dificultad.
