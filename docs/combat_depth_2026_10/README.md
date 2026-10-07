# Combate táctico y héroes detallados — 07/10/2026

## Alcance entregado

| Sistema | Comportamiento |
| --- | --- |
| Héroes de batalla | Seis héroes redibujados; cuadros de 256×256, doce poses por acción, pies anclados, reposo de manos/capa sin deformar el cuerpo |
| Acciones | Reposo, ataque, habilidad, defensa dibujada, reacción desde la derecha, caída y carrera; recuperación invierte la caída |
| Equipo | Arma/armadura conservan sus niveles independientes y reglas. En los actores nuevos, shader de metal/encantamiento distingue las 16 combinaciones; no se generaron 96 atlas nuevos de equipo |
| Transiciones y efectos | Fundido de 80 ms entre poses; chispas locales de ataque/defensa/impacto, respetando intensidad y efectos reducidos |
| Mejoras de cartas | Potencia o eficiencia; curaciones puras permiten restauración individual o amparo de ambos. Preview antes de confirmar; cartas gratuitas ganan golpe/bloqueo en eficiencia |
| Ataques preparados | Doce cartas tácticas comprables: una preparación y una interrupción por héroe. Preparar consume carta/energía ahora; ejecuta el daño guardado al iniciar el siguiente turno, después de los enemigos |
| Interrupción | Cancela resurrección, brasas y contraataque antes del golpe. No cancela el ataque normal ni el bloqueo anunciado |
| Formación | Protectores cubren los demás enemigos en retaguardia. Maga, explorador, penetrantes y ataques de área los alcanzan; al caer el protector se abre el acceso |
| Reliquias | Cuatro parejas con efectos adicionales de multigolpe, veneno, bloqueo y curación. Botón de explicación al activarse |
| Cripta | Resurrección anunciada en turnos múltiplos de tres si existe un cadáver; cada enemigo regresa una vez con un tercio de vida |
| Bosque | Raíces de 10 PV en etapas 3, 6, 9 y 12; absorben golpes directos sin transferir exceso. El veneno las ignora |
| Fortaleza | Brasas anunciadas en turnos 2, 5, 8…; causan 4 de daño bloqueable a cada héroe al actuar el enemigo que las prepara |
| Élites | Vampírico, Baluarte o Frenético; semilla fija, explicación al pasar sobre su sala antes del combate y aviso en batalla |
| Mercader errante | Uno por piso nuevo; tres consumibles distintos con una unidad por oferta. Intercambia una reliquia de aventura por otra aleatoria, una vez. Excluye entregar reliquias de vida máxima para no retener su beneficio |
| Encuentros encadenados | Campamento abandonado → contraseña para el siguiente mercader; espíritu → siguiente descanso +5 PV; biblioteca → siguiente cofre añade poción |
| Entrenamiento | Entrada desde campamento, pareja y niveles 0–3, maniquí, energía 99, selector de todas las cartas de la pareja, reinicio y salida. Usa otra instancia sin persistencia; restaura exactamente la aventura/perfil originales |
| Registro | Diálogo desplazable; daño, absorción, PV perdidos, recuperación, bloqueo y efectos en orden; conserva hasta 200 entradas del combate |
| Historia | «Ver» en Últimos retornos: pareja, semilla, piso, mazo final con variantes, reliquias, estadísticas, abandono y último causante de golpe fatal |
| Bestiario | Entrada desde campamento; solo revela arte, vida base, patrón y comportamiento al encontrar la criatura. Registra encuentros y derrotas |

Catálogo: **126 cartas**, **72 comprables**, **10 tipos de encuentro**. Los mazos
iniciales siguen teniendo diez cartas por héroe; las tácticas necesitan compra
para entrar en recompensas. Entrenamiento permite probarlas sin comprarlas.

## Persistencia y límites

- `upgrade_variant` es opcional; una mejora antigua mantiene **Potencia**, con sus valores históricos.
- `tactics_version=1` activa las reglas en aventuras nuevas. Las aventuras antiguas no reciben formaciones, raíces, resurrección, brasas o el ajuste normal de daño al reanudar; mantienen su grafo y límite de pisos guardados.
- `combat.prepared`, modificadores de élite y ofertas se guardan; las animaciones reproducen resultados confirmados, sin resolver daño ni conceder premios.
- `bestiary` y campos nuevos de historial son opcionales. Historial antiguo muestra el resumen disponible; no se inventan mazos ni causantes de muerte retrospectivos.
- Formación y elegibilidad se vuelven a comprobar al ejecutar una preparación; si el objetivo cayó, el golpe busca un objetivo vivo válido.
- El daño de brasas figura en las barras/registro; no se presenta como un ataque de carta del enemigo.
- Las fuentes antiguas y variantes de herrería siguen usadas fuera de batalla; no se eliminan.

## Arte, procedencia e importación

**58 imágenes nuevas:** 42 hojas de héroes, doce ilustraciones tácticas, patio,
mercader, raíces y maniquí. **504 poses dibujadas**, además de recuperación invertida.
Generadas con ImageGen integrado, sin API key. [Prompts](prompts/) y [hojas originales](sources/)
conservados; las tres escenas/raíces sin transformación conservan su fuente final
en `assets/combat_depth/`. [Manifest de procedencia](assets.json) registra hashes,
referencias y archivos del proyecto.

- Referencias de identidad: `assets/comic/<hero>.png`; estilo de cartas: `rogue_dark_cloak.png`.
- `scripts/import_detailed_heroes.gd`: recorta el grid 4×3 por los espacios reales entre filas y columnas, mantiene escala común por héroe y centra el apoyo inferior; atlas final 1024×768 con cuadros de 256. Esto evita incluir fragmentos de poses vecinas en cuadros con armas altas o efectos anchos.
- `scripts/import_training_dummy.gd`: normaliza el prop de práctica a 128×128.
- `data/detailed_heroes.json`: altura visible para conservar el tamaño sobre el suelo.
- Atlas con compresión de calidad 0.9 y coordenadas intactas; cartas a 512 px, escenarios a 1280 px, raíces a 512 px. No se agrandan sprites anteriores.
- Fuentes, scripts y pruebas ya están excluidos por los presets. **No se exportó Web ni APK.**

## Arquitectura

Reglas: `card_actions.gd`, `card_upgrades.gd`, `combat_depth.gd`, `relic_sets.gd`,
`travel_encounters.gd`. La fachada `game.gd` mantiene los checkpoints.
Presentación: `detailed_hero.gd`, `actor_sparks.gd` y shader de equipo.
UI: pantallas propias de entrenamiento, mercader y bestiario; navegación de
entrenamiento, avisos tácticos y lectura desplazable. Los componentes no guardan
ni conceden recompensas.

## Validación realizada

- Reglas nuevas: `test_combat_depth.gd`, 28 comprobaciones: preparación/guardado, interrupción, cobertura, raíces, resurrección, brasas, mejoras, mercader, cadena, historial y bestiario.
- Actores en ejecución local: `test_detailed_heroes.gd`, 1662 comprobaciones; seis héroes, doce cuadros por acción, resolución, contenido, 16 combinaciones de equipo y recuperación.
- Interacción local con renderizado: `test_combat_depth_ui.gd`, 7 comprobaciones; aislamiento del entrenamiento, restauración, selección de variante y lectura por encima de cartas.
- Secuencia animada local: `test_depth_animation_flow.gd`, 4 comprobaciones; preparación sin golpe anticipado, ejecución posterior, nuevos actores y defensa que retorna al reposo.
- Regresión: aventura 5224, progresión 1001, cartas de soporte 1922, reliquias de élite 134, equipamiento 90, mapa 66, cartas 773, arte de cartas 787, carrera 181, grounding legado 486, presentación 25, UI soporte 609, herrería 110, descanso 37; también terminación de aventura y contraataques.
- Arrastre con ratón y táctil simulado sobre ventana local: `test_expansion_ui.gd`, 17 comprobaciones, incluidos objetivos de formación y ataques de área.
- Revisión visual: seis héroes en reposo/ataque/defensa/habilidad/reacción, entrenamiento, mercader, bestiario, mejora, historial y registro. Capturas descartables en `artifacts/combat-depth/`.

Las pruebas de reglas/headless no sustituyen la revisión visual. Algunos tests
headless de UI informan recursos vivos al cerrar; las ejecuciones gráficas
citadas terminaron sin errores de scripts. Mesa/llvmpipe informa que V-Sync no
está disponible. **No probado en navegador exportado, emulador o dispositivo físico.**

### Ajuste inicial de dificultad

Las raíces aparecen en cuatro etapas específicas, en vez de cada pelea del bosque.
En dificultad normal y aventuras nuevas, los ataques base de pisos 2–3 usan
multiplicador **0.88**; conserva dificultades superiores y guardados anteriores.

Bot determinista, quince parejas y tres semillas, sin comprar cartas, usar
consumibles, elegir recompensas ni mejorar en descansos: **4/45** victorias sin
equipo y **17/45** con armas/armaduras de nivel 3. Es una observación inicial,
**no una tasa esperada de jugadores**. Falta evaluación humana de equilibrio,
especialmente de mejoras gratuitas, cartas preparadas y parejas sin curación inicial.
