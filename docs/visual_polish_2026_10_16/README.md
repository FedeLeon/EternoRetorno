# Guardia suave, escenarios e iconos de desbloqueos

Actualizado el **16/10/2026**. Dirección vigente: cómic americano, civiles del
campamento y tecnología improvisada del mundo postapocalíptico.

> La guardia descrita en esta sección fue reemplazada después por
> [24 dibujos por héroe](../guard_weather_2026_10_16/README.md).
> Los resultados siguientes documentan la implementación anterior.

## Guardia durante el combate

La secuencia anterior cambiaba entre dibujos con diferencias de silueta y añadía
una copia de la pose previa que se desvanecía. El resultado podía parecer una
superposición o un salto de postura, aunque el suelo/escala fueran estables.

Ahora el reposo conserva una **silueta estable**, con respiración y balanceo leves
calculados de forma continua: pecho, hombros, brazos/herramientas, pelo y ropa.
No hay saltos entre imágenes, copias superpuestas ni cambios de escala del actor.
Los ciclos duran entre 4,4 y 4,97 segundos, desfasados por personaje; el balanceo
más lento continúa entre ciclos y la amplitud entra gradualmente al volver a
reposo. Las botas quedan fuera de la zona móvil.

- `hero_guard_idle.gd`: reloj visual, activación/interrupción y fase continua.
- `guard_breath.gdshaderinc`: movimiento local pequeño, con máscara que lo anula
  completamente en los pies; una sola imagen y sin cambiar proporciones globales.
- `detailed_equipment.gdshader`: integra el muestreo conservando tintes de daño,
  alfa y brillo de equipo. Se apaga al atacar, defender, correr o caer.
- El atlas existente de 12 poses conserva formato, UID y referencias; el reposo
  usa su pose neutral. No se afirma que se hayan creado más sprites de guardia.
- Las animaciones de acciones y los primeros planos estáticos siguen separados.

## Escenarios más oscuros

`battle_background.SCENERY_TINT = (0.77, 0.79, 0.83)` reduce ligeramente el brillo
solo del escenario, sin pintar una capa oscura encima de los personajes.
Se aplica en los tres pisos y sus variantes de combate, entrenamiento, caminos,
descanso, cofres y encuentros. El shader de encuentros admite el mismo tinte
sin perder su animación ambiental. Campamento, selección y edificios conservan
su iluminación actual.

Personajes, salud, intenciones, cartas, HUD, rayos y partículas mantienen sus
colores. La selección del fondo y su encuadre/suelo no cambian ni consumen RNG.

## Ocho nuevos primeros planos de ataque

Dos ilustraciones nuevas por héroe, además de la original: **tres por personaje**.
Todas son estáticas, con borde blanco fino y efectos independientes detrás.

| Personaje | Variantes nuevas |
| --- | --- |
| Nicolás | Estocada de sierra improvisada y golpe descendente a dos manos |
| Inés | Empujón de escudo de señal y barrido con palanca |
| Mauro | Doble corte de cuchillas y lanzamiento de frasco corrosivo |
| Vera | Disparo eléctrico a dos manos y arco con emisor de bobinas |

`hero_cut_in.gd` alterna 0 → 1 → 2 por héroe, sin repetir el dibujo consecutivo,
incluyendo los golpes de cartas de dos/tres impactos. El contador es únicamente
de presentación: no consume RNG de reglas ni se guarda. La defensa mantiene su
imagen actual. Conserva duración, tamaño, posición inferior izquierda y luces
extendidas por la vista. Los ocho PNG nuevos son 1536 × 1024, alfa real e
importación con la misma calidad 0,9 que los primeros planos existentes.

## Desbloqueos con arte propio

Quince PNG nuevos de cómic, de 256 × 256:

- Cuatro cartas desbloqueables: Marca de corte, Refuerzo permanente, Oxidación
  persistente y Señal persistente. Ya no repiten el icono de victoria del héroe.
- Reloj sin arena.
- Las nueve reliquias exclusivas de los jefes, con ilustración dedicada para
  esta galería. Los assets de reliquias usados fuera de la colección se conservan.
- Icono de la pestaña Desbloqueos.

La navegación suministra el icono individual en cada snapshot; la pantalla sigue
sin conceder premios ni guardar. Los iconos bloqueados conservan más color para
que se aprecie el dibujo, junto al requisito existente de desbloqueo.

## Procedencia y reproducción

`jobs.json` conserva los diez prompts exactos, herramienta `image_gen.imagegen`,
referencias/originales y rutas finales; las fuentes están en `sources/`.
Hay ocho generaciones individuales de primeros planos y dos hojas de iconos,
con orden explícito de celdas. `scripts/import_visual_polish_16.gd` solo separa
celdas, conserva proporciones y añade margen transparente. La extracción del
reloj y la credencial toma la silueta principal para evitar fragmentos vecinos;
esa decisión está registrada en el trabajo de la hoja.

El manifiesto `docs/art_direction/postapocalyptic/assets.json` incluye SHA-256 y
fuente de cada recurso. No se sobrescriben los primeros planos originales.
Fuentes, pruebas y capturas siguen fuera de exportaciones mediante los filtros
existentes; no se exportó el juego.

## Validación local

Comprobaciones actuales con Godot 4.7.2, audio Dummy y datos de prueba aislados:

| Comprobación | Resultado |
| --- | --- |
| Regresión completa headless | **103/103 suites aprobadas** |
| Contenido | 1.510 comprobaciones / 0 errores |
| Procedencia/dirección visual | 712 recursos validados, 0 pendientes/legacy/hashes inválidos |
| Atlas existentes de batalla | 96 hojas / 928 frames / 0 errores |
| Guardia e interrupciones | 1.358/0 headless y 1.358/0 nativo aislado |
| Nuevos escenarios, iconos, variantes y RNG | 115/0 headless y 118/0 nativo aislado |
| Primeros planos estáticos | 261/0 headless |
| Colección | 50/0 headless y 50/0 nativo aislado |
| Combos/contraataques reales | 0 fallos; dos/tres imágenes distintas para dos/tres golpes |

La prueba nativa adicional compara imágenes realmente renderizadas: hay
movimiento en el cuerpo, tiempos cercanos producen variaciones pequeñas y la
zona de las botas permanece idéntica. También se revisaron las capturas de los
tres pisos, las tres variantes de cada héroe y los quince iconos. Las primeras
comprobaciones detectaron movimiento residual en las botas: se corrigió la
máscara para anular **todas** las contribuciones en esa zona. Se actualizaron
las aserciones antiguas que exigían repetir una misma imagen durante el combo;
se conservaron las verificaciones de número de golpes, daño y contraataques.

Algunas suites UI muestran avisos de ObjectDB/recursos al cerrar Godot; las
aserciones y errores de script se evalúan por separado. Esta evidencia es local:
**no se exportó ni se probó Web, emulador o dispositivo físico**. Los materiales
se comprobaron en el render nativo Compatibility/llvmpipe.

Capturas/logs desechables: `artifacts/visual_polish_16/` (fuera de Git).
