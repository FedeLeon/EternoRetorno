> **Etapa histórica retirada el 14/10/2026.** Los primeros planos de héroes
> ahora usan [ocho imágenes estáticas nuevas](../static/README.md). Se eliminaron
> los atlas y fuentes PNG de animación, junto con sus montadores exclusivos.
> Los prompts y resultados siguientes se conservan como historial, no como
> instrucciones de reproducción ni validación de la entrega actual.

# Primeros planos sketchbook — 13/10/2026

## Dirección visual para todo el juego

Decisión explícita: todo Eterno Retorno debe migrar a arte conceptual con aspecto
de grafito y lápices de colores dibujados a mano, sobre papel, con líneas de
construcción, tramado, pigmento irregular y pequeñas desprolijidades. Predominan
negro, gris y violeta, con contraste suficiente. El aspecto de dibujo manual no
es una afirmación de autoría: estos assets se generan mediante ImageGen.

Esta dirección incluye héroes, enemigos, mazmorras, escenarios, campamento,
interiores, cartas, menús y cinemáticas. Se guardó también como preferencia en
la memoria de Codex, por pedido del usuario. La migración es progresiva: no se
presenta una conversión completa mientras sigan activos assets anteriores.

[Guía común para cualquier asset nuevo](STYLE_GUIDE.md).

## Primera etapa: ataque y defensa en primer plano

Cuatro protagonistas: Nicolás/Carpintero, Inés/Constructora, Mauro/Boticario y
Vera/Profesora. Referencias: la hoja sketchbook, los cuatro retratos aprobados
y el cuerpo de Mauro con cara visible. Se conservan las cuatro variantes de
ataque y una defensa por héroe, con dieciséis poses dibujadas por secuencia.

Las fuentes se generan en hojas 2×2 para mantener 768×512 píxeles por pose;
el montaje final es 4×4, 3072×2048. Fondo RGBA transparente para seguir viendo
la mazmorra. El papel se representa mediante textura dentro de los trazos,
sin un rectángulo opaco detrás del personaje. Se mantienen encuadre inferior
izquierdo, escala 1,28, desplazamiento (-0,10; 0,12), duración 0,96 s y rotación
visual de variantes en combos. No se cambian reglas, daño, energía ni guardados.

Los efectos del héroe usan destellos discretos, marcas cortadas y tramados
violetas, sin bloom aditivo liso. El adaptador de enemigos mantiene su modo
actual hasta su rediseño. Las poses normales de batalla/correr/descanso también
siguen pendientes de conversión; este cambio corresponde a los primeros planos.

## Archivos y reproducción

- `prompts.json`: 80 instrucciones exactas, referencias, héroe/acción/parte.
- `sources/*.png`: cuatro hojas por cada una de las veinte secuencias.
- `sources/*.json`: procedencia y salida original de cada generación.
- `scripts/import_sketchbook_cutins.gd`: montaje con el importador HD existente,
  recorte/escala común por secuencia; no interpola ni inventa dibujos.
- `assets/comic/motion/<hero>_<variant>.png` y `<hero>_defense.png`: rutas y UIDs
  existentes, reemplazadas cuando las nuevas fuentes estén verificadas.

```sh
./scripts/run.sh --headless --script scripts/import_sketchbook_cutins.gd
./scripts/run.sh --headless --editor --import
./scripts/run.sh --headless --script tests/test_comic_motion.gd
```

Las fuentes documentales están excluidas de la exportación. No se exporta el
juego en esta entrega. Dimensiones, hashes y pruebas actuales se registran en
`validation.json` al terminar; los resultados históricos del estilo anterior
no validan las imágenes nuevas.

## Siguientes etapas

1. Actores de combate y poses de los cuatro protagonistas, incluidos correr y descanso.
2. Enemigos: identidad de cada familia, poses y primeros planos de ataques.
3. Mazmorras: fondos de batalla, mapas, encuentros y descansos coherentes.
4. Campamento e interiores; después cartas, iconos, menús y escenas de historia.

Cada etapa debe reutilizar identidades, escala y paleta; revisar a tamaño real y
en movimiento antes de reemplazar el siguiente conjunto.

## Validación final de esta entrega

- Auditoría: 80 fuentes RGBA y veinte atlas HD, sin errores; hashes de fuentes
  y runtime en [asset_audit.json](asset_audit.json). Los dieciséis cuadros de
  cada atlas son distintos y conservan fondo transparente.
- 86 suites de Godot headless aprobadas; 1501 comprobaciones de catálogos y
  ocho pruebas negativas del validador. Se incluyen reproducción, golpes
  múltiples, defensas, resolución antes de animación y guardados.
- Godot nativo a 1280×720: veinte secuencias reproducidas, 1773 checks sin fallos.
  Revisión de capturas de Nicolás, Inés, Mauro y Vera confirma encuadre,
  identidades y escenario visible detrás. No se presenta como validación Web
  ni en dispositivo físico.
- Varias suites de UI dejan avisos de recursos/ObjectDB al cerrar, registrados
  en sus logs; no se afirma ausencia de fugas. Importación y diff sin fallos.
- Sin exportación. [Resultados, alcance pendiente y rutas de logs](validation.json).
