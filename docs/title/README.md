# Inicio y opciones

El fondo original del usuario se conserva en `assets/title/background.png`.
Se utiliza tanto en el splash nativo de Godot durante el arranque como en el
menú inicial; no se añade una espera artificial ni una barra de progreso ficticia.

Los botones se generaron con imagegen a partir de la misma referencia. El original
está en `generated-buttons.png` y el prompt en `prompt.md`. `scripts/import_title.gd`
recorta las placas rectangulares y las escala con vecino más cercano; sus textos
se dibujan en Godot para mantener legibilidad y permitir «Continuar aventura».
Los estados de puntero y pulsación cambian el tono; teclado tiene borde de foco.

- Iniciar juego abre el campamento.
- Continuar aventura restaura la aventura activa sin reemplazarla.
- Colección y acceso al campamento con aventura activa se mantienen.
- Opciones guarda volumen general y pantalla completa en el perfil permanente.
  El volumen controla el bus Master (no se agrega música en esta entrega).
  En Android, pantalla completa no se puede cambiar desde este menú.
- Atrás/Escape vuelve de Opciones al inicio.

Validación local: `tests/test_title.gd` prueba clics, volumen, persistencia,
pantalla completa/ventana y continuación. `tests/test_base_camp.gd` comprueba
la navegación del campamento. Capturas renderizadas: `home.png`, `options.png`.
Motor Godot 4.7.2, Compatibility, Linux. Sin compilar APK ni probar Android.

## Campamento como botón principal — 16/09/2026

Con una aventura activa, el menú central muestra «Continuar aventura»,
«Campamento» y «Opciones», en ese orden. Campamento reutiliza la placa principal
con igual ancho y altura; reemplaza el acceso lateral anterior. Sin aventura
activa, «Iniciar juego» sigue abriendo el campamento.

Cambio localizado en `src/main.gd::home()`. Prueba actual renderizada:
`tests/test_title.gd`, 13 comprobaciones sin fallos, incluyendo ir al campamento
y continuar conservando la aventura. Diseño revisado a 1280×720 en Linux.
Captura temporal eliminada después de revisar. Sin APK ni prueba Android.

## Botones de madera (17/09/2026)

Las acciones del inicio usan ahora el tablón del [tema compartido](../ui_buttons/README.md).
Textos y navegación se conservan. Validación local de inicio/opciones: 13 sin fallos.
