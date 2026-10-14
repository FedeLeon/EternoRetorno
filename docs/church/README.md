> **Limpieza del 14/10/2026:** se retiraron los PNG fuente sustituidos/rechazados
> de esta etapa y sus importadores antiguos. Los prompts y registros se conservan
> como historial; las fuentes y herramientas del arte vigente permanecen intactas.
> [Inventario y validación actuales](../cleanup/2026-10-14.md).

## Actualización visual — 13/10/2026

Interior redibujado con grafito y lápices de colores, conservando su temática.
[Assets, galería ampliada y pruebas actuales](../base_camp/interiors/README.md).

> **Estado 13/10/2026:** cuatro protagonistas: Nicolás, Carpintero; Inés, Constructora; Mauro, Boticario; Vera, Profesora. El contenido y la compatibilidad de seis personajes descritos anteriormente quedan sustituidos por el [retiro definitivo](../cleanup/2026-10-13.md). Los resultados históricos no son pruebas del cambio actual.

## Actualización de pulido — 07/10/2026

[Implementación actual, assets, reglas y validación](../polish_2026_10/README.md).
La documentación y resultados anteriores se conservan como historial.

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

### Espaciado de las tarjetas — 30/09/2026

Se compacta el bloque de título, efecto y requisito en las doce especializaciones.
El botón Aprender/Activar sube 12 px y deja 22 px hasta el borde inferior de la
tarjeta; el requisito queda separado del botón. Textos, tamaños de fuente y arte
se conservan. `camp_offer_card.gd` ajusta solo la variante vertical usada por la
Iglesia; `church_screen.gd` coloca el estado y la acción.

Validación local: `test_camp_expansion_ui.gd`, 39 comprobaciones sin fallos con
renderizado X11/Compatibility. Revisión visual a 1280×720 de Clériga y Guardiana,
incluidos requisitos de dos líneas. `git diff --check` limpio. Sin exportación
ni nueva prueba Web/Android.

## Sacerdotisa y tarjetas a la derecha — 30/09/2026

Nuevo `assets/church/interior.png` con sacerdotisa a la izquierda. Galería de
héroes en dos columnas/tres filas a la derecha; las dos especializaciones,
encabezado y Volver a héroes también pasan a esa zona. Tarjetas de 358×512,
textos centrados y acción a 28 px del borde inferior. Globos con cinco frases.
[Componente, procedencia y pruebas actuales](../base_camp/attendants.md).
