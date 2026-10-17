# Marcos y reversos anteriores — 17/10/2026

Por pedido del usuario se recuperan los cuatro marcos y cuatro reversos de metal
con papel anteriores a la renovación integral de cómic. Las 88 ilustraciones
actuales se mantienen, igual que la tipografía Source Sans 3 y los números
eléctricos minimalistas.

`card_view.gd` recupera los centros de coste, título y banda de tipo propios de
estos marcos. No cambia reserva, arrastre, efectos ni guardados.

Procedencia original: `docs/cards/pixel_retain/frame_*.json`, `back_*.json` y
`sources/`. El manifest conserva sus hashes originales y marca la elección
explícita `user_preserved_revision`. El importador de cómic respeta esa marca;
la auditoría verifica tanto los 708 recursos renovados como los 8 conservados.
`previous_manifest.json` registra la versión sustituida sin borrar fuentes.

Validación local: cartas nativas 30 comprobaciones y ajuste de textos headless
665 comprobaciones, sin fallos. Auditoría de procedencia sin errores. Captura
`artifacts/pixel_cards/fronts_backs.png`; logs `artifacts/restored_cards/`.
Sin exportación ni validación web o dispositivo físico.
