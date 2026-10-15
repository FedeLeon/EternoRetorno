# Primeros planos estáticos de héroes — 14/10/2026

## Rayos de primeros planos hasta los bordes — 15/10/2026

Los rayos de luz detrás de los ataques y defensas de los cuatro héroes ahora
atraviesan la vista completa, en vez de terminar a una distancia proporcional
al recorte del personaje. El lienzo `HeroLights` ocupa toda la superposición y
`hero_comic_fx.ray_reach()` calcula la longitud desde el origen hasta la esquina
más lejana, con margen y compensación por la fase más corta de crecimiento.
Ambos vértices exteriores quedan fuera de pantalla, evitando puntas/cortes
visibles dentro de la escena.

`hero_cut_in.gd` activa `full_view_rays`; el valor predeterminado compartido
con los enemigos sigue siendo local. Se conservan el dibujo estático, encuadre,
partículas, arcos defensivos, color, opacidad, duración, orden detrás del héroe,
preferencias de efectos y entrada sin bloquear. No se modifican assets/prompts,
reglas ni guardados.

Validación actual: `test_hero_cut_in.gd` **260/0 nativo aislado**, ocho acciones
(cuatro héroes × ataque/defensa), lienzo completo, longitud en 16 direcciones
para cada caso desde el origen real, imagen quieta y finalización única.
Capturas de ataque de Nicolás y defensa de Inés revisadas en
`artifacts/comic_static/`. Regresiones headless: imágenes estáticas **33/0**;
primeros planos enemigos **sin fallos**. Audio Dummy, sin exportar ni probar
Web/dispositivo.


> Limpieza posterior: las fuentes bitmap e importadores sustituidos de esta etapa
> se retiraron; se conservan prompts, metadatos y hashes. [Registro](../../game_review_2026_10_14/README.md).

> Registro histórico. Los dibujos y fuentes activos fueron sustituidos el 14/10
> por el [cómic postapocalíptico](../../art_direction/postapocalyptic/README.md). Las validaciones inferiores
> pertenecen a la etapa anterior y no certifican los recursos nuevos.

Por pedido del usuario se sustituyen las secuencias de ataque/defensa por **ocho
ilustraciones estáticas nuevas**: una de ataque y una de defensa por protagonista.
Se generaron con la herramienta integrada `image_gen.imagegen`, usando como
referencia los retratos actuales. Grafito y lápices de colores, composición de
cómic, negro/gris/violeta y fondo RGBA realmente transparente.

## Presentación

- Nicolás/Carpintero: espada para atacar y parar, casco abierto, sin escudo.
- Inés/Constructora: golpe y protección con escudo de acero.
- Mauro/Boticario: cuchillos para atacar/parar, rostro humano completo visible.
- Vera/Profesora: magia de ataque y barrera, bastón y libro.

El personaje permanece quieto: sin reproducción de poses, desplazamiento de
entrada, zoom, parpadeo o deformación de la ilustración. Solo se funde su aparición
y desaparición. Las marcas de energía y partículas se animan **detrás** del dibujo,
sin panel opaco, y sigue viéndose el escenario. Se conservan duración de 0,96 s,
escala 1,28 y encuadre inferior izquierdo desplazado (-0,10; 0,12).

Los ataques múltiples vuelven a mostrar la imagen estática por cada golpe;
no rotan variantes animadas. El argumento antiguo de variante, sin consumidores vigentes, se retiró en la
limpieza posterior.
No se modifican daños, energía, resolución de acciones ni guardados.
Las animaciones de los actores sobre el escenario y los primeros planos enemigos
se conservan; la lógica común de poses sigue teniendo consumidor enemigo.

## Archivos, prompts y procedencia

- Runtime: `assets/comic/static/<hero>_attack.png` y `<hero>_defense.png`.
- Fuentes originales: `sources/`, con metadatos JSON al lado de cada PNG.
- `assets.json`: ocho prompts completos, referencias, origen, dimensiones y hashes.
- `scripts/import_static_cutins.py`: valida alfa/definición y copia los píxeles
  generados sin inventar poses ni repintar; conserva 1536×1024.
- Importación Godot: calidad 0,9 con alfa, sin reducir resolución; la política
  de `optimize_texture_imports.py` conserva estos valores.
- Adaptador: `src/presentation/hero_cut_in.gd`; presentación compartida:
  `comic_cut_in.gd`; partículas: `hero_comic_fx.gd`.

## Limpieza

`removed.json` lista ruta, tamaño y hash de cada archivo eliminado. Se retiran
20 atlas de movimiento, sus imports, cuatro imágenes base antiguas sin uso,
196 hojas fuente PNG de las tandas anteriores, capturas viejas y herramientas
exclusivas del montaje animado. Se reemplaza la prueba obsoleta de dieciséis
cuadros por una prueba de imágenes estáticas. Se conservan prompts, procedencia
y resultados históricos como documentación, claramente separados del estado actual.

Se eliminaron 275 archivos (730,2 MiB), más 48 archivos regenerables de caché
correspondientes exclusivamente a las imágenes retiradas (44,5 MiB). Estas cifras
incluyen fuentes documentales y capturas; **no son una estimación del tamaño de
exportación**. Los ocho PNG nuevos ocupan aproximadamente 23 MiB en disco.

## Validación de esta entrega

- Importación Godot 4.7.2: finalizada, sin errores de script.
- Imágenes: 33 comprobaciones de resolución, transparencia, identidad de archivos
  y ausencia de los atlas retirados; sin fallos.
- Presentación: 124 comprobaciones sin fallos tanto headless como en X11 local
  aislado (Compatibility/llvmpipe, audio Dummy). Transformación/textura estables,
  partículas detrás, encuadre, finalización única y liberación del efecto.
- Primeros planos enemigos: prueba de las 56 apariencias, sin fallos.
- Contenido: 1502 comprobaciones, cero errores. Inventario global: 617 hashes
  actualizados coincidentes, sin imágenes activas pendientes.
- Revisión visual de los ocho originales y capturas de composición de ataque y
  defensa sobre la cripta. Las capturas temporales quedan en `artifacts/comic_static/`.

Sin exportación Web/APK ni validación en dispositivo. Las fuentes en `docs/`
continúan excluidas de la exportación. Reiniciar la ejecución después de importar
para renovar texturas cargadas de una partida abierta durante el cambio.
