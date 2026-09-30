# Colección de ecos — 30/09/2026

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
