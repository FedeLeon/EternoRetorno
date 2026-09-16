# Eterno Retorno

Prototipo jugable de rol y cartas para Android. Una mazmorra, seis personajes,
parejas de dos, mazo compartido y desbloqueos permanentes. Interfaz en español,
pixel art basado en los conceptos del usuario, sprites y funcionamiento sin conexión.

**Documentación:** [índice y estado actual](docs/README.md) ·
[historial de desarrollo](docs/HISTORIAL.md).

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
   distinta a cada uno antes de entrar en la cripta.
2. Tocá una sala iluminada del mapa. Las ramas vuelven a unirse antes del jefe.
3. Tocá una carta y luego un objetivo iluminado. Para cartas sobre su dueño o
   todo el grupo/enemigos, confirmá tocando al personaje dueño de la carta.
4. Compartís 3 de energía y robás 6 cartas por turno. El coste está arriba a la
   derecha; las cartas sin energía suficiente se desactivan.
5. Al terminar el turno descartás tu mano; el descarte se mezcla al agotar el
   mazo. El bloqueo absorbe daño y expira al comienzo del siguiente turno aliado.
6. El veneno daña antes de actuar los enemigos, ignora bloqueo y pierde un punto
   después de cada aplicación. Los ataques penetrantes también ignoran bloqueo.
7. Un aliado caído pierde acceso a sus cartas durante ese combate. Si ganás,
   vuelve con el 25 % de vida máxima, redondeado hacia arriba. Si caen ambos,
   termina la aventura.
8. Elegí una carta después de ganar o saltá la recompensa. En los descansos podés
   curar el 30 % de vida o mejorar una carta (+3 a daño/bloqueo/curación positivos,
   +2 a veneno). Cada instancia admite una mejora.
9. Derrotá al jefe, resolvé la recompensa y tocá **Bajar por la escalera**.
   Completar el primer piso termina esta versión de prueba.

El botón Atrás cancela una selección de carta, vuelve desde el mazo o abre una
pausa. Desde el inicio permite salir con confirmación. El avance se guarda tras
cada acción resuelta y al pasar a segundo plano; **Continuar aventura** restaura
la mano, los enemigos, las intenciones y las recompensas pendientes.

## Contenido

| Sistema | Contenido inicial |
| --- | --- |
| Clases | Guerrero, guardiana, pícaro, maga, clériga, explorador |
| Cartas | 24 básicas y 6 desbloqueables; 6 instancias iniciales por personaje |
| Mapa | 12 salas con conexiones dirigidas en espiral; 9 salas en cada ruta |
| Enemigos | 4 comunes, Esqueleto guardián (élite), Autómata roto (jefe); 50 sprites reservados |
| Eventos | Pozo, altar y biblioteca |
| Reliquias de grupo | Ascua, colmillo, cáliz y reloj desbloqueable |
| Equipamiento | 8 reliquias personales; una distinta por héroe |
| Consumibles | 8 tipos; una unidad de cada uno al iniciar una aventura |

Ganar el piso con una clase desbloquea su quinta carta para futuras recompensas.
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
./scripts/run.sh --script tests/capture_screens.gd
```

Exportamos con plantillas precompiladas; este flujo no requiere compilar Godot,
Gradle, NDK ni CMake. La plantilla de Godot 4.7.2 fija API mínima 24 y target 36.
Referencia: [exportación Android de Godot](https://docs.godotengine.org/en/stable/tutorials/export/exporting_for_android.html).

## Organización

Ver [arquitectura y organización del código](docs/ARQUITECTURA.md) para las
responsabilidades actuales, estructura objetivo y criterios de separación.

- `src/game.gd`: estado y reglas; cada acción pública valida la fase y guarda.
- `src/content.gd` y `data/content.json`: catálogo con identificadores estables,
  efectos y descripción de cartas. `scripts/create_content.py` reproduce los datos.
- `src/dungeon.gd`: grafo acíclico, posiciones y encuentros con semilla.
- `src/save_store.gd`: persistencia con versión, archivo temporal y copia anterior.
- `src/main.gd`: interfaz táctil y pantallas; `src/*_sprite.gd`: animaciones.
- `data/equipment.json` y `data/enemy_visuals.json`: objetos y biblioteca visual.
- `assets/`: imágenes utilizadas; `docs/`: decisiones, prompts, fuentes y capturas.
- `tests/`: reglas, partidas completas, capturas y recorrido de la APK por ADB.

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

Ver [docs/VALIDACION.md](docs/VALIDACION.md) para los resultados y capturas.
La dificultad y el arte son una base inicial: las simulaciones no sustituyen
el balance con jugadores. Esta entrega tiene un solo piso, sin audio, cuentas,
compras, sincronización ni contenido descargable. Las proporciones se conservan
con bandas laterales en pantallas más anchas que 16:9.
