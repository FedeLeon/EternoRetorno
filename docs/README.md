# Documentación de Eterno Retorno

Estado actual revisado el **20/10/2026**. Este índice describe lo que contiene el
proyecto; las versiones anteriores se consultan en el historial de Git.

## Guías vigentes

| Documento | Contenido |
| --- | --- |
| [Juego](JUEGO.md) | Preparación, aventura, cartas y progreso. |
| [Combate](COMBATE.md) | Turnos, reserva, sinergias, cuerpos estáticos y primeros planos. |
| [Campamento](CAMPAMENTO.md) | Edificios, materiales, equipo y progresión permanente. |
| [Interfaz](INTERFAZ.md) | Vistas, navegación, cartas, intenciones y lectura en pantalla. |
| [Historia y protagonistas](HISTORIA.md) | Mundo y cuatro civiles; alcance de la narrativa. |
| [Dirección de arte](ARTE.md) | Cómic, colores, contornos, tipografía y composición. |
| [Audio](AUDIO.md) | Reproducción, sonidos de combate, licencias y pruebas. |
| [Arquitectura](ARQUITECTURA.md) | Responsabilidades, módulos, datos y guardados. |
| [Recursos y mantenimiento](RECURSOS.md) | Fuentes, prompts, importadores y limpieza segura. |
| [Validación](VALIDACION.md) | Comandos, comprobaciones de esta revisión y límites. |
| [Historial vigente](HISTORIAL.md) | Registro de mantenimiento de esta documentación. |

## Organización

- `docs/`: documentación escrita vigente, sin imágenes, capturas ni registros JSON.
- `assets/`: recursos utilizados por el juego.
- `art_sources/`: fuentes de producción, prompts, licencias, geometría y procedencia
  necesarios para mantener los recursos. No forma parte de una exportación.
- `artifacts/`: informes automáticos, capturas y datos temporales de prueba;
  descartables e ignorados por Git.
- `data/`: catálogos que consume el juego.
- `scripts/` y `tests/`: herramientas y comprobaciones locales.

## Convención de mantenimiento

1. Documentación mínima: cambios principales en el historial, con texto corto
   tipo commit. No repetir cada tarea en varias guías ni producir informes por rutina.
2. Añadir explicaciones breves de arquitectura solo si cambia una responsabilidad
   o estructura importante. Actualizar este índice únicamente si cambia la organización.
3. Conservar prompts, fuentes útiles y procedencia en `art_sources/`, junto a su
   familia de producción; actualizar los importadores cuando se mueven.
4. Mantener solo documentación vigente. Las pruebas nuevas de cada tarea son
   temporales: eliminarlas junto con sus UIDs y artefactos cuando pasen. No crear
   suites permanentes salvo solicitud explícita; corregir los fallos antes de borrar.
5. Distinguir pruebas automáticas, revisión visual local, audio por escucha,
   navegador, emulador y dispositivo físico. No atribuir pruebas anteriores a una
   modificación posterior.
6. Desarrollar y probar localmente; exportar APK únicamente si se solicita.

No se guardan dentro de `docs/` resultados generados, copias de fuentes de arte,
planes de migración completados ni documentación de funcionalidades retiradas.
