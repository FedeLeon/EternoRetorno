# Refugio central, Aventuras y animales — 15/10/2026

## Distribución

- Refugio permanente sobre el círculo del brasero, con área máxima
  `516 / 116 / 282 / 175`; conserva recorte alfa, proporción y apoyo por la base.
  Su cartel queda debajo del edificio. Separado del Mercado y con los mismos
  callbacks de acceso a la galería de héroes.
- Aventuras pasa de una zona invisible con cartel a un botón visible de
  **164×164**, en `1100 / 116`. Icono Play de **128×128** y texto dentro del botón.
  Se reutiliza `assets/ui/play.svg`, rasterizado al doble para este tamaño;
  se conserva UID y no se agrega un símbolo de fuente.
- El botón abre el menú existente de aventura nueva/continuar. No se modifica
  la aventura activa ni las confirmaciones de reemplazo.

## Electricidad

`camp_adventure_button.gd` compone el acceso. Reutiliza
`presentation/end_turn_electricity.gd` con `rectangular=true`: los arcos y chispas
siguen el borde cuadrado y dejan despejados icono y texto. Capa sin captura de
entrada; respeta intensidad de destellos y calidad de efectos. Por defecto sigue
siendo circular para Terminar turno y Configuración.

## Perro y gato

Dos hojas ilustradas independientes, en cómic y con transparencia real. Cada
animal tiene ocho poses: cuatro de pasos alternados y cuatro para bajar la
cabeza/olfatear/comer y levantarla. El perro es marrón claro con orejas oscuras;
el gato gris, con pecho y patas claras.

`camp_companions.gd` alterna caminar, olfatear/comer y pausas. Patas/cuello/cola
cambian mediante sprites, sin estirar todo el cuerpo. Caminan despacio por
recorridos cortos; las patas conservan la misma altura del suelo. Estados y
duraciones se desfasan entre ambos animales.

| Animal | Recorrido horizontal | Suelo Y | Escala del cuadro |
| --- | --- | --- | --- |
| Perro | 451…488 | 536 | 0,57 |
| Gato | 1144…1194 | 393 | 0,42 |

El perro está en el pasillo a la derecha del Taller, y el gato a la derecha del
Laboratorio. Se revisaron con edificios construidos para evitar que parezcan
parados sobre los muros del primer plano. Dibujos/sombras decorativos sin
captura de clics. RNG visual propio; no alteran partidas, reglas o progreso.

## Assets y procedencia

- Activos: `assets/base_camp/companions/dog.png` y `cat.png`.
- Herramienta integrada **`image_gen.imagegen`**, una generación por animal.
- `jobs.json` y cada `<animal>.json`: prompts exactos, ruta original, herramienta,
  fecha, dimensiones reales y hash. `sources/` conserva las hojas originales.
- `scripts/import_camp_companions.gd` valida ambas hojas antes de reemplazar
  recursos. Divide cuadrícula 4×2, conserva una escala común por animal y prepara
  atlas de **768×384**, cuadros de **192×192**, apoyo a **174 px**.
- Inventario general `art_direction/postapocalyptic/assets.json` conserva hashes
  del PNG activo/fuente y vínculo al registro de generación. Originales excluidos
  de exportación con el resto de `docs/`.

## Validación local

- `test_camp_companions.gd`: **54/0 headless y 54/0 nativo** en Xephyr/llvmpipe,
  con audio Dummy. Ocho poses distintas por animal, apoyo, movimiento de patas,
  comida sin desplazamiento, pausas, límites, RNG/progreso intactos, clic real
  sobre Play y acceso al refugio reubicado.
- `test_camp_plot_ground.gd`: **155/0 nativo**, capturas de cada construcción;
  carteles, máscaras y edificios sin superposición de accesos.
- `test_base_camp.gd`: **38/0 nativo**, incluida continuación de aventura.
- Regresiones focalizadas: Inicio **16/0**, HUD **112/0**, expansión **33/0**
  headless. Se revisaron capturas reales del patio y animales. Auditoría general:
  **680 recursos visuales válidos**, sin fuentes pendientes ni errores de hash.
- Avisos de recursos/ObjectDB al cerrar algunas suites, sin errores de script
  ni aserciones. Sin exportar ni probar Web, emulador o dispositivo físico.

Capturas de prueba en `artifacts/camp_companions/` y `artifacts/camp_dusk/`,
ignoradas por Git. No se escribe el guardado personal.
