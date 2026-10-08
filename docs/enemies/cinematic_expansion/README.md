# Seis enemigos de plantillas existentes — 08/10/2026

| Piso | Enemigo / ID | Plantilla | Papel y patrón |
| --- | --- | --- | --- |
| Cripta | Heraldo de tormenta / `crypt_storm` | `elemental_3` | Apoyo; daño a ambos, golpe directo y turno de bloqueo/contraataque |
| Cripta | Escorpión de las criptas / `crypt_scorpion` | `beast_3` | Atacante; pinza defensiva, contraataque y golpe fuerte |
| Bosque | Espíritu del pantano / `forest_miasma` | `elemental_4` | Apoyo; presión a ambos, bloqueo y golpe directo |
| Bosque | Cazador encapuchado / `forest_hunter_enemy` | `bandit_6` | Atacante; disparo, preparación defensiva y disparo fuerte |
| Fortaleza | Bombardero / `ash_bombardier` | `bandit_4` | Atacante; explosiones a ambos alternadas con protección |
| Fortaleza | Escarabajo de obsidiana / `ash_wing_beetle` | `flying_5` | Protector; bloqueo, contraataque y embestida |

Las apariencias estaban reservadas, sin participación en las aventuras. Se mantiene
su diseño y se generan ocho poses (cuatro de reposo, cuatro de ataque) y un ataque
HD transparente de derecha a izquierda para cada una. Los roles usan las reglas
existentes; «Espíritu del pantano» no introduce un veneno enemigo nuevo.

Catálogo: `data/cinematic_enemies.json`, integrado por `content.gd`. Distribución
y debut: `data/dungeons.json`; 18 tipos comunes en cripta, 20 en bosque, 16 en
fortaleza. Los encuentros guardados no se recalculan. Total: 51 definiciones,
50 apariencias activas. El generador conserva variedad y progresión de encuentros.

Arte con herramienta integrada `image_gen.imagegen`, referenciando
`assets/enemies/hd/<visual>.png`. [Prompts](prompts.json), [resultados originales](generated.json)
y [fuentes/finales con hashes](sources.json). Fuentes ignoradas por Godot en `sources/`.
`scripts/import_cinematic_enemies.gd` utiliza el importador compartido, ahora capaz
de normalizar dimensiones impares antes de separar la grilla: los originales
son 1774×887; atlas finales 1024×128, cuadros 128×128, apoyo opaco a 120 px.
Cut-ins de 900 px de ancho, alfa preservado. Se regeneran las métricas con
`scripts/audit_enemy_pose_sizes.py` para conservar tamaño de ataque.

Pruebas: `test_cinematic_enemies.gd` comprueba poses distintas, ataque/reposo,
transparencia, dirección de reproducción, limpieza de partículas y mezcla de audio.
`test_enemy_formations.gd` revisa disponibilidad/variedad en 600 mapas y
`test_enemy_pose_sizes.gd` revisa apoyo/tamaño de todos los atlas activos.
La revisión nativa muestra actores y cut-ins; no reemplaza balance con jugadores.
