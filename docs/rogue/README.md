# Pícaro

> **Actualización 16/09/2026:** los actores ahora usan cuadros de **128×128**,
> reimportados desde las fuentes originales. Se mantienen tamaño en pantalla,
> diseños y alineación. Ver [calidad actual, archivos y pruebas](../quality/README.md).
> Las medidas de 64 px y comprobaciones que siguen documentan la versión inicial.


Concept del usuario: capucha verde oscura, máscara de pico marfil, ojos verdes,
cuero marrón, capa rasgada, dos dagas curvas y frascos de veneno.

Atlas `assets/rogue/rogue-64.png`: 384 × 384, cuadros de 64 × 64 con alfa real.
Generado mediante imagegen integrada; prompts completos en `prompt.md`.
`generated-sheet.png` aporta reposo, esquiva, daño y caída. Los ataques y
el lanzamiento usan `generated-actions.png`, generado aparte para evitar
solapamientos entre poses de la primera hoja.

`scripts/import_rogue.gd` permite reconstruir el atlas: recorte, escalado nearest
y alineación por píxeles visibles a y=60, ignorando residuos casi transparentes.

| Animación | FPS | Acción |
| --- | --- | --- |
| Reposo | 6 | Bucle de respiración |
| Dagas | 12 | Puñalada, Hoja tóxica, Herida perpetua |
| Veneno | 12 | Veneno negro |
| Esquiva | 10 | Paso sombrío |
| Daño | 15 | Pérdida de vida |
| Caída | 8 | Vida a cero, último cuadro persistente |
| Recuperación | 9 | Caída en reversa tras victoria del compañero |

Cada secuencia usa seis cuadros. Sin caminata ni carrera, porque el combate
actual no tiene movimiento libre. Estadísticas y efectos de cartas sin cambios.

## Validación

`./scripts/run.sh --headless --script tests/test_rogue.gd` comprueba alineación,
cartas, aplicación de veneno, bloqueo de toques repetidos, guardado previo a
animación, daño, caída, recuperación y derrota. Usa una partida aislada.
Sin `--headless`, guarda capturas de Godot en esta carpeta.
Se comprueban también las pruebas de guerrero, guardiana e interfaz.
No se compiló APK ni se probó este cambio en Android.
