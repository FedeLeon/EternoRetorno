# Validación

## Última comprobación: equipo superpuesto en héroes (07/10/2026)

Actores: 1662 comprobaciones headless; equipo UI: 48 headless. Animación actual:
534 en ventana local Godot 4.7.2/Linux/Mesa/llvmpipe, seis héroes con niveles 1–3;
reposo/defensa revisados y tres ataques capturados. Sin fallos de script/aserciones.
Se conservan avisos de recursos al cierre de la prueba UI, separados del resultado.
No se exportó ni se probó navegador, emulador o dispositivo físico.
[Corrección y pruebas](polish_2026_10/README.md#corrección-posterior-equipo-duplicado-sobre-héroes--07102026).

## Última comprobación: iconos de efectos de batalla (07/10/2026)

Diez suites headless sin errores de script/aserciones. Suite nueva: 233
comprobaciones, también aprobadas en ventana local Linux/Mesa/llvmpipe a 1280×720;
16 capturas de catálogo, combate triple, guardianes, diálogos y estados acumulados.
Se verifica consulta sin mutar estado/RNG, acciones por energía, bloqueo, caída,
interrupción/cobertura y distribución con texto ampliado.

Avisos de ObjectDB/recursos al cierre de algunas suites headless se distinguen
de los resultados funcionales; el recorrido gráfico nuevo termina sin ellos.
No se exportó Web/APK ni se probó navegador, emulador o dispositivo físico.
[Detalle y límites](battle_effects/README.md#pruebas-realizadas),
[resumen verificable](battle_effects/validation.json).

## Última comprobación: pulido y expansión táctica (07/10/2026)

73 suites locales aprobadas. Las nuevas reglas pasan 51 comprobaciones, actores
528, interfaz 13 y colección 43. Recorrido gráfico de 36 vistas en Godot 4.7.2,
Linux/Mesa/llvmpipe a 1280×720: capturas revisadas y ninguna etiqueta desbordando
su altura asignada. Guardados de pruebas separados del progreso del usuario.

90 aventuras automáticas con decisiones legales, premios, consumibles y mejoras:
31/45 victorias sin equipo y 39/45 con equipo nivel 1. No sustituye balance humano.
Las advertencias de cierre de suites históricas se registran separadas de errores
de script/aserciones y del recorrido gráfico nuevo, que termina sin ellas.

La medición Web corresponde únicamente al exportado existente del 05/10 servido
por HTTP; no contiene estos cambios. No se exportó Web/APK, no se publicó ni se
probó esta entrega en emulador/dispositivo físico.
[Resultados y límites detallados](polish_2026_10/README.md#pruebas-y-límites),
[informe reproducible](polish_2026_10/validation.json).

## Validaciones históricas

## Última comprobación: limpieza (16/09/2026)

19 suites headless, 1717 comprobaciones sin fallos. Enemigos (498) y tesoros (8)
también renderizados en Linux/llvmpipe; galería y combate revisados. Importación,
referencias de recursos y diff correctos. Capturas temporales retiradas al terminar.
Sin APK ni validación Android nueva. Detalle en [LIMPIEZA.md](LIMPIEZA.md).
Los apartados siguientes describen entregas anteriores; sus capturas fueron
eliminadas y sus resultados no sustituyen una prueba actual en dispositivo.


## Última comprobación local del combate

La revisión de distribución y robo de seis cartas pasó **584 comprobaciones**:
lógica 137, interfaz 121, cartas 243, equipamiento 64, interfaz de equipamiento 11
y distribución 8. Hubo 45 victorias en 45 simulaciones de las 15 parejas.
Se revisaron capturas locales en Linux. No se compiló APK ni se probó en Android
esta revisión. Ver [estado actual](README.md) e [historial](HISTORIAL.md).

## Informe histórico del prototipo inicial

**Todo lo que sigue corresponde a la entrega inicial**, antes de los cambios
posteriores de arte, campamento, equipamiento y distribución del combate.
Sus cifras se conservan como registro histórico; las capturas fueron retiradas en la limpieza. El controlador
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

El antiguo controlador `tests/android_smoke.py` (retirado por coordenadas obsoletas) usaba toques ADB en la APK instalada. Lee
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

El controlador terminó con `PASS`; registro en android-smoke.log (archivo retirado en la limpieza).
Se inspeccionaron capturas renderizadas, incluidas selección, mapa, combate,
recompensa, descanso, mejora y victoria. Los registros de la versión final no
mostraron errores de GDScript ni cierres Java.

## Capturas

- Selección de personajes (archivo retirado en la limpieza)
- Combate en Android (archivo retirado en la limpieza)
- Pausa con Atrás (archivo retirado en la limpieza)
- Recompensa (archivo retirado en la limpieza)
- Descanso (archivo retirado en la limpieza)
- Mejora de carta (archivo retirado en la limpieza)
- Escalera desbloqueada (archivo retirado en la limpieza)
- Victoria y desbloqueos (archivo retirado en la limpieza)

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
# Recorrido ADB antiguo retirado: requiere un controlador adaptado a la interfaz actual.
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

## Actualización local: escenarios y tesoros (16/09/2026)

Último cambio: dos escenarios adicionales y cofres con consumibles/trampas.
Pruebas de esta entrega: `test_treasure.gd` 22, `test_game.gd` 137 y 45 aventuras,
`test_equipment.gd` 90, `test_equipment_ui.gd` 12, `test_hud.gd` 92,
`test_treasure_ui.gd` 8: **361 comprobaciones, cero fallos**.
Los cinco primeros se ejecutaron headless; tesoros UI se ejecutó renderizado
con entrada de ratón en Linux/llvmpipe. Capturas de ambos fondos, cofre cerrado
y modal normal/trampa revisadas. Importación de Godot y `git diff --check` correctos.
No se compiló APK ni se probó esta entrega en Android.
