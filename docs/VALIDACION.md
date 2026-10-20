# Validación local

## Comandos

Desde la raíz del proyecto:

```bash
python3 scripts/audit_repository.py
python3 scripts/audit_content.py
python3 scripts/audit_static_combat.py
python3 scripts/audit_postapocalyptic_art.py
python3 scripts/audit_pixel_cards.py
python3 scripts/audit_enemy_cutins.py
python3 scripts/run_regressions.py --jobs 6 --output artifacts/regressions
```

El runner usa partidas temporales aisladas por suite. Las herramientas locales
están en `.tools/`. Godot actual: **4.7.2**, renderizador Compatibility.

Para inspección nativa con ventana aislada, si Xephyr está disponible:

```bash
python3 .tools/isolated_x11.py tests/test_static_combat_flow.gd
```

La ejecución local normal es `./scripts/run.sh`; `--editor` abre el editor.
No hace falta generar una APK para trabajar ni para verificar documentación.

## Alcance de cada prueba

| Método | Qué comprueba | Qué no certifica |
| --- | --- | --- |
| Auditorías estáticas | Rutas, catálogos, dimensiones, hashes y procedencia. | Apariencia o rendimiento durante una partida. |
| Godot headless | Contratos, reglas, guardado y comportamiento de nodos. | GPU, legibilidad visual ni mezcla por escucha. |
| Ventana nativa local | Composición y comportamiento en ese entorno. | Navegador o dispositivo físico. |
| Navegador | Exportación web servida y reproducida con interacción real. | Android ni todos los equipos. |
| Dispositivo físico | Controles, audio y rendimiento del equipo probado. | Plataformas o equipos no probados. |

Los avisos de objetos/recursos retenidos al salir deben registrarse aparte.
Un proceso que cierra sin fallar no demuestra ausencia de fugas.

## Mapa vertical — 20/10/2026

- Regresión completa: 105/105 suites headless aprobadas tras el cambio.
- `test_vertical_map.gd`: 24813/0 headless y nativo aislado; 30 mazmorras de los
  tres pisos, caminos ascendentes, separación, jefe superior y compatibilidad de
  geometría sin metadatos. Comprueba rueda, foco inicial/actual, recorte, retratos,
  menú fijo y que inspeccionar no modifique la aventura ni el RNG.
- `test_map.gd`: 141/0 headless y nativo; clics en salas, grupo, mazo y transiciones.
- Capturas de recorrido inferior, intermedio, superior y posición actual revisadas
  con X11/Mesa llvmpipe y audio Dummy. Avisos de retención de 8 objetos/2 recursos
  en la prueba nativa de interacción. Contenido 2793/0, repositorio y enlaces sin
  errores. Evidencia en `artifacts/vertical_map/` y `artifacts/map/`.
- Sin validación táctil en celular, navegador ni exportación APK. La ejecución
  nativa y los eventos de ratón no certifican esas plataformas.

## Retirada de proyectos y mascotas — 20/10/2026

- Regresión completa posterior a la retirada: 104/104 suites headless aprobadas.
- Prueba `test_retired_projects_pets.gd`: 24/0 headless y nativo aislado; carga y
  segunda carga de guardados antiguos, conservación de combate/RNG/progreso,
  ausencia de bonos en nuevos combates, precios normales y controles retirados.
- Animales ambientales: 54/0, con las animaciones originales conservadas.
- Capturas revisadas de campamento, selección, componentes y combate en ventana
  X11/Mesa llvmpipe. Audio Dummy. No se probó navegador ni dispositivo físico.
- Contenido 2793/0; 360 dibujos de cuerpos, 112 primeros planos de máquinas y
  procedencia de 950 recursos sin errores. Repositorio y enlaces válidos.
- 47 suites avisan retención al salir; la revisión nativa registra 20 objetos/5
  recursos. Evidencia en `artifacts/retired_projects_pets/`. No se exportó APK.

## Primeros planos enemigos — 19/10/2026

- Cobertura: 57 definiciones, 56 modelos y 112 dibujos distintos de ataque/defensa;
  auditoría específica sin errores y diez pruebas Python del validador correctas.
- `test_enemy_foreground_pairs.gd`: 1350 comprobaciones sin fallos headless y en
  ventana nativa aislada. Verifica selección de acción/identidad, alfa, encuadre,
  imagen estática, cierre, ausencia de fallback y preferencias de primeros planos.
- Revisión visual manual de los 112 dibujos en 14 láminas contra su modelo de
  batalla y ocho capturas con primeros planos reales. No aparecen humanos ajenos.
- Contenido 2794/0; repositorio sin referencias rotas o metadatos huérfanos;
  360 cuerpos estáticos válidos y procedencia vigente de los 952 recursos visuales.
- Evidencia y registros en `artifacts/enemy_cutins_review/`. Las aprobaciones
  visuales y prompts están en `art_sources/enemy_cutins_2026_10_19/`.
- Regresión final completa: **104/104 suites headless aprobadas**, sin errores de
  script ni fallos de aserción, con datos temporales aislados por suite. 44 suites
  registran avisos de retención al salir; detalle en `regressions_verified/`.
- Efectos activos: 1029/0 headless y nativo aislado; separación respecto al escudo
  revisada visualmente. Contraataques: prueba existente sin fallos tras proteger
  el paso de referencias de primeros planos que ya fueron liberados.

La ventana nativa usa X11/Mesa llvmpipe y audio Dummy. Se registraron avisos de
retención de 4 objetos/1 recurso al cerrar algunas ejecuciones nativas; no se
deduce ausencia general de fugas. No se probó navegador ni dispositivo físico.

## Revisión de acciones HD de héroes — 19/10/2026

Las veinte poses nuevas se verificaron después de importar sus imágenes:

- `test_hero_actions_hd.gd`: 152/0 headless y 152/0 nativo aislado; detalle nativo,
  transparencia, mismos reposos, tamaño/anclaje y cuerpo estático. Ocho capturas
  de ataque/defensa revisadas con X11/Mesa llvmpipe, no GPU física.
- Actores estáticos: 1626/0; sincronización con primeros planos: 93/0;
  efecto de corte: 21/0; flujo en las tres mazmorras: 48/0, todos headless.
- Contenido: 2568/0; auditoría de 360 imágenes estáticas sin errores y procedencia
  de los 896 recursos visuales vigente. No se amplían las fuentes de baja resolución.
- Originales, prompts y referencias: cuatro reposos sin cambios; veinte acciones
  con fuentes y borde pintado correctos. Enlaces de documentación y referencias válidos.

HD, sincronización y flujo headless registran al cerrar 4 objetos/1 recurso cada
uno; impacto registra 12/3. Actores estáticos y recorrido nativo no registraron
esos avisos. No se declara ausencia general de fugas. Evidencia actual en
`artifacts/hero_actions_hd/`; alcance en [Historial](HISTORIAL.md).

En esa revisión de héroes no se repitió la regresión completa. No se exportó
APK/web. No se probó navegador,
emulador, dispositivo físico o mezcla de audio por escucha. La revisión documental
conserva 12 guías Markdown y el marcador `.gdignore`, sin archivos generados dentro
de `docs/`.

## Pendientes de validación de producto

- Medir CPU, GPU y memoria en las batallas de la versión web antes de atribuir
  lentitud a una causa concreta.
- Escuchar la mezcla de música, golpes de metal y voces durante partidas reales.
- Investigar avisos de retención al cerrar algunas suites.
- Balancear materiales, parejas y progresión con partidas humanas.

Son trabajos pendientes; no se presentan como resultados de esta limpieza.
