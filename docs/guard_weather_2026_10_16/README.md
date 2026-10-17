# Guardia dibujada y escenarios lúgubres

Actualizado el **16/10/2026**. Estilo vigente: cómic americano postapocalíptico,
cuatro civiles con herramientas improvisadas; no cambia la identidad de los héroes.

## Guardia con dibujos propios

Cuatro hojas nuevas, **24 dibujos por héroe / 96 dibujos en total**, en
`assets/heroes/guard/{warrior,guardian,rogue,mage}.png`. Manos y armas cambian de
postura de guardia, pecho/hombros respiran, pelo, trenza, pañuelo y ropa acompañan
la brisa. Cada hoja tiene seis columnas por cuatro filas de celdas de 256 px.

`detailed_hero.gd` utiliza estas hojas solamente en reposo; ataques, defensa,
carrera y caída conservan sus recursos y prioridad. `hero_guard_idle.gd` reproduce
los 24 dibujos hacia delante y hacia atrás: **46 pasos por ciclo**, no 46 dibujos
nuevos. Ciclos de 3,8–4,28 s desfasados, alrededor de 11–12 cambios por segundo.
No añade copias difuminadas ni deforma el cuerpo mediante shader. La guardia se
interrumpe al actuar, correr o caer y vuelve desde neutral al terminar la acción.

El importador aplica una escala proporcional común a cada hoja y ancla las botas
al mismo suelo y centro de apoyo. No reajusta el tamaño fotograma a fotograma.
La altura inicial se guarda en los datos de presentación, conservando el tamaño
visual de los héroes y la alineación con las otras acciones. Se retira el include
anterior `guard_breath.gdshaderinc`, que ya no usa la presentación actual.

## Seis fondos nuevos

Reemplazan los PNG existentes, conservando rutas e importación:

| Piso | Recursos |
| --- | --- |
| Mantenimiento | `assets/dungeon/combat.png`, `combat_columns.png`, `combat_canal.png` |
| Zona invadida por vegetación | `assets/forest/combat_glade.png`, `combat_ruins.png` |
| Reactor | `assets/volcano/combat.png` |

Tinta negra, acero gris, violeta y azul petróleo; luces pequeñas y oscuridad en
estructuras/vegetación. Suelo continuo y despejado para las unidades. Son imágenes
nuevas, no solamente un filtro de oscuridad. Se conserva el tinte de escenario;
no oscurece personajes, cartas o HUD. `battle_background.combat_rect` ajusta el
encuadre al suelo de los nuevos dibujos (horizonte 0,59 / 0,56 / 0,59).

## Ambiente animado

`battle_atmosphere.gd` dibuja el ambiente detrás de los personajes, sin capturar
clics ni cubrir cartas. Hojas giratorias y viento en el bosque; polvo/aire en
mantenimiento y cenizas en reactor. Una variante exterior incorpora lluvia suave;
la variante interior usa gotas de filtraciones, no lluvia en una sala cerrada.

La variante depende de semilla + sala, sin consumir el RNG de reglas. El reloj
visual es independiente. Hasta 24 partículas ambientales y 48 gotas; redibujo
limitado a 30 Hz. «Menos partículas y luces» usa 8 partículas, 16 gotas y 15 Hz.
No se crea un nodo por partícula ni se cargan texturas durante el ambiente.
Estos límites son de implementación; **no certifican FPS ni mejoras en Web**.

## Procedencia y reproducción

Generación con **image_gen.imagegen integrado**, sin API key. Prompts completos,
referencias y rutas originales en [jobs.json](jobs.json). Originales conservados
en `sources/` con `.gdignore`; los presets de exportación excluyen `docs/*`.

`scripts/import_guard_weather.gd` recorta/empaca geométricamente sin inventar
fotogramas y actualiza altura de presentación y manifest de procedencia. Usa una
altura objetivo fija por trabajo para que repetirlo no achique progresivamente
los personajes. Las hojas nuevas usan importación comprimida con calidad 0,9.
Los primeros planos HD estáticos y sus efectos no cambian.

## Validación local

Regresión: **105 suites verificadas sin fallos pendientes**. El recorrido inicial
pasó 103; dos pruebas aún exigían 12 poses/ruta anterior de reposo. Se actualizaron
para verificar 24 dibujos y el nuevo recurso conservando las comprobaciones de
equipo/apoyo, y ambas pasaron al repetirlas: héroes detallados **1.265/0** y
herrería **96/0**. No se presenta el primer recorrido como 105/105 limpio.
Informes originales y repetición conservados en `artifacts/guard_weather/regressions`;
[resumen](validation.json).

- Guardia: **1.354/0 headless y 1.354/0 nativo aislado**; dibujos diferentes,
  apoyo, escala, interrupción por ataques/carrera y caída.
- Ambiente: **249/0 nativo aislado**; variantes, posición de partículas, modo
  reducido, capas y ausencia de mutaciones de aventura/RNG.
- Distribución/inspección: **184/0 nativo aislado**; render de los tres pisos,
  objetivos, carta ampliada e iconos al pie.
- Render/primeros planos/desbloqueos: **118/0 nativo aislado**; ahora comprueba
  cambios de dibujo de guardia en el render real y apoyo fijo.
- Atlas: **100 hojas / 1.024 fotogramas / 0 errores**. Procedencia vigente de
  **716 recursos**, sin recursos heredados pendientes en ese inventario.

Capturas revisadas de reactor y bosque con lluvia en `artifacts/combat-floor/`
y `artifacts/guard_weather/`; reposo en `artifacts/guard_idle/`. Godot 4.7.2,
ventanas locales aisladas con Mesa/llvmpipe y audio Dummy. Algunas suites emiten
avisos de recursos retenidos al cerrar, separados de los fallos de aserciones.

**Sin exportar Web/APK, sin medir FPS en navegador y sin probar dispositivo físico.**
La apreciación final del ritmo de guardia queda a revisión del usuario jugando.
