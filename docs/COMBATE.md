# Combate y presentación

## Contrato actual

Los enemigos muestran **una imagen estática por acción**. Los estados son
reposo, ataque, defensa, habilidad, daño y caída. Hay 360 PNG individuales en
`assets/combat_static/`, configurados por `data/static_combat.json`.
Las cinco poses de acción de cada héroe usan dibujos HD nuevos sobre lienzos
de 512×512. Su escala anatómica se compara con una referencia de reposo del
mismo trabajo: evita ampliar figuras pequeñas o cambiar de tamaño al actuar.
Los PNG individuales de héroes se conservan como respaldo.

Los cuatro héroes usan dibujos cuadro a cuadro. No hay esqueletos,
deformación, balanceo del cuerpo completo ni carrera al terminar la batalla.

Los primeros planos conservan ilustraciones estáticas con luces y partículas.

Cada una de las 56 máquinas tiene dos primeros planos propios: ataque y defensa
(112 PNG de 768×512 para las 57 definiciones de enemigos). Solo aparece la máquina,
sin supervivientes, víctimas ni personajes adicionales. `enemy_cut_in.gd` elige
la acción desde `enemy_visuals.json.foreground`; una identidad o acción desconocida
no reutiliza otra imagen. Se conserva el encuadre inferior derecho y la duración.
El héroe aparece abajo a la izquierda y el enemigo abajo a la derecha, dejando
visibles los personajes del escenario. Los rayos de fondo cubren la vista sin
terminar en el límite del recorte del personaje.

Se mantienen animaciones de interfaz y ambientación: volteo de cartas, números,
barras, anuncios de turno, electricidad y clima. Esto no añade movimiento al cuerpo.

Cada impacto de ataque sobre una máquina añade un corte de luz diagonal y chispas
encima de su silueta durante 0,42 s. El sentido alterna por golpe; los impactos
absorbidos por bloqueo usan un acento azul y los demás, chispas cálidas. Las cifras
quedan encima del efecto. El veneno de fin de turno conserva su señal verde, sin
convertirse en un corte. La opción de intensidad de destellos cero suprime esta
luz; efectos reducidos usa seis chispas en lugar de doce.

## Reglas y turnos

Dos héroes comparten mazo y energía. Las reglas validan objetivo, coste y estado,
resuelven el resultado y guardan antes de mostrarlo. Al terminar el turno se
anuncia «Turno del enemigo»; al recuperar el control, «Tu turno» y su número.
La animación o el sonido no vuelven a calcular el daño.

La pose del héroe permanece activa durante toda la vida de su primer plano,
tanto en ataque como en defensa. Vuelve al reposo al terminar el efecto, no por
un temporizador independiente ni por finalizar antes la barra de daño. Cada golpe
de una carta múltiple mantiene su propia sincronización. Una carta que concede
bloqueo no repite una guardia breve después de su primer plano. Sin primeros
planos habilitados se conserva la presentación breve correspondiente.

Guardar una carta la deja en la mano de espaldas. Puede deshacerse la reserva
antes de terminar el turno. La presentación conserva una posición visual para
el reverso independiente del índice de las cartas jugables. Las cartas
reservadas no se pueden jugar hasta que vuelven a estar disponibles.

Las seis combinaciones entre los cuatro protagonistas tienen interacciones y
emblemas propios. La interfaz señala oportunidades; su resolución pertenece a
`pair_tactics.gd` y `synergy_actions.gd`. La práctica guiada enseña bloqueo,
reserva y combinación en una partida temporal.

## Lectura de información

- La intención enemiga muestra ataque/daño, retrato del héroe objetivo y el resto
  de indicadores. El bloqueo previsto muestra el icono sin cifra.
- Vida, bloqueo activo y estados permanecen cerca de los personajes. Los nombres
  y detalles completos de las máquinas se consultan al inspeccionarlas.
- Los retratos se centran en la cara y usan el color de identidad del héroe.
- Los iconos explican el efecto al tocarlos. El número de bloqueo se centra en
  un escudo oscuro con borde claro; la vida se centra en su barra.
- Las cifras flotantes se ubican junto al personaje y dentro de la batalla,
  debajo del menú superior. El daño de veneno tiene señal verde.
- Los cables de sujeción se dibujan como líneas eléctricas sobre el suelo,
  detrás de la máquina; no envuelven su cuerpo con un aro.

## Colocación y estados

`combat_layout.gd` reserva suelo, intenciones, efectos y mano;
`combat_actor_scale.gd` limita las máquinas según silueta y espacio por columna.
Deben conservar presencia sin solaparse de forma permanente. Las métricas
permiten mantener el mismo apoyo y escala cuando cambia la imagen por acción.

`static_combat_actor.gd` conserva la imagen hasta que termina la acción o se
restaura reposo. Al morir deja de volver a guardia. Cada modelo enemigo tiene
su propio dibujo destruido: piezas rotas y cables sobre el suelo, visibles durante
el resto del combate, con chispazos intermitentes. Al revivir recupera su postura.

Cada héroe usa seis secuencias de 16 dibujos: guardia con respiración y ajustes
del arma, ataque, bloqueo, habilidad, daño y caída. Sus acciones interrumpen el reposo
y luego lo restauran; la caída mantiene el último fotograma. El reposo recorre
un medio ciclo en ida y vuelta durante 4,2 s, sin cambiar escala y con apoyos registrados.

## Archivos de referencia

- `src/ui/screens/combat_screen.gd`, `src/ui/combat_flow.gd`.
- `src/ui/components/combat_hand.gd`, `enemy_intent.gd`, `combat_layout.gd`.
- `src/presentation/static_combat_actor.gd`, `detailed_hero.gd`, `enemy_sprite.gd`.
- `src/presentation/hero_attack_playback.gd`, `enemy_action_playback.gd`.
- `src/rules/card_reserve.gd`, `combat_turns.gd`, `combat_rewards.gd`.
- `data/static_combat.json`, `data/battle_effects.json`, `data/synergies.json`.

La regeneración mecánica de PNG individuales está documentada en
[Recursos](RECURSOS.md). Las pruebas y sus límites están en [Validación](VALIDACION.md).
