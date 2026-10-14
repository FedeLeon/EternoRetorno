> **Limpieza del 14/10/2026:** se retiraron los PNG fuente sustituidos/rechazados
> de esta etapa y sus importadores antiguos. Los prompts y registros se conservan
> como historial; las fuentes y herramientas del arte vigente permanecen intactas.
> [Inventario y validación actuales](../cleanup/2026-10-14.md).

# Revisión del juego y pulido — 08/10/2026

## Alcance

Se revisaron las pantallas de inicio/opciones, campamento y edificios, preparación,
mapas, combate, mazo/bolsa, encuentros/descanso, premios, resultados y bestiario;
también presentación de impactos, audio, catálogos y generación de las tres mazmorras.
La revisión local parte de los sistemas existentes (incluidas las cinemáticas),
sin reconstruirlos ni atribuir sus entregas anteriores a este cambio.

## Cambios aplicados

| Área | Problema observado | Resultado |
| --- | --- | --- |
| Turno enemigo | La vida aliada se actualizaba al final de toda la ronda | Cada golpe muestra su cifra, absorción, vida y reacción sobre su receptor; la caída se presenta inmediatamente |
| Accesibilidad | Desactivar sacudidas también ocultaba las cifras | Números y audio permanecen disponibles con impactos sin sacudidas |
| Animación enemiga | Salto del cuarto reposo al primero y ataques con poca anticipación | Ciclo de ida y vuelta, anticipación, golpe sostenido y recuperación; perfiles de bestia, vuelo, armas, magia y ataque a distancia |
| Efectos | Curación/bloqueo dependían casi solo del cambio numérico | Partículas verdes al recuperar vida y destellos azules al ganar bloqueo, sin carteles de estados; modos de menos efectos respetados |
| Mapa | Conexiones disponibles estáticas y contador sobre papiro | Marcadores pequeños recorren caminos disponibles; mensaje inicial y contador enmarcados, sin revelar tipos de sala |
| Bestiario | Muchas fichas desconocidas antes de encontrar datos útiles | Descubiertos primero, búsqueda, filtros por mazmorra, contador de descubrimientos y estado vacío legible; no revela nombres sin descubrir |
| Opciones | Deslizadores sin valor explícito | Porcentaje actual junto a cada volumen e intensidad de destellos |
| Audio | Cambios bruscos de ambiente y muestras consecutivas iguales | Fundidos de ambiente/ganancia musical y alternancia de muestras de efectos; sin sonido al pasar el mouse |
| Música | Misma pista en batallas de los tres pisos | Dos arreglos locales del material CC0 existente para bosque y fortaleza; premios suavizan la misma pista sin reiniciarla |
| Enemigos | Seis conceptos seguían reservados | Dos nuevas criaturas por piso con ocho poses dibujadas y ataque HD transparente de derecha a izquierda |

### Nuevos enemigos

| Piso | Enemigos nuevos | Función |
| --- | --- | --- |
| Cripta | Saqueador de tumbas, Serpiente de escarcha | Dagas/contraataque y ataque helado en área con pausas defensivas |
| Bosque | Murciélago alfa, Cuervo de las ruinas | Ataques fuertes alternados con defensa y golpes en área moderados |
| Fortaleza | Lobo de ceniza, Señor de las brasas | Bestia ofensiva y protector de compañeros con contraataque |

Los catálogos comunes pasan a **20/22/18 tipos**, con debut gradual y formación
variable existente. Las 57 definiciones activas usan las 56 apariencias de las
plantillas; las seis anteriores reservadas reciben sus atlas propios.
Los patrones usan reglas existentes; no incorporan estados ocultos ni nuevas
maldiciones. Requieren balance adicional mediante partidas humanas.

## Arquitectura y compatibilidad

- `data/polish_enemies.json` se integra por la fachada `content.gd`; `dungeons.json`
  solo determina encuentros de aventuras/pisos generados nuevos.
- `enemy_motion.gd` extrae perfiles visuales del actor; `enemy_sprite.gd` conserva
  tamaño/apoyo y APIs. `enemy_pose_sizes.json` añade métricas de seis atlas nuevos.
- `game.resolved_enemy_hits` es un recibo transitorio por acción, fuera del guardado.
  `combat_turns.gd` registra diferencias después de aplicar daño. No cambia cálculo,
  orden de reglas, duración del bloqueo ni recompensas.
- `enemy_action_playback.gd` presenta esos recibos; `support_feedback.gd` y
  `map_route_flow.gd` son efectos locales sin mutación de juego/RNG.
- Bestiario consulta una copia de descubrimientos. Sus filtros no escriben perfiles.
  El controlador principal no crece; no se reorganizan IDs/UIDs ni guardados.
- Audio usa su RNG propio. Música/ambiente/SFX conservan buses y preferencias Web.

## Assets, música y regeneración

ImageGen integrado, una generación por atlas/cut-in, con los seis conceptos
existentes como referencia. [Prompts completos](prompts.json),
[fuentes y hashes](sources.json). Los originales permanecen en `sources/` bajo
`docs/.gdignore`; los presets excluyen documentación.

```sh
python3 scripts/pack_polish_motion.py
.tools/Godot_v4.7.2-stable_linux.x86_64 --headless --path . --script scripts/import_polish_enemies.gd
python3 scripts/audit_enemy_pose_sizes.py
python3 scripts/prepare_dungeon_music.py
```

Seis reparaciones conservan figuras completas, pero sus columnas no son uniformes.
`pack_polish_motion.py` separa mecánicamente cuerpos conectados y asigna partículas
al cuerpo más próximo, sin dibujar ni cambiar escala; deja 20 px de alfa alrededor
de cada pose en `normalized/`. Los intentos anteriores están en `rejected/`;
[reparaciones](repair_prompts.json) y [medidas del empaquetado](packing.json) registran
la procedencia. Requiere Pillow, NumPy y SciPy para regenerar.

El importador comparte corte/alineación de atlas: 4×2 cuadros a 8×128×128, sin
pintar poses ni sustituirlas por escalados. Cut-ins a 900 px, alfa conservado,
compresión lossy 0,9; atlas sin pérdida. Los gráficos nuevos suman **6,54 MiB de
PNG de trabajo**. Los arreglos musicales suman **4,84 MiB de Ogg**. No son medidas
de exportación ni de memoria en dispositivos.

La música combina la pista de batalla licenciada con ambiente de aves/fuego,
ecualización y normalización; son arreglos de grabaciones existentes, no
composiciones IA. [Procedencia de mezclas](music_sources.json) y
[autores/licencias originales](../audio/sources.json).

## Validación y límites

Las **84/84 suites headless** pasan sin errores de script/aserciones.
La suite nueva verifica 125 condiciones en ventana nativa; tamaño/apoyo de enemigos
verifica 867 y el recorrido de interfaz 13 condiciones sobre 36 vistas.
Pruebas actuales y revisión visual se registran en [validation.json](validation.json).
Entorno nativo: Godot 4.7.2, Linux, Compatibility/Mesa llvmpipe, 1280×720.
Se inspeccionan los doce assets nuevos, ataques/cut-ins en combate, filtros del
bestiario, opciones, mapas y cifras de impacto. El recorrido automático de 36
vistas no detecta desbordamientos de etiquetas.

La grabación nativa de las dos músicas tiene señal y pico limitado; no equivale
a una evaluación humana de composición/mezcla ni valida el desbloqueo del audio
en navegadores. Los avisos de recursos al cerrar algunas suites se separan de
fallos de script/aserciones. No se afirma haber eliminado esos avisos del motor.

**No se exportó Web/APK ni se probó navegador, emulador o dispositivo físico.**
Quedan para partidas humanas el balance de los seis patrones y la preferencia
musical; para dispositivos, memoria/FPS y lectura táctil. La arquitectura general
conserva las extracciones futuras documentadas, sin una migración masiva.
