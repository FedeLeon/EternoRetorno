# Interiores sketchbook y galerías de cuatro héroes — 13/10/2026

> Limpieza posterior: las fuentes bitmap e importadores sustituidos de esta etapa
> se retiraron; se conservan prompts, metadatos y hashes. [Registro](../../game_review_2026_10_14/README.md).

> Registro histórico. Los dibujos y fuentes activos fueron sustituidos el 14/10
> por el [cómic postapocalíptico](../../art_direction/postapocalyptic/README.md). Las validaciones inferiores
> pertenecen a la etapa anterior y no certifican los recursos nuevos.

## Aspecto y distribución actuales

Mercado, herrería, iglesia y refugio muestran cuatro tarjetas a la derecha,
en **dos filas de dos**, de 244×254 px. La galería abarca desde y=164 hasta
y=692, con 20 px entre filas y columnas. Los rostros ya existentes se amplían
dentro del dibujo de 232×188 px para llenar la tarjeta; nombre y oficio tienen
una placa de 50 px con márgenes interiores. No se regeneran los protagonistas.
Los rostros se revisaron en ventana: ojos, nariz y mandíbula siguen visibles.

El refugio reutiliza la misma galería y conserva el editor de sus diez cartas
iniciales. Vínculos y explicación se sitúan a la izquierda, debajo del lecho.
Los tamaños predeterminados del componente de retratos se conservan para
otras vistas: el entrenamiento mantiene sus tarjetas compactas anteriores.
Las fuentes de cuerpos y sus regiones de retrato vertical siguen intactas.

Se redibujan los seis fondos interiores con grafito/lápiz de color, tramado
irregular, negro/gris/violeta y luces ámbar, manteniendo temática y personajes
de atención a la izquierda:

| Edificio | Asset activo | Elementos propios |
| --- | --- | --- |
| Mercado | `assets/market/interior.png` | Mercader, libros, balanza y frascos |
| Herrería | `assets/forge/interior.png` | Herrero, fragua, herramientas y yunque |
| Iglesia | `assets/church/interior.png` | Cuidadora, libro, velas y vidriera |
| Expediciones | `assets/expeditions/interior.png` | Encargado, mapas, brújula y equipaje |
| Refugio | `assets/refuge/interior.png` | Carpa, cama, mantas y objetos personales |
| Proyectos | `assets/projects/interior.png` | Taller propio con mesa de planos y herramientas |

Se conservan las cinco rutas anteriores y sus UIDs; proyectos deja de compartir
la carpa del refugio. Sus tarjetas reutilizan los nuevos edificios exteriores
de `assets/base_camp/dusk/`. Contratos y especializaciones conservan sus reglas,
cantidades y assets de cartas anteriores; este cambio actualiza fondos/galerías.
Los globos de diálogo existentes permanecen activos.

## Fuentes y regeneración

Seis fondos generados con **image_gen.imagegen integrado**, no una API externa.
La apariencia manual es dirección artística, no una afirmación de autoría humana.
Referencias: composición interior previa de cada edificio y campamento al
atardecer. [Prompts](prompts.json), [procedencia/hash y dimensiones](sources.json),
[ubicaciones originales de las generaciones](generation_outputs.json).
`sources/` conserva las imágenes elegidas; se copian sin filtros o repintados
al runtime. Las fuentes documentales no se exportan.

```sh
.tools/Godot_v4.7.2-stable_linux.x86_64 --headless --path . --script scripts/import_sketchbook_interiors.gd
.tools/Godot_v4.7.2-stable_linux.x86_64 --headless --editor --path . --import
```

Este importador restaura los fondos nuevos. Los importadores históricos que
usan las fuentes anteriores pueden restaurar el estilo antiguo si se ejecutan.

## Código y validación actual

- `building_hero_picker.gd`: cuadrícula compartida 2×2; admite un padre local
  para reconstruir la galería del refugio sin dejar botones duplicados.
- `refuge_portrait.gd`: tamaño opcional, encuadre ampliado y placa más alta;
  mantiene sus dimensiones predeterminadas y texturas originales.
- `refuge_screen.gd`: galería derecha compartida y vínculos a la izquierda.
- `projects_screen.gd`: interior propio y edificios nuevos en sus tarjetas.
- `tests/test_building_galleries.gd`: límites, filas, separación, retratos dentro
  de cada botón, entrada a cada protagonista y progreso intacto al seleccionarlo.

Validación actual aislada con `XDG_DATA_HOME` por suite: **84 comprobaciones
con ventana local** de las cuatro galerías y navegación de todos los héroes;
revisión visual a 1280×720 de los seis interiores y sus vistas de detalle.
Headless: retratos 22, refugio 109, mercado 43, herrería 96 y expansión UI 33,
todas sin fallos. Importación sin errores; seis PNG runtime idénticos a sus
fuentes documentales, con dimensiones y hashes registrados.

Los tests headless de mercado y refugio informan objetos/recursos pendientes al
cierre. La prueba nueva con ventana no los informa; el driver Mesa/llvmpipe
avisa de su limitación de V-Sync. Capturas temporales en
`artifacts/building_interiors/`. Sin exportación ni comprobación Web/dispositivo.
