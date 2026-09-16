# Biblioteca de enemigos

> **Actualización 16/09/2026:** los 56 enemigos usan sprites de **128×128**
> desde `assets/enemies/hd/`. Los seis de la cripta tienen ciclos nuevos de
> ocho poses en `assets/enemies/animations/` y ataques diferenciados.
> Ver [estado actual, fuentes, prompts y pruebas](../quality/README.md).
> El contenido siguiente describe la primera incorporación a 64 px.


56 sprites RGBA de 64 × 64 derivados de las siete plantillas del usuario.
Los originales generados se conservan como `sheet-1.png` a `sheet-7.png`.
`scripts/import_enemies.gd` separa las figuras, mantiene su proporción y las
alinea sobre una línea de suelo común usando escalado vecino más cercano.
Las variantes de lobo, bandido, lancero, cuervo y murciélago se conservan
por separado aunque algunos conceptos compartan nombre.

## Primera cripta

| ID de encuentro conservado | Nueva apariencia y nombre |
| --- | --- |
| rat | Murciélago nocturno |
| skeleton | Esqueleto lancero |
| cultist | Chamán de ceniza |
| slime | Baba ácida |
| elite | Esqueleto guardián |
| boss | Autómata roto |

Se conservan vida, patrones, recompensas y semillas; los guardados existentes
resuelven los nuevos gráficos mediante los mismos IDs. Los otros 50 sprites
no entran en los encuentros actuales. `data/enemy_visuals.json` registra nombre,
familia de origen, tipo de movimiento y piso (0 significa reservado).

## Animaciones

`src/enemy_sprite.gd` comparte animaciones procedurales de Godot para todas las
figuras: respiración con pivote inferior, flotación de voladores, pulsación de
babas, anticipación y avance al atacar, retroceso y destello al recibir daño,
y caída atenuada que se mantiene hasta abandonar el combate. Son movimientos
del sprite completo, no secuencias dibujadas de extremidades ni aleteo por cuadros.
No consumen el generador aleatorio de la aventura. La resolución y el guardado
siguen precediendo a la animación para evitar repetir acciones al reanudar.

## Comprobación

`./scripts/run.sh --script tests/test_enemies.gd` revisa las 56 imágenes y sus
animaciones, los seis reemplazos en combate y genera galería y capturas.
`tests/test_game.gd` comprueba reglas y las 15 parejas; `tests/test_warrior.gd`
comprueba la secuencia de combate, bloqueo de entradas, muerte y recuperación.
Pruebas locales con Godot 4.7.2 Compatibility en Linux. Sin APK ni prueba Android.

Para reutilizar un enemigo, asignar un ID de `enemy_visuals.json` al campo
`visual` de su definición de combate. Las estadísticas de futuras mazmorras
todavía no están definidas.
