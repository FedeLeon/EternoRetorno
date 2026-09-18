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
