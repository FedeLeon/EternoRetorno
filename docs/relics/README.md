> **Limpieza del 14/10/2026:** se retiraron los PNG fuente sustituidos/rechazados
> de esta etapa y sus importadores antiguos. Los prompts y registros se conservan
> como historial; las fuentes y herramientas del arte vigente permanecen intactas.
> [Inventario y validación actuales](../cleanup/2026-10-14.md).

## Actualización de pulido — 07/10/2026

[Implementación actual, assets, reglas y validación](../polish_2026_10/README.md).
La documentación y resultados anteriores se conservan como historial.

# Reliquias de aventura y recompensas de élite

## Reglas — 22/09/2026

Cada combate de élite ganado concede automáticamente una reliquia aleatoria del
catálogo de aventura, excluyendo las ya obtenidas en esa aventura. Se mantienen
las cuatro reliquias anteriores y se agregan veinte (24 en total). El Reloj sin
arena conserva su requisito anterior: vencer a un élite lo desbloquea antes de
sortear la recompensa. La elección usa el RNG guardado de la aventura.

La reliquia se aplica al resolver la victoria y queda guardada antes de mostrar
la recompensa. La pantalla de cartas muestra también su icono, nombre y efecto,
con «Ya añadida al grupo». Elegir o saltear la carta no concede otra reliquia ni
quita la recibida. Salir al menú, abrir bolsa/mazo o cargar la partida mantiene
la misma recompensa. Al continuar se limpia solamente el aviso.

- Las reliquias halladas son compartidas por ambos héroes y duran esa aventura.
- Aparecen junto a la inicial en la barra superior y en Grupo, con popovers.
- Las veinte nuevas no se agregan al selector de reliquia inicial.
- Los bonos de cartas modifican solo estadísticas positivas y se suman al equipo,
  reliquia inicial y especialización. Daño significa daño por impacto; no suma impactos.
- Las condiciones se evalúan cuando se consulta/juega la carta. Los bonos nuevos
  de carta no modifican los ataques combinados de enlace ni los consumibles.
- Bloqueo inicial y por turno respetan el reinicio de bloqueo existente. El robo
  adicional es solo del primer turno: luego se vuelve a las seis cartas habituales.
- Semilla del manantial cura después de victorias siguientes a su adquisición,
  incluyendo héroes recuperados al ganar. Corazón de gigante aplica vida máxima
  y curación una sola vez al obtenerlo; no se reaplica al recargar.
- No se inventa una reliquia pendiente en recompensas guardadas de versiones
  anteriores. Sus reliquias adquiridas siguen vigentes. Sin cambios de versión/IDs.
- Si el catálogo se agotara, se entrega la recompensa de cartas sin duplicar
  reliquias. La mazmorra actual tiene dos élites, por lo que no agota el catálogo.

## Veinte reliquias nuevas

| # | Reliquia | Efecto | Asset |
| --- | --- | --- | --- |
| 1 | Sello del duelista | Las cartas de un solo impacto infligen +2 de daño. | `duelist_seal.png` |
| 2 | Tambor de tormenta | Cada golpe de las cartas con varios impactos inflige +1 de daño. | `storm_drum.png` |
| 3 | Fragmento estelar | Las cartas que atacan a todos los enemigos infligen +2 de daño por impacto. | `star_shard.png` |
| 4 | Colmillo perforante | Las cartas que atraviesan bloqueo infligen +2 de daño por impacto. | `drill_tusk.png` |
| 5 | Martillo del titán | Las cartas de coste 2 o más infligen +3 de daño por impacto. | `titan_hammer.png` |
| 6 | Rubí de sangre | Con la mitad de vida o menos, las cartas del héroe infligen +3 de daño por impacto. | `blood_ruby.png` |
| 7 | Espejo de marfil | Con toda la vida, las cartas del héroe otorgan +3 de bloqueo. | `ivory_mirror.png` |
| 8 | Nudo de hierro | Las cartas que dan bloqueo otorgan +2 de bloqueo. | `iron_knot.png` |
| 9 | Campana del alba | Las cartas de curación restauran +2 de vida. | `dawn_bell.png` |
| 10 | Diente de víbora | Las cartas que aplican veneno añaden +1 de veneno. | `viper_tooth.png` |
| 11 | Cincel rúnico | Las cartas mejoradas infligen +2 de daño por impacto. | `rune_chisel.png` |
| 12 | Talismán de tortuga | Las cartas de bloqueo dirigidas a su dueño otorgan +3 de bloqueo. | `turtle_charm.png` |
| 13 | Hilo de plata | Las cartas que curan a un aliado o a ambos héroes restauran +3 de vida. | `silver_thread.png` |
| 14 | Chispa solar | Durante el primer turno, las cartas infligen +2 de daño por impacto. | `sun_spark.png` |
| 15 | Engranaje antiguo | Desde el tercer turno, las cartas infligen +2 de daño por impacto. | `ancient_cog.png` |
| 16 | Máscara centinela | Al empezar un combate, cada héroe vivo gana 6 de bloqueo. | `sentinel_mask.png` |
| 17 | Cadena del juramento | Al empezar cada turno, cada héroe vivo gana 2 de bloqueo. | `oath_chain.png` |
| 18 | Semilla del manantial | Tras ganar un combate, ambos héroes recuperan 4 de vida. | `spring_seed.png` |
| 19 | Corazón de gigante | Al obtenerla, ambos héroes ganan 6 de vida máxima y recuperan 6 de vida durante esta aventura. | `giant_heart.png` |
| 20 | Pluma del cuervo | Robás una carta adicional en el primer turno de cada combate. | `raven_quill.png` |

## Arquitectura

- `data/elite_relics.json`: catálogo declarativo. `content.gd` lo combina con el anterior.
- `src/rules/run_relics.gd`: sorteo sin duplicados, adquisición, bonos de cartas y sumas de efectos.
- `src/game.gd`: invoca reglas desde inicio de turno, resolución de cartas/victoria y elección de recompensa; conserva checkpoints.
- `run.reward_relic`: ID del aviso de recompensa pendiente; `run.relics`: inventario ya concedido.
- `src/presentation/relic_art.gd`: texturas individuales y compatibilidad con atlas anterior.
- `src/ui/components/elite_relic_reward.gd`: panel informativo sin concesión ni guardado.
- `reward_screen.gd`: reserva el sector izquierdo a la reliquia, desplazando las tres cartas a la derecha solo en recompensas de élite.
- `combat_hud.gd`, `map_group_drawer.gd`: consumen los mismos iconos/descripciones.

## Arte y procedencia

Veinte PNG transparentes nuevos, uno por reliquia, creados con la herramienta
integrada imagegen. Referencia de estilo: `assets/objects/icons.png`, sin reemplazar
el atlas. Prompts completos y procedencia en los veinte JSON de esta carpeta;
originales generados en `sources/`. `scripts/import_relics.gd` reduce a 192×192,
preservando alfa; finales en `assets/relics/`. Fuentes/documentación excluidas
por los presets de exportación existentes.

## Validación

- `test_elite_relics.gd`: **134 comprobaciones**, sin fallos. Veinte definiciones,
  efectos aplicados a cartas reales, condiciones negativas, bloqueo/robo/curación,
  vida máxima, dos élites distintos, agotamiento del catálogo, recarga, omisión
  de carta y compatibilidad con recompensa anterior sin recibo.
- `test_game.gd`: **156 comprobaciones**, sin fallos; 45 simulaciones deterministas.
- `test_equipment.gd`: **90 comprobaciones**, sin fallos.
- `test_camp_expansion.gd`: **192 comprobaciones**, sin fallos.
- `test_reward_ui.gd`: render local sin fallos; navegación, reliquia y cartas sin
  solapamiento, detalle en barra, regreso desde mazo y conservación al elegir carta.
- `test_map.gd`: **109 comprobaciones**, sin fallos, también con render local.
- Revisión visual de las veinte imágenes y pantalla de élite a 1280×720. Los
  veinte finales son RGBA 192×192 con transparencia; total PNGs: 833049 bytes.
- Importación Godot y `git diff --check` sin errores. Capturas temporales eliminadas.
- Sin exportación Web/APK, emulador ni teléfono. Balance sujeto a partidas reales.
