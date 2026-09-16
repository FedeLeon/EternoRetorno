# Validación — 15 de septiembre de 2026

## Última comprobación local del combate

La revisión de distribución y robo de seis cartas pasó **584 comprobaciones**:
lógica 137, interfaz 121, cartas 243, equipamiento 64, interfaz de equipamiento 11
y distribución 8. Hubo 45 victorias en 45 simulaciones de las 15 parejas.
Se revisaron capturas locales en Linux. No se compiló APK ni se probó en Android
esta revisión. Ver [estado actual](README.md) e [historial](HISTORIAL.md).

## Informe histórico del prototipo inicial

**Todo lo que sigue corresponde a la entrega inicial**, antes de los cambios
posteriores de arte, campamento, equipamiento y distribución del combate.
Sus cifras y capturas se conservan como evidencia histórica. El controlador
Android debe revisarse para la interfaz actual antes de reutilizarlo.

### Resultado

APK de depuración generada, firmada, instalada y jugada hasta completar el piso
sobre **Android 15/API 35**, emulador Pixel 5 x86_64, pantalla **2340 × 1080 en
horizontal**. La compilación usa target 36 y mínimo 24. No hubo teléfono físico
conectado: la comodidad táctil y el rendimiento en un teléfono real quedan por
validar allí.

## Pruebas automatizadas

- `tests/test_game.gd`: **137 comprobaciones, 0 fallos**. Catálogos, 15 parejas,
  grafo completo, acciones inválidas, energía, objetivos, bloqueo, daño penetrante,
  múltiples impactos, veneno, curación, descarte, mezcla, reliquias, caídas,
  recuperación, derrota, recompensas, descansos, eventos, desbloqueos y guardado.
- **45 aventuras simuladas**, tres semillas por pareja. **44 victorias**; todas
  las parejas ganaron al menos dos veces. El jugador automático evita el élite,
  prioriza daño letal/curación y no recibe ventajas ni modifica estadísticas.
- `tests/test_ui.gd`: **121 comprobaciones, 0 fallos**. Las 30 cartas mejoradas
  caben en sus paneles de combate; selección de personajes mediante eventos de
  entrada de Godot.
- Recarga exacta de combate y recompensa, continuidad del generador aleatorio,
  rechazo de premios repetidos, ignorar archivos temporales incompletos y
  recuperación desde la copia anterior.
- Firma APK válida, esquemas **v2 y v3**. SHA-256 en `builds/SHA256SUMS`.
- `aapt dump permissions`: la APK no solicita permisos, incluido internet.
- Archivos de pruebas, scripts de herramientas y capturas excluidos de la APK.

## Recorrido de Android mediante toques

El controlador `tests/android_smoke.py` usa toques ADB en la APK instalada. Lee
el guardado de la aplicación de depuración para decidir jugadas y comprobar
resultados; **no lo modifica ni altera estadísticas**. Se ejecutó con Wi-Fi y
datos móviles desactivados en el emulador.

Recorrido validado:

1. Selección de guerrero y clériga; primera sala del mapa.
2. Selección de carta y objetivo, consumo de energía y turnos enemigos.
3. Cierre forzado y reapertura durante combate: mismo mazo, mano y estado.
4. Botón Atrás abre la pausa; volver no consume acciones. Pasar al inicio de
   Android y reabrir permite continuar el mismo combate.
5. Cierre y reapertura en una recompensa pendiente; aceptar añade una sola carta.
6. Tesoro, evento, bifurcación sin élite, descanso para mejorar Tajo y otro descanso
   para recuperar vida. Combates contra grupos de enemigos y jefe.
7. Durante el jefe, la clériga llegó a **0/48**; el guerrero siguió solo. Ganó y
   ella volvió con **12/48**, el 25 %. El resultado conservó **46/58** en el guerrero.
8. Recompensa final, escalera, victoria y desbloqueo de `warrior_echo` y
   `cleric_echo`. Resumen: **9 salas y 16 cartas**.
9. Tras reiniciar: exactamente **1 victoria, 1 entrada de historial y 2 cartas
   desbloqueadas**. No se duplicó el resultado.

El controlador terminó con `PASS`; registro en [android-smoke.log](android-smoke.log).
Se inspeccionaron capturas renderizadas, incluidas selección, mapa, combate,
recompensa, descanso, mejora y victoria. Los registros de la versión final no
mostraron errores de GDScript ni cierres Java.

## Capturas

- [Selección de personajes](android-02-personajes.png)
- [Combate en Android](android-04-combate.png)
- [Pausa con Atrás](android-05-pausa.png)
- [Recompensa](android-06-recompensa.png)
- [Descanso](android-07-descanso.png)
- [Mejora de carta](android-08-mejora.png)
- [Escalera desbloqueada](android-09-escalera.png)
- [Victoria y desbloqueos](android-10-victory.png)

## Reproducir las pruebas de Android

Herramientas adicionales: Python 3 con Pillow; emulador Android con aceleración
KVM. En este equipo el controlador gráfico **swangle** funciona; el antiguo
`swiftshader_indirect` falló al compilar los shaders del motor. Esto se resolvió
en la configuración del emulador.

```bash
export JAVA_HOME="$PWD/.tools/jdk"
export ANDROID_HOME="$PWD/.tools/android"
.tools/android/cmdline-tools/latest/bin/sdkmanager 'emulator' 'system-images;android-35;google_apis;x86_64'
.tools/android/cmdline-tools/latest/bin/avdmanager create avd -n EternoRetornoTest -k 'system-images;android-35;google_apis;x86_64' --device pixel_5
.tools/android/emulator/emulator -avd EternoRetornoTest -gpu swangle -no-snapshot
```

Una vez iniciado el emulador, instalar la APK, abrirla desde su icono y ejecutar:

```bash
python3 tests/android_smoke.py --serial emulator-5554
```

El recorrido nuevo requiere la pantalla inicial sin aventura activa. El argumento
`--continue-run` retoma una aventura de prueba existente; el controlador opera
exclusivamente sobre un identificador de emulador. Su lectura binaria contempla
las variantes utilizadas por este guardado, no es un deserializador general.
Las esperas verifican que la pantalla inicial ya esté renderizada antes de tocar
Continuar; las transiciones esperan el guardado completo.

## Límites

El prototipo es intencionalmente accesible y necesita balance con jugadores.
Las 15 parejas se probaron en lógica; el recorrido nativo completo usó guerrero y
clériga. No se ensayaron todos los fabricantes, tamaños ni versiones de Android,
y el rendimiento del emulador no representa el de un teléfono físico.
