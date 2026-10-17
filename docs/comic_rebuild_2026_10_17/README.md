# Renovación integral: juego dentro de un cómic

> Revisión posterior: [Source Sans 3 restaurada y números eléctricos minimalistas](../typography_2026_10_17/README.md). Las fuentes Comic Neue/Bangers y la validación completa descritas abajo corresponden a la primera entrega; la revisión posterior tiene pruebas propias.


**17/10/2026. Arte integrado: 716/716 recursos, sin pendientes de conversión.**
Regresión final completada: **107/107 suites headless**, más revisión nativa de las vistas principales.

## Dirección y alcance

[Guía vigente](STYLE_GUIDE.md): cómic americano original postapocalíptico, tinta
negra, sombras planas, tramas, acentos violeta/naranja/teal/cian y recorte blanco.
Nicolás, Inés, Mauro y Vera conservan sus oficios, identidades y herramientas.

- **684 PNG renovados y 32 SVG reelaborados**: personajes, animaciones, 56 máquinas,
  primeros planos, escenarios, interiores, edificios, caminos, cartas e iconos.
- Comic Neue para lectura, Comic Neue Bold para cartas/botones y Bangers para
  titulares. Licencias OFL conservadas en `assets/fonts/`:
  [Comic Neue](https://github.com/google/fonts/tree/main/ofl/comicneue),
  [Bangers](https://github.com/google/fonts/tree/main/ofl/bangers).
- Botones y paneles de tinta/papel, cartuchos de intención oscuros, bordes de
  viñeta y paneles oblicuos detrás de los primeros planos con rayos y partículas.
- Las 88 ilustraciones de cartas mantienen símbolos sencillos. Cuatro marcos y
  reversos propios; títulos/costes medidos por héroe, tipografía en negrita y
  filtrado lineal. Reserva reversible y datos de cartas conservados.
- Energía, terminar turno y configuración usan componentes aislados con centros
  despejados. Descanso muestra botiquín/mejora de carta y el barril compartido con
  brasas, luz y chispas entre los héroes.

## Implementación y compatibilidad

`comic_outline` configura la alternativa de contorno por fotograma, limitada a
su celda incluso al leer el color base. `data/comic_art.json` permite omitir ese
muestreo en dibujos que ya tienen el recorte pintado. `comic_presentation` decora
nodos al crearlos, con caché acotada y sin recorrer el árbol cada frame.
`comic_panel` aporta márgenes y tramas sin recibir entrada; inicio, cinemáticas y
caminos usan el borde exterior completo para respetar sus cabeceras.

Los componentes visuales conservan las rutas, UIDs y las reglas de combate,
premios y persistencia. Las mejoras de equipo usan tintes sobre los nuevos
atlas compatibles. Primeros planos estáticos; reposo de héroes con 24 dibujos,
acciones detalladas con 12 y carrera clásica con ocho. Las correcciones de
escala de carrera se preparan fuera de ejecución, manteniendo escala uniforme
al reproducir; pies de animales en 174 y dígitos con línea de base en 46.

## Fuentes y reproducción

[queue.json](queue.json) contiene **241 trabajos** que cubren todo el inventario.
[jobs/](jobs/) conserva prompts, referencias, salida original y fuente local de
cada trabajo. [revisions/](revisions/) conserva las cinco versiones sustituidas
al despejar tres controles y mejorar las dos opciones de descanso. Los originales
permanecen en `sources/` con `.gdignore`; no forman parte de los recursos runtime.
Generación con `image_gen.imagegen` integrado, sin fallback de API key.

- `plan_comic_rebuild.py`, `comic_rebuild_queue.py`, `generate_remaining.js`:
  inventario y cola duradera; admite las referencias congeladas de revisiones.
- `comic_rebuild_packer.gd`, `import_comic_rebuild.gd`: recorte/escala/atlas,
  conversión RGBA, validación de dimensiones y fuentes; el inicio recorta desde
  arriba para conservar el logotipo completo.
- `derive_comic_rebuild.gd`: atlas clásicos/equipo y retratos compatibles.
- `rebuild_comic_vectors.py`: conserva geometría semántica y añade tinta/recorte.
- `audit_comic_rebuild.py`: verifica cobertura, hashes de fuentes/salidas,
  dimensiones e ilustraciones de cartas no vacías. Resultado: [status.json](status.json).
- `build_comic_style_index.py`: índice pequeño exportable para el decorado.

Los importadores históricos actualizados respetan la revisión nueva de los recursos que
producen para evitar volver a instalar sus ilustraciones anteriores.

## Validación local

- Auditoría nueva: **241/241 trabajos, 716/716 recursos, cero pendientes/errores**.
- Auditoría de arte general: **716 convertidos, cero recursos anteriores**.
- Atlas: **100 hojas / 1.024 fotogramas / cero errores**.
- Contenido: **1.511 comprobaciones / cero errores**.
- Regresión final: **107/107 suites headless, cero fallos de aserción/script**.
  Resumen conservado en [validation.json](validation.json); logs regenerables en
  `artifacts/comic_rebuild/final_regressions/`.

Pruebas nativas aisladas realizadas con Godot 4.7.2 y X11/llvmpipe:

| Vista o componente | Comprobaciones | Fallos |
| --- | ---: | ---: |
| Inicio | 18 | 0 |
| Preparación de aventura | 30 | 0 |
| Campamento y animales | 54 | 0 |
| Presentación/campamento/mapas | 115 | 0 |
| Galerías de edificios | 84 | 0 |
| Colección | 50 | 0 |
| Descanso | 25 | 0 |
| Cartas y reserva reversible | 30 | 0 |
| Guardia de héroes | 1.354 | 0 |
| Distribución de combate | 184 | 0 |
| Contorno y aislamiento de atlas | 54 | 0 |
| Primeros planos de héroes | 261 | 0 |
| Caminos | 153 | 0 |
| Cinemáticas | 84 | 0 |

Tras la revisión de capturas se repitieron inicio, caminos, descanso y combate
con sus correcciones finales. Evidencia en `artifacts/comic_rebuild/native/`;
capturas en `artifacts/title/`, `combat-floor/`, `building_interiors/`,
`collection/`, `rest/` y `pixel_cards/`. Revisados visualmente inicio completo,
preparación, campamento construido, laboratorio/especializaciones, colección,
descanso, cartas/reversos y batalla del tercer piso.

Algunas suites avisan de objetos/recursos retenidos al cerrar. La prueba de
integridad provoca deliberadamente un fallo de copia de respaldo para comprobar
que conserva el guardado principal. Se distinguen de fallos de aserción o script.
No se exportó Web/APK ni se probó navegador, emulador o dispositivo físico;
las pruebas locales no certifican el rendimiento de esas plataformas.
