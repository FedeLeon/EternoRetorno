# Revisión de animaciones y selección — 14/10/2026

## Alcance y problemas encontrados

Se revisó la cadena activa de presentación: poses detalladas, atlas clásicos,
carrera, ataques cuerpo a cuerpo, proyectiles, primeros planos, reacciones,
corrosión, disolución, descarte, bloqueo y transición del turno. Inventario de
96 hojas activas y 928 cuadros de héroes/enemigos en `atlas_audit.json`.
Las comprobaciones técnicas de cuadros no sustituyen ver todos los encuentros
jugando; las capturas locales indicadas en `validation.json` son la revisión visual.

- Las fuentes de poses no tienen todas seis columnas por fila: Profesora tiene
  7/7/6/4; Carpintero 6/6/6/5. Las otras dos tienen 6/6/6/6, con orden de acciones
  distinto del supuesto. El corte fijo podía mostrar fragmentos de botas de otra
  fila, usar una caída como reacción o una pose especial como carrera.
- `pose_layouts.json` registra distribución y asignación semántica revisadas de
  las cuatro fuentes ImageGen existentes. Extracción geométrica con separadores
  adaptativos y encuadre de la silueta principal; no se redibujan las fuentes.
  Se vuelve a generar todo derivado detallado, clásico, carrera y equipo para
  conservar las rutas, las dimensiones de cuadros, UIDs y las bases 240/368/120.
  El banco del Carpintero tiene 23 dibujos: la celda de reserva se rellena con
  reposo; ninguna secuencia depende de una pose ausente.
- `detailed_hero.gd` mantiene el reposo en cuadro 0, evitando saltos entre dibujos.
  Carrera a 10 FPS. Una acción interrumpida no devuelve a reposo una acción nueva.
- Se reconstruyen también las 56 hojas de enemigos y sus 56 imágenes de
  reposo con encuadre de silueta principal, eliminando fragmentos de otras filas.
  Métricas por cuadro recalculadas desde las hojas nuevas.
- Enemigos con filtro lineal, acorde al arte cómic; conservan correcciones de
  tamaño por cuadro, reacciones verdes/rojas y disolución sin resolver daño otra vez.
- Selección: dos personajes por lado, pies en la misma línea de suelo, imágenes
  recortadas por alfa y zona de toque que incluye toda la figura. El descanso
  comparte el encuadre proporcional mediante `seated_hero_art.gd`.
- Primeros planos: rayos radiales amplios, halo, chispas escalonadas y arcos de
  protección detrás del personaje. Ilustración sin movimiento ni cambio de pose;
  escenario visible, sin panel opaco. Colores por héroe, menor cantidad en calidad
  reducida e intensidad vinculada a la preferencia de destellos.

## Archivos y procedencia

`hero_comic_fx.gd`, `detailed_hero.gd`, `enemy_sprite.gd`, `selection_screen.gd`,
`rest_screen.gd`, `seated_hero_art.gd`, posiciones de preparación en `main.gd`.
Importación: `sketchbook_sheet_packer.gd`, `import_sketchbook_actors.gd -- --comic`,
`import_postapocalyptic_art.gd -- --actors-only`; después
`audit_enemy_pose_sizes.py` y `audit_battle_atlases.py`.
Fuentes/prompts ImageGen existentes en `docs/art_direction/postapocalyptic/`;
registro de procesamiento versión 5 en `assets.json`, con hash de pose_layouts.
Rayos/partículas son geometría nativa animada, sin nuevas imágenes generadas.

## Validación y límites

Ver `validation.json` y el historial para resultados de esta revisión.
Render local aislado con llvmpipe y audio Dummy. Sin exportar ni probar Web,
GPU física, sonido audible o dispositivo móvil. Se conservan partidas y reglas.
