# Iglesia y especializaciones

Implementado el 22/09/2026. Solar 4, construcción por **600 almas**.

## Acceso y decisiones

La entrada usa las seis tarjetas de héroes en estilo cómic compartidas con Refugio,
Mercado y Herrería. Al tocar un héroe, se muestran sus dos ilustraciones nuevas,
efectos, estado y botón de compra/activación. «Volver a héroes» regresa a la galería;
«Campamento» permanece en la barra superior con el saldo de almas.

Para habilitar las compras hay que **ganar una aventura completa** con ese héroe
(en aventuras nuevas, superar cripta y bosque y finalizar desde la salida del bosque;
las aventuras antiguas conservan su final de un piso). Ambos integrantes
obtienen el requisito, aunque alguno haya caído en un combate y sido recuperado.
Se interpretó «terminar completa» como victoria, no derrota ni abandono.

Cada especialización cuesta **450 almas una sola vez**. Comprar también la activa.
Solo hay una activa por héroe; cambiar entre las aprendidas es gratuito.
La elección se copia al iniciar la siguiente aventura: comprar o cambiar durante
una partida no modifica sus héroes. Las especializaciones afectan cartas individuales,
no consumibles, enemigos ni ataques combinados de enlace.

## Las doce especializaciones

| Héroe | Especialización | Efecto |
| --- | --- | --- |
| Guerrero | Guerrero del torbellino | +1 de daño por golpe en cartas con dos o más impactos. |
| Guerrero | Verdugo | +2 de daño en cartas de un solo impacto. |
| Guardiana | Baluarte | +3 de bloqueo en cartas dirigidas a un aliado o a ambos héroes. |
| Guardiana | Vindicadora | +3 de daño con cartas ofensivas mientras la Guardiana tenga bloqueo activo. |
| Pícaro | Alquimista tóxico | +1 de veneno en cartas que ya aplican veneno. |
| Pícaro | Hoja certera | +2 de daño en cartas con penetración de bloqueo. |
| Maga | Tejedora de tormentas | +2 de daño por enemigo en cartas que atacan a todos. |
| Maga | Canalizadora | +2 de daño en cartas de un impacto contra un solo enemigo. |
| Clériga | Sanadora | +2 de vida restaurada con cartas de curación. |
| Clériga | Custodia sagrada | +2 de bloqueo con cartas defensivas. |
| Explorador | Ojo de halcón | +2 de daño en cartas de un impacto contra un solo enemigo. |
| Explorador | Vanguardia | +3 de daño por impacto con cartas durante el primer turno de cada combate. |

Los bonos se suman solo a valores ya positivos, después de equipo/reliquias,
y cada impacto conserva el daño individual. Las condiciones (bloqueo activo,
primer turno, objetivo y cantidad de impactos) se evalúan al consultar/resolver
la carta; no dependen de la animación.

## Arquitectura y guardados

- `data/camp_expansion.json`: definiciones, precios, condiciones y referencias de arte.
- `src/rules/specializations.gd`: elegibilidad, compras, selección, snapshot y aplicación.
- `src/ui/screens/church_screen.gd`: composición; reutiliza `building_hero_picker.gd` y `camp_offer_card.gd`.
- `src/ui/camp_expansion_navigation.gd`: obtiene snapshots y envía acciones a `game.camp_action`.
- `profile.specializations`: `victorious`, `owned`, `active`.
- `run.heroes[*].specialization`: copia de la definición elegida, preservada al cargar.
- Migración idempotente: recupera héroes de victorias que aún constan en `profile.history`.
  El historial anterior estaba limitado a 30 entradas: victorias borradas de ese historial
  no se pueden atribuir a héroes de forma fiable. Las victorias nuevas guardan la elegibilidad
  permanentemente aunque luego salga la entrada del historial.
- Partidas anteriores sin especialización continúan sin efectos añadidos a mitad de aventura.

## Arte y pruebas

`assets/church/`: edificio transparente, interior y doce ilustraciones nuevas (dos por héroe).
Prompts, referencias y procedencia en los JSON de esta carpeta; originales en `sources/`.
Referencias de identidad: `assets/rest/<hero>.png`. Empaquetado con `scripts/import_camp_expansion.gd`.

Validación local compartida: [pruebas de la expansión](../expeditions/README.md#validación-y-pendientes).
Se revisaron las pantallas renderizadas y las ilustraciones; no hubo exportación ni prueba móvil/web.
Precios y bonos son valores iniciales para probar y ajustar.

## Legibilidad del encabezado — 23/09/2026

La galería de héroes muestra «Una victoria abre nuevos caminos para cada héroe»
sobre un marco gótico oscuro compartido (`dark_skin.gd`), colocado en
`church_screen.gd`. El texto permanece centrado y el marco no captura pulsaciones.
Revisión visual local a 1280×720: texto legible y tarjetas libres de superposiciones.
Sin exportación ni validación web/móvil para este ajuste.

### Título de especializaciones — 23/09/2026

El encabezado «Héroe · Especializaciones» también tiene fondo oscuro y marco
fino compartido (`DarkSkin.dialog`), en `SpecializationHeadingFrame`. Conserva
su posición centrada y deja separado el botón de volver a héroes. El panel no
captura eventos del ratón. Revisión renderizada local a 1280×720 con Explorador:
título legible, sin superposición con tarjetas ni navegación. Sin exportación.
