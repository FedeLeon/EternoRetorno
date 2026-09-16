# Campamento de selección

> **Actualización 16/09/2026:** los actores ahora usan cuadros de **128×128**,
> reimportados desde las fuentes originales. Se mantienen tamaño en pantalla,
> diseños y alineación. Ver [calidad actual, archivos y pruebas](../quality/README.md).
> Las medidas de 64 px y comprobaciones que siguen documentan la versión inicial.


Pantalla de elección ambientada en el concept `campamento.png` del usuario.
Fondo sin textos incrustados ni llama fija, seis vistas frontales alrededor de
la fogata, etiquetas de nombre, función y vida y selección de dos personajes.
La descripción completa se conserva en el tooltip de cada personaje.

## Recursos

- `assets/camp/background.png`: fondo de campamento adaptado a horizontal.
- `assets/camp/front-64.png`: seis vistas frontales de 64 × 64 para selección.
  El combate conserva sus sprites y animaciones anteriores.
- `assets/camp/fire-64.png`: seis cuadros de llama, 9 FPS en bucle.
- `src/campfire.gd`: animación, resplandor y 16 chispas pequeñas que ascienden
  y pierden opacidad. No utiliza el generador aleatorio de la aventura.
- `scripts/import_camp.gd`: recorte y escalado nearest reproducibles de las
  fuentes `front-source.png` y `fire-source.png`, conservando transparencia.

Las imágenes se generaron con imagegen integrada; prompts en `prompts.md`.
Los personajes frontales son poses estáticas; la fogata y las chispas se animan.

## Validación local

`./scripts/run.sh --script tests/test_camp.gd`: 47 comprobaciones sin fallos.
Comprueba movimiento de fuego, las 15 parejas mediante eventos de entrada,
límite de dos, deselección e inicio de aventura. Capturas reales en esta carpeta:
`camp-first.png`, `camp-second.png`, `camp-selected.png`.
La prueba de interfaz usa las nuevas posiciones del campamento.
No se compiló APK ni se probó este cambio en Android.
