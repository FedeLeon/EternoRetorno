# Ampliación de enemigos del bosque

## Encuentros

Se añaden seis diseños existentes a la segunda mazmorra: once tipos comunes,
el oso ancestral élite y Gorvak como guardián. No cambia la cantidad de salas,
élites ni acompañantes. Los combates comunes mezclan dos o tres tipos distintos.

| ID | Enemigo | PV | Patrón de tres acciones |
| --- | --- | --- | --- |
| `goblin_lancer` | Goblin lancero | 28 | 7 daño + 3 bloqueo / 10 daño / contraataque 4 |
| `goblin_bomber` | Goblin bombardero | 23 | 4 a ambos héroes / 10 daño / 4 bloqueo |
| `goblin_raider` | Goblin saqueador | 25 | 8 daño / 5 daño + 5 bloqueo / 11 daño |
| `goblin_rider` | Goblin jinete | 34 | 8 daño / 12 daño / 5 daño + 3 bloqueo |
| `forest_bat` | Murciélago gigante | 21 | 6 daño / 9 daño / 4 a ambos héroes |
| `forest_raven` | Cuervo carroñero | 20 | 7 daño / 5 daño + 3 bloqueo / 9 daño |

Bombardero disponible desde etapa 2, jinete desde etapa 4. Las demás incorporaciones
pueden aparecer desde la entrada. La variedad se aplica cuando se genera el piso:
un bosque ya guardado conserva sus encuentros; una aventura todavía en la cripta
recibe la nueva variedad al descender. No se cambia ningún ID antiguo.

## Recursos y organización

- Catálogo existente ampliado: `data/forest_enemies.json`.
- Selección de encuentros: `data/dungeons.json`, reutiliza `distinct_common` y
  `min_stage` del generador compartido; la interfaz no elige encuentros.
- Seis atlas de 1024×128, ocho cuadros de 128×128: cuatro poses de reposo y cuatro
  de ataque. Visuales `goblin_1`, `goblin_4`, `goblin_5`, `goblin_6`, `beast_2`, `beast_7`.
- Seis ilustraciones RGBA de 900 px de ancho en `assets/comic/enemies/`, mismo ID.
  Ataques en primer plano desde abajo a la derecha hacia la izquierda, sin tapar
  el escenario con un fondo opaco. Daño y muerte usan la presentación existente.
- `enemy_visuals.json` registra cuadros y piso; `enemy_cut_in.gd` agrega paletas.
- `scripts/import_forest_expansion.gd` delega en `enemy_art_import.gd` sin duplicar
  el empaquetador. No regenera los recursos originales del bosque.

Fuentes producidas con la habilidad imagegen y la herramienta integrada,
referenciando los sprites existentes de `assets/enemies/hd/`. `prompts.json`
conserva instrucciones; `spacing-prompts.json` registra correcciones de espaciado;
`sources.json` registra procedencia. Imágenes originales generadas en `sources/`.
La importación determinista recorta por alfa visible, mantiene escala uniforme
entre cuadros y alinea la base a y=120. No se retoca arte mediante código.

## Validación

Se amplían `tests/test_forest.gd` y `test_forest_ui.gd`: cobertura de los once tipos,
etapas mínimas, grupos distintos, guardado sin regeneración, fuentes sin cortes,
poses distintas, regreso a reposo, transparencia y ataques desde la derecha.
`test_enemies.gd` recorre también las nuevas unidades activas. Resultados finales
en `docs/HISTORIAL.md`; revisión visual local, sin exportar Web/APK ni validar móvil.
El equilibrio requiere partidas humanas; las simulaciones no lo certifican.

Resultados de esta entrega: mapas/bosque 24.615, reglas generales 142, enemigos
859 y UI renderizada 146; sin fallos. Revisados seis atlas, seis ataques en
primer plano y formación mixta de tres. Capturas temporales retiradas.
