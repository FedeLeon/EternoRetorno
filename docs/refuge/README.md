# Refugio de héroes — 18/09/2026

Se accede tocando la carpa del campamento. El interior muestra una cama,
equipaje, mapas y faroles. Delante hay seis cartas con retratos de cara/torso:
reutilizan `assets/comic/<hero>.png`, con regiones `AtlasTexture` por héroe.
No hay copias nuevas de las imágenes de personajes ni uso de RNG.

## Preparación inicial

- Tocar un retrato abre las cuatro cartas distintas del mazo inicial y sus copias.
- Se reparten ocho copias básicas entre ataque y defensa, con 2–6 ataques y
  6–2 defensas. Se pueden intercambiar hasta dos copias desde el reparto 4/4.
- Las dos cartas de clase restantes se conservan: total diez por héroe.
- Los botones +/− intercambian una copia con la otra básica. Nunca aumentan
  el tamaño ni incorporan cartas del mercado, mejoras o cartas de otro héroe.
- «Guardar mazo» confirma; se deshabilita cuando no hay cambios.
- «Restaurar original» prepara el reparto 4/4 para guardarlo explícitamente.
- Volver descarta el borrador no guardado. Escape retrocede primero a los
  retratos y después al campamento. La barra superior muestra almas y Campamento.
- Configurar es gratis. La próxima aventura recibe veinte cartas, diez por
  héroe. Una aventura activa mantiene exactamente su mazo y estado previos.

## Archivos y persistencia

- `src/rules/starter_decks.gd`: límites, validación y composición del mazo.
- `game.configure_starter`: valida y usa el checkpoint existente.
- `game.new_run`: genera el mazo desde la configuración en vez del catálogo directo.
- `src/ui/refuge_navigation.gd`: prepara instantáneas y conecta guardar/navegar.
- `src/ui/screens/refuge_screen.gd`: galería y editor, borrador local.
- `src/ui/components/refuge_portrait.gd`: encuadre y composición de los retratos.
- `profile.starter_attacks`: diccionario ID de héroe → cantidad de ataques básicos.
  Perfiles anteriores sin ese campo usan 4/4 y conservan las cartas originales.
  Se mantiene versión 1 del guardado; no se reescribe la aventura activa.

El fondo nuevo está en `assets/refuge/interior.png`. Se generó con imagegen
integrado; la herrería fue referencia de estilo, no contenido. Prompt exacto,
referencia y procedencia: [interior.json](interior.json). Los retratos son
encuadres visuales en ejecución de los cómics existentes, sin editar los PNG.

## Validación

`test_refuge.gd` renderizado en Linux/llvmpipe: 159 comprobaciones aprobadas,
con seis héroes, límites, borradores, guardar/restaurar, clics, persistencia,
compatibilidad de perfiles y aislamiento de la aventura actual. Revisión visual
de la galería y editor a 1280×720. `test_game.gd`: 156 comprobaciones headless;
`test_base_camp.gd`: 33 headless. Importación y diff correctos. Sin exportación
Web/APK ni prueba en navegador/dispositivo para esta implementación.

Pendiente fuera de esta primera versión: especializaciones, vínculos, estadísticas
por héroe y elección alternativa de las dos cartas de clase. El límite 2–6 es una
decisión inicial de equilibrio que puede ajustarse tras jugar; no fue balanceado
exhaustivamente con todas las combinaciones personalizadas.

## Ampliación del 07/10/2026

El botón Vínculos abre las quince parejas, victorias compartidas, conversaciones y selección de una variante de enlace para aventuras nuevas. Se desbloquea con una victoria conjunta.

[Reglas, assets y pruebas actuales](../expansion_2026_10/README.md).
