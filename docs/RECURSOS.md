# Recursos y mantenimiento

## Distribución

| Carpeta | Contenido |
| --- | --- |
| `assets/` | PNG, SVG, fuentes, shaders y audio que utiliza el juego. |
| `data/` | Definiciones y referencias del juego. |
| `art_sources/` | Originales, prompts, trabajos, licencias y procedencia de producción. |
| `docs/` | Guías escritas del estado actual. |
| `artifacts/` | Capturas, auditorías y guardados temporales de prueba. |

`art_sources/` mantiene la agrupación por familia de producción para conservar
la trazabilidad. Una fecha en el nombre identifica el trabajo que produjo un
recurso, no una versión alternativa del diseño vigente. Algunas fuentes antiguas
siguen siendo referencias o ancestros de dibujos actuales y no son descartables
solo por su nombre.

Los originales de producción no se trasladan a `assets/`: eso los convertiría
en posibles recursos importados/exportados del juego. `art_sources/.gdignore`
evita importarlos, y ambos presets excluyen `art_sources/*` y `docs/*`.
No se crean capturas, PNG de prueba o informes automáticos dentro de `docs/`.

## Procedencia actual

`art_sources/art_direction/postapocalyptic/assets.json` registra los recursos
visuales integrados, con hash de destino, fuente, hash de fuente y procesamiento.
Puede contener `origin` para conservar el origen de un dibujo seleccionado de
un banco anterior. No se pierde esa relación por retirar el reproductor de atlas.

`scripts/audit_postapocalyptic_art.py` verifica cobertura y hashes;
`audit_pixel_cards.py` comprueba cartas y fuentes vigentes. Los informes van a
`artifacts/art_provenance/` y `artifacts/pixel_cards/`.
El manifiesto vigente prevalece sobre una aprobación intermedia de otra migración.

`art_sources/static_combat_2026_10_19/extraction.json` describe los dibujos
seleccionados. `source_frames/` conserva PNG individuales para regenerar el
resultado sin recuperar atlas de animación retirados:

```bash
python3 scripts/audit_static_combat.py
```

Para regenerarlos deliberadamente existe `scripts/prepare_static_combat.py`.
Es una herramienta de escritura, no un auditor: actualiza PNG y catálogos.
Debe revisarse su diff e importación antes de considerar válido el resultado.

## Acciones HD de héroes

`art_sources/hero_actions_hd_2026_10_19/` conserva cuatro fuentes de ImageGen,
los prompts y las referencias de identidad. Cada fuente contiene seis dibujos
independientes: cinco acciones y una referencia de escala, que no sustituye
el reposo usado por el juego. No son ciclos de animación ni atlas de ejecución.

`scripts/import_hero_actions_hd.gd` selecciona cada silueta conectada para no
mezclar herramientas que atraviesan separadores con la figura vecina. Conserva
alfa y su franja suavizada, corrige el color transparente de los bordes y solo
reduce proporcionalmente. Alinea los pies a 496 dentro de 512×512 y utiliza una
escala anatómica común derivada de la referencia de reposo. Guarda las veinte
poses en `source_frames/heroes/` y en sus rutas estables de `assets/combat_static/`.

El importador actualiza catálogo, extracción y procedencia; la reducción común
no supera 1 y las referencias conservan 361–423 px de detalle vertical nativo,
frente a los 358 px de las ilustraciones actuales de reposo. La calidad no se
obtiene ampliando las poses erguidas antiguas de 132–195 px de alto.

Para regenerar deliberadamente esta integración, antes de importar el editor:

```bash
.tools/Godot_v4.7.2-stable_linux.x86_64 --headless --path . --script scripts/import_hero_actions_hd.gd
```

Es un comando de escritura, no una auditoría. Las rutas y los UIDs existentes
se conservan; los hashes nuevos corresponden a dibujos nuevos. El índice de
cómic marca las poses con borde ya pintado para evitar duplicarlo con el shader.

## Importadores

Las herramientas de `scripts/` buscan sus registros y fuentes en `art_sources/`.
Los importadores compartidos siguen filtrando cuerpos animados retirados y
respetando recursos conservados por decisión del usuario.

`art_sources/retired_resources.json` es la política mínima de recursos retirados
que consume `resource_retirements.gd`. No depende de un informe histórico de
limpieza y no se carga desde el juego. Una restauración intencional debe revisar
esa política, sus consumidores y el catálogo.

Los generadores de arte/audio y las colas pueden modificar resultados. No deben
ejecutarse como si fueran verificaciones de solo lectura. Los auditores generan
únicamente informes en `artifacts/`.

## Limpieza segura

1. Comprobar referencias de código, catálogos, importadores y rutas dinámicas.
2. Revisar relaciones de fuentes, geometría y procedencia antes de borrarlas.
3. Conservar IDs/UIDs de recursos vigentes y compatibilidad de guardados.
4. Ejecutar las comprobaciones apropiadas y revisar enlaces tras mover archivos.
5. Mantener resultados descartables fuera de `docs/` y actualizar las guías afectadas.

`scripts/audit_repository.py` detecta referencias literales rotas y metadatos
huérfanos. Un archivo sin coincidencias literales no queda demostrado como inútil.
Los PNG individuales de estados distintos se conservan aunque compartan píxeles:
son recursos explícitos que consume el sistema de acciones actual.

El historial de versiones vive en Git. La documentación vigente no mantiene
carpetas de sistemas retirados, planes completados ni copias de sus informes.
La limpieza no reescribe Git ni borra las herramientas locales o los guardados
reales del jugador fuera del repositorio.
