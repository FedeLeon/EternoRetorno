# Guardiana

Sprites basados en el concept del usuario: trenza castaña, armadura plateada
con bordes dorados, manto verde azulado, escudo grande y mangual.

- Atlas: `assets/guardian/guardian-64.png`, 384 × 384, 36 cuadros de 64 × 64.
- Fuente: `generated-sheet.png`; generación con imagegen integrada y prompt
  completo en `prompt.md`.
- Importador reproducible: `scripts/import_guardian.gd`. Recorta los márgenes
  reales, conserva alfa y escala con nearest. La silueta visible se alinea en
  y=60; los residuos casi transparentes no determinan la altura.
- Presentación: `src/guardian_sprite.gd`, compartiendo las conexiones de acciones
  de `src/main.gd` con el guerrero. Reglas y estadísticas sin cambios.

| Fila | Animación | FPS | Uso |
| --- | --- | --- | --- |
| 0 | Reposo | 6 | Bucle |
| 1 | Mangual | 12 | Contraataque |
| 2 | Golpe de escudo | 12 | Golpe de escudo |
| 3 | Defensa | 10 | Baluarte, Muro del alba, Juramento eterno |
| 4 | Daño | 15 | Pérdida de vida |
| 5 | Caída | 8 | Derrota individual |

Recuperación reutiliza caída en reversa a 9 FPS. El último cuadro de caída
permanece mientras combate el compañero. No hay caminata ni carrera en esta
entrega, ya que el combate no tiene desplazamiento libre.

## Validación local

```bash
./scripts/run.sh --headless --script tests/test_guardian.gd
./scripts/run.sh --headless --script tests/test_warrior.gd
./scripts/run.sh --headless --script tests/test_ui.gd
```

La prueba de guardiana usa una partida aislada: cartas ofensivas y defensivas,
bloqueo de entrada repetida, guardado, daño, caída, recuperación y derrota.
Para capturas en Godot, ejecutar la prueba sin `--headless`; las imágenes se
guardan en esta carpeta. No se compiló APK ni se probó este cambio en Android.
