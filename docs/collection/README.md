# Colección de ecos

## Ilustraciones desbloqueadas a pantalla completa — 15/10/2026

Al seleccionar un logro desbloqueado, el panel derecho conserva su estado y
agrega **Ver ilustración** debajo. Abre su imagen sobre toda la vista, con
fondo oscuro y ajuste proporcional que muestra el dibujo completo. Usa los
PNG actuales de 512 px, sin nuevos assets ni duplicados de mayor resolución.

Los logros pendientes no tienen el botón; los secretos solo muestran su arte
real una vez descubiertos. Volver o Escape cierra el visor y recupera el foco
en el botón, conservando selección, pestaña y desplazamiento de la colección.
El fondo bloquea clics sobre los controles que quedan detrás.

`collection_screen._open_art()` comprueba que el logro esté desbloqueado;
`ui/components/artwork_viewer.gd` solo presenta una textura y reutiliza
`ui.overlay`/`close_modal`, incluido el regreso por teclado. Sin conceder logros,
modificar perfiles, descargar imágenes ni acceder a fuentes documentales.

Validación actual: `test_collection_artwork.gd` **21/0 nativo aislado**, logro
normal y secreto desbloqueados, pendientes, proporciones, clics bloqueados,
cierre por botón/Escape, restauración de selección/foco y perfil/partida sin
cambios. Capturas de ambos dibujos revisadas en `artifacts/collection/`.
`test_collection_ui.gd` **50/0 headless**. Audio Dummy; avisos de recursos al
cerrar, sin errores de script/aserciones. Sin exportar ni probar Web/dispositivo.


## Arte actual: ilustraciones detalladas — 15/10/2026

Los **28 logros activos** usan nuevas ilustraciones individuales generadas con
la herramienta integrada, en el cómic de acción del juego: objetos/escenas,
tinta, desgaste y luces. Reemplazan los pictogramas vectoriales anteriores.
Assets a 512×512, detalle de selección ampliado a 184×184 y menor atenuación de
pendientes. Se conservan requisitos, guardados y ocultación de los cinco secretos.
[Galería, fuentes, prompts e importación reproducible](comic_illustrations/README.md).

La máscara secreta también tiene ilustración propia de candado/caja cerrada,
sin pistas. Solo los seis recursos de pestañas, reloj e historial siguen en SVG.
Validación actual: **50/0 nativo**, galería/vistas revisadas y **674 hashes válidos**.

## Etapa vectorial sustituida — 15/10/2026 (histórico)

Conjunto de **35 dibujos**: 28 logros activos, emblema secreto, tres pestañas,
Reloj sin arena y dos resultados de historial. Medallas metálicas octogonales,
tinta negra, caras planas y luces cian/violeta/ámbar. Cada logro tiene un archivo
distinto; los niveles superiores añaden refuerzos, laureles o luces de rango.

- Los cuatro oficios usan sierra, escudo de chapa, frasco y bobina.
- Batallas, élites, guardián, compras, cofres, mejoras, contratos y retornos tienen
  símbolos propios; los logros secretos usan sus dibujos solo al descubrirse.
- Se conserva el candado común para los cinco secretos pendientes, sin filtrar
  nombre, progreso, requisito o ilustración real. No se cambian condiciones.
- Pestañas con trofeo/candado abierto/libreta; historial con bandera de victoria
  o refugio de retorno. Reloj sin arena tiene ahora un reloj propio, sin reutilizar
  la medalla de victorias. Los objetos/reliquias descubiertos conservan su arte.

### Archivos y procedencia

- `scripts/collection_icons.py`: geometría original SVG, integrada en
  `postapocalyptic_icons.svg_for/create`. No generación de imágenes ni fuentes
  externas. `assets/collection/icons/<id>.png` conserva rutas, dimensiones y UIDs.
- Fuentes en `docs/art_direction/postapocalyptic/vectors/collection__icons__*.svg`;
  rasterizado selectivo `scripts/import_postapocalyptic_icons.gd -- --collection-only`.
- `assets/collection/secret.svg` sustituido; seis recursos nuevos bajo
  `assets/collection/ui/`: achievements, unlocks, history, hourglass, victory, return.
  Fuente de estos siete SVG nativos registrada con hash en `assets.json`.
- Presentación en `collection_screen.gd`; snapshot de reloj en
  `collection_navigation.gd`. Sin modificar perfil, premios, historial ni guardado.

### Validación actual

Colección **50/0** con render nativo aislado: 28 dibujos distintos, recursos,
pestañas, reloj específico, ambos resultados de historial, ocultación secreta y
consulta sin mutar perfil. Galería de los 35 iconos y vistas de logros/desbloqueos/
historial revisadas; capturas en `artifacts/collection/`, ignoradas por Git/export.
Auditoría **674 hashes válidos**, cero visuales antiguos. Audio Dummy; sin
exportar ni probar Web/dispositivo físico. Los registros inferiores son históricos.

## Actualización — 07/10/2026

El tema compartido mejora marcos, tipografía, contraste y pestañas. Desbloqueos
muestra también las nueve reliquias exclusivas de guardianes: sus descubrimientos
se conservan en `profile.boss_relics`, sin conceder efectos en aventuras futuras.
Últimos retornos → Ver incluye métricas locales por carta y combate cuando la
aventura las registró; los historiales antiguos siguen funcionando sin esos datos.
43 comprobaciones actuales en headless y Linux/Mesa, con capturas revisadas;
no se exportó ni probó esta entrega en Web/Android.
[Alcance y validación](../polish_2026_10/README.md).

## Entrega original — 30/09/2026

## Vista

La colección del inicio tiene fondo propio de archivo gótico oscuro y tres
pestañas: **Logros**, **Desbloqueos** y **Últimos retornos**. Se conservan las seis
cartas de victoria, el Reloj sin arena y el historial. El encabezado usa el marco
oscuro compartido; **Inicio**, con el asset de flecha izquierda junto al texto,
reemplaza al menú y al botón inferior.

Los logros se presentan en una grilla de tres columnas con scroll y un detalle
fijo a la derecha. Cada uno tiene icono propio y estado; los visibles muestran
progreso. Los cinco secretos usan un emblema cerrado y el nombre «Eco desconocido»
hasta desbloquearse. Ni antes ni después muestran requisitos, métricas o cifras
que revelen la condición. No conceden ventajas ni alteran el balance.

## Catálogo visible

| Logro | Objetivo |
| --- | --- |
| El primer paso | Comenzá una aventura. |
| Acero despierto | Ganá un combate. |
| Veteranos del camino | Ganá 10 combates. |
| Leyenda de acero | Ganá 50 combates. |
| Rompefilas | Derrotá a un élite. |
| Azote de élites | Derrotá a 10 élites. |
| Caída del guardián | Derrotá a un guardián de mazmorra. |
| Algo entre las sombras | Abrí un cofre. |
| Buscadores de fortuna | Abrí 10 cofres. |
| Una nueva posibilidad | Mejorá una carta durante un descanso. |
| Mazo templado | Mejorá 10 cartas durante los descansos. |
| El primer retorno | Completá una aventura. |
| Volver a levantarse | Completá 5 aventuras. |
| Más allá del destino | Completá 10 aventuras. |
| Juramento de acero | Completá una aventura con el Guerrero. |
| Bastión eterno | Completá una aventura con la Guardiana. |
| Huella invisible | Completá una aventura con el Pícaro. |
| Voluntad arcana | Completá una aventura con la Maga. |
| Luz que regresa | Completá una aventura con la Clériga. |
| Nunca falla el rumbo | Completá una aventura con el Explorador. |
| Trato hecho | Comprá una carta en el mercado. |
| Cliente conocido | Comprá 10 cartas diferentes en el mercado. |
| Filo definitivo | Mejorá el arma de un héroe al nivel 3. |
| Segunda piel | Mejorá la armadura de un héroe al nivel 3. |
| Palabra cumplida | Completá un contrato de expedición y terminá la aventura. |

Los cinco secretos completan el catálogo de 30; sus IDs y reglas son internos en
`data/achievements.json` y `src/rules/achievements.gd`.

## Estado y compatibilidad

- `profile.achievements` conserva IDs desbloqueados y totales acumulados.
- `run.achievement_receipt` registra los contadores ya incorporados al perfil.
  Ambos se guardan en la misma escritura atómica existente. Reabrir, cambiar de
  piso o repetir un checkpoint no duplica combates, cofres, mejoras ni contratos.
- `game.checkpoint` sincroniza después de las acciones resueltas, antes del
  guardado; cargar un perfil anterior añade el estado faltante sin cambiar IDs
  ni la versión del sobre de guardado.
- Se recuperan intentos, victorias, héroes victoriosos, compras, equipo,
  edificios y parejas del historial disponible. El progreso de la aventura
  guardada también cuenta. No se inventan combates/cofres de aventuras antiguas
  cuyo detalle ya no existe. El historial truncado no revoca logros concedidos.
- Los contratos cuentan cuando se confirma su resultado al terminar la aventura.
- Abrir la colección, cambiar de pestaña o seleccionar un icono no modifica ni
  guarda estado. El controlador entrega una instantánea sin requisitos secretos.

## Archivos

- `data/achievements.json`: 30 definiciones con IDs estables.
- `src/rules/achievements.gd`: acumulación, migración y vista pública sin pistas.
- `src/ui/collection_navigation.gd`: adaptación del perfil y navegación al inicio.
- `src/ui/screens/collection_screen.gd`: composición visual y selección local.
- `assets/collection/background.png`: fondo nuevo.
- `assets/collection/icons/*.png`: 30 iconos nuevos, uno por logro.
- `assets/collection/secret.svg`: emblema genérico de bloqueo dibujado en código,
  usando la misma paleta de los marcos SVG existentes.

## Arte e importación

Fondo y 30 iconos generados individualmente mediante **image_gen integrado**.
Prompts exactos y procedencia: [provenance.json](provenance.json),
[icon_prompts.json](icon_prompts.json), [background_prompt.txt](background_prompt.txt).
Los originales seleccionados están copiados al proyecto; no dependen de la ruta
externa de generación. No se sustituyó ningún asset anterior.

Importación de iconos limitada a 256 px sin pérdida; fondo a 1280 px, compresión
con pérdida 0,85. Los 31 recursos importados ocupan aproximadamente **2,45 MiB**
localmente; esto no es una medición de exportación. Los PNG fuente conservan
su resolución. La política de iconos se conserva en `optimize_texture_imports.py`.

## Validación local

- 57/57 scripts `tests/test_*.gd` aprobados en Godot headless.
- `test_achievements.gd`: 121 comprobaciones, cero fallos (reglas, secretos,
  migración, persistencia, recibos, acumulación entre aventuras).
- `test_collection_ui.gd`: 41 comprobaciones, cero fallos tanto headless como
  con renderizado local X11/Compatibility (Mesa llvmpipe).
- Revisión visual de capturas a 1280×720: títulos, marcos, pestañas, grilla,
  detalle, iconos, progreso y botón Inicio con flecha junto al texto.
- Importación de recursos y `git diff --check` sin errores.
- Sin nueva prueba Web, emulador ni dispositivo físico. No se exportó Web ni APK.

## 16/10/2026 — Ilustraciones propias en Desbloqueos

Catorce iconos individuales (cuatro cartas, reloj y nueve reliquias exclusivas)
y un icono para la pestaña, en cómic postapocalíptico y 256 px. Los bloqueados
conservan visibilidad del arte y mantienen sus requisitos. No se modifican
recompensas/persistencia. [Procedencia y pruebas](../visual_polish_2026_10_16/README.md).
