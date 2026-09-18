# Sinergias de cartas

Implementado el 16/09/2026. Se adopta la variante de **dos cartas reutilizables
por héroe**, con **una combinación por pareja de héroes**: 12 cartas participantes
y 15 ataques especiales. No se añadieron 30 cartas ni se cambió el mazo inicial.
Estas 12 cartas ya pertenecían al catálogo de recompensas libres; aparecen
normalmente al ganar batallas, sin compra previa. Se mantienen los 90 IDs.

## Cómo se usan

- Las dos cartas indicadas deben estar simultáneamente en la mano y ambos
  héroes vivos. No basta con que estén en el mazo o en el descarte.
- Las cartas participantes llevan **ENLACE**. Al seleccionar una, si falta su
  compañera, se muestra cuál necesita para la pareja actual. El tooltip también
  enumera sus combinaciones con otros héroes.
- Cuando las dos están disponibles aparece **Combinar · 2 energía**. Tocarlo
  muestra el efecto y resalta enemigos válidos. Tocar un enemigo ejecuta el ataque.
- Se descartan ambas instancias y se pagan 2 de energía compartida. No termina
  el turno y no añade una carta nueva al mazo. También pueden jugarse por separado.
- Se permite inspeccionar la combinación sin energía; no ejecutarla. Atrás
  cancela la selección. Una pareja incompleta o un héroe caído anulan la opción.
- Una copia de cada carta basta; con duplicados se usa la primera instancia de
  cada ID en la mano, conservando el resto. Cada componente mejorado añade
  **3 de daño** al especial. La vista muestra el resultado efectivo.
- El bloqueo y la curación del especial benefician a ambos héroes vivos; daño y
  veneno van al enemigo seleccionado. La penetración ignora su bloqueo.
- Los modificadores de ataque de ambos participantes se suman; la reliquia de
  colmillo encontrada añade 1 una vez. El bono de veneno se aplica una vez, con
  el mayor valor entre los participantes, sin duplicar una reliquia compartida.
- Resultado y guardado se resuelven antes de mostrar las animaciones de ambos
  héroes. Una victoria concede almas y recompensa mediante el flujo habitual.

## Combinaciones (valores base)

| Pareja | Cartas | Especial | Daño | Efecto adicional |
| --- | --- | --- | --- | --- |
| Guerrero + Guardiana | Respuesta de hierro + Cadena de hierro | Muralla cortante | 20 | 8 bloqueo a ambos |
| Guerrero + Pícaro | Barrido de acero + Doble colmillo | Filo ponzoñoso | 24 | 5 veneno |
| Guerrero + Maga | Respuesta de hierro + Prisma doble | Acero astral | 24 | Golpe conjunto |
| Guerrero + Clériga | Barrido de acero + Bendición tenue | Espada del alba | 20 | 6 curación a ambos |
| Guerrero + Explorador | Respuesta de hierro + Descarga de flechas | Asalto certero | 24 | Ignora bloqueo |
| Guardiana + Pícaro | Cadena de hierro + Niebla tóxica | Bastión tóxico | 20 | 8 bloqueo a ambos; 5 veneno |
| Guardiana + Maga | Círculo protector + Lluvia de cristales | Égida de cristal | 20 | 8 bloqueo a ambos |
| Guardiana + Clériga | Cadena de hierro + Primer alba | Juramento del refugio | 20 | 8 bloqueo a ambos; 6 curación a ambos |
| Guardiana + Explorador | Círculo protector + Punta de acero | Vigilia del cazador | 20 | 8 bloqueo a ambos; Ignora bloqueo |
| Pícaro + Maga | Niebla tóxica + Prisma doble | Veneno del vacío | 24 | 5 veneno |
| Pícaro + Clériga | Doble colmillo + Bendición tenue | Purga oscura | 20 | 6 curación a ambos; 5 veneno |
| Pícaro + Explorador | Niebla tóxica + Descarga de flechas | Cacería venenosa | 24 | 5 veneno; Ignora bloqueo |
| Maga + Clériga | Prisma doble + Primer alba | Aurora astral | 20 | 6 curación a ambos |
| Maga + Explorador | Lluvia de cristales + Punta de acero | Constelación certera | 24 | Ignora bloqueo |
| Clériga + Explorador | Primer alba + Descarga de flechas | Flecha del alba | 20 | 6 curación a ambos; Ignora bloqueo |

## Organización y compatibilidad

- `data/synergies.json`: recetas y valores con IDs estables; cargado por Content.
- `src/rules/card_synergies.gd`: deriva combinaciones desde mano y héroes vivos,
  sin modificar estado ni acceder a UI/guardado.
- `src/game.gd`: validación, modificadores, resolución atómica y checkpoint.
- `src/ui/components/synergy_view.gd`: marca ENLACE, pistas y botón de combinación.
- `src/main.gd`: selección/objetivos y coordinación de presentación existente.
- No hay campos nuevos en las partidas: la disponibilidad se reconstruye desde
  la mano guardada. IDs de cartas, mazos y formato de guardado se conservan.
- No hay assets raster nuevos; se reutiliza la interfaz del juego.

## Validación actual

Godot 4.7.2, Linux: 481 comprobaciones de reglas de sinergia, cubriendo las 15
parejas, mejoras, consumo, energía, muerte, duplicados, juego individual,
modificadores, guardado y victoria. UI: 11 comprobaciones con clics y animaciones,
y revisión renderizada de la combinación seleccionada.
Regresión: reglas 137 (42/45 victorias simuladas; el bot no utiliza sinergias),
cartas 568, distribución 38, equipamiento 90, progresión/mercado 795.
Sin exportar APK/Web ni probar esta entrega en navegador o Android.
El equilibrio de los especiales queda pendiente de partidas humanas.

## Identificación visual — 18/09/2026

Las cartas de enlace se reconocen por cadena en la pastilla inferior y
resplandor dorado. Se retira la etiqueta ENLACE sobre la imagen. Los tooltips
conservan las recetas; elegibilidad, costes y daño permanecen iguales.
[Acabado visual y validación](../cards/README.md#icono-de-enlace-y-acabado-de-cartas--18092026).

## Interacción con contraataque — 18/09/2026
El ataque conjunto cuenta como un único impacto. Si el objetivo sobrevive con postura de contraataque, responde por 4 contra el primer héroe de `combo.heroes`; bloqueo y mitigación normales se aplican. No se conceden curación ni bloqueo de la sinergia a un héroe que haya caído en esa respuesta.
