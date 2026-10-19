# Interfaz y navegación

El juego usa una vista horizontal de referencia de **1280×720**, renderizador
Compatibility y controles compartidos con texto en español.

## Vistas

- Inicio: entrar/continuar, colección, bestiario y configuración.
- Campamento e interiores: edificios, progreso permanente, galería de cuatro
  héroes y preparación. Los rótulos se alinean con los edificios.
- Preparación: selección de dos héroes y mascota; componentes sobre un centro
  oscuro con objetos laterales; dificultad/condición en tarjetas ilustradas.
- Aventura: primera batalla directa; luego recompensas y vista de caminos.
  El panel lateral permite consultar grupo, mazo y mapa.
- Encuentros: ilustración a pantalla completa sin franja superior. La pausa usa
  Escape en la navegación existente.
- Descanso: héroes sentados, barril visible y dos opciones con ilustraciones
  contenidas en sus tarjetas; mejora de cartas con rama de mejora persistente.
- Colección, logros y bestiario: consulta del progreso descubierto y sus fichas.
  Los logros desbloqueados permiten ampliar su imagen.
- Cinemáticas: secuencias ilustradas y galería de capítulos descubiertos.

## Cabecera y regreso

La flecha izquierda vuelve a la vista anterior únicamente cuando se permite
retroceder. No revierte combates, decisiones ni etapas confirmadas de aventura.
La navegación la resuelve `back_navigation.gd`, sin botones interiores redundantes.
`header_back_button.gd` fija el botón en (24, 20), de 44×44 px, con flecha
centrada de 24 px y márgenes simétricos propios en todos sus estados. El estilo
general de los botones no puede ensancharlo al calcular el tamaño mínimo.

En batalla, el HUD contiene energía, mazo, objetos, registro y menú.
El botón de mazo reutiliza `assets/map/sidebar/deck.png`, el mismo icono del menú
lateral del mapa, ajustado al espacio de la cabecera. El registro usa
un icono de libreta entre objetos y menú. La bolsa muestra retratos de los posibles
destinatarios cuando el objeto requiere elegir héroe o enemigo.

## Cartas

Se conservan los marcos y reversos de metal/papel por héroe y las ilustraciones
actuales. Título, coste y tipo se alinean con las áreas de su marco; el coste usa
centrado óptico. Títulos y descripción tienen peso en negrita. El texto es vivo,
no parte de una imagen con cifras horneadas.

Cada héroe se reconoce por color y marco. No se muestra una placa de nombre/oficio,
crestas superiores adicionales ni la pastilla inferior con iconos de efectos.
La carta conserva su texto completo y el tipo debajo de la ilustración.

La mano reduce escala y separación al superar seis cartas, incluyendo el reverso
reservado en el cálculo. La carta enfocada se amplía para leerla. El arrastre
ilumina los objetivos y no añade el cartel negro de instrucciones sobre la batalla.

## Combate legible

Intención y efectos usan símbolos simples, contrastados y pulsables. El cuadro de
inspección enemigo es compacto, con iconos por dato y desplazamiento si hace falta.
Vida, bloqueo y números eléctricos se centran por sus límites visibles. El escudo
de bloqueo activo ocupa 32 px y tiene una silueta más ancha para contener cifras
de varias posiciones, manteniendo la punta por encima de la tira de estados.

La batería y Terminar turno tienen electricidad decorativa sin tapar cifras ni
zonas de clic. Los fondos oscuros dan contraste a personajes, mano y símbolos.
Las luces del primer plano pueden cubrir el fondo; su ilustración permanece en
una esquina para dejar visible la batalla.

`src/ui/components/` comparte estos controles; las pantallas están separadas en
`src/ui/screens/`. Cambiar composición no debe cambiar reglas ni recompensas.
