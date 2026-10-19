# Eterno Retorno

Juego de cartas y exploración para dos protagonistas por aventura, ambientado en
un mundo postapocalíptico de civiles contra máquinas. Interfaz en español,
estética de cómic y progreso local sin conexión.

**Documentación:** [estado e índice](docs/README.md) ·
[arquitectura](docs/ARQUITECTURA.md) · [historial](docs/HISTORIAL.md) ·
[recursos y mantenimiento](docs/RECURSOS.md).

## Jugar y desarrollar localmente

Abrí `project.godot` con **Godot 4.7.2** o usá el ejecutable local mediante:

```bash
./scripts/run.sh --editor
./scripts/run.sh
```

El proyecto usa el renderizador Compatibility y una vista horizontal de 1280×720.
Las herramientas instaladas viven en `.tools/`, fuera del control de versiones.
`scripts/setup_tools.sh` permite instalarlas y configurar el entorno Android;
conservá `.tools/debug.keystore` para mantener la firma de las instalaciones de prueba.

Las exportaciones se generan en carpetas ignoradas por Git. El repositorio no
incluye una APK ni una exportación web histórica como versión jugable actual.
Durante el desarrollo se prueba localmente; se exporta una APK cuando se solicita.
El comando de exportación es `./scripts/build_android.sh`.

## Cómo se juega

- Elegí dos entre Bruno/Carpintero, Mara/Constructora, Ciro/Boticario y Alma/Profesora,
  una mascota y los componentes de preparación.
- Compartís un mazo y energía. Arrastrá una carta sobre el objetivo iluminado o
  tocá carta y objetivo. Las cartas defensivas propias se aplican sobre su dueño.
- Podés guardar una carta por turno, dejándola dada vuelta en la mano; también
  podés cancelar esa reserva y elegir otra antes de terminar el turno.
- Las intenciones anticipan la acción enemiga. Vida, bloqueo y efectos permanecen
  visibles; los iconos ofrecen explicaciones al tocarlos.
- Los cuerpos muestran imágenes estáticas por acción. Los primeros planos
  conservan luces y partículas; no hay animación corporal ni carrera de salida.
- Después de una batalla elegís un camino. El mapa completo se consulta desde
  el menú lateral. Cofres, encuentros, descanso y élites modifican la aventura.
- Las mazmorras actuales son Red de mantenimiento, Cinturón industrial y Central
  del Reinicio. Elegir la reliquia exclusiva del jefe conduce al siguiente mapa.
- El campamento conserva mejoras y desbloqueos. Los materiales de enemigos se
  funden en el taller para mejorar armas y armaduras.

El avance se guarda después de cada acción resuelta. `Continuar aventura` restaura
la partida pendiente. Una derrota conserva el progreso permanente del campamento.

## Organización

- `src/game.gd`, `src/rules/`: estado, validación y reglas.
- `src/content.gd`, `data/`: catálogos con identificadores estables.
- `src/ui/`: pantallas, navegación y componentes.
- `src/presentation/`: imágenes estáticas, primeros planos y feedback visual.
- `src/audio/`: reproducción, mezcla y contexto sonoro.
- `src/save_store.gd`: guardado atómico, archivo temporal y copia de respaldo.
- `assets/`: recursos vigentes del juego.
- `docs/`: documentación escrita del estado actual.
- `art_sources/`: fuentes, prompts, licencias y procedencia de producción.
- `scripts/`: ejecución, auditorías, importación y preparación de recursos.
- `tests/`: regresiones de reglas, persistencia y presentación.

`user://eterno.save` contiene `profile` y `run`; no pertenece al repositorio.
La persistencia conserva el estado aleatorio de 64 bits, sin serializar objetos.
Los cambios visuales no deben modificar reglas ni resolver premios o daños.

## Comprobaciones locales

```bash
python3 scripts/audit_repository.py
python3 scripts/audit_content.py
python3 scripts/audit_static_combat.py
python3 scripts/audit_postapocalyptic_art.py
python3 scripts/run_regressions.py --jobs 6 --output artifacts/regressions
```

Las pruebas usan partidas temporales y el runner aísla sus datos por suite.
Para una revisión con ventana local aislada, si está instalado Xephyr:

```bash
python3 .tools/isolated_x11.py tests/test_static_combat_flow.gd
```

Los resultados concretos y sus avisos se registran en el historial y en el documento
de cada cambio. Pasar pruebas headless no certifica apariencia, audio por escucha,
rendimiento en navegador, exportación Android ni funcionamiento en un dispositivo.
Las capturas y logs se generan en `artifacts/`, ignorado por Git y Godot.
