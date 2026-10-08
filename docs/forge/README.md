## Actualización de pulido — 07/10/2026

[Implementación actual, assets, reglas y validación](../polish_2026_10/README.md).
La documentación y resultados anteriores se conservan como historial.

# Herrería y equipo permanente

## Reglas (17/09/2026)

El solar 3 permite construir la herrería por **400 almas**, una sola vez por
perfil. El edificio construido abre el interior con el herrero. Se reutilizan
la cabecera del campamento, el saldo gráfico y los botones de madera.

Cada uno de los seis héroes tiene dos ramas independientes:

| Rama | Niveles | Beneficio acumulado |
| --- | --- | --- |
| Arma | 0, 1, 2, 3 | +0, +1, +2, +3 de fuerza por golpe de cartas de daño |
| Armadura | 0, 1, 2, 3 | +0, +2, +4, +6 al bloqueo de sus cartas defensivas |

Cada rama cuesta **150 / 300 / 600 almas** por sus tres mejoras sucesivas.
No se pueden saltar niveles, recomprarlos ni superar el nivel 3. El servidor de
reglas valida saldo, héroe, rama y nivel esperado, aunque se repita un callback.
La fuerza también participa en sinergias mediante el cálculo compartido de daño.
No aumenta veneno o curación; el bloqueo adicional solo se suma a cartas que ya
conceden bloqueo. Estos valores están en `data/forge.json`, pendientes de balance
con partidas humanas; no se añadió otra entrega automática de almas.

## Persistencia

- `profile.buildings.forge`: construcción permanente.
- `profile.forge_upgrades.<hero>.weapon/armor`: niveles permanentes 0–3.
- `run.heroes[].forge`: instantánea de niveles y bonificaciones tomada al crear
  la aventura. Las compras del campamento se aplican desde la siguiente run.
- Runs anteriores sin instantánea mantienen estadísticas y sprites anteriores.
- Migración aditiva y guardado atómico existentes; ningún ID anterior cambia.
- La pérdida de la aventura no elimina construcción, niveles ni almas.

## Arquitectura

- `src/rules/forge_progression.gd`: configuración, migración, compras y snapshot.
- `src/game.gd`: API pública y checkpoint tras cada compra/construcción.
- `src/ui/forge_navigation.gd`: apertura, confirmación de obra y callbacks.
- `src/ui/screens/forge_screen.gd`: categorías, niveles, precios y vista previa.
- `src/ui/screens/base_camp_screen.gd`: edificio y entrada del solar 3.
- `src/presentation/hero_equipment.gd`: sustitución de atlas conservando contrato
  de animaciones, velocidades, bucles y recuperación invertida.
- `scripts/import_forge.gd`: recorte/normalización a 128 px desde fuentes generadas;
  usa anclajes y alturas por fila del atlas anterior, preservando alfa.

## Arte

Herrero e interior: `assets/forge/interior.png`. Edificio transparente:
`assets/forge/building.png`. Generados con la herramienta integrada image_gen;
procedencia y prompts en esta carpeta. No se utilizó CLI/API externa.

Se incluyen **96 atlas: 16 combinaciones por héroe** (arma 0–3 × armadura 0–3),
incluyendo el equipo inicial; son 3.360 cuadros de arte. Los atlas conservan seis cuadros por acción y las filas
originales de cada clase. Los movimientos procedurales, la reacción al daño y
la salida del combate siguen a cargo de los componentes existentes.

Fuentes y prompts individuales: `docs/forge/sources/<hero>_w<W>_a<A>.png/.json`.
Atlas de juego: `assets/forge/heroes/<hero>_w<W>_a<A>.png`.
Los atlas anteriores de `assets/<hero>/` siguen siendo necesarios: contienen el
contrato original de animación y mantienen el aspecto de aventuras antiguas.
La selección frontal y los retratos de intención conservan sus imágenes existentes;
el equipo nuevo se muestra en combate, mapa, recompensas y vista previa de la herrería.

Reimportar después de añadir fuentes:

```bash
./scripts/run.sh --headless --script scripts/import_forge.gd
./scripts/run.sh --headless --editor --import
```

El importador no sobrescribe atlas ya normalizados; para reimportar una variante
corregida, retirar únicamente su PNG de destino antes de ejecutarlo.
La caché de reproducción conserva hasta ocho variantes; los actores que están
en pantalla mantienen sus propias referencias. No se cargan los 96 atlas juntos.
`scripts/preview_forge.gd -- <hero>` permite revisar las 16 variantes de una clase
en escritorio; las capturas se escriben en `artifacts/forge/` y son desechables.

## Validación

- Reglas/persistencia: **330 comprobaciones** (costes, niveles, seis héroes,
  cartas, recarga, derrota, migración, duplicados e instantáneas de run).
- Assets/animaciones: **10.626 comprobaciones**, 96 atlas distintos y transparentes,
  dimensiones/cuadros/velocidades/bucles, mantenimiento de pose y pausa; reproducción
  de ataque, muerte y recuperación de las seis clases.
- Interfaz de herrería renderizada: **46 comprobaciones**, categorías, compras,
  saldo visible, nivel máximo, regreso, clics de mercado/herrería coexistentes
  y correspondencia del atlas mejorado en batalla.
- Regresiones locales: reglas 155 (42/45 victorias simuladas sin mejoras),
  progresión/mercado 819, campamento 33, UI general 271, HUD 92, distribución 38,
  mapa 21; todas sin fallos. Las simulaciones no representan balance humano.
- Revisión visual Linux a 1280×720: seis galerías de variantes, campamento con
  ambos edificios, interior, mapa y tres parejas en combate con equipo máximo.
  Capturas temporales retiradas tras revisarlas. Prompts/fuentes conservados.
- Sin exportar APK/Web. No probado en navegador, emulador o dispositivo físico;
  el balance de las mejoras sigue pendiente de partidas humanas.

## 18/09/2026 — Equipo mejorado en el HUD de combate

Armas y armaduras con nivel 1–3 aparecen después de las reliquias en la barra
superior del combate y de su recompensa. Cada icono lleva el nivel con los
dígitos existentes; al tocarlo abre el cuadro compartido con héroe, nivel y
bonificación de fuerza por golpe o bloqueo en cartas defensivas. Se conserva
el cierre por segundo toque, toque exterior y Volver. Los niveles 0 no aparecen.

Se muestran los valores de `run.heroes[].forge`, aplicados al inicio de la
aventura, sin recalcular desde el perfil ni modificar partidas en curso.
`src/presentation/equipment_badges.gd` prepara descripciones y texturas;
`combat_hud.gd` presenta reliquias y equipo en la misma fila, ajustando
separación si fuera necesario. Las pantallas de combate/recompensa suministran
la instantánea. La interfaz no concede mejoras ni guarda.

Assets nuevos: `assets/forge/icons/`, 21 SVG transparentes dibujados en código
como extensión de los iconos vectoriales existentes: seis armas (espada,
escudo de guardiana, dagas, báculo arcano, báculo sagrado y arco) y armadura,
cada una en tres niveles con metales y gemas distintos. Son iconos de HUD;
los atlas de personajes conservan su arte actual. Sin generación de imágenes.

Validación actual: `test_forge_ui.gd`, 97 comprobaciones renderizadas locales
sin fallos, incluyendo los cuatro equipos de cada pareja, apertura/cambio de
cuadro, héroe/nivel y bonos +3/+6; `test_hud.gd`, 107 headless sin fallos.
Importación y `git diff --check` correctos. Revisión visual Linux 1280×720;
capturas temporales eliminadas. Sin exportación ni prueba en dispositivo.

## 18/09/2026 — Regreso al campamento desde la barra de herrería

La herrería muestra únicamente «Campamento» como acción de navegación en la
barra superior: reemplaza «Menú» y elimina «Volver al campamento» inferior.
Mantiene marco y almas, desplazando el contador para dar espacio al botón.
`preparation_header.gd` admite una etiqueta opcional; las demás pantallas
conservan «Menú» por defecto. `forge_screen.gd` conecta la acción de regreso;
se retira el callback de menú sin uso en `forge_navigation.gd`.

Validación local headless: `test_forge_ui.gd`, 97 comprobaciones sin fallos,
incluido clic en Campamento superior y retorno. `git diff --check` correcto.
Sin revisión visual manual de este cambio ni exportación.

## 18/09/2026 — Categorías visuales de héroe en herrería

La columna de selección reutiliza miniatura frontal, nombre y marco del color
de cada clase del mercado. Se extrae `ui/components/hero_category.gd` para
que ambas tiendas compartan la presentación; IDs y callbacks se conservan.
La vista previa animada de equipo aumenta un 25 % (área de 124 a 155 px),
reposicionada en la esquina derecha del bloque sin tapar textos ni compras.
Se reutilizan `assets/cards/<hero>.png` y el atlas frontal; sin assets nuevos.

Validación actual: herrería renderizada en Linux 1280×720, 97 comprobaciones
sin fallos; mercado headless, 34 sin fallos. Revisión visual del interior con
las seis categorías y personaje ampliado; `git diff --check` correcto.
Capturas temporales eliminadas. Sin exportación ni prueba en dispositivo.

## 18/09/2026 — Sustitución del arte de equipo del HUD

Los 21 SVG simples de armas/armadura se reemplazan por PNG transparentes de
128×128 en `assets/forge/icons/`. Tres niveles para cada arma (espada violeta,
escudo turquesa, dagas verdes, báculo azul, báculo sagrado y arco azul) y tres
armaduras comunes. Metal desgastado, grabados, gemas y acabados progresivos
siguen el pixel art detallado de las reliquias. Dígitos y cuadros siguen siendo
componentes de interfaz; no se pintan números ni marcos sobre los assets.

Generados con image_gen integrado, usando `assets/objects/icons.png` como
referencia estilística; edición posterior mediante la misma herramienta para
extraer fondo transparente. Prompts completos, fuentes y procedencia:
`docs/forge/hud-icons.json`; cuatro hojas finales en `hud-sources/`.
`scripts/import_equipment_icons.gd` recorta celdas y normaliza la silueta a
112 px dentro de un lienzo de 128 px, preservando alfa; ignora alfa residual
inferior a 0,25 solo para calcular los límites del recorte. No recalcula reglas.
`presentation/equipment_badges.gd` carga PNG. SVG sustituidos eliminados.

Validación: 21 PNG comprobados por tamaño, canal alfa, transparencia de borde
y contenido; importación Godot y diff sin errores. Prueba de herrería/HUD
renderizada local con 97 comprobaciones aprobadas; revisión visual de iconos
y cuadro de efecto en combate. Sin exportación ni dispositivo físico.
Capturas temporales eliminadas; fuentes y prompts se conservan.


## 22/09/2026 — Selección mediante tarjetas de héroes

Al entrar se muestran seis tarjetas de cara y torso, reutilizando
`refuge_portrait.gd` y el arte comic existente. No hay héroe preseleccionado.
`building_hero_picker.gd` comparte la galería entre mercado y herrería.

Al tocar una tarjeta desaparece la galería y aparece el bloque de operaciones
exclusivo de ese héroe. Comprar conserva la selección y actualiza saldo/estado.
«Volver a héroes» restaura la galería; Atrás/Escape sigue ese mismo recorrido.
El botón superior Campamento sale directamente del edificio. Entrar otra vez
siempre comienza en la galería. Sin cambios en precios, compras ni guardados.

Se retiró hero_category.gd y su constante CAMP_FRONT, ya sin consumidores.
El atlas frontal se conserva para retratos de intención de combate.

Validación actual: mercado 49 y herrería 110 comprobaciones renderizadas sin
fallos, con los seis héroes, compras y regreso a la galería. Campamento: 33
comprobaciones headless aprobadas. Revisión visual Linux 1280×720 de galería y
paneles; capturas retiradas. Sin exportación Web/APK ni prueba en dispositivo.


## 22/09/2026 — Galería a la derecha

Las seis tarjetas de héroes se distribuyen en dos columnas y tres filas en el
sector derecho (desde x=738 en el lienzo 1280×720), dejando libre al personaje
del edificio a la izquierda. Tarjetas compactas de 244×166, nombres legibles
y encuadres de cara/torso ajustados por héroe sobre los assets comic existentes.

`building_hero_picker.gd` admite el modo `right_grid`, activado solo por Mercado
y Herrería; `refuge_portrait.gd` aporta el formato compacto y sus recortes.
Validación actual: mercado 49/49 y herrería 110/110 con render local, revisión
visual de galerías a 1280×720. Capturas temporales retiradas. Sin exportaciones.

## Volver a héroes en el encabezado — 23/09/2026

Mercado y Herrería ubican el botón dentro del panel derecho, a la derecha del
título. El mercado reserva ancho para el nombre y Nuevas cartas; la herrería
baja la vista del héroe y sus mejoras para evitar superposiciones. Se conserva
el estilo de tablón y la navegación existente.

Pruebas headless: mercado 61 y herrería 110 comprobaciones sin fallos.
Revisión visual local de ambas vistas a 1280×720; capturas temporales retiradas.
Sin exportación ni validación Web/móvil.

## Diálogo del herrero — 30/09/2026

Cinco frases ambientales alternadas en un globo abajo a la izquierda, tanto en
la galería como en la mejora de equipo. Reutiliza el fondo y no captura clics.
[Componente y validación actual](../base_camp/attendants.md).
