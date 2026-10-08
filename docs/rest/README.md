## Actualización de pulido — 07/10/2026

[Implementación actual, assets, reglas y validación](../polish_2026_10/README.md).
La documentación y resultados anteriores se conservan como historial.

# Descansos — 22/09/2026

## Escena

Fogata central en una mazmorra oscura, con los dos integrantes de la aventura
sentados a los lados. Cada héroe tiene un PNG propio y una barra de vida encima,
con el componente compartido de corazón y PV. El segundo sprite se invierte
horizontalmente para mirar al fuego. Son poses estáticas; una apariencia por
héroe, sin variantes de equipo de herrería en esta pantalla.

Dos tarjetas con ilustración y texto permiten recuperar el 30 % de la vida
máxima de cada héroe o abrir la selección de mejora. Volver de esa selección
conserva el descanso. Confirmar una opción consume la sala según `Game.rest`.
Si todas las cartas están mejoradas, se deshabilita esa opción. Menú accesible
arriba; sin almas ni información de turnos de combate.

## Organización

- `src/ui/screens/rest_screen.gd`: presentación mediante instantánea de héroes
  y disponibilidad de mejora. Emite solicitudes; no cura, mejora ni guarda.
- `src/main.gd::room_view`: conecta señales a `Game.rest`, al selector existente
  de mejora y al menú. Retirado el bloque anterior de descanso de `main.gd`.
- `assets/rest/`: fondo, seis poses transparentes y dos ilustraciones finales.
- `scripts/import_rest.gd`: recorta por alfa visible (umbral 0,125 para ignorar márgenes residuales) y normaliza poses a lienzos 320×256;
  fondo a 1280 px de ancho e ilustraciones a 384 px. Conserva proporciones.
- `docs/rest/sources/`: originales generados, excluidos de la exportación.
- Los nueve JSON de esta carpeta conservan los prompts, referencias y procedencia
  de image_gen integrado. No se usó CLI ni API externa adicional.

## Validación

- `tests/test_rest.gd`: 37 comprobaciones aprobadas con render Linux/llvmpipe.
  Revisa los seis assets, transparencia, orientación, PV, curación de ambos,
  entrada/cancelación de mejora, sala consumida una sola vez y opción desactivada
  cuando todo el mazo está mejorado.
- `tests/test_card_upgrade.gd`: sin fallos, modo headless; confirma únicamente
  la carta elegida y retorna al mapa.
- Revisión visual de tres parejas a 1280×720, cubriendo los seis héroes.
  Capturas temporales eliminadas después de revisar.
- Importación local y `git diff --check` correctos. Sin exportar Web/APK ni
  validar en Android. No se modificaron archivos de TestWeb ni guardados reales.


## Luz cálida — 22/09/2026

Los héroes sentados reciben el shader compartido firelight.gdshader, conectado
por src/presentation/firelight.gd. Iluminación fluctuante del lado del fuego sin
movimiento geométrico. Mismos PNG y reglas del descanso. Revalidado test_rest:
37 comprobaciones renderizadas aprobadas y revisión visual local.
