# Encargados y diálogo ambiental — 30/09/2026

## Vistas

- **Mercado y Herrería:** conservan sus encargados y fondos; añaden diálogo ambiental.
- **Iglesia:** interior nuevo con sacerdotisa a la izquierda. Seis héroes a la
  derecha, en dos columnas y tres filas. Al elegir héroe, sus dos especializaciones
  ocupan la zona derecha, con título y Volver a héroes encima. Se conserva la
  separación de texto, acción y borde inferior.
- **Expediciones:** interior nuevo con veterano y mesa de mapas a la izquierda;
  tres contratos verticales a la derecha. Se mantienen ilustraciones, recompensa,
  aceptación/cancelación y restricciones durante la aventura.

## Globos

Los cuatro encargados tienen cinco frases propias cada uno, en
`data/camp_dialogue.json`. El primer globo aparece después de un segundo;
permanece entre 5,5 y 7 segundos, con entrada de 0,3 s y salida de 0,4 s.
Entre frases hay silencios de 7–11 segundos. La siguiente frase siempre es
 distinta a la anterior. Cambiar de vista reinicia el ciclo local.

El globo usa el marco oscuro compartido y una pequeña punta dibujada en código.
Queda abajo a la izquierda, sobre el mostrador, sin tapar la cara ni las tarjetas.
Sus nodos ignoran el ratón; no abren modales ni bloquean compras.

`src/ui/components/attendant_dialogue.gd` compone y anima el globo. Su reloj y
generador aleatorio son locales, sin acceso al juego o persistencia. Desaparece
con la pantalla; no quedan temporizadores externos ni callbacks pendientes.
No altera la generación de mazmorras, contratos ni guardados.

## Assets

Fondos reemplazados con **image_gen integrado**:

- `assets/church/interior.png`: [prompt y procedencia](../church/attendant-interior.json).
- `assets/expeditions/interior.png`: [prompt y procedencia](../expeditions/attendant-interior.json).

Los interiores anteriores fueron referencias temáticas; el mercado sirvió como
referencia visual y de composición. Originales nuevos copiados al proyecto;
rutas, UIDs e importación a 1280 px con calidad 0,85 conservados. Los interiores
previos siguen en Git. Mercado y herrería reutilizan sus assets actuales.

## Validación de este cambio

- `test_attendant_dialogue.gd`: **187 comprobaciones**, cero fallos con renderizado
  local X11/Compatibility. Ciclo de aparición/cierre y frase distinta con avance
  controlado del reloj, texto de las 20 frases, ratón ignorado, perfil intacto,
  eliminación al salir y separación de textos de 30 contratos/12 especializaciones.
- Regresiones headless: expansión **39**, herrería **110**, mercado **61**, sin fallos.
- Revisión de capturas a 1280×720: cuatro encargados con globo, galería de Iglesia,
  especializaciones y tres contratos visibles simultáneamente.
- `git diff --check` limpio. Capturas temporales en `artifacts/attendants/`.
- Sin exportación Web/APK ni prueba de navegador, emulador o dispositivo físico.
