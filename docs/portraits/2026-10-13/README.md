# Retratos para tarjetas pequeñas — 13/10/2026

> Limpieza posterior: las fuentes bitmap e importadores sustituidos de esta etapa
> se retiraron; se conservan prompts, metadatos y hashes. [Registro](../../game_review_2026_10_14/README.md).

## Actualización: galerías ampliadas de edificios

Mercado, herrería, iglesia y refugio reutilizan estos rostros en tarjetas
244×254, dos filas de dos, con encuadre ampliado para llenar el rectángulo.
Nombre/oficio tienen placa de 50 px. Entrenamiento conserva el tamaño compacto;
las texturas de cuerpos y regiones verticales siguen intactas.
[Fondos, composición y pruebas actuales](../../base_camp/interiors/README.md).
La sección siguiente describe la entrega original, previa a esta ampliación.

## Pedido e implementación

Cuatro assets independientes de cabeza/hombros, casi de perfil hacia la derecha,
para que las caras se distingan en la galería compacta: Nicolás con visor levantado,
Inés con trenza, Mauro sin máscara y Vera de pelo gris. Mismo grafito/lápiz sobre
papel gris, sombras negras y tela violeta de la dirección aprobada.

`refuge_portrait.gd` selecciona textura mediante `portrait(hero, compact)`:

- **Pequeña (244×166, imagen 232×112):** PNG propio en
  `assets/heroes/identity/portraits/`, región completa y ajuste de proporción
  centrado; no recorta cabeza, mandíbula o nariz para llenar el rectángulo.
- **Vertical (190×338):** mantiene los mismos archivos de cuerpos existentes
  (`sketchbook.png` y `rogue_unmasked.png`) y sus regiones previas. No se repintan,
  recortan nuevamente ni sustituyen por los nuevos rostros.
- IDs legados Clériga/Explorador conservan el fallback de arte anterior.

Mercado, herrería, iglesia y entrenamiento usan los rostros donde sus tarjetas
son compactas. Refugio conserva las tarjetas verticales. Nombres, oficios,
acciones de botones, dimensiones y reglas permanecen iguales.

## Procedencia y regeneración

Cuatro llamadas individuales a ImageGen integrado, cada una con referencia
vista del personaje. [Prompts, fuentes y hashes](sources.json). Los originales
están en `sources/`, excluidos de exportación por `docs/.gdignore` y los presets.
`import_compact_portraits.gd` reduce proporcionalmente a 928 px de ancho con
Lanczos; mantiene toda la composición. No pinta caras ni simula el cambio con
un filtro. Los cuatro PNG de runtime suman **3.025.776 bytes / 2,89 MiB**;
no es una medida de exportación ni memoria en dispositivo.

```sh
.tools/Godot_v4.7.2-stable_linux.x86_64 --headless --path . --script scripts/import_compact_portraits.gd
.tools/Godot_v4.7.2-stable_linux.x86_64 --headless --path . --script tests/test_compact_portraits.gd
```

## Validación actual

- 24 comprobaciones headless: archivos/encuadres verticales preservados mediante
  baseline, regiones completas de caras, tamaño proporcional y fallback legado.
- Ventana local: 437 comprobaciones de galerías/elenco y compatibilidad;
  13 de interfaz sobre 36 vistas, sin fallos de aserciones. Revisión visual de
  las cuatro caras en la galería del mercado a 1280×720.
- Importación y `git diff --check` pasan. No se repite la corrida completa histórica
  de 86 suites para este cambio localizado de retratos.
- Las suites/driver pueden avisar de recursos al cierre o VSync; no se atribuye
  su solución a este cambio. Sin exportar ni probar Web/emulador/dispositivo.

[Evidencia actual](validation.json), [baseline vertical](vertical_baseline.json).
