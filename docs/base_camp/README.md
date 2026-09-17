# Campamento previo a la aventura

Estado actual: **17/09/2026**.

## Navegación e interfaz

- Barra superior: «El Campamento, un lugar al que volver...», almas con icono
  y números gráficos existentes, y botón Menú para regresar al inicio.
- No hay barra inferior. Tocar el arco de piedra abre Continuar aventura,
  Nueva aventura y Volver. Continuar queda desactivado si no existe una run.
- Nueva aventura pide confirmación cuando hay otra activa. Cancelar conserva
  la partida; la sustitución solo ocurre al iniciar la nueva pareja.
- El saldo de almas solo se muestra en el campamento y dentro del mercado.
  Se siguen concediendo almas al ganar combates, sin mostrar saldo ni premio
  de almas en combate, mapa o recompensa.
- El solar 1 permite construir el [mercado](../market/README.md) por 300 almas.
  Una vez construido muestra el edificio; tocarlo abre el mercado. La construcción
  y el saldo son persistentes. Otros solares y mejoras del refugio quedan pendientes.

## Archivos y assets

- `src/ui/screens/base_camp_screen.gd`: escenario, barra y zonas interactivas.
- `src/ui/components/soul_counter.gd`: icono y dígitos, sin reglas económicas.
- `src/ui/components/dialog_view.gd`: presentación de diálogos con acciones.
- `src/ui/components/modal_frame.gd`: marco compartido de diálogos y tesoros.
- `src/main.gd`: conecta acciones y mantiene la navegación y confirmaciones.

El fondo original del usuario `campamentoConstruccion.png` se conserva en
`assets/base_camp/background.png`. Assets nuevos generados con imagegen integrado:

- `assets/base_camp/market_building.png`: edificio aislado para el solar 1.
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
