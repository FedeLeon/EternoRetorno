# Optimización de importación — 22/09/2026

Se cambiaron opciones `.png.import`, no los PNG originales, rutas, UIDs ni reglas.
No se exportó Web/APK y no se modificó TestWeb.

## Política aplicada

- 180 ilustraciones/fondos usan Lossy a calidad 0,85: cómics, arte de cartas,
  fondos de pantallas e interiores. Conservan transparencia.
- Sprites de héroes/enemigos/equipo, números, iconos y marcos siguen Lossless.
- Ilustraciones individuales de cartas: máximo 512 px; las que ya tenían ese
  límite lo conservan. Atlas `originals.png` sin reducción por sus regiones fijas.
- Fondos grandes: máximo 1280 px. Marcos de cartas: 768 px en el lado mayor.
- Iconos del mapa: 192 px; bolsa, puerta, pestaña de grupo y terminar turno:
  256 px. Los pequeños sprites y atlas de movimiento mantienen sus dimensiones.
- Se preserva el límite existente de 512 px en los tablones de botones.

La pérdida de calidad se aplica únicamente a la copia importada. Se revisaron
comparaciones a tamaño de uso de escenario, cómic y carta, y los seis marcos
renderizados con texto nativo. No equivale a revisar cada imagen en cada pantalla.
Lossy reduce almacenamiento; no reduce por sí solo memoria de vídeo. Los límites
resolutivos sí reducen píxeles, por lo que deben revisarse si aumenta el tamaño de UI.

## Exclusiones auditadas

Ambos presets excluyen `assets/comic/attacks/*`: 18 variantes estáticas antiguas,
reemplazadas por `assets/comic/motion/<hero>_<variant>.png` en `hero_cut_in.gd`.
No hay referencias a la carpeta antigua en src ni data. Se conserva como fuente
local para regenerar arte. Los seis cómics principales siguen incluidos porque
`refuge_portrait.gd` los carga por ID. Defensa, enemigos, equipo y catálogos con
rutas dinámicas también se conservan. No se cambió a exportación por escenas:
las cargas por cadenas necesitan inclusión explícita de sus recursos.

## Medición local, no tamaño de descarga Web

Suma de los `.ctex` referenciados por los importadores PNG actuales (sin cachés
obsoletas, SVG, motor ni código):

| Estado | MiB |
| --- | ---: |
| Antes | 236,54 |
| Después de compresión y resolución | 106,18 |
| Después, descontando las 18 exclusiones | 96,19 |

Reducción estimada en texturas incluidas: 59,3 %. El paquete Web real y la descarga
HTTP deben medirse después de la exportación que hará el usuario.
`before.json` y `after.json` registran bytes por asset; campos mode/quality/size_limit
indican la política de destino, no la configuración histórica anterior.

## Repetición y comprobaciones

`python3 scripts/optimize_texture_imports.py` aplica la política; luego abrir Godot
para reimportar (o `./scripts/run.sh --headless --editor --import`).
`python3 scripts/optimize_texture_imports.py --report` solo actualiza la medición.
El script no exporta y conserva la medición inicial. Nuevas familias de imágenes
requieren revisar la política; no asumir que cualquier atlas puede reducirse.

Pruebas actuales: card_art 715, forge_assets 12450 y map 109 sin fallos;
comic_motion 1134 comprobaciones sin fallos, incluidos los 24 ataques y alfa.
Auditoría de configuración de sprites/dígitos/reliquias y referencias antiguas
correcta. Importación y diff sin errores. Capturas locales revisadas y eliminadas.
`test_support_cards_ui.gd` fue interrumpido al no concluir; no se cuenta como
aprobado. Se verificó en una vista renderizada independiente una carta de cada
héroe. No se validó navegador, emulador ni dispositivo físico.
