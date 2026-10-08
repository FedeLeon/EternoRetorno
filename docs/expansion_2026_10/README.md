# Aventura ampliada, controles y tercera mazmorra — 07/10/2026

Implementado localmente. No se exportó Web ni APK. Las partidas existentes conservan
sus nodos, IDs, RNG y `floor_count`; una aventura nueva tiene tres pisos.

## Funciones entregadas

| Mejora | Comportamiento y archivos |
| --- | --- |
| Arrastre de cartas | Mouse y táctil; umbral de 14 px, objetivos válidos iluminados, soltar afuera cancela. Defensa propia solo sobre su dueño; ataques grupales sobre cualquier enemigo vivo. Conserva tocar carta y objetivo. `ui/components/card_drag.gd` |
| Vista previa | Ejecuta las reglas sobre una copia aislada: daño a vida, bloqueo absorbido, golpes, caída, contraataques, curación y veneno. No altera estado/RNG/guardado. `rules/combat_preview.gd` |
| Velocidad | Opciones 1×, 1,5× y 2× durante la presentación. Resolución y checkpoint ocurren primero; se restaura el reloj después. `ui/combat_flow.gd`, `presentation/preferences.gd` |
| Comodidad y rendimiento | Reducir primeros planos, menos luces/partículas, intensidad de destellos, textos comunes +12%, volumen ambiental independiente. Preferencias persistentes. `ui/screens/options_screen.gd`, `presentation/hero_comic_fx.gd` |
| Formaciones | El generador combina atacantes con protectores/apoyos cuando hay tipos disponibles. Protector: +3 bloqueo a sus aliados vivos; apoyo: +3 PV a los enemigos vivos al actuar. La descripción aparece al inspeccionar su objetivo. El bloqueo previo se borra antes de conceder protección nueva. |
| Jefes por fases | Al llegar al 50% de vida, recalculan intención, conservan objetivo y muestran Fase II. Los tres guardianes tienen otro patrón declarado en datos. |
| Mazo en encuentros | Retirar una instancia elegida, intercambiarla o transformarla en una distinta de su héroe y coste 0–1. Transformar también mejora la nueva instancia. Solo usa cartas disponibles; retirar conserva ≥12 cartas y ≥4 por héroe. `rules/expanded_events.gd`, `ui/screens/event_cards_screen.gd` |
| Rechazar premio | Rechazar la carta tras una batalla entrega 12 almas, una sola vez. No rechaza la reliquia del élite. `rules/combat_rewards.gd` |
| Encuentros propios | Tres encuentros de cripta, tres de bosque y tres de fortaleza, con decisiones y fondos propios. |
| Vínculos | Desde Refugio, las quince parejas registran victorias compartidas. Una victoria abre diálogo y variante; tres abren otro recuerdo. Equilibrado: original; Ofensivo: +4 daño/−3 bloqueo; Protector: −4 daño/+4 bloqueo. Cambios se aplican al iniciar otra aventura, sin acumular bonos. `ui/screens/bonds_screen.gd` |
| Condiciones | Normal; Profanada (+3 guardia cada tercer turno); Expedición peligrosa (un élite extra por piso, contraataques cada tercer turno y +25% almas de combate). La condición se fija para la aventura. |
| Dificultad | Normal y Retorno I–III, desbloqueados al completar el nivel anterior. Cada nivel suma 6% vida enemiga, 1 daño a intenciones ofensivas y 15% almas de combate. II/III incluyen contraataques periódicos. Perfiles con victorias anteriores tienen I disponible. `rules/adventure_extensions.gd`, `ui/screens/run_setup_screen.gd` |
| Resumen | Pareja, piso, dificultad, condición, salas, cartas, combates, élites, guardianes, almas, daño a vida, reliquias y contrato. Distingue abandonar de caer. Conserva la instantánea antes de limpiar inventario/mazo/reliquias. `ui/screens/run_result_screen.gd` |
| Introducción | Cuatro pasos en el primer combate de perfiles sin introducción completada; se puede omitir y volver a abrir desde Opciones → Cómo jugar. `ui/tutorial_navigation.gd` |

La vista previa usa daño efectivo a vida, no promete que daño nominal atraviese
bloqueo. Los golpes/counters se resuelven por separado mediante las reglas existentes.
Los primeros planos siguen usando transparencia y el escenario permanece visible.

## Mazmorras y enemigos

| Piso | Comunes | Élite / guardián | Incorporaciones |
| --- | ---: | --- | --- |
| Cripta | 16 | Esqueleto guardián / Autómata roto | Lancero de la cripta, Corcel sin alma, Custodio de hielo |
| Bosque | 18 | Élite del bosque / Guardián de las raíces | Murciélago nocturno, Avispa gigante, Búho vigía, Saqueador del bosque |
| Fortaleza del Último Fuego | 9 | Verdugo de la fortaleza / Wyvern del Último Fuego con escolta | Lancero, Escudero y Bruto de las brasas, Cría del Último Fuego, Espíritu de ceniza y Wyvern |

Catálogo activo: **45 definiciones y 44 apariencias**, incluidas catorce definiciones
nuevas (el élite comparte aspecto con Bruto). Los pisos conservan 28 salas y rutas
aleatorias; bosque/fortaleza tienen grupos de dos o tres comunes y guardián con escolta.
En desarrollo se puede comenzar en cualquiera de los tres pisos; el selector conserva
el aviso de que se retirará para la versión final. Después se eligen dificultad y condición.

La cripta conserva sus encuentros originales. Bosque: manantial (8 PV, 12 con
Clériga), campamento abandonado (retirar carta), espíritu (5 PV, 10 con Explorador
/Pícaro, y 15 almas). Fortaleza: altar (transformar), archivo (intercambiar), puente
(8 PV por héroe a cambio de 45 almas, solo si ambos sobreviven).

## Assets y procedencia

**34 imágenes originales nuevas**, generadas con la herramienta integrada `imagegen`:

- 13 hojas transparentes 4×2: cuatro poses de reposo y cuatro de ataque por enemigo,
  **104 poses dibujadas**. Importador empaqueta atlas 1024×128, alfa y suelo común.
- 13 primeros planos transparentes de ataque de derecha a izquierda, cómic HD,
  integrados en el reproductor existente con desplazamiento/efectos.
- 6 fondos de encuentros, 1 fondo de combate volcánico y 1 de descanso volcánico.
- Referencias de identidad: plantillas del usuario `Enemigos/enemigos3.png` (esqueletos),
  `enemigos5.png` (elementales), `enemigos6.png` (bandidos), `enemigos7.png` (voladores)
  dentro de `/home/fede/Escritorio/EternoRetornoConceptArt`.
- Prompts, referencia y rutas de generación: [prompts.json](prompts.json).
  Fuentes conservadas en `sources/`; recursos finales en `assets/enemies/animations/`,
  `assets/comic/enemies/`, `assets/encounters/`, `assets/volcano/`.
- Se reutilizan arte del Refugio, marcos, iconos y cómics de héroes que ya estaban
  integrados. No se reemplazaron sus secuencias de 16 poses HD.

Reimportar esta entrega (no exporta el juego):

```bash
./scripts/run.sh --headless --script scripts/import_adventure_assets.gd
./scripts/run.sh --headless --editor --quit
```

El fondo de combate ya es el PNG final conservado. Atlas usan compresión sin pérdida;
fondos y primeros planos importan con compresión con pérdida al 85%, siguiendo el
resto del proyecto. `docs`, fuentes y capturas están excluidas de la exportación.
[manifest.json](manifest.json) registra dimensiones/tamaños/hashes de fuentes y finales.

## Arquitectura y compatibilidad

`game.gd` conserva API y checkpoints. Se extrajeron ciclo de aventura, turnos y
recompensas a `rules/run_lifecycle.gd`, `combat_turns.gd`, `combat_rewards.gd`.
`screen_backgrounds.gd` separa fondos del controlador de UI. Pantallas nuevas tienen
archivos propios; componentes visuales no conceden premios ni guardan.

Perfiles antiguos leen campos opcionales por defecto; nodos legados no se regeneran.
Las aventuras antiguas de uno/dos pisos terminan con su límite guardado. Las nuevas
preferencias, estadísticas y vínculos se guardan en los checkpoints existentes.

## Validación y límites

- `test_adventure_expansion.gd`: 5224 comprobaciones; catálogo/grafos para 60
  combinaciones piso/semilla, preview sin mutaciones, mazo, recompensa única,
  fases, roles, dificultad, condición, vínculos, tres pisos y recarga compatible.
- `test_expansion_ui.gd`: 17 comprobaciones con eventos reales de mouse/táctil
  entregados al viewport: arrastrar, cancelar, energía inmediata, tap, defensa propia,
  falta de energía y vistas nuevas. Ejecutado en Godot de escritorio con renderizado.
- `test_adventure_assets.gd`: 78 comprobaciones en escritorio: trece actores, ocho
  cuadros distintos cada uno, ataque y retorno a reposo, alfa y dirección de cómics.
- Revisión visual local de combate, arrastre, opciones, vínculos, encuentros, descanso,
  preparación y tutorial; capturas descartables en `artifacts/expansion/`.
- Regresiones registradas en [HISTORIAL](../HISTORIAL.md), sin sumar pruebas antiguas.
- Bot sencillo: 45 aventuras terminan, 4 victorias. Ignora recompensas/mejoras y sirve
  para detectar bloqueos del flujo; no representa balance de jugadores humanos.
- Falta validación humana del equilibrio, rendimiento en móvil y controles en
  navegador/dispositivo real. No se hizo exportación ni se presenta la prueba táctil
  sintética como una prueba física.

## Preparación mediante tarjetas — 08/10/2026

`src/ui/screens/run_setup_screen.gd` reemplaza los dos desplegables por cuatro
pequeñas tarjetas de dificultad y tres de condición. Cada una reutiliza un dibujo
RGBA existente de `assets/battle_effects/`: guardia, ataque, contraataque, furia,
preparación, profanación y frenesí. La procedencia permanece en
[efectos de batalla](../battle_effects/README.md); no se generó arte nuevo.

Las tarjetas muestran nombre, efectos y estado «Elegida». Cada fila permite una
única selección mediante ButtonGroup. Los niveles bloqueados se ven atenuados y
explican qué aventura ganar; no pueden seleccionarse. Cancelar conserva las
preferencias; iniciar confirma dificultad/condición y utiliza el flujo previo,
con la configuración fija de esa aventura. No cambia el formato de guardado.

Pruebas actuales: `test_run_setup_cards.gd`, 22 comprobaciones en ventana Linux
Godot 4.7.2/Mesa/llvmpipe; clics reales, exclusividad, bloqueos, cancelar, dibujos,
límites de tarjetas y valores aplicados al empezar el piso tres. Capturas
`artifacts/run-setup/{locked,selected}.png` revisadas visualmente. Regresión de
reglas `test_adventure_expansion.gd`: 5.224 comprobaciones headless sin fallos.
La ventana informa solamente que no puede cambiar VSync. Sin exportación Web/APK
ni validación en navegador, emulador o dispositivo físico.
