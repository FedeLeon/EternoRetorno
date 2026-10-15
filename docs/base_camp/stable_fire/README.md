# Edificios en sus solares y brasero fijo — 14/10/2026

## Edificios

El PNG completo tenía bandas transparentes amplias arriba/abajo. El ajuste por
altura reducía mucho el dibujo real y dejaba el solar casi vacío. La presentación
ahora usa un `AtlasTexture` sobre el rectángulo visible del PNG, conservando el
asset y sus proporciones. La escala responde al dibujo, no al lienzo vacío.

Las áreas se amplían sobre las superficies del suelo. El borde inferior es el
punto de apoyo; el centrado horizontal conserva el eje de cada solar. Las áreas
son límites de encaje, no una orden de deformar el edificio:

| Edificio | Área máxima, x/y/ancho/alto |
| --- | --- |
| Mercado | 88 / 157 / 342 / 205 |
| Expediciones | 476 / 478 / 328 / 200 |
| Taller | 56 / 376 / 350 / 224 |
| Laboratorio | 780 / 176 / 320 / 215 |
| Refugio | 352 / 220 / 282 / 175 |
| Proyectos | 866 / 416 / 282 / 183 |

Los solares vacíos y la construcción conservan sus reglas. El cartel acompaña
el borde inferior. Máscaras de clic usan la **misma textura recortada** que el
dibujo y respetan los carteles vecinos; los carteles se dibujan encima de techos.
Refugio y Proyectos también usan máscara. Los accesos, costes y edificios
permanentes no cambian.

## Barril y llamas separados

Antes se reproducía el dibujo entero: pequeñas diferencias de barril/posición
entre los 24 cuadros se percibían como un desplazamiento lateral. La alineación
vertical por base no corregía esos cambios horizontales.

`campfire.gd` ahora compone dos capas:

- **StaticBarrel:** `Sprite2D` con un único recorte del primer fotograma del asset
  existente. No tiene reloj de animación, offset variable ni deformación.
- **Flames:** `AnimatedSprite2D`, 24 ilustraciones nuevas solo de fuego, 12 FPS.
  Escala común, celdas 256×256 y raíz fija sobre el mismo borde del barril.
  Las chispas salen desde ese borde; la luz ambiental conserva su pulso.

Se reutiliza en el campamento y en la elección de personajes. La hoja original
sigue siendo necesaria como fuente del barril fijo; no se elimina por confundir
sus otros cuadros con una dependencia completamente inactiva. Los datos de
baselines antiguos quedan como registro del importador; ya no mueven el sprite
ni participan en la reproducción actual.

## Assets, herramientas y procedencia

- Nuevo recurso activo: `assets/camp/fire-flames.png`.
- Original RGBA: `sources/flames.png`, generado con herramienta integrada
  `image_gen.imagegen`; prompt, referencia y archivo original en
  [generation.json](generation.json). No se dibuja un fuego sustituto por código.
- `scripts/import_camp_flames.gd`: recorte/encaje geométrico, 6×4 celdas,
  escala proporcional compartida, máximo 124 px de altura de tinta y base 240.
- PNG activo registrado por hash y fuente en el inventario postapocalíptico.
  Importación con pérdida a 0,9 sin reducción de hoja, manteniendo los recortes.
- Los PNG de edificios no se modifican. La corrección se hace en su presentación
  con cache de AtlasTexture, no mediante estiramiento o eliminación de detalles.

Archivos funcionales: `base_camp_screen.gd`, `building_hotspot.gd` reutilizado,
`main.gd` (solo orden de carteles), `campfire.gd` y política de importación.
Sin cambios de reglas, guardados, RNG ni inventario del campamento.

## Validación actual

**89/89 suites headless**; render nativo: campamento/fuego **109/0**, solares
**149/0**, expansión/clics **33/0**. Auditoría: 643 hashes visuales válidos y
cero recursos antiguos/faltantes. [Resultados](validation.json). Pruebas de campamento cubren los 24 cuadros:
textura/transformación del barril constantes, raíz inmóvil y 24 dibujos de llamas
distintos. Los solares comprueban margen eliminado, ancho visible mínimo,
carteles dentro de vista, sin superposición y sin interceptar clics vecinos.
Prueba de expansión con clics reales confirma Aventuras y Expediciones.

Render local aislado a 1280×720, llvmpipe, audio Dummy y perfil privado. Revisión
del campamento completo y sus estados de construcción. Capturas desechables en
`artifacts/camp_dusk/` y `artifacts/camp_expansion/`, ignoradas por Git/exportación.
Avisos de recursos al cerrar registrados; sin exportar ni certificar Web,
Android, escucha real o dispositivo físico.
