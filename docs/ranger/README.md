# Explorador

> **Actualización 16/09/2026:** los actores ahora usan cuadros de **128×128**,
> reimportados desde las fuentes originales. Se mantienen tamaño en pantalla,
> diseños y alineación. Ver [calidad actual, archivos y pruebas](../quality/README.md).
> Las medidas de 64 px y comprobaciones que siguen documentan la versión inicial.


Diseño basado en el concept del usuario: capucha y capa azul desgarrada,
rostro cubierto, cuero oscuro, carcaj y arco largo asimétrico.

Atlas: `assets/ranger/ranger-64.png`, 384 × 384, 36 cuadros de 64 × 64.
Fuente: `generated-sheet.png`, creada con imagegen integrada. Prompt completo
en `prompt.md`. `scripts/import_ranger.gd` reproduce el recorte y escalado
nearest conservando alfa y alineando la silueta visible a y=60.

| Animación | FPS | Uso |
| --- | --- | --- |
| Reposo | 6 | Bucle |
| Disparo | 12 | Flecha certera y Doble disparo |
| Disparo potente | 12 | Disparo al corazón y Último horizonte |
| Retirada | 10 | Retirada |
| Daño | 15 | Pérdida de vida |
| Caída | 8 | Vida a cero, último cuadro persistente |
| Recuperación | 9 | Caída en reversa |

Cada secuencia tiene seis cuadros. Doble disparo comparte la secuencia visual
de arco; sus dos impactos se resuelven en las reglas de combate. No se agregan
lluvia de flechas, marcas ni movimiento libre: las cartas y estadísticas actuales
se conservan.

## Pruebas locales

`./scripts/run.sh --script tests/test_ranger.gd` usa una partida aislada y guarda
capturas de Godot aquí. Comprueba las cinco cartas, perforación del bloqueo,
los dos impactos, persistencia, caída, recuperación y derrota. Agregar
`--headless` para ejecutarla sin ventana.

También se ejecutan las pruebas de los otros cinco personajes y de interfaz.
No se compiló APK ni se probó este cambio en Android.
