# Arquitectura y organización del código

Estado revisado el **18/09/2026**. Esta página describe el código actual y los
siguientes pasos, por separado. [Decisiones históricas](architecture/EVOLUCION.md).

## Estructura actual

| Ubicación | Responsabilidad |
| --- | --- |
| `main.tscn`, `src/main.gd` | Entrada, navegación, composición de pantallas y helpers de UI todavía compartidos |
| `src/game.gd` | API pública de acciones, estado de aventura/perfil y puntos de guardado |
| `src/content.gd`, `data/` | Catálogos y diseño declarativo de la mazmorra |
| `src/dungeon.gd` | Encuentros por semilla y coordenadas compatibles con guardados anteriores |
| `src/save_store.gd` | Persistencia atómica, versión y copia de respaldo |
| `src/rules/` | Reglas de progresión, herrería, tesoros, sinergias y consumibles |
| `src/ui/screens/` | Composición de pantallas; selección, reliquias, mapa, mercado, herrería, tesoro, recompensa y combate |
| `src/ui/components/` | Cartas, barras, números, paneles, botones y elementos reutilizables |
| `src/ui/combat_flow.gd` | Coordinación de una acción de combate resuelta con sus animaciones |
| `src/ui/forge_navigation.gd` | Construcción, acceso y acciones de la herrería |
| `src/presentation/` | Efectos visuales, viñetas de ataque (`hero_cut_in.gd`) y selección de apariencia del equipo |
| `src/*_sprite.gd` | Animaciones de actores; se mantienen rutas/UIDs actuales |
| `assets/` | Recursos finales usados por el juego, agrupados por sistema |
| `docs/` | Documentación, prompts, procedencia y fuentes que permiten regenerar arte |
| `scripts/` | Importadores, herramientas locales y preparación/exportación explícita |
| `tests/` | Pruebas de reglas, compatibilidad, recursos e interfaz |
| `artifacts/` | Capturas y resultados temporales, ignorados por Git y exportación |
| `builds/`, `TestWeb/` | Entregables existentes; no son fuentes ni recursos del juego |

## Flujo y límites

1. Una pantalla solicita una acción al controlador.
2. `game.gd` valida y aplica reglas. Sus colaboradores en `rules/` no guardan.
3. El controlador de juego confirma el estado mediante `save_store.gd`.
4. El flujo de UI presenta el resultado y espera las animaciones.
5. La pantalla se reconstruye a partir del estado confirmado.

Cerrar el juego durante una animación no debe volver a conceder premios o
consumir cartas. Los efectos de ceniza, luz y movimiento no calculan daño.
Los módulos de presentación tampoco leen/escriben guardados.

La selección previa de héroes/reliquia solo vive en memoria. Una aventura nueva
empieza vacía; volver dentro de la preparación conserva la elección actual.
El grafo y las posiciones se guardan con la aventura; partidas legadas mantienen
su recorrido de 12 salas y nuevas aventuras reciben 28.

## Extracciones terminadas en esta limpieza

| Módulo | Líneas | Cambio |
| --- | ---: | --- |
| `main.gd` | 702 (antes 893) | Delega pantalla y secuencia de combate |
| `game.gd` | 550 (antes 586) | Delega objetivos y aplicación de consumibles; mantiene checkpoint |
| `ui/screens/combat_screen.gd` | 100 | HUD, actores, objetivos y mano |
| `ui/combat_flow.gd` | 99 | Resolución, guardado previo, animaciones y transición |
| `rules/items.gd` | 45 | Validación de objetivos y efectos de los ocho consumibles |

Los métodos públicos anteriores permanecen como delegaciones para conservar
llamadores y pruebas. No cambiaron IDs, formato de guardado ni reglas.

## Acoplamiento que todavía existe

La extracción es incremental: `combat_screen.gd` y otras fábricas reciben el
controlador `ui` y reutilizan sus helpers; no son escenas completamente autónomas.
`items.gd` recibe el juego y usa sus operaciones de robo y dueño de carta.
Eso evita duplicar reglas, pero es un límite pendiente de mejorar, no una
separación completa. `main.gd` y `game.gd` siguen por encima de la guía de tamaño.

## Próximas extracciones recomendadas

En orden de prioridad, al trabajar en esas funciones:

1. Extraer inventario, descanso/evento, mazo, colección y resultados a pantallas
   propias, pasando instantáneas y callbacks como en mapa y tesoros.
2. Extraer tema/helpers visuales de `main.gd` a componentes concretos, sin crear
   otra clase gigante con todos los helpers.
3. Separar resolución de combate y recompensas de `game.gd`, manteniendo allí
   la API pública y el checkpoint atómico. Hacerlo con pruebas de guardado y
   recompensas para impedir duplicaciones.
4. Reducir gradualmente la dependencia de fábricas respecto de `ui.game` y
   sustituirla por datos y señales. No hacer una migración masiva de escenas ahora.

No se recomienda reorganizar los sprites por estética de carpetas ni renombrar
IDs/UIDs; no resuelve la concentración de responsabilidades y aumenta el riesgo.

## Convenciones para el crecimiento

- Pantalla nueva, archivo propio; componentes reutilizables en `ui/components/`.
- Reglas en `rules/`; efectos en `presentation/`; persistencia en `save_store.gd`.
- Revisar responsabilidades cerca de 350–400 líneas. No fragmentar funciones
  pequeñas solo para cumplir un número.
- Un cambio incluye documento del sistema, historial y pruebas pertinentes.
- Conservar fuentes/procedencia útiles; capturas solo en `artifacts/`.
- No exportar APK/Web durante el desarrollo salvo petición explícita.
- Documentar por separado estructura existente, cambios completados y propuestas.

## Pantalla de recompensa extraída — 18/09/2026

`ui/screens/reward_screen.gd` compone fondo, HUD compartido y ofertas; mantiene
`game.choose_reward` como única operación de selección. `CombatHUD.show_energy`
permite reutilizar la barra sin mostrar el orbe fuera del combate.

## Ilustraciones defensivas — 18/09/2026

`presentation/hero_cut_in.gd` recibe héroe y tipo visual (`attack`/`defense`).
`ui/combat_flow.gd` selecciona el tipo según la carta ya resuelta; el componente
visual no consulta el juego ni modifica bloqueo/guardados. Assets finales en
`assets/comic/defense/`, prompts y procedencia en `docs/comic/defense.json`.
