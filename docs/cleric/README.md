# Clériga

Concept del usuario: vestimenta blanca y dorada, capucha, cabello rubio ceniza,
halo y relicario luminoso suspendido de una cadena.

Atlas: `assets/cleric/cleric-64.png`, 384 × 384, 36 cuadros de 64 × 64.
Fuente: `generated-sheet.png`, creada con imagegen integrada. Prompts de
generación y revisión en `prompt.md`. El importador `scripts/import_cleric.gd`
reproduce el recorte y escalado nearest conservando alfa. Alinea los cuadros
por la silueta visible, ignorando residuos casi transparentes.

| Animación | FPS | Uso |
| --- | --- | --- |
| Reposo | 6 | Bucle |
| Ataque de luz | 12 | Luz cortante y Juicio |
| Curación | 12 | Restauración y Luz del retorno |
| Protección | 10 | Fe |
| Daño | 15 | Pérdida de vida |
| Caída | 8 | Vida a cero, último cuadro persistente |
| Recuperación | 9 | Caída en reversa |

Cada secuencia tiene seis cuadros. No se incluyen caminata ni carrera porque
el combate actual no tiene desplazamiento libre. Estadísticas sin cambios.
Juicio conserva la curación de su lanzadora además del daño al enemigo.

## Validación local

`./scripts/run.sh --script tests/test_cleric.gd`: 71 comprobaciones sin fallos,
con capturas de Godot en esta carpeta. Incluye las cinco cartas, aliados
seleccionados, curación y protección de ambos, persistencia, caída y recuperación.
Usa una partida aislada; agregar `--headless` para ejecutarla sin ventana.

Las pruebas anteriores esperan ahora el ataque animado de la clériga antes de
comprobar la recuperación de su compañero. No se compiló APK ni se probó este
cambio en Android.
