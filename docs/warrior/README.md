# Guerrero — Portador Maldito

> **Actualización 16/09/2026:** los actores ahora usan cuadros de **128×128**,
> reimportados desde las fuentes originales. Se mantienen tamaño en pantalla,
> diseños y alineación. Ver [calidad actual, archivos y pruebas](../quality/README.md).
> Las medidas de 64 px y comprobaciones que siguen documentan la versión inicial.


Diseño basado en el concept art del usuario: casco cerrado, armadura de acero
oscuro, capa y penacho violeta, ojos magenta y espada con energía maldita.
Se conserva la clase Guerrero y sus reglas; cambia su apariencia en inicio,
selección, mapa, recompensa y combate, más el color de sus cartas.

## Archivos

- `assets/warrior/warrior-64.png`: atlas RGBA de **384 × 320**, 6 columnas y 5 filas.
- `src/warrior_sprite.gd`: AnimatedSprite2D, escalado entero y filtrado nearest.
- `docs/warrior/generated-sheet.png`: fuente seleccionada creada con **imagegen integrada**.
- `docs/warrior/prompts.md`: prompts completos usados para generar y ajustar la hoja.
- `scripts/import_warrior.gd`: recorte reproducible por filas y alineación de pies.

Cada cuadro mide **64 × 64**. La silueta conserva su escala durante ataques y caída;
la línea inferior se alinea en y=60. El importador contempla los márgenes reales
de la hoja generada, que no forman filas perfectamente uniformes. El canal alfa
se conserva; no se usan fondos negros ni una cuadrícula pintada.

En reposo, la línea de los pies se calcula con alfa ≥ 0,5: los residuos casi
transparentes debajo de las botas ya no elevan el último cuadro del ciclo.
La prueba de alineación comprueba esa silueta visible en los seis cuadros.

| Animación | Cuadros | FPS | Activación |
| --- | ---: | ---: | --- |
| idle | 6 | 6 | Reposo en las pantallas |
| attack | 6 | 12 | Tajo y Embestida |
| heavy | 6 | 9 | Golpe pesado y Filo del retorno |
| hurt | 6 | 15 | Pérdida de vida por ataques enemigos |
| death | 6 | 8 | Vida a cero; se mantiene el último cuadro |
| revive | 6 reutilizados en reversa | 9 | El compañero gana y el guerrero vuelve |

Guardia de hierro usa un pulso violeta sobre la pose de reposo. No se agregan
caminata ni carrera porque este combate no tiene desplazamiento libre.

Las acciones se resuelven y guardan **antes** de reproducir las animaciones.
Durante la secuencia se bloquean los toques adicionales. Al terminar se muestra
el estado actualizado; una derrota espera la caída antes de abrir el resultado.
Reabrir la aplicación restaura el estado de juego guardado, sin repetir cartas.

## Probar

```bash
./scripts/run.sh
./scripts/run.sh --headless --script tests/test_warrior.gd
# Prueba con capturas reales en docs/warrior (requiere pantalla gráfica):
./scripts/run.sh --script tests/test_warrior.gd
# Reconstruir el atlas desde la hoja fuente:
./scripts/run.sh --headless --script scripts/import_warrior.gd
```

Ver `idle.png`, `attack.png`, `heavy.png`, `hurt.png`, `fallen.png`, `revive.png`
y `selection.png`. Las capturas de prueba usan encuentros controlados para
comprobar las transiciones, sin modificar las estadísticas del juego distribuido.

## Validación

- 137 comprobaciones de reglas y 121 de interfaz sin fallos.
- 56 comprobaciones específicas: atlas, transparencia, alineación de cuadros,
  bucles, animaciones de cartas, caída persistente, recuperación, derrota,
  bloqueo de acciones repetidas y guardado antes de terminar la animación.
- Las poses se inspeccionaron renderizadas dentro del combate en escritorio.
- APK `builds/EternoRetorno-guerrero.apk` instalada sobre el emulador Pixel 5,
  Android 15/API 35: sprite renderizado, ataque por toque, consumo único de energía
  y reapertura con el mismo estado guardado. Capturas `android-idle.png` y
  `android-attack.png`; registro `android-test.log`. No se probó en teléfono físico.
