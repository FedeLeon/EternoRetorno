# Efectos de batalla con iconos

## Diseño minimalista vigente — 08/10/2026

Los 36 PNG de héroes/enemigos se sustituyen por símbolos originales dibujados
en código: siluetas simples, contorno oscuro, un color por efecto, sin texturas,
ornamentos ni brillos internos. Se conservan nombres, rutas, UIDs, transparencia
y lienzos de 128×128. El escudo gris activo ya utiliza una silueta vectorial simple.

La imagen de cada efecto crece de 32 a 36 px en celdas de 40 px; las intenciones
crecen de 26 a 30 px, con números separados. Bloqueo previsto conserva la flecha
verde superpuesta. Se muestran todos los estados activos, en cinco columnas y
tantas filas como hagan falta, sin desplazamiento ni límite de dos filas.
La vida y su escudo bajan juntos para reservar espacio. Los diálogos y acciones
especiales mantienen su funcionamiento, sin cambios de reglas o guardados.

Fuentes actuales: [SVG y procedencia](minimal/sources.json), excluidos del import
del juego mediante `.gdignore`. Regeneración:

```sh
python3 scripts/generate_minimal_effect_icons.py
.tools/Godot_v4.7.2-stable_linux.x86_64 --headless --path . --script scripts/import_minimal_effect_icons.gd
```

`scripts/import_battle_effects.gd` delega al importador nuevo para evitar restaurar
por accidente las ilustraciones anteriores. Los originales de ImageGen y sus
prompts se conservan como procedencia histórica, no como fuentes activas.

Validación de esta versión: 883 comprobaciones de iconos/disposición/consulta
con ventana local Godot a 1280×720, incluidas filas completas, ausencia de
solapamiento con vida y casos acumulados de ambos bandos. Revisión visual del
catálogo, tres enemigos y estados acumulados. Regresiones headless: HUD 103,
cartas de soporte 609 y disposición de combate 41, sin fallos. HUD y disposición
avisan de recursos pendientes al cierre; no son fallos de aserciones.
Importación correcta; sin exportación ni validación Web/Android.

## Implementación y arte anteriores — 07/10/2026

Retaguardia, brasas y demás estados se presentan mediante iconos, sin carteles
sobre la mano de cartas. En enemigos aparecen debajo de ataque/bloqueo/contraataque,
entre el nombre y la vida; en héroes, sobre la vida. Los valores actuales se muestran
sobre cada icono cuando corresponden. El escudo gris de bloqueo activo permanece
en el extremo izquierdo de la barra, con su animación de cenizas.

## Catálogo y consulta

**36 assets transparentes nuevos**, en `assets/battle_effects/`, y títulos/textos
en `data/battle_effects.json`:

- Intenciones: ataque, bloqueo y contraataque; resurrección, brasas, prisión y carga.
- Formación/defensa: retaguardia, protector, raíces, placas y fuente del guardián.
- Comportamientos: sanador, caza de bestias, furia por caídos, segunda fase,
  emboscada e impulso maldito; tres modificadores de élite.
- Estados aliados/debilitamientos: fuerza, debilidad, defensa quebrada, veneno,
  potencia física/mágica, ataque preparado y concentración del vínculo.
- Tres maldiciones y cuatro combinaciones de reliquias.

Tocar un efecto abre su explicación particular y valores vigentes. Las intenciones
básicas y el bloqueo activo mantienen su cuadro pequeño anclado. Los nuevos estados
usan el modal del juego, con altura de texto calculada para evitar tocar los botones,
también con texto ampliado. La consulta no consume energía ni modifica estado/RNG.

Fuente, placas y prisión activa ofrecen la acción de **1 energía** dentro del diálogo;
la acción queda deshabilitada sin energía. También siguen disponibles los controles
de teclado/mando existentes. Desaparece el bloque central del objetivo del guardián.
La segunda fase se indica con su icono, sin añadir texto al nombre del enemigo.

Los iconos desaparecen al finalizar su efecto o caer la unidad. La cobertura se
muestra solamente mientras quede un protector vivo. Máximo de dos filas; más de
diez efectos permiten desplazamiento horizontal dentro de la misma zona. La barra
de vida baja lo necesario en los casos con dos filas. Registro conserva su botón.

## Arquitectura y compatibilidad

- `battle_effect_snapshot.gd`: instantánea de estados y descripciones; solo lectura.
- `battle_effect_strip.gd`: distribución, iconos, cantidades e inspección.
- `enemy_intent.gd`: intenciones compactas y retratos de objetivos; comparte la tira.
- `combat_modifier_badges.gd`: entrega descripciones/porcentajes a la instantánea.
- `status_effects.gd`: conserva únicamente el escudo activo y su interfaz de reproducción.
- `boss_objective.gd`: prepara acciones; Game conserva validación y checkpoint.
- `tactical_badges.gd`: decoración de raíces y apertura del registro.

No se cambia daño, duración, recompensas, IDs del contenido ni formato de guardado.
Campos opcionales ausentes no inventan estados. Los marcos y controles generales
mantienen sus estilos anteriores; se reutiliza `dialog_view.gd` con altura opcional.

## Arte y procedencia

ImageGen integrado, una generación por icono, sin API key y con alfa transparente.
Pixel art de fantasía oscura, plata envejecida, oro tenue y colores distintivos.
[Prompts completos](prompts.md) y [manifest con rutas/hashes](sources.json).
Los originales quedan en `sources/`, con `.gdignore`; los presets excluyen `docs/*`.

`scripts/import_battle_effects.gd` solo normaliza: recorte de alfa, ajuste proporcional
a 116 px y centrado en un lienzo transparente de 128×128. Los 36 PNG finales suman
**0,76 MiB**; importación sin pérdida, sin mipmaps y filtro nearest en los iconos.
Los 43 MiB de originales documentales no forman parte de los presets exportables.
No se midió el tamaño de un exportado nuevo.

## Pruebas realizadas

Diez suites locales headless, sin fallos de script/aserciones: iconos, HUD, soporte,
presentación, disposición de combate, cenizas de bloqueo, descuento de energía,
combate táctico, reglas de pulido y secuencia de turno. La nueva suite comprueba
assets/alfa, estados, consultas reales simuladas con ratón, ausencia de mutaciones,
interrupción/cobertura, desbordamiento, texto ampliado, acciones por energía y caída.

La misma suite pasa **233 comprobaciones** con ventana local de Godot 4.7.2,
Linux/Mesa/llvmpipe a 1280×720. Genera 16 capturas descartables en
`artifacts/battle_effects/`; revisión del catálogo, tres enemigos, guardianes,
modales, efectos acumulados y texto ampliado. Es entrada simulada en ventana local,
sin pruebas táctiles físicas. [Resumen verificable](validation.json).

Algunas suites headless siguen avisando de ObjectDB/recursos al cerrar; se registran
separados de errores de script/aserciones. El recorrido gráfico nuevo termina sin
esos avisos; el driver informa que no permite cambiar V-Sync.

**No se exportó Web/APK ni se probó navegador, emulador o dispositivo físico.**
