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

## Edificios sin recuadro y cartel del mercado arriba — 18/09/2026

`main.gd::camp_hotspot` usa StyleBoxEmpty para normal, hover, pulsado, foco
y deshabilitado, retirando el rectángulo amarillo sobre los edificios.
La opción `caption_above` coloca el tablón encima y extiende hacia arriba
el área de clic. `base_camp_screen.gd` la activa para el mercado construido;
el solar sin construir conserva el cartel inferior. El mercado queda rotulado
sobre el tejado y separado de la herrería. Se conserva el asset de madera.

Validación actual: `test_forge_ui.gd`, 46 comprobaciones sin fallos, incluyendo
clics en ambos carteles. Revisión visual Linux a 1280×720. Capturas temporales
eliminadas. Sin exportar APK/Web ni probar en dispositivo.

## 18/09/2026 — Ambientación animada del campamento diurno

El fondo diurno usa `assets/shaders/camp_day.gdshader`: brisa suave localizada
en las copas laterales, ondulación/reflejos del lago, flujo discreto de la
cascada izquierda y oscilación/brillo de las llamas centrales. Máscaras suaves
por coordenadas y color limitan el movimiento sobre la ilustración original.
No es animación esquelética ni un nuevo atlas; no se modifica el PNG fuente.
Edificios, carteles, interfaz y zonas interactivas conservan sus posiciones.
Solo se aplica a `base_camp`; el fondo nocturno de selección no cambia.

`main.gd::background` asigna el material al nodo `DayCampBackground`. Efecto
puramente visual mediante tiempo de shader, sin RNG de juego ni persistencia.
No se generan assets con IA: shader escrito en código y fondo existente.

Validación local Linux/llvmpipe 1280×720: `test_base_camp.gd`, 37 comprobaciones
sin fallos. Comparación de cuadros separados por 0,45 s confirma cambio de
píxeles en follaje, agua y fuego, con una región del suelo idéntica; conserva
pruebas de solares, refugio, arco y regreso/continuación. Revisión de captura
renderizada; captura temporal eliminada. No implica revisión temporal manual
exhaustiva ni validación de rendimiento Web/Android. Sin exportación.

## Refugio funcional — 18/09/2026
La carpa abre la galería de seis héroes y el editor de cartas iniciales,
reemplazando el aviso de mejoras futuras. La preparación se aplica solo a
nuevas aventuras. [Reglas, assets y pruebas](../refuge/README.md).
