# Configuración: engranaje de cómic y electricidad — 15/10/2026

Nuevo engranaje de metal desgastado, placas violetas, tornillos de cobre y
canales cian, con tinta y sombras de cómic. Generado con la herramienta integrada
`image_gen.imagegen`, una llamada independiente con fondo transparente.

- Asset activo: `assets/ui/settings.png`, **512×512**, sustituye el SVG anterior;
  UID de importación conservado. Fuente intacta en `sources/gear.png`.
- [Prompt exacto y procedencia](generation.json): herramienta, referencia visual
  (`heroes/identity/portraits/warrior.png`), ruta original de generación, dimensiones
  medidas y hashes. No generación por API externa ni pictograma de sustitución.
- `scripts/import_settings_icon.gd` valida transparencia y reduce proporcionalmente;
  manifiesto actualizado. Política de importación: 512 px, calidad 0,9. El generador
  vectorial deja de crear `settings.svg`. Originales/prompts bajo docs no se exportan.

`title_actions.gd` mantiene botón cuadrado 70×70, arriba a la derecha, sin texto,
con engranaje de 52×52 y filtro lineal con mipmaps para evitar ruido al reducirlo.
Reutiliza `end_turn_electricity.gd` para
arcos y chispas alrededor; capa sin captura de entrada. Respeta preferencias de
intensidad/calidad y estado deshabilitado. Sin giro del icono ni sonidos nuevos.
Configuración, guardado, volumen, pantalla completa y salida conservan sus acciones.

## Validación actual

`test_title.gd`: **18/0** con render nativo aislado, revisión de inicio/opciones,
icono a 512 px, alfa, capa animada sin captura de clic, apertura, volumen,
persistencia, modos de ventana, retorno y salida nativa. Auditoría **674 hashes
válidos**, sin visuales antiguos. Audio Dummy; avisos de recursos al cerrar,
sin errores de script/aserciones. Sin exportar ni probar Web/dispositivo físico.
