# Nueva variedad de enemigos de la cripta — 22/09/2026

Se activan seis diseños existentes: cuatro esqueletos y dos elementales. La
primera mazmorra pasa de cuatro a **diez tipos comunes**; se mantienen su élite
(esqueleto guardián), guardián final (autómata) y la composición de sus 28 salas.
El juego tiene 19 enemigos activos entre las dos mazmorras.

## Encuentros

| Enemigo | ID lógico | Apariencia | PV | Estilo |
| --- | --- | --- | --- | --- |
| Esqueleto guerrero | `skeleton_warrior` | `skeleton_0` | 24 | Espada, escudo ligero y contraataque |
| Esqueleto arquero | `skeleton_archer` | `skeleton_2` | 22 | Disparos de daño variable |
| Esqueleto escudero | `skeleton_shielder` | `skeleton_3` | 32 | Poco daño y bloqueo alto |
| Esqueleto berserker | `skeleton_berserker` | `skeleton_5` | 28 | Hachas y golpe a ambos héroes |
| Elemental de roca | `rock_elemental` | `elemental_2` | 36 | Puñetazos y defensa de roca |
| Elemental de sombra | `shadow_elemental` | `elemental_7` | 24 | Garras, daño grupal y contraataque |

- Encuentros comunes de dos y tres mezclan tipos diferentes, sin repetir un
  mismo enemigo dentro del grupo. El primer combate sigue siendo individual.
- Guerrero y arquero pueden aparecer desde la entrada; escudero desde la etapa
  2, berserker desde la 4, elementales desde la 5 (etapas del grafo, empezando en 0).
  Es una aparición progresiva, no una garantía de ver todos los tipos en una ruta.
- `data/dungeons.json` define el grupo, `distinct_common` y `min_stage`; el
  generador mantiene semilla, grupos de combate y grafo guardado. La configuración
  del bosque conserva sus reglas anteriores.
- Partidas existentes no se regeneran: mantienen enemigos y conexiones guardados.
  **Empezar una aventura nueva** para encontrar la nueva variedad.

## Animaciones y procedencia

Doce assets finales generados con **imagegen integrado**, usando como referencia
los seis diseños `assets/enemies/hd/<apariencia>.png` ya existentes.

- Seis atlas `assets/enemies/animations/<apariencia>.png`, 1024×128, con ocho
  cuadros de 128×128: cuatro de reposo y cuatro de ataque. Reposo con cambios en
  armas, brazos, tela o cuerpo elemental; sin deformación de respiración.
- Seis viñetas RGBA `assets/comic/enemies/<apariencia>.png`, 900 px de ancho.
  Ataques de derecha a izquierda desde primer plano inferior derecho, con
  transparencia real para mantener visible el nivel detrás.
- El arquero suelta la cuerda del arco; el escudero golpea con su escudo; guerrero
  y berserker usan espada/hachas; roca golpea con el puño y sombra con sus garras.
- Se conservan daño, destello, contraataque y disolución en cenizas existentes.
- Fuentes en `sources/`, [prompts iniciales](prompts.json), [corrección de espacio
  entre poses](motion-spacing-prompts.json) y [procedencia](sources.json).
  La corrección evita que armas/efectos crucen los límites del cuadro vecino.

## Organización

`data/crypt_enemies.json` agrega reglas sin cambiar IDs antiguos; `content.gd`
lo fusiona con los demás catálogos. `enemy_visuals.json` indica los ciclos de
reposo y ataque; `enemy_cut_in.gd` registra paletas y usa el presentador común.
No se agregan reglas de combate al componente visual.

`scripts/import_crypt_enemies.gd` y `import_forest.gd` comparten el empaquetador
`scripts/enemy_art_import.gd`: recorte por alfa visible, escala uniforme entre
poses, pies a y=120 y reducción del arte en primer plano. No se modifican las
fuentes ni se regeneran recursos del bosque al importar la cripta.

## Verificación

Los resultados finales se registran en `docs/HISTORIAL.md`. Se comprueban cien
semillas de la cripta, apariciones por etapa, grupos distintos, persistencia,
poses únicas y dentro de su celda, retorno de ataque a reposo, transparencia,
orientación de viñetas y grupo de tres. También se compara el empaquetado
compartido con un atlas existente del bosque para detectar cambios accidentales.

Revisión visual local a 1280×720; capturas temporales en
`artifacts/crypt_variety/`, retiradas tras revisión. Sin exportación Web/APK ni
pruebas en dispositivo físico. Balance pendiente de partidas humanas.

Resultados locales finales: variedad 5.161 comprobaciones, enemigos 745,
generación 20.414, reglas generales 142 y mazmorra 66; todas sin fallos.
Importación y revisión de diferencias correctas.
