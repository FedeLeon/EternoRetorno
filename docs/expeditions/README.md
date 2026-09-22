# Puesto de expediciones

Implementado el 22/09/2026. Solar 2, construcción por **500 almas**.

## Funcionamiento

- Tres contratos visibles, uno aceptado por aventura. Elegir o cancelar es gratis antes de comenzar.
- Cada oferta incluye ilustración, objetivo y recompensa. Se usan seis ilustraciones por categoría: combate, élite, guardián, pareja, exploración y dominio.
- Al concluir una aventura (victoria, derrota o abandono mediante nueva aventura), aparecen tres contratos nuevos, sin repetir los tres anteriores. Siempre hay uno de pareja y dos generales.
- Las ofertas persisten al cerrar el juego y no se vuelven a sortear al entrar al edificio. El generador es independiente de la semilla de la mazmorra.
- Una aventura en curso conserva su contrato y no permite aceptar/cambiar otro. Construir el puesto durante una aventura permite usarlo a partir de la siguiente.
- Los objetivos de pareja requieren llevar ambos héroes indicados. Los de victoria con un héroe admiten cualquier compañero.
- El progreso cuenta solo dentro de esa aventura. Combates incluye comunes, élites y guardián; los cofres trampa también cuentan. Las mejoras cuentan al confirmarlas en un descanso, no al previsualizarlas.
- «Sin bajas» excluye combates donde un héroe cayó, aunque se recupere al ganar. Un rescate de fénix que impide caer no se cuenta como baja.
- El premio se concede una sola vez al terminar, junto con la renovación de ofertas y el guardado de perfil/aventura. Un objetivo de progreso ya cumplido se paga incluso si luego se pierde; los contratos de victoria requieren ganar.
- Se ve el progreso del contrato activo al visitar el puesto y el resultado al concluir. El saldo de almas continúa limitado a las vistas del campamento.

## Catálogo: 30 contratos

| # | Contrato | Objetivo | Almas |
| --- | --- | --- | ---: |
| 1 | Guerrero y Guardiana | Ganá una aventura con Guerrero y Guardiana. | 350 |
| 2 | Guerrero y Pícaro | Ganá una aventura con Guerrero y Pícaro. | 350 |
| 3 | Guerrero y Maga | Ganá una aventura con Guerrero y Maga. | 350 |
| 4 | Guerrero y Clériga | Ganá una aventura con Guerrero y Clériga. | 350 |
| 5 | Guerrero y Explorador | Ganá una aventura con Guerrero y Explorador. | 350 |
| 6 | Guardiana y Pícaro | Ganá una aventura con Guardiana y Pícaro. | 350 |
| 7 | Guardiana y Maga | Ganá una aventura con Guardiana y Maga. | 350 |
| 8 | Guardiana y Clériga | Ganá una aventura con Guardiana y Clériga. | 350 |
| 9 | Guardiana y Explorador | Ganá una aventura con Guardiana y Explorador. | 350 |
| 10 | Pícaro y Maga | Ganá una aventura con Pícaro y Maga. | 350 |
| 11 | Pícaro y Clériga | Ganá una aventura con Pícaro y Clériga. | 350 |
| 12 | Pícaro y Explorador | Ganá una aventura con Pícaro y Explorador. | 350 |
| 13 | Maga y Clériga | Ganá una aventura con Maga y Clériga. | 350 |
| 14 | Maga y Explorador | Ganá una aventura con Maga y Explorador. | 350 |
| 15 | Clériga y Explorador | Ganá una aventura con Clériga y Explorador. | 350 |
| 16 | El camino del Guerrero | Ganá una aventura llevando a Guerrero, con cualquier compañero. | 250 |
| 17 | El camino de la Guardiana | Ganá una aventura llevando a Guardiana, con cualquier compañero. | 250 |
| 18 | El camino del Pícaro | Ganá una aventura llevando a Pícaro, con cualquier compañero. | 250 |
| 19 | El camino de la Maga | Ganá una aventura llevando a Maga, con cualquier compañero. | 250 |
| 20 | El camino de la Clériga | Ganá una aventura llevando a Clériga, con cualquier compañero. | 250 |
| 21 | El camino del Explorador | Ganá una aventura llevando a Explorador, con cualquier compañero. | 250 |
| 22 | Primeras escaramuzas | Ganá 3 combates en una aventura (incluye élites y guardián). | 115 |
| 23 | Paso firme | Ganá 6 combates en una aventura (incluye élites y guardián). | 160 |
| 24 | La larga expedición | Ganá 10 combates en una aventura (incluye élites y guardián). | 220 |
| 25 | Cazador de élites | Derrotá a 1 élite en una aventura. | 150 |
| 26 | Dos amenazas menos | Derrotá a 2 élites en una aventura. | 300 |
| 27 | El sello quebrado | Derrotá al guardián en una aventura. | 220 |
| 28 | Buscadores de secretos | Abrí al menos un cofre durante una aventura, incluso si tiene trampa. | 100 |
| 29 | Acero templado | Mejorá dos cartas en descansos durante una aventura. | 160 |
| 30 | Todos regresan | Ganá tres combates sin que ningún héroe caiga durante esos combates. | 180 |

## Archivos y compatibilidad

- `data/camp_expansion.json`: precios y catálogo editable.
- `src/rules/expeditions.gd`: ofertas, aceptación, conteos y liquidación.
- `src/rules/camp_expansion.gd`: fachada de transacciones; `game.gd` conserva los checkpoints.
- `src/ui/camp_expansion_navigation.gd`: navegación y snapshots de presentación.
- `src/ui/screens/expeditions_screen.gd`, `components/camp_offer_card.gd`: tarjetas.
- `profile.expeditions`: ciclo, ofertas, selección y último resultado.
- `run.contract`, `run.expedition_stats`, `run.contract_result`: contrato y progreso de esa aventura. Las aventuras antiguas sin estos campos siguen siendo válidas; no se inventa progreso anterior.
- No se cambia la versión ni se sobrescriben equipos, reliquias o mazos existentes.

## Arte

`assets/expeditions/`: edificio transparente, interior y seis ilustraciones de contratos.
Prompts y procedencia: archivos JSON de esta carpeta; originales: `sources/`.
Generados con imagegen y empaquetados por `scripts/import_camp_expansion.gd`:
interior de 1280 px, edificio de 512 px e ilustraciones de 480 px de ancho.
Las fuentes de documentación no entran en las exportaciones.

## Validación y pendientes

`tests/test_camp_expansion.gd`: 192 comprobaciones aprobadas (reglas, migración, guardado, recompensas, condiciones y resolución real de daño).
`tests/test_camp_expansion_ui.gd`: 30 comprobaciones aprobadas con render local a 1280×720; revisión visual de campamento, contratos, galería e Iglesia.
Regresión: 156 checks de juego, 819 de progresión y 33 de campamento aprobados.
Sin exportar APK/Web, sin emulador ni dispositivo físico. Precios/bonos iniciales sujetos a balance mediante partidas; no se afirma balance completo por estas pruebas.

## Aventuras de dos pisos — 22/09/2026

Pasar de la cripta al bosque no termina el contrato ni renueva ofertas. Los
contadores siguen acumulándose; la liquidación ocurre al ganar el bosque, perder
o abandonar. Los guardados antiguos de un piso conservan su final anterior.

## Terminar una aventura desde el menú — 22/09/2026

El menú de pausa ofrece «Terminar aventura» cuando hay una run activa. Tras
confirmar, vuelve al campamento y permite elegir un contrato nuevo. «Ir al inicio»
sigue conservando la aventura para continuarla; cancelar no cambia el contrato.

`game.end_adventure()` reutiliza el cierre sin victoria: conserva almas y mejoras
permanentes, liquida el contrato según el progreso realmente alcanzado, renueva
las tres ofertas y elimina equipo/mazo transitorios. No concede victoria ni
especializaciones. El cierre y las nuevas ofertas se guardan juntos y no pueden
liquidarse dos veces. Se conserva el formato de guardado; el historial registra
el resultado como una aventura no ganada.

La navegación está en `src/ui/pause_navigation.gd`; `main.gd` delega allí. Se
impide abrir el menú durante acciones de combate en reproducción.
