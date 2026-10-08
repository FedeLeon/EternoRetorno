## Actualización de pulido — 07/10/2026

[Implementación actual, assets, reglas y validación](../polish_2026_10/README.md).
La documentación y resultados anteriores se conservan como historial.

# Salas de encuentro — 30/09/2026

## Presentación

Los tres encuentros existentes tienen ilustración propia a pantalla completa,
compartida entre la cripta y el bosque. Ruinas, raíces y piedra mantienen la
continuidad visual de ambos pisos.

| Encuentro | Asset | Animación |
| --- | --- | --- |
| El pozo de los ecos | `assets/encounters/well.png` | Ondas y reflejos sobre el agua, motas turquesa ascendentes |
| El altar hambriento | `assets/encounters/altar.png` | Luz carmesí pulsante en la grieta y pequeñas partículas |
| La biblioteca hundida | `assets/encounters/library.png` | Resplandor cálido del libro y motas suspendidas |

Se eliminan los encabezados «Eterno Retorno», «Encuentro» y número de sala.
El nombre propio del suceso se conserva dentro del cuadro. Menú permanece
arriba a la derecha para acceder a la pausa y al cierre de aventura.

El cuadro pasa de 856×458 a **660×280**, centrado en la zona inferior de la
vista de 1280×720. Título, descripción y opciones están centrados. La escena
principal queda visible por encima; los efectos no deforman texto ni controles.

## Implementación y reglas

- `src/ui/screens/encounter_screen.gd`: fondo, material independiente, cuadro y señales.
- `assets/shaders/encounter_atmosphere.gdshader`: agua, luz y partículas locales;
  el resto de la mampostería permanece inmóvil. Posiciones calibradas contra
  los assets finales, sin mover toda la imagen.
- `src/main.gd::room_view`: entrega la instantánea y conecta las elecciones a
  `Game.choose_event`; omite el fondo genérico en estas salas.
- Se conservan IDs, efectos, restricciones y checkpoints existentes: beber cura
  ocho PV, ofrendar cuesta cinco PV a ambos y mejora una carta, leer ofrece una
  carta. El altar sigue bloqueado con vida insuficiente o sin cartas mejorables.
- No cambia el formato de guardado ni la generación de mapas.

## Arte y procedencia

Tres fondos nuevos generados individualmente con **image_gen integrado**.
Originales copiados a `assets/encounters/`; [prompts exactos](prompts.json) y
[procedencia](provenance.json) conservados aquí.

PNG fuente a resolución original; importación limitada a 1280 px, compresión
con pérdida 0,85. Política en `scripts/optimize_texture_imports.py` para conservar
esta configuración al ejecutar la herramienta. Los efectos se generan en el
shader, sin atlas de animación adicionales.

## Validación realizada

- Importación local en Godot 4.7.2 sin errores.
- `test_encounters_ui.gd`: **41 comprobaciones headless** y **47 con renderizado
  X11/Compatibility**, sin fallos. Incluye ambos pisos, efectos de las decisiones,
  restricciones del altar, salida y acceso al menú.
- La prueba renderizada compara cuadros separados: detecta movimiento en la
  región del encuentro y verifica que el suelo distante permanece inmóvil.
- Revisión visual de las tres capturas a 1280×720: foco de la escena libre,
  opciones legibles, marco compacto y textos centrados.
- Regresiones locales: `test_game.gd` **142** comprobaciones y
  `test_forest_ui.gd` **146**, sin fallos. `git diff --check` limpio.
- Capturas temporales en `artifacts/encounters/`. Sin exportación Web/APK;
  sin nueva validación de navegador, emulador ni dispositivo físico.

## Ampliación del 07/10/2026

Se agregan seis fondos/situaciones para bosque y fortaleza, con agua, brasas o luces localizadas según cada ilustración; textos/opciones conservan el cuadro compacto. Las modificaciones de mazo se eligen y confirman en una pantalla propia.

[Reglas, assets y pruebas actuales](../expansion_2026_10/README.md).
