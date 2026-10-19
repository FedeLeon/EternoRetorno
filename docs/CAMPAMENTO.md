# Campamento y progreso permanente

El campamento es un refugio civil al atardecer. Sus edificios dan acceso a los
sistemas permanentes; los marcadores de construcción y los niveles corresponden
al perfil guardado. Los proyectos tienen su puesto permanente junto al círculo
central. El refugio se sitúa arriba del círculo, separado del mercado.

## Instalaciones

| Vista | Función |
| --- | --- |
| Refugio | Consultar protagonistas y mazos iniciales; acceder a vínculos. |
| Taller | Fundir materiales y mejorar arma/armadura. |
| Mercado | Comprar cartas mediante su economía y catálogo. |
| Iglesia | Progresión y opciones propias de ese edificio. |
| Expediciones | Consultar y gestionar contratos. |
| Proyectos | Proyectos del campamento con sus requisitos y efectos. |
| Entrenamiento | Práctica/configuración mediante partidas temporales. |
| Aventuras | Preparar pareja, mascota y componentes para una aventura. |

Cada interior conserva su vista y cuatro tarjetas de héroes distribuidas dos
por fila en el bloque derecho. La cabecera permite retroceder por niveles cuando
la pantalla es reversible, sin repetir un botón de regreso dentro del contenido.

El barril central usa un cuerpo estático con luz y chispas; no se desplaza de lado
a lado ni lleva una llama dibujada sobre toda la imagen. El perro y el gato del
campamento conservan sus pequeñas secuencias ambientales, independientes de los
cuerpos estáticos de batalla.

## Materiales del taller

Los enemigos derrotados conceden chatarra al resolver una victoria. El depósito
se conserva en el perfil y no ocupa espacio en la bolsa de objetos.

- Fundición: **3 chatarra → 1 aleación**; se conservan los restos.
- Arma y armadura: **3 / 6 / 10 aleación** para niveles 1 / 2 / 3.
- Arma: +1 de fuerza por nivel. Armadura: +2 de bloqueo por nivel.
- Los materiales solo sirven para mejorar equipo; no se consumen en batalla ni
  sustituyen el dinero de compras, edificios o especializaciones.

Los valores se definen en `data/forge.json`. El equipo comprado se aplica a la
siguiente aventura; una aventura activa conserva su instantánea. Las mejoras
anteriores permanecen al migrar un guardado. El recibo de botín no concede una
segunda entrega al abrir la recompensa o recargar.

`forge_materials.gd` administra depósito, receta y botín;
`forge_progression.gd` valida la compra. `combat_rewards.gd` entrega una sola vez;
`Game.smelt_forge` confirma la fundición mediante checkpoint. La vista y
`forge_material_display.gd` presentan el resultado sin modificar reglas.

## Persistencia

Las reglas del campamento se distribuyen en `src/rules/camp_progression.gd`,
`camp_expansion.gd`, `building_projects.gd`, `forge_progression.gd` y sus
colaboradores. Los datos residen en `data/camp_expansion.json`,
`data/progression.json` y `data/forge.json`. Deben conservarse niveles, materiales,
contratos y compatibilidad de guardado al cambiar la presentación.
