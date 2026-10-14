# Eterno Retorno

Prototipo jugable de rol y cartas para Android. Tres mazmorras, cuatro protagonistas civiles,
parejas de dos, mazo compartido y desbloqueos permanentes. Interfaz en español,
arte sketchbook de grafito y lápices de colores, animaciones y funcionamiento sin conexión.

**Documentación:** [índice y estado actual](docs/README.md) ·
[historial de desarrollo](docs/HISTORIAL.md) ·
[pulido visual y táctico del 07/10](docs/polish_2026_10/README.md).

Durante el desarrollo se ejecuta y prueba localmente. Se exporta una nueva APK
solo cuando se solicita; la APK existente no incluye necesariamente los últimos cambios.

## Jugar

La APK está en `builds/EternoRetorno-0.1.0-debug.apk`. Copiala al teléfono y abrila
para instalarla, o usá ADB con un dispositivo de pruebas conectado:

```bash
adb install -r builds/EternoRetorno-0.1.0-debug.apk
```

Requisitos: **Android 7.0/API 24 o posterior**, OpenGL ES 3.0, orientación
horizontal. Incluye ARM de 32 y 64 bits y x86_64 para emuladores. La versión de
prueba tiene firma de depuración y no pide permisos de Android, incluido internet.
El guardado vive en el almacenamiento privado de la aplicación; desinstalarla o
borrar sus datos elimina el progreso. Las actualizaciones con la misma firma lo
conservan. No se publica en Google Play.

### Controles y reglas

1. Desde el campamento, elegí dos personajes diferentes y equipá una reliquia
   compartida antes de entrar en la cripta: sus efectos benefician a ambos.
2. Tocá una sala iluminada del mapa. Las ramas vuelven a unirse antes del jefe.
3. Arrastrá una carta hasta un objetivo iluminado o tocá carta y objetivo.
   Defensa propia va sobre su dueño; ataque grupal sobre cualquier enemigo vivo.
   Soltar afuera cancela y conserva la energía.
4. Empezás con 20 cartas (10 por héroe), con ataques y defensas básicos repetidos.
   Compartís 3 de energía y robás 6 cartas por turno. El coste está arriba a la
   derecha; las cartas sin energía suficiente se pueden inspeccionar pero no jugar.
5. Al terminar el turno descartás tu mano; el descarte se mezcla al agotar el
   mazo. El bloqueo absorbe daño y expira al comienzo del siguiente turno aliado.
6. El veneno daña antes de actuar los enemigos, ignora bloqueo y pierde un punto
   después de cada aplicación. Los ataques penetrantes también ignoran bloqueo.
7. Un aliado caído pierde acceso a sus cartas durante ese combate. Si ganás,
   vuelve con el 25 % de vida máxima, redondeado hacia arriba. Si caen ambos,
   termina la aventura.
8. Elegí una carta después de ganar o rechazala por 12 almas. En los descansos podés
   curar el 30 % de vida o mejorar una carta, eligiendo entre Potencia y Eficiencia
   con una vista previa. Cada instancia admite una mejora.
9. Derrotá al jefe y elegí su reliquia exclusiva: se muestra directamente el mapa del siguiente piso.
   Las aventuras nuevas recorren cripta, bosque y fortaleza volcánica;
   los guardados anteriores conservan su límite de pisos.

En aventuras nuevas cada guardián tiene un objetivo propio que cuesta 1 energía
por acción: fuente de resurrección, prisión o placas de armadura. Después de la
carta de recompensa elegís una de tres reliquias exclusivas. Pactos y desvíos de
riesgo anuncian sus costes antes de aceptarlos. Los controles completos de
teclado/mando y las opciones de efectos están en la [guía de pulido](docs/polish_2026_10/README.md#controles).

El botón Atrás cancela una selección de carta, vuelve desde el mazo o abre una
pausa. Desde el inicio permite salir con confirmación. El avance se guarda tras
cada acción resuelta y al pasar a segundo plano; **Continuar aventura** restaura
la mano, los enemigos, las intenciones y las recompensas pendientes.

## Contenido

| Sistema | Contenido actual de nuevas aventuras |
| --- | --- |
| Protagonistas | Nicolás/Carpintero, Inés/Constructora, Mauro/Boticario y Vera/Profesora |
| Cartas | 88, 22 por héroe; 52 comprables y 10 instancias iniciales por héroe |
| Mapa | 28 salas, cinco bifurcaciones de tres opciones; 18 salas por ruta y dos élites posibles |
| Enemigos | 57 definiciones activas entre tres pisos, con élites y guardianes |
| Eventos | 28 definiciones, con pactos, historias de parejas y decisiones de mazo |
| Reliquias de aventura | 24 generales y 9 exclusivas de guardianes |
| Equipamiento | 8 opciones; una sola reliquia por pareja |
| Consumibles | 8 tipos; bolsa vacía al iniciar, se encuentran en cofres |

Ganar una aventura con una clase desbloquea su carta de victoria para futuras recompensas.
Vencer al élite desbloquea el reloj inmediatamente, aunque luego pierdas la
aventura. Las reliquias de grupo no se repiten dentro de la misma aventura. El altar exige
más de 5 de vida en ambos personajes y una carta todavía mejorable; nunca mata.

## Desarrollo y compilación

Versión exacta: **Godot 4.7.2.stable.official.ed1daf0bf**, GDScript, renderizador
Compatibility. Herramientas de esta entrega: Temurin **17.0.20.1+1**, Android
command-line tools **13114758**, SDK/target **36**, build-tools **36.0.0**.

En este equipo las herramientas ya están en `.tools/`. Para instalarlas desde
cero en Linux x86_64, con `curl`, `unzip` y `tar` disponibles:

```bash
./scripts/setup_tools.sh
```

El script descarga las herramientas locales y muestra las licencias del SDK.
Configura los campos de exportación Android del editor Godot de ese usuario;
no modifica el PATH del sistema. Conservá `.tools/debug.keystore` para poder
actualizar una instalación de prueba sin cambiar su firma.

```bash
# Abrir el editor o ejecutar en escritorio
./scripts/run.sh --editor
./scripts/run.sh

# Importar, probar, exportar y comprobar la firma
./scripts/build_android.sh

# Solo pruebas de lógica, sin ventana
./scripts/run.sh --headless --script tests/test_game.gd

# Capturas de todas las pantallas, con un servidor gráfico disponible
./scripts/run.sh --script tests/test_combat_layout.gd
```

Exportamos con plantillas precompiladas; este flujo no requiere compilar Godot,
Gradle, NDK ni CMake. La plantilla de Godot 4.7.2 fija API mínima 24 y target 36.
Referencia: [exportación Android de Godot](https://docs.godotengine.org/en/stable/tutorials/export/exporting_for_android.html).

## Organización

Ver [arquitectura y organización del código](docs/ARQUITECTURA.md) para las
responsabilidades actuales, estructura objetivo y criterios de separación.

- `src/game.gd`: estado y reglas; cada acción pública valida la fase y guarda.
- `src/content.gd` y `data/content.json`: catálogo con identificadores estables,
  efectos y descripción de cartas; JSON declarativo mantenido directamente.
- `src/dungeon.gd`: grafo acíclico, posiciones y encuentros con semilla.
- `src/save_store.gd`: persistencia con versión, archivo temporal y copia anterior.
- `src/main.gd`: interfaz táctil y pantallas; `src/*_sprite.gd`: animaciones.
- `data/equipment.json` y `data/enemy_visuals.json`: objetos y biblioteca visual.
- `assets/`: imágenes utilizadas; `docs/`: decisiones, prompts y fuentes de arte.
- `tests/`: pruebas de reglas, partidas completas e interfaz.

### Guardado e interfaces

`ERGame.new_run(party, seed, equipment)` inicia una aventura reproducible; `enter_node`,
`play_card`, `end_turn`, `choose_reward`, `take_treasure`, `rest`, `choose_event`
y `descend` devuelven `false` ante acciones inválidas y no modifican el estado.
`available_nodes` y `valid_targets` alimentan los controles de la interfaz.

`user://eterno.save` contiene dos secciones independientes, `profile` y `run`,
en una transacción atómica. Guardarlas juntas evita conceder un desbloqueo sin
registrar su victoria o repetir una recompensa tras una interrupción. Se usa la
serialización binaria de variantes de Godot, sin objetos, para preservar los
enteros de 64 bits del estado aleatorio. Un archivo `.bak` permite recuperar la
instantánea anterior si el principal es ilegible. No hay migraciones anteriores;
la versión del formato es 1. Al concluir una aventura se borran mazo, reliquias,
combate y recompensas adquiridas, conservando su resumen y el perfil.

## Validación y límites

Ver [docs/VALIDACION.md](docs/VALIDACION.md) para los resultados y límites de validación.
La dificultad y el arte son una base inicial: las simulaciones no sustituyen
el balance con jugadores. Esta entrega tiene un solo piso, sin audio, cuentas,
compras, sincronización ni contenido descargable. Las proporciones se conservan
con bandas laterales en pantallas más anchas que 16:9.

Las capturas de desarrollo se generan en `artifacts/`, ignorado por Git y Godot.
Se puede borrar esa carpeta. Ver [limpieza y mantenimiento](docs/LIMPIEZA.md).

### Cinemáticas y pulido integral · 08/10/2026

Inicio, cuatro historias de héroes y tres finales de guardianes con galería, pausa
y salto; seis enemigos adicionales, atmósferas/impactos locales y mezcla de audio
mejorada. [Assets, compatibilidad, análisis y pruebas](docs/cinematics/README.md).
Sin exportación; la publicación Web sigue siendo manual.
