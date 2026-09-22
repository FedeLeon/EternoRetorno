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

## Ataques en primer plano — 18/09/2026

Los seis enemigos activos de la cripta tienen ilustraciones de ataque en cómic
con transparencia y dirección derecha → izquierda. Se presentan abajo a la
derecha durante ataques realmente resueltos. [Assets, arquitectura y pruebas](../comic/README.md#enemigos-de-la-primera-mazmorra).

## Muerte en cenizas — 18/09/2026

Los enemigos ahora se disuelven con brasas y cenizas durante 1,3 s en total,
y luego se ocultan. Reemplaza la caída lateral atenuada. Delegación visual en
`presentation/enemy_ash.gd`; 498 comprobaciones de enemigos aprobadas y revisión
renderizada local. [Detalles](../quality/README.md).


## Contraataque y golpes independientes — 18/09/2026

El lancero (`skeleton`) adopta contraataque cada tercer turno; el guardián
(`elite`) y autómata (`boss`) cada cuarto. Es un patrón recurrente,
sin azar adicional. El guardián además anuncia 6 de bloqueo futuro.
La espada con flecha de retorno y número 4 marca una postura **ya activa**
durante el turno del jugador; desaparece cuando cambia la intención.

Cada impacto directo recibido devuelve 4 de daño al héroe atacante si el
enemigo sobrevive, incluso si su bloqueo absorbió el golpe. Se aplican las
mitigaciones y Fénix normales del héroe. Veneno periódico y aplicaciones de
veneno sin impacto no disparan esta respuesta. Un golpe mortal no genera
contraataque. La muerte del atacante cancela los impactos restantes; si ambos
héroes caen se resuelve derrota. Las cartas del héroe caído quedan inactivas.

Los ataques múltiples resuelven impacto/respuesta uno por uno. Por ejemplo,
3×5 produce tres impactos de 5 alternados con tres respuestas de 4.
Una sinergia es un impacto conjunto: su respuesta se atribuye al primer héroe
de la receta. Los consumibles conservan su resolución actual y no cuentan
como golpes de carta.

`rules/card_hits.gd` aplica la secuencia mediante las operaciones del juego.
`game.resolved_card_hits` es un recibo transitorio; el estado final se guarda
antes de animar. `presentation/card_impacts.gd` reproduce cada ataque, flash,
vida decreciente y bloqueo restante. No se cambia el formato de guardado:
intenciones ya guardadas continúan hasta el siguiente turno.

## Enemigos del bosque — 22/09/2026

Se activan siete apariencias existentes con reglas nuevas en
`data/forest_enemies.json`: goblin guerrero, arquero, chamán y jefe, lobo, jabalí
y oso ancestral. Tienen atlas de ocho poses (cuatro reposo y cuatro ataque) y
viñetas transparentes desde la derecha. [Assets, importación y pruebas](../forest/README.md).
La cripta conserva sus ciclos anteriores. Los combates de tres enemigos usan
espaciado y barras adaptadas para mantener todo el HUD dentro de la pantalla.

## Esqueletos y elementales de la cripta — 22/09/2026

Seis diseños existentes ahora activos: esqueletos guerrero, arquero, escudero y
berserker; elementales de roca y sombra. Diez tipos comunes para la primera
mazmorra, grupos mixtos y apariciones por etapa. [Catálogo, assets, procedencia
y organización](crypt_expansion/README.md). Mapas guardados intactos.
