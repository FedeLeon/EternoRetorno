# Auditoría visual — estado final del 14/10/2026

## Resultado actual

Conversión completada, primeros planos de héroes estáticos y 88 ilustraciones
mínimas de cartas: **703 archivos, 630 imágenes** (611 PNG y 19 SVG).
Hay **628 imágenes actualizadas con hash verificado**, dos SVG adaptados, cero
discrepancias y cero imágenes activas pendientes. Las 69 imágenes de cartas
anteriores fueron sustituidas por 88 dibujos individuales. Las 56 apariencias
enemigas conservan sus poses propias y cuatro dibujos de primer plano. Los 12
shaders se inventarían como efectos por código, separados de imágenes pendientes.

[Conversión integral](../../migration/README.md),
[primeros planos estáticos](../../../comic/static/README.md) y
[cartas minimalistas: fuentes y validación](../../../cards/minimal/README.md).
[Galería actual](gallery.html), [CSV actual](inventory.csv), [JSON actual](inventory.json).

## Diagnóstico inicial del 13/10 (histórico)

Los números y pendientes siguientes describen el punto de partida, no el estado
actual. El inventario y la galería enlazados se regeneraron al finalizar.

Revisión posterior al campamento crepuscular y los seis interiores nuevos.
**La conversión a sketchbook sigue incompleta**, sobre todo durante la aventura.
No se generan, sustituyen ni eliminan assets en esta revisión.

## Inventario actual

Se censan **708 archivos** bajo `assets/`, excluyendo imports/UIDs:
616 PNG, 18 SVG, 13 shaders, 55 audios y seis archivos de fuentes/configuración/licencia.
Son **634 imágenes** en total.

| Clasificación | Cantidad | Interpretación |
| --- | ---: | --- |
| PNG sketchbook actualizados | 42 | Primeros planos, identidad, exterior e interiores |
| PNG con estética anterior y consumidor resuelto | 502 | Pendientes activos, incluyendo variantes y atlas |
| PNG anteriores condicionales | 60 | 56 retratos enemigos de fallback y cuatro retratos cinematográficos |
| PNG anteriores sin consumidor runtime resuelto | 8 | Revisar uso antes de rediseñar o eliminar |
| PNG históricos de cómic | 4 | Procedencia de generaciones anteriores |
| SVG adaptados | 2 | Marcos compartidos de botones y paneles |
| SVG por revisar | 16 | Ajustar trazo/paleta donde corresponda, manteniendo su significado |

Los 570 PNG anteriores incluyen los 502 activos, 60 condicionales y ocho sin
consumidor resuelto. **Una imagen puede contener muchas poses o iconos**; estos
números no son una estimación de trabajo ni implican dibujar cada variante de nuevo.
Audios y tipografías no requieren sustitución por cambiar el medio visual.

- [Galería de las 634 imágenes](gallery.html): búsqueda, estilo, uso y vista.
- [Inventario CSV](inventory.csv): archivo, familia, estilo, uso y consumidores.
- [Inventario JSON](inventory.json): incluye 57 definiciones enemigas y 28 grupos
  de vistas/superficies. Los grupos listan assets específicos; actores, cartas
  y HUD compartidos se documentan por separado, no se duplican en cada pantalla.

## Qué ya está convertido

- **20 atlas** de ataque/defensa de héroes en primer plano: 16 cuadros cada uno.
- **6 imágenes de identidad**: hoja de personajes, cuerpo de Mauro sin máscara
  y cuatro rostros para tarjetas.
- **10 PNG del campamento**: paisaje, seis edificios, solar, muñeco y fuego.
- **6 interiores**: mercado, herrería, iglesia, expediciones, refugio y proyectos.
- Marcos SVG compartidos de botones/paneles con líneas irregulares y gris/violeta.

Los **42 PNG** coinciden con sus hashes documentados, sin divergencias. La galería
2×2 y sus tarjetas ampliadas permanecen como fueron verificadas en la entrega
anterior; esta auditoría no las vuelve a implementar ni presenta esas pruebas
anteriores como nuevas.

## Pendientes por pantalla y situación

| Pantalla/situación | Estado actual | Assets que faltan |
| --- | --- | --- |
| Inicio y opciones | Paleta oscura adecuada; pintura digital anterior | `title/background.png`, conservando composición y nombre |
| Campamento exterior | Convertido | Sin reemplazo pendiente del conjunto nuevo; revisar el resto de vistas relacionadas |
| Mercado/herrería/refugio | Fondos y galería convertidos; otros elementos mixtos | Cartas de venta/mazo, preview de equipo, iconos y objetos compartidos |
| Iglesia | Fondo convertido; ocho especializaciones anteriores | `church/<hero>_<spec>.png`, con identidades nuevas |
| Expediciones | Fondo convertido; seis artes de contrato anteriores | `expeditions/contract_*.png` |
| Proyectos | Fondo y edificios de tarjetas convertidos | Mantener el conjunto nuevo |
| Elección de pareja | Fondo nocturno y héroes sentados anteriores | `camp/background.png`, cuatro `rest/<hero>.png`, fuego anterior |
| Equipo previo | Escenario luminoso y puerta anteriores | `equipment/valhalla.png`, `equipment/door.png`, iconos de reliquias |
| Mapas de las tres mazmorras | Papiro dorado y pixel art anteriores | Fondo, recuadro de sala, seis iconos, pestaña de grupo y flecha SVG |
| Combate en la cripta | Tres fondos anteriores | `dungeon/combat*.png`, actores y HUD compartidos |
| Combate en el bosque | Dos fondos anteriores | `forest/combat_*.png`, actores y HUD compartidos |
| Combate en fortaleza volcánica | Un fondo anterior | `volcano/combat.png`, actores y HUD compartidos |
| Descanso | Tres fondos, cuatro figuras sentadas y dos opciones anteriores | `rest/background.png`, `forest/rest.png`, `volcano/rest.png`, figuras y tarjetas |
| Encuentros/mercader errante | Nueve fondos y complementos anteriores | `encounters/*.png`, `combat_depth/merchant.png`, raíces |
| Tesoros | Cofre animado anterior; escenario de aventura | `treasure/chest.png`, objetos y fondos de mazmorra |
| Recompensa de combate | Marco energético/fondo anterior | `reward/background.png`, cartas y reliquias compartidas |
| Ver mazo/bolsa | Fondo anterior compartido | `inventory/background.png`, cartas/objetos/iconos |
| Colección/bestiario | Fondo anterior compartido e iconos detallados | `collection/background.png`, 28 iconos, retratos enemigos |
| Entrenamiento | Fondo/muñeco propios anteriores | `combat_depth/training.png`, `combat_depth/dummy.png`, actores |
| Cinemáticas e historias | 17 planos y cuatro fondos complementarios anteriores | `cinematics/shots/*.png`, fondos y protagonistas coherentes |

### Mazmorras y mapas

Los tres pisos comparten el mapa base; **ninguno tiene todavía mapa sketchbook**.
Hay que sustituir `map/minimal/parchment.png`, `room_papyrus.png` y los seis tipos
(combate, encuentro, tesoro, descanso, élite y guardián), además de `map/group_tab.png`.
La flecha `current_room.svg` se revisa por trazo/paleta. Se puede reutilizar una
base de papel gris dibujado en todos los pisos, con pequeños acentos por bioma;
la espiral y los caminos no necesitan cambios por esta conversión.

Los **seis fondos de combate** (3 cripta, 2 bosque, 1 fortaleza) mantienen sus
formas y ambiente anteriores. Conviene redibujar suelo, arquitectura y
vegetación con masas tranquilas detrás de los actores y el HUD; conservar
identidad de cada bioma mediante acentos moderados, sin teñir todo de violeta.

## Héroes: la identidad todavía cambia entre vistas

- Combate: **40 hojas de 12 poses**, 28 de acciones principales y 12 adicionales.
- Descanso/elección: **cuatro figuras sentadas** del diseño antiguo.
- Grupo/preview de herrería: **cuatro sprites clásicos y 64 variantes de equipo**.
- Carrera: **cuatro atlas antiguos**; el actor detallado también tiene cuatro
  hojas `run` incluidas en las 40 hojas. Unificar rutas antes de duplicar dibujos.
- Intención de objetivo: `camp/front-128.png` conserva las figuras anteriores.
- Ocho especializaciones y ocho planos personales conservan diseños anteriores.

**Mauro aún aparece con máscara/pico en combate, descanso, especializaciones y
su historia**, mientras los retratos/primeros planos nuevos muestran su cara.
Nicolás conserva el casco con cuernos en esas vistas; Inés mantiene armadura
oro/capa verde y Vera ropa blanca/azul. Son diferencias de rostro, silueta,
ropa y arma, no solamente de paleta.

La hoja conjunta `identity/sketchbook.png` también conserva la figura histórica
con máscara en su tercer lugar. El cargador de Mauro usa `rogue_unmasked.png`
o su retrato propio, por lo que esa figura no debe tomarse como referencia para
nuevos assets. Mantener las referencias individuales y oficios aprobados.

**No recomiendo generar 64 atlas de equipo nuevos por inercia**: primero
reutilizar el actor actualizado en mapa/herrería y resolver mejoras con tintes
u overlays simples, preservando los niveles y guardados.

## Enemigos y ataques en primer plano

Hay **57 definiciones y 56 apariencias compartidas**. Todas conservan actores
pixel art y ataques en primer plano de cómic/pintura digital:

- **56 atlas de animación** y **56 ataques en primer plano** por convertir.
- 50 apariencias tienen cuatro cuadros de reposo y cuatro de ataque.
- Seis no tienen poses de ataque propias: `crypt_bat`, `crypt_lancer`,
  `crypt_shaman`, `crypt_slime`, `skeleton_6` y `crypt_automaton`.
- Los **56 primeros planos son una sola ilustración por enemigo**: se mueve
  la imagen y sus estelas; no son secuencias de poses como las de los héroes.
- Los 56 PNG `enemies/hd/` son fallback cuando falta el atlas animado; todos
  los atlas actuales existen. No regenerarlos antes de decidir si se conservará
  esa ruta alternativa.

Al cambiar los actores, ajustar cuadrícula, filtrado NEAREST, anclaje del suelo
común y métricas `enemy_pose_sizes.json`. Mantener la corrección de tamaño al
recibir daño/morir. Los nuevos primeros planos deben seguir atacando de derecha
hacia izquierda; agregar poses coherentes y trazos de energía dibujados.

## Iconos, cartas y elementos compartidos

| Familia | Cantidad/formato actual | Cambio recomendado |
| --- | --- | --- |
| Intenciones y efectos | 36 PNG | Símbolos claros de grafito/color, pocos detalles, sin acabado brillante |
| Reliquias individuales | 20 de élite y nueve de jefes | Simplificar silueta, tramado corto y acentos funcionales |
| Consumibles/reliquias iniciales | Un atlas de 16 celdas | Redibujar manteniendo orden de celdas/IDs |
| Equipo mejorado | 15 PNG | Herramientas/armas coherentes con los oficios y acero gris |
| Logros | 28 PNG | Emblemas de cuaderno; menos ornamento y textura fina |
| Cartas | 88 ilustraciones en 69 PNG y cuatro marcos | Mantener legibilidad, siluetas simples y diferencias entre héroes |
| Contratos | Seis artes | Dibujos de expedición sobre papel sin exceso de oro |
| Especializaciones | Ocho artes | Mismos rostros, ropa y armas que los protagonistas nuevos |
| HUD raster | Energía, almas, terminar turno y diez cifras | Revisar materiales/brillos; mantener formas, lectura y disposición |
| SVG auxiliares | 16 | Revisar línea/paleta; no necesitan convertirse obligatoriamente en PNG |

El escudo, la cruz, la calavera, las flechas y la cadena deben seguir siendo
reconocibles en pequeño. Mantener verde para veneno, rojo para curación/vida y
los colores que permitan distinguir efectos. El botón de terminar turno conserva
su forma circular y comportamiento; se revisa su dibujo, no su disposición.

## Shaders y presentación por código

Hay 13 shaders; el de campamento crepuscular ya acompaña el dibujo nuevo y el
antiguo `camp_day.gdshader` carece de consumidor runtime resuelto. Los demás
necesitan revisión contextual, no sustitución automática:

- Fuego de selección/descanso, brillo energético y partículas: evitar que un
  resplandor digital tape la textura de lápiz.
- Cenizas de cartas/enemigos/bloqueo: conservar el efecto y adecuar partículas/trazo.
- Líquido de la vida: conservar movimiento, lectura y rojo; ajustar el marco
  al estilo de dibujo si resulta necesario.
- Encuentros y atmósfera de biomas: recalibrar las máscaras cuando cambien los fondos.
- `pixel_art.gd` todavía es el fondo procedural de algunos fallbacks: también
  entra en la conversión aunque no exista como PNG en `assets/`.

## Archivos anteriores sin consumidor runtime resuelto

Ocho PNG: los cinco de la raíz `base_camp/` (fondo, suelo construido, mercado,
proyectos y entrenamiento), y `church/building.png`, `expeditions/building.png`,
`forge/building.png`. También el shader diurno antiguo.

Son **candidatos a revisar**, no archivos declarados muertos: los importadores,
fuentes históricas y procedencia pueden referenciarlos. No se borran ni se
redibujan durante esta auditoría. Las dos licencias de tipografías sin referencia
runtime deben conservarse. Cuatro cómics históricos y 60 fallbacks se clasifican
por separado y tampoco se priorizan como arte activo.

## Orden recomendado de conversión

1. **Protagonistas normales/sentados e icono de objetivo**: igualar sus identidades
   con retratos y primeros planos; eliminar la máscara de Mauro en todas las vistas.
2. **Fondos de las tres mazmorras y mapa**: son las superficies de mayor presencia
   después de los interiores ya actualizados; conservar biomas y espacio del HUD.
3. **Enemigos por mazmorra**, incluyendo élite/jefe, poses y primer plano como
   conjunto; empezar por la cripta y los seis casos sin ataque propio.
4. **Cartas y 36 efectos de combate**, luego equipo/reliquias/consumibles: se ven
   continuamente junto a los personajes y deben seguir siendo claros en pequeño.
5. **Selección, descanso y encuentros**, especializaciones/contratos, recompensas,
   mazo/bolsa, colección/bestiario e Inicio.
6. **Cinemáticas** y revisión contextual final de partículas/brillos.

Cambiar conjuntos coherentes, conservando IDs, UIDs, alfa, apoyos, poses y
funcionalidad. No usar un filtro general de papel como sustituto del rediseño.

## Método y validación realmente realizados

- Censo de todo `assets/`, resolución de rutas literales y convenciones dinámicas;
  corregidas las rutas de edificios que la auditoría previa consideraba activas.
- Clasificación de estilo por familias y procedencia; no es un clasificador de IA.
- **544 PNG con consumidor resuelto** revisados en 21 hojas de contacto: un
  cuadro representativo por atlas y las imágenes estáticas. No equivale a inspeccionar
  cada cuadro ni a probar la reproducción completa de las animaciones.
- SVG revisados por sus recursos/componentes; galería con 634 imágenes completas.
- 42 hashes de arte actualizado verificados, cero divergencias.
- Auditoría de contenido: **1502 comprobaciones, cero errores**.
- Primeros planos: 80 fuentes y 20 atlas, cero errores de estructura/alfa/cuadros.
- Inventario: 708 rutas únicas, galería completa y grupos de vistas consistentes;
  scripts Python compilados sin errores.
- Sin modificar assets, reglas o guardados. No se ejecutan suites de gameplay
  por una entrega exclusivamente documental. Sin exportación o prueba Web/dispositivo.

```sh
python3 scripts/audit_visual_style.py
python3 scripts/audit_visual_contact_sheets.py
python3 scripts/audit_content.py
python3 scripts/audit_sketchbook_cutins.py
```

Las hojas de contacto son temporales en `artifacts/sketchbook-review-current/`,
excluidas de exportación. Los prompts y la procedencia ya guardados permanecen
junto a cada sistema; esta revisión no genera nuevos dibujos.
