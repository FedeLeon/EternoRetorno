# Pautas de trabajo

- Generar la menor documentación posible. Registrar solo cambios principales en
  `docs/HISTORIAL.md`, con texto corto tipo commit y una explicación breve si aporta.
  No duplicar el mismo cambio en varias guías ni crear informes por rutina.
- Actualizar `docs/ARQUITECTURA.md` únicamente si cambia la estructura o una
  responsabilidad importante, con explicaciones pequeñas de la arquitectura vigente.
  Consultar `docs/README.md` para el índice y la convención de mantenimiento.
- Las pruebas creadas para una tarea son temporales: ejecutarlas y, cuando pasen,
  eliminar sus archivos, UIDs y artefactos temporales. No acumular nuevas suites
  permanentes salvo solicitud explícita. Si fallan, corregir y volver a probar
  antes de eliminarlas. Esta preferencia no ordena borrar en bloque pruebas
  preexistentes fuera del alcance de la tarea.
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
- Documentar solo la estructura vigente cuando cambie; resumir cada extracción
  importante en el historial sin mantener planes ni relatos extensos de ejecución.
