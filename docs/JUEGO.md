# Juego y aventura

Eterno Retorno es un juego de cartas y exploración de dos protagonistas por
aventura, con progreso permanente de campamento y una ciudad dominada por máquinas.

## Preparación

Se eligen dos entre Bruno/Carpintero, Mara/Constructora, Ciro/Boticario y
Alma/Profesora. La pareja comparte mazo y energía. Se seleccionan
componentes, dificultad y condición adicional mediante opciones ilustradas.
El comienzo abre el mapa con tres batallas iniciales para elegir, cada una con
distintas conexiones posteriores. Las nuevas mazmorras tienen 35 salas en 13 etapas.

El perro y el gato son parte del ambiente del campamento; no se eligen para
la aventura ni otorgan efectos de combate.

## Recorrido

Las tres mazmorras actuales son **Red de mantenimiento**, **Cinturón industrial**
y **Central del Reinicio**. `data/dungeons.json` define sus grupos y encuentros.
Se conservan IDs internos anteriores para no romper catálogos ni guardados.

Después de una victoria normal se resuelven las recompensas y se elige entre
los caminos disponibles en una vista ilustrada. Los accesos laterales permiten
consultar grupo, mazo y mapa. El mapa es vertical y desplazable: se comienza abajo
y se avanza por etapas hacia el jefe final, arriba de todo. Al abrirlo se enfoca
la posición del grupo. La vista de caminos presenta únicamente destinos inmediatos.

Hay combates normales, élites, jefes, cofres, encuentros, mercader y descansos.
El generador combina formaciones y considera salas previas para reducir
repeticiones; no promete que todos los encuentros de una aventura sean únicos.

Después de un jefe se presenta su secuencia de cierre y la reliquia exclusiva.
Elegirla abre el mapa de la siguiente mazmorra cuando existe; no requiere otro
botón de entrada. La última mazmorra conduce al cierre de la aventura.

## Cartas y decisiones

Las cartas pueden arrastrarse sobre un objetivo válido o jugarse mediante
selección de carta y objetivo. Los efectos propios respetan el dueño de la carta.
Los tipos son ataque, defensa, habilidad y poder según el catálogo.

Una carta puede reservarse dada vuelta en la mano para el próximo turno.
Antes de terminar, se puede cancelar y elegir otra. La mano se adapta cuando
hay más de seis cartas. El texto describe efectos y objetivos; no se repiten
pequeños iconos inferiores de ataque, defensa o veneno.

El descanso ofrece recuperar vida o mejorar una carta. En la mejora se conserva
la elección de Eficiencia al cambiar de carta hasta elegir Potencia manualmente.
Los encuentros presentan decisiones con sus resultados; la bolsa permite elegir
el héroe o enemigo destinatario con su retrato cuando el objeto lo necesita.

## Progreso

El campamento conserva edificios, equipo, desbloqueos y materiales. Los enemigos
derrotados dejan materiales destinados exclusivamente a mejoras del taller.
Los componentes y reliquias modifican la aventura según sus propias reglas.
Colección, logros, bestiario y cinemáticas permiten consultar el contenido descubierto.

Las acciones resueltas se guardan antes de su presentación. Continuar restaura
la aventura pendiente. Una derrota o abandono conserva el progreso permanente
según las reglas actuales; no permite cobrar de nuevo una victoria resuelta.

## Fuentes de reglas

`data/content.json` y sus catálogos complementarios definen héroes, cartas,
enemigos y objetos. `src/content.gd` los combina; `src/rules/` resuelve las acciones.
Los valores de los JSON y sus validaciones prevalecen ante cambios de balance.
El ritmo de progresión y la diversión requieren partidas humanas; las pruebas
automáticas verifican contratos y resultados técnicos.
