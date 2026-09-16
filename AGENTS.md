# Pautas de trabajo

- Mantener la documentación como parte de cada cambio funcional o visual.
  Consultar `docs/README.md` para estado, índice y convención de mantenimiento.
- Actualizar el documento del sistema y `docs/HISTORIAL.md`; registrar decisiones,
  archivos relevantes, pendientes y pruebas realmente realizadas.
- Diferenciar resultados locales, revisión visual, emulador y dispositivo físico.
  No presentar resultados históricos como validación de cambios posteriores.
- Conservar prompts y procedencia de assets generados en la carpeta correspondiente.
- Preferencia del usuario: desarrollar y probar localmente; no compilar/exportar
  APK salvo que lo pida explícitamente.
- Preservar cambios existentes del usuario y compatibilidad de guardados.

## Arquitectura y tamaño de archivos

- Leer `docs/ARQUITECTURA.md` antes de añadir pantallas, sistemas o reorganizar archivos.
- Crear nuevas pantallas en archivos propios; extraer responsabilidades de archivos
  grandes al ampliarlas. No seguir concentrando toda la interfaz en `src/main.gd`.
- Separar interfaz, presentación, reglas, datos y persistencia. Los componentes
  visuales no deben calcular daño, conceder premios ni guardar partidas.
- Revisar separación al superar aproximadamente 350–400 líneas; es una guía,
  no un límite que justifique fragmentación artificial o código comprimido.
- Mantener IDs, UIDs y compatibilidad de guardado; actualizar referencias y pruebas
  al mover recursos. Preservar resolución y guardado antes de las animaciones.
- Documentar estructura actual y propuesta por separado; registrar cada extracción
  terminada en el historial y actualizar el mapa de arquitectura.
