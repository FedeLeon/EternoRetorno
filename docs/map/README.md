# Mapa de aventura — 16/09/2026

## Presentación actual

- Fondo propio de piedra oscura, bordes dorados envejecidos y detalles violetas.
- Seis iconos interactivos: espadas (combate), santuario (encuentro), cofre,
  calavera (élite), fogata (descanso) y puerta del guardián.
- Las salas disponibles tienen un anillo dorado; la actual tiene un marcador.
  Visitadas y pendientes mantienen tonos diferentes. Solo se pueden tocar las
  conexiones que devuelve `Game.available_nodes()`.
- Se conserva el nombre de la cripta; se retiran «ETERNO RETORNO» y el subtítulo
  sobre el piso y las conexiones. Semilla disponible como tooltip del mapa.
- Héroes del lateral con área visual de 152×128 frente a la anterior de unos
  92×80, nombre y PV. Esta escala solo cambia el mapa.
- Reliquia inicial visible con su icono, nombre, alcance y efecto. También se
  muestran las encontradas, y equipos personales de partidas antiguas.
  Lista desplazable para evitar desbordamientos; Fénix conserva el estado por héroe.
- Mazo accesible con `assets/ui/deck.svg` (tres cartas), sin botón textual.
- Escalera disponible únicamente después de vencer al jefe.

## Organización

`src/ui/screens/map_screen.gd` recibe una instantánea de nodos, conexiones
habilitadas, héroes y reliquias. Emite peticiones de sala, menú, mazo y escalera.
No calcula recompensas ni modifica o guarda la aventura.
`src/main.gd::map_view()` conecta estas señales a las acciones existentes.
`equipped_relics()` comparte la preparación de datos entre mapa y HUD de combate.
No se cambian IDs, grafo, semilla ni formato de guardado.

`assets/map/background.png` y `nodes.png` son los originales finales utilizados
por el juego; el atlas se divide en tres columnas y dos filas en ejecución.
No se guardan copias redundantes. [Prompts y procedencia](prompts.md).

## Validación de esta entrega

- `tests/test_map.gd`: 21 comprobaciones renderizadas en Linux/llvmpipe a 1280×720.
  Incluye reliquias actuales y legadas, mazo por clic, entrada por icono, rechazo
  de sala inaccesible, bifurcaciones y escalera condicionada al jefe.
- `tests/test_hud.gd`: 92 comprobaciones headless, sin fallos tras compartir datos
  de reliquias.
- Revisión visual del mapa con dos héroes y reliquias inicial/hallada. Capturas
  temporales en `artifacts/map/`, eliminadas tras revisar.
- Importación y `git diff --check` correctos. Sin APK ni pruebas en Android.

## Almas (16/09/2026)

La barra del mapa muestra el saldo permanente de almas, enviado por el controlador.
