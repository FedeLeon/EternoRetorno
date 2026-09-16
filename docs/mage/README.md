# Maga

> **Actualización 16/09/2026:** los actores ahora usan cuadros de **128×128**,
> reimportados desde las fuentes originales. Se mantienen tamaño en pantalla,
> diseños y alineación. Ver [calidad actual, archivos y pruebas](../quality/README.md).
> Las medidas de 64 px y comprobaciones que siguen documentan la versión inicial.


Diseño basado en el concept del usuario: cabello plateado, capucha azul,
túnica blanca y azul con detalles dorados y bastón con cristales flotantes.

Atlas: `assets/mage/mage-64.png`, 384 × 384, 36 cuadros de 64 × 64.
Fuente: `generated-sheet.png`, creada con imagegen integrada; prompt completo
en `prompt.md`. `scripts/import_mage.gd` reproduce los recortes y el escalado
nearest, conservando alfa y alineando la silueta visible a y=60.

| Animación | FPS | Uso |
| --- | --- | --- |
| Reposo | 6 | Bucle |
| Proyectiles | 12 | Chispas, Misiles del vacío |
| Hechizo de área | 12 | Tormenta, Constelación rota |
| Barrera | 10 | Velo arcano |
| Daño | 15 | Pérdida de vida |
| Caída | 8 | Vida a cero |
| Recuperación | 9 | Caída en reversa tras victoria del compañero |

Cada secuencia tiene seis cuadros. La caída mantiene el último cuadro mientras
combate el compañero. Las reglas y estadísticas de cartas no cambian.
No se incluyen caminata ni carrera porque el combate no tiene movimiento libre.

## Validación local

`./scripts/run.sh --script tests/test_mage.gd`: 70 comprobaciones sin fallos,
con capturas de Godot en esta carpeta. Incluye las cinco cartas, daño a dos
enemigos, ataques múltiples, bloqueo de entrada repetida, persistencia,
caída, recuperación y derrota. Usa una partida aislada.

También pasaron guerrero (56), guardiana (67), pícaro (69) e interfaz (121):
383 comprobaciones en total. No se compiló APK ni se probó en Android.
