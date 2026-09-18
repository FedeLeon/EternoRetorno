# Campamento previo a la aventura

Estado actual: **17/09/2026**.

## Navegación e interfaz

- Barra superior: «El Campamento, un lugar al que volver...», almas con icono
  y números gráficos existentes, y botón Menú para regresar al inicio.
- No hay barra inferior. Tocar el arco de piedra abre Continuar aventura,
  Nueva aventura y Volver. Continuar queda desactivado si no existe una run.
- Nueva aventura pide confirmación cuando hay otra activa. Cancelar conserva
  la partida; la sustitución solo ocurre al iniciar la nueva pareja.
- El saldo de almas solo se muestra en el campamento y dentro de sus edificios.
  Se siguen concediendo almas al ganar combates, sin mostrar saldo ni premio
  de almas en combate, mapa o recompensa.
- El solar 1 permite construir el [mercado](../market/README.md) por 300 almas.
  Una vez construido muestra el edificio; tocarlo abre el mercado. La construcción
  y el saldo son persistentes.
- El solar 3 permite construir la [herrería](../forge/README.md) por 400 almas.
  Su edificio abre mejoras independientes de arma y armadura para cada héroe.
  Los solares 2 y 4 y las otras mejoras del refugio quedan pendientes.

## Archivos y assets

- `src/ui/screens/base_camp_screen.gd`: escenario, barra y zonas interactivas.
- `src/ui/components/soul_counter.gd`: icono y dígitos, sin reglas económicas.
- `src/ui/components/dialog_view.gd`: presentación de diálogos con acciones.
- `src/ui/components/modal_frame.gd`: marco compartido de diálogos y tesoros.
- `src/main.gd`: conecta acciones y mantiene la navegación y confirmaciones.

El fondo original del usuario `campamentoConstruccion.png` se conserva en
`assets/base_camp/background.png`. Assets nuevos generados con imagegen integrado:

- `assets/base_camp/market_building.png`: edificio aislado para el solar 1.
- `assets/forge/building.png`: herrería aislada para el solar 3; [procedencia](../forge/building.json).
- `assets/ui/soul.png`: alma celeste con fondo transparente.
- `assets/ui/modal_frame.png`: marco ornamental de hierro y oro, interior oscuro.

Prompts completos en [assets-2026-09-17.json](assets-2026-09-17.json), procedencia
por archivo en [sources-2026-09-17.json](sources-2026-09-17.json).
El pequeño cuadro anclado de reliquias conserva su presentación independiente.

## Validación de este cambio

Pruebas locales Godot: campamento 33, mercado 34, tesoro UI 8, HUD 92,
mapa 21, reglas de tesoro 22 e interfaz general 271; todas sin fallos.
Campamento, arco, confirmación, mercado y recompensa de tesoro revisados
renderizados en Linux a 1280×720. Capturas temporales eliminadas tras revisar.
Sin exportar APK/Web ni probar este cambio en navegador, emulador o dispositivo físico.

La barra superior usa ahora el [marco ornamental compartido](../ui_buttons/README.md)
y Menú un cartel de madera (17/09/2026). Los textos de los modales están centrados.

## Carteles de madera — 17/09/2026

Los carteles del campamento reutilizan `assets/ui/buttons/wood_button.png`
mediante `button_skin.gd`, aplicado al panel de `main.gd::camp_hotspot`.
Mercado y Herrería construidos muestran solamente su nombre, sin «Entrar».
Se conservan las áreas interactivas y la prioridad del cartel del mercado.
Procedencia del asset compartido: [wood-assets.json](../ui_buttons/wood-assets.json).

Validación de este ajuste: `test_forge_ui.gd`, 46 comprobaciones sin fallos,
incluyendo clics en ambos carteles. Revisión visual del campamento en Linux
a 1280×720. Sin exportar APK/Web ni probar en dispositivo.
