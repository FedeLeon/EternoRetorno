# Conversión integral sketchbook — completada el 14/10/2026

> Limpieza posterior: las fuentes bitmap e importadores sustituidos de esta etapa
> se retiraron; se conservan prompts, metadatos y hashes. [Registro](../../game_review_2026_10_14/README.md).

> Registro histórico. Los dibujos y fuentes activos fueron sustituidos el 14/10
> por el [cómic postapocalíptico](../postapocalyptic/README.md). Las validaciones inferiores
> pertenecen a la etapa anterior y no certifican los recursos nuevos.

> **Limpieza posterior del 14/10:** se conservan 314 trabajos activos y sus fuentes.
> Los 69 trabajos de cartas sustituidas y las entradas de recursos retirados se
> archivaron en [cleanup](../../cleanup/2026-10-14.md). Se retiraron PNG rechazados
> y originales de etapas obsoletas, conservando prompts/procedencia. El inventario
> global actual verifica 628 imágenes. Las cifras siguientes describen su entrega.

> Actualización posterior del 14/10: las veinte secuencias de primer plano de
> héroes se reemplazaron por [ocho ilustraciones estáticas](../../comic/static/README.md).
> Se retiraron hojas/atlas y cuatro cómics antiguos de procedencia, conservando
> metadatos históricos. Esa etapa verificó 617 imágenes; los
> números y pruebas de la conversión inicial que siguen son históricos.
> Después se sustituyeron las ilustraciones de cartas por [88 dibujos mínimos](../../cards/minimal/README.md);
> el inventario global actual verifica 636 imágenes. Los originales de la etapa
> anterior quedan como documentación, sin sus 69 PNG runtime sustituidos.

Se integraron los **383 trabajos de generación de la cola**, además de las hojas
propias de actores y los derivados documentados. La auditoría final verifica
**629 imágenes actualizadas por hash, sin discrepancias y sin imágenes activas
pendientes de conversión**. Es un censo de archivos: un atlas contiene varias
poses y una variante derivada no equivale a una ilustración independiente.

## Dirección visual y alcance

Grafito y lápices de colores sobre papel, trazos imperfectos, negro/gris/violeta
y contraste marcado. Nicolás/Carpintero lleva casco abierto y espada, sin escudo;
Inés/Constructora conserva escudo de acero y trenza; Mauro/Boticario muestra
su rostro humano completo; Vera/Profesora usa libro y magia violeta.

- Cuatro héroes: cuarenta hojas de doce poses, diez acciones por protagonista.
  Atlas detallados de 256 px y ataques adicionales de 384 px, con escala corporal
  y apoyo comunes; carrera de ocho cuadros. Las 64 variantes de herrería son
  derivados con matiz discreto por nivel. No se agregan piezas sobre el cuerpo.
- 56 apariencias enemigas: ocho poses por actor (cuatro reposos/cuatro ataques),
  celdas de 256 px y cuatro dibujos de ataque en primer plano por apariencia.
  Los retratos de fallback usan el mismo cuadro normalizado del actor.
- Mazmorras, descansos, encuentros, mapa, selección, colección, inventario,
  entrenamiento, recompensas, marcos, cartas, objetos, reliquias, equipo,
  efectos, contratos, especializaciones y escenas cinematográficas.
- 17 SVG actualizados dentro del sistema editable existente; partículas con
  trazo de lápiz y paleta sobria. Se conservan los efectos funcionales de shaders
  (sangre, cenizas, viento, etc.); no se presentan como nuevas ilustraciones.
- Se reutilizan el campamento crepuscular, interiores, retratos y fuego aprobados.
  Ocho rutas heredadas reciben derivados del arte actual, conservando dimensiones.
  Los cuatro cómics antiguos quedan únicamente como procedencia histórica.
  Los veinte atlas de primer plano de héroes ya aprobados se mantienen.

## Fuentes y reproducción

`jobs/` conserva prompts exactos, referencias y ruta original de la herramienta;
`sources/` conserva las imágenes generadas y variantes rechazadas. Los manifiestos
`actors.json` (112 salidas), `assets.json` (458) y `vectors.json` (17) registran
integración y hashes; incluyen derivados y reutilizaciones. El inventario global
incluye también arte aprobado en entregas anteriores.

`queue.json` conserva el alcance; `generate_queue.js` describe la orquestación
mediante la herramienta integrada de generación. No ejecutarlo con Node ni usar
API/proveedores alternativos. La cola está terminada: no requiere regeneración.

Importadores: `scripts/import_sketchbook_actors.gd`,
`import_sketchbook_assets.gd` e `import_sketchbook_derivatives.gd`, con recortes,
escala y anclajes compartidos en `sketchbook_sheet_packer.gd`. Solo preparan
presentación: no calculan combate, conceden premios ni guardan partidas.
Las fuentes documentales están excluidas de Godot por `docs/.gdignore`.
Se preservan rutas, UIDs y compatibilidad de guardados; no se exportó el juego.

## Correcciones de revisión

Se regeneraron el papel del mapa con transparencia real, el muñeco y las raíces
como recortes independientes, dieciséis cartas que habían salido como mosaicos,
las opciones de descanso, el fondo de recompensa y cinco escenas de guardianes
con el entorno correcto. La hoja básica de veinte cartas conserva sus regiones
y muestra identidades actuales, incluido Mauro sin máscara. Los rechazos quedan
separados y no cuentan como aprobados.

Se corrigió la importación del papel grande del mapa (1280 px frente al límite
anterior de 192), el anclaje y escala de actores de 256 px, el halo bajo un pie,
y la alineación de numerales: los diez tienen su base opaca en la fila 46.
Filtro lineal para el dibujo nuevo; atlas sin redimensionar y alfa conservada.
Los primeros planos de héroes mantienen su encuadre inferior izquierdo y duración.

## Validación local final

| Control | Resultado |
| --- | --- |
| Inventario visual | 709 archivos, 635 imágenes; 629 hashes verificados, 0 discrepancias, 0 imágenes activas pendientes |
| Contenido | 1502 comprobaciones, 0 errores |
| Héroes detallados | 1108 comprobaciones, 0 fallos |
| Apoyo/tamaño/cenizas de enemigos | 867 comprobaciones, 0 fallos |
| Primeros planos enemigos | 0 fallos; 56 apariencias y sus cuatro poses transparentes |
| Variantes de herrería | 8220 comprobaciones, 0 fallos |
| Carrera | 121 comprobaciones, 0 fallos |
| Mapa | 141 comprobaciones, 0 fallos |
| Recompensas | 0 fallos de UI; advertencias de salida por 24 instancias/5 recursos vivos |
| Tesoro | 8 comprobaciones, 0 fallos |
| Cinemáticas | 84 comprobaciones, 0 fallos |
| Importación de Godot y formato del diff | Finalizadas correctamente, sin errores de script |

Render local con Godot 4.7.2, Compatibility/Mesa llvmpipe, X11 anidado fuera de
pantalla y audio Dummy para no interferir con la partida del usuario. Revisión
visual de hojas de contacto, identidades, alfa y composiciones generadas; no
sustituye recorrer manualmente toda la aventura. Sin pruebas Web, Android,
emulador o dispositivo físico, ni exportación.

Descanso pasó 25 comprobaciones durante una tanda anterior, antes de los últimos
dibujos de opciones; no se cuenta como validación visual final de esos dibujos.
Los intentos interrumpidos por pérdida del servidor X o salida 143 no se cuentan
como ejecuciones finales exitosas. Las advertencias de recursos de recompensa
quedan registradas como pendiente técnico de liberación al cerrar la prueba.

Para probar todos los reemplazos, reiniciar la ejecución del juego y permitir
que el editor termine de importar las texturas. [Inventario y galería](../2026-10-13/review/README.md).
