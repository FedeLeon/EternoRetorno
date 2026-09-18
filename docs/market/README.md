# Mercado, almas y progresión de cartas

Implementado el 16/09/2026. Campamento → solar 1 → construir → mercado.
Construir cuesta **300 almas** y se hace una sola vez. Con el mercado construido,
el mismo solar abre su interior. Atrás vuelve al campamento sin alterar la run.
Las otras construcciones y mejoras de héroes siguen pendientes.

## Economía inicial

- Victoria normal: **30 almas**; élite: **80**; jefe: **150**.
- Saldo permanente: se conserva al perder, ganar o iniciar otra aventura.
- Seis cartas comprables por héroe, precios **100, 140, 180, 220, 260 y 320**.
- Comprar desbloquea una carta para el conjunto de recompensas de su clase;
  no la añade al mazo actual ni al inicial, y no garantiza que salga al ganar.
- Las recompensas siguen ofreciendo tres cartas compatibles con la pareja.
- El mercado actualmente vende cartas. Venta de consumibles, mejoras de héroes
  y ventajas de otros edificios se incorporarán posteriormente.

### Almas para probar

`data/progression.json` habilita **5.000 almas una sola vez por perfil**,
mediante `test_grant.id = market_playtest_1`. Se añaden al saldo existente al
cargar esta versión. No se reponen al reiniciar ni al comenzar una run.
Para desactivar la entrega en futuras distribuciones: `test_grant.enabled=false`.
Esto no elimina almas ya concedidas. No cambiar el ID para cada actualización.

## Cartas y balance

90 cartas: las 30 originales más **10 nuevas por cada héroe**. De esas diez,
dos son básicas para el mazo inicial, dos se obtienen libremente en recompensas
y seis se desbloquean en el mercado. Se conservan las seis cartas originales
que se desbloquean con la primera victoria de cada clase.

Cada héroe empieza con diez cartas (cuatro tipos): cuatro copias de su ataque base,
cuatro de su defensa base y una de cada nueva carta básica. La pareja suma 20. Las otras
cartas originales se siguen consiguiendo en recompensas. Las mejoras mantienen
+3 a daño/bloqueo/curación y +2 a veneno. Las partidas ya iniciadas conservan su mazo.

[Catálogo completo](../cards/CATALOGO.md). Fuente de las nuevas definiciones:
`data/additional_cards.json`; `scripts/create_content.py` las incorpora a
`data/content.json`. Cambiar la fuente y regenerar, no solo el resultado.
Son valores iniciales: requieren partidas humanas para ajustar dificultad.

## Archivos y guardado

- `src/rules/camp_progression.gd`: migración, costes, validaciones, disponibilidad
  de cartas y concesión de almas. No dibuja ni guarda.
- `src/game.gd`: conecta las acciones a guardado y recompensas.
- `src/ui/screens/market_screen.gd`: interior, categorías y catálogo; callbacks.
- `src/ui/screens/base_camp_screen.gd`: solares y navegación visual del campamento.
- `assets/market/interior.png`: interior con mercader; [procedencia](prompts.md).
- Perfil: `souls`, `buildings.market`, `market_cards`, `test_grants`.
- Run: `soul_rooms` impide pagar dos veces la misma victoria; `last_souls` informa
  el premio reciente. Guardado conjunto con recompensa pendiente antes de animar.
- Migración aditiva: IDs y guardados previos se conservan. El preset Web incluye
  `data/*.json` para cargar también la configuración nueva. No se exportó.

## Verificación de esta entrega

Godot 4.7.2, Linux local. Reglas: 137 comprobaciones, 42/45 victorias simuladas
con las 15 parejas (todas consiguieron al menos una victoria). El bot salta las
recompensas: no representa el balance final con compras y elecciones humanas.
Progresión: 795 comprobaciones, incluyendo las 60 cartas normales/mejoradas,
compra, saldo, recompensas, recarga, duplicados y derrota.
Interfaz de mercado: 34 comprobaciones y revisión renderizada de su interior.
Campamento: 19; equipamiento: 90; cartas: 544; mapa: 21; HUD: 92; UI: 271.
No probado en navegador, emulador ni teléfono en esta entrega. Sin APK nueva.
Capturas de revisión temporales eliminadas después de inspeccionarlas.

## Presentación del campamento (17/09/2026)

El saldo solo se muestra en el campamento y sus edificios, con `soul_counter.gd`
y los dígitos existentes. Ya no aparece en mapa, combate o recompensas.
El solar construido muestra `assets/base_camp/market_building.png`, pulsable para
entrar al mercado. Ver [campamento](../base_camp/README.md) para assets y pruebas.

## Catálogo visual (17/09/2026)

- Los seis selectores muestran el sprite frontal del héroe y su nombre; reutilizan
  `assets/camp/front-128.png` sin generar imágenes adicionales.
- Catálogo con desplazamiento vertical y dos cartas completas por fila, usando
  la misma presentación de combate: marco, coste, tipo, nombre, imagen y efecto.
- Cada carta tiene debajo su botón «Comprar · N almas»; las adquiridas indican
  «Habilitada». Se conservan las validaciones de saldo y compra única.
- La previsualización muestra valores base, sin bonificaciones de una aventura
  activa. Comprar sigue desbloqueando futuras recompensas, sin añadir cartas al mazo.
- Validación de este cambio: mercado renderizado en Linux (34 comprobaciones,
  seis categorías y compras), UI general headless (271); sin fallos. Revisada la
  captura del catálogo y retirada después. Sin exportar ni probar en Web/Android.

## Categorías compartidas — 18/09/2026
El selector visual mantiene su aspecto y pasa a `ui/components/hero_category.gd`, reutilizado por la herrería. Regresión de mercado: 34 comprobaciones headless aprobadas.
