# Suelo de batalla de la fortaleza — 14/10/2026

El fondo anterior comenzaba el patio aproximadamente al 56 % de su altura.
Al mostrarse en `(0,64,1280,656)`, el suelo aparecía cerca de `y=430`, por
debajo del apoyo de los héroes, situado alrededor de `y=409`. Las ruinas y los
desniveles detrás de sus pies producían la sensación de flotar.

Se redibuja `assets/volcano/combat.png`: el patio comienza aproximadamente al
37 % (`y=307` en pantalla), con pavimento continuo bajo ambos bandos. Escaleras,
pedestales y escombros quedan al fondo; las grietas profundas se concentran en
los extremos inferiores. Se conserva la fortaleza volcánica dibujada a grafito
y lápices, con negro/gris/violeta y fuego discreto.

La tercera mazmorra utiliza este mismo fondo para sus combates normales,
élites y jefe mediante `ui/components/battle_background.gd`. No se cambian las
posiciones, escalas, animaciones, reglas ni guardados de los personajes.

## Procedencia y reproducción

- Edición con herramienta integrada `image_gen.imagegen`, dos iteraciones.
- [Prompt final](volcano_ground_prompt.txt).
- Fuente vigente: `docs/art_direction/migration/sources/scene/volcano__combat.png`.
- Trabajo, prompt anterior y rutas de generación:
  `docs/art_direction/migration/jobs/volcano__combat.json`.
- Hashes de fuente/runtime actualizados en `migration/assets.json`.
- Se conserva la ruta y resolución de 1536×1024; el importador habitual puede
  reproducir el recurso desde la fuente vigente.

## Validación actual

- Importación local Godot 4.7.2 sin errores de script.
- Revisión de dos capturas nativas a 1280×720, X11 aislado/llvmpipe y audio Dummy:
  Carpintero/Constructora contra Elemental de fuego y Lancero de ceniza;
  Boticario/Profesora contra el jefe volcánico. Los cuatro héroes apoyan sobre
  pavimento visible, con margen hasta las escaleras y muros del fondo.
- Auditoría de contenido: 1502 comprobaciones, cero errores. Inventario visual:
  628 hashes verificados, cero discrepancias.
- Capturas descartables en `artifacts/volcano_ground/`. Sin exportación ni
  validación Web/dispositivo; no se presenta como recorrido manual completo.
