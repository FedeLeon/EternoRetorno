# Ilustraciones individuales de logros — 15/10/2026

Los **28 logros activos** tienen ahora una ilustración de cómic completa propia:
tinta negra, tramado, desgaste de materiales, sombras violetas, luz cian y ámbar.
Objetos y escenas del mundo civil contra máquinas; se sustituyen los pictogramas
y sus medallas octogonales. No se usan iconos vectoriales como arte de los logros.

## Generación y procedencia

- Herramienta integrada de suscripción **`image_gen.imagegen`**; 29 llamadas
  independientes: una por logro y otra para la máscara secreta común. No API externa, no atlas de iconos ni dibujos
  de sustitución por código.
- Referencia de lenguaje visual: `assets/heroes/identity/portraits/warrior.png`,
  vista antes de generar. Los sujetos son nuevos, no ediciones de ese personaje.
- [jobs.json](jobs.json) conserva los 28 prompts exactos, IDs, recurso activo,
  referencia y su hash, ruta original de la herramienta, dimensiones medidas y
  hash de fuente. Cada `<id>.json` contiene también su registro individual.
- [secret.json](secret.json) registra el candado y caja cerrada neutrales, sin
  pistas sobre requisitos, en `assets/collection/secret.png`; sustituye el SVG.
- Originales sin editar en `sources/<id>.png`, copiados al proyecto desde
  `/home/fede/.codex/generated_images/`. El directorio `docs/` no se exporta.
- Assets activos: `assets/collection/icons/<id>.png`, a **512×512**. Se preservan
  IDs/rutas y UIDs de importación, logros, progreso y compatibilidad de guardado.

## Integración reproducible

`scripts/import_collection_illustrations.gd` comprueba las 29 fuentes antes de
reemplazar activos. Solo reduce proporcionalmente con Lanczos; no sintetiza
ilustraciones. Registra hashes de originales, referencia y activos en el
inventario postapocalíptico. `optimize_texture_imports.py` mantiene 512 px y
compresión con pérdida a 0,9, sin reducir estas ilustraciones a 256 px.

Los 28 trabajos salen del rasterizador SVG: tipo `collection_illustration` en
la cola y sin registros de iconos de logro en `vectors.json`. La generación
vectorial conserva seis iconos auxiliares de pestañas/reloj/historial, pero no
puede sobrescribir los dibujos nuevos. Las fuentes SVG previas son históricas.

Colección muestra la ilustración seleccionada a **184×184** y atenúa menos los
logros pendientes para no perder detalle. Los cinco secretos conservan candado
común y nombre/condición ocultos hasta desbloquearse; su ilustración no se filtra.

## Validación actual

- **50/0** comprobaciones nativas de Colección: 28 ilustraciones distintas a
  512×512, pestañas, desbloqueos, secretos, navegación e historial.
- Revisión visual de galería completa y vistas de colección, con render local
  aislado, llvmpipe y audio Dummy. Capturas en `artifacts/collection/`, ignoradas.
- **674 hashes visuales activos válidos**, sin recursos antiguos. El inventario
  inicial de 140 bancos/ilustraciones se complementa con estas 29 generaciones.
- Regenerador vectorial ejecutado: 80 fuentes nativas; importación selectiva
  de colección rasteriza **0** logros; se comparan los 29 hashes antes/después,
  conservando las ilustraciones y sin recrear la máscara SVG sustituida.
- Se registran avisos de recursos al cerrar la prueba nativa, sin errores de
  script ni aserciones. No se exportó ni probó en Web o dispositivo físico.
