# Sinergias de cartas

Estado actual **15/10/2026**: cuatro héroes, seis parejas, dos cartas reutilizables
por héroe. Coste compartido de 2, una copia de cada carta en mano y ambos héroes
vivos; cada mejora añade 3 de daño. Se pueden jugar por separado. La reserva
boca abajo no cuenta como carta disponible hasta recuperarla.

Las seis recetas mantienen sus IDs y valores base. Las nuevas aventuras activan
interacciones condicionadas propias de cada pareja; aventuras guardadas sin la
versión nueva conservan sus efectos. Cada pareja tiene emblema, señal sobre las
dos instancias combinables y conexión visual al ejecutar. Con tres enemigos el
control se ubica sobre la energía para dejar libres los objetivos.

Consultar [tabla, comportamiento y validación actuales](../combat_refinement/README.md).
Las cifras y nombres de recetas anteriores a la reducción de seis a cuatro héroes
son históricos y no describen el catálogo actual.

## Organización

- `data/synergies.json`: seis recetas y sus IDs estables.
- `card_synergies.gd`: oportunidades y texto condicionado a versión de aventura.
- `pair_tactics.gd`: efectos condicionados antes del daño; sin interfaz/guardado.
- `synergy_actions.gd`: validación atómica y resolución; Game hace checkpoint.
- `synergy_view.gd` / `synergy_readiness.gd`: controles y marcas de la mano.
- `pair_link_fx.gd`: efecto de presentación independiente de reglas/RNG.

El texto de condición no promete activación si falta el estado previo: los bonos
no usan el bloqueo/corrosión que la propia sinergia vaya a conceder después.
