# Documentación de Eterno Retorno

Punto de entrada de la documentación del proyecto. Actualizado el **18/09/2026**.

## Estado actual

Prototipo de un piso de 28 salas, seis clases y parejas de dos héroes. Campamento inicial,
selección alrededor de la fogata, equipamiento previo, mapa en espiral, combate,
recompensas, descanso, eventos, jefe y escalera final. Funciona sin conexión.

- Combate: 3 de energía compartida y **6 cartas por turno**; mazo inicial de **20 cartas (10 por héroe)**.
- Interfaz: fondo de cripta, personajes sobre el suelo sin recuadros, barra
  superior, energía abajo a la izquierda y cartas asomadas que se elevan al tocar.
- Tesoros: cofres animados con un consumible; 15 % de trampas. Bolsa inicial vacía.
- Cartas: seis marcos con emblemas por clase, coste superior derecho, pastilla de
  ataque/defensa e ilustraciones minimalistas asignadas por ID.
- Equipamiento: ocho reliquias disponibles, una sola elegida por pareja que beneficia a ambos héroes; ocho consumibles.
- Actores: seis héroes y 56 enemigos con sprites de 128×128; seis enemigos activos
  con ciclos nuevos de ocho poses y ataques diferenciados.
- Campamento: mercado construible en solar 1 por 300 almas, con 36 cartas comprables.
  Almas persistentes por victoria, visibles solo en campamento y edificios. Barra superior
  con saldo gráfico; arco para continuar/nueva aventura y edificio de mercado visible.
  Herrería en solar 3 por 400 almas: tres niveles independientes de arma y armadura
  por héroe, permanentes y aplicados al iniciar cada aventura. Otras construcciones pendientes.
- Cartas: 90 en total, 15 por héroe; mazos iniciales modestos y desbloqueos de mercado.
- Sinergias: 12 cartas con ENLACE, 15 combinaciones entre parejas por 2 de energía.
- Godot 4.7.2, GDScript, Compatibility, orientación horizontal, interfaz en español.

La APK existente corresponde a una entrega anterior. Los cambios recientes se
probaron localmente; **no se exporta una APK por cada cambio**. La validación
Android histórica no certifica la interfaz actual.

Auditoría del 18/09: [limpieza y separación de módulos](cleanup/2026-09-18.md),
con 30/30 pruebas automatizadas aprobadas; sin nueva exportación.

## Guías por sistema

| Tema | Documentación |
| --- | --- |
| Ejecutar, reglas y compilación | [README principal](../README.md) |
| Arquitectura actual, organización objetivo y límites entre módulos | [ARQUITECTURA.md](ARQUITECTURA.md) |
| Limpieza y archivos temporales | [LIMPIEZA.md](LIMPIEZA.md) |
| Historial y decisiones | [HISTORIAL.md](HISTORIAL.md) |
| Última comprobación local e informe Android histórico | [VALIDACION.md](VALIDACION.md) |
| Guerrero y alineación del reposo | [Guerrero](warrior/README.md) |
| Guardiana | [Guardiana](guardian/README.md) |
| Pícaro | [Pícaro](rogue/README.md) |
| Maga | [Maga](mage/README.md) |
| Clériga | [Clériga](cleric/README.md) |
| Explorador | [Explorador](ranger/README.md) |
| Selección y fogata animada | [Campamento de selección](camp/README.md) |
| Campamento previo y solares | [Campamento base](base_camp/README.md) |
| Mercado, almas y cartas desbloqueables | [Mercado](market/README.md) |
| Herrería, equipo permanente y variantes animadas | [Herrería](forge/README.md) |
| Reliquias y consumibles: valores y guardado | [Objetos](objects/README.md) |
| Sinergias entre héroes | [Sinergias](synergies/README.md) |
| Marcos y colores de cartas | [Cartas](cards/README.md) |
| Botones compartidos y barras de preparación | [Botones](ui_buttons/README.md) |
| Inicio, botones y opciones | [Inicio](title/README.md) |
| Calidad de actores, atlas de 128 px y vista previa animada | [Actores](quality/README.md) |
| Biblioteca de 56 enemigos | [Enemigos](enemies/README.md) |
| Barra, reliquias, orbe y dígitos gráficos | [HUD de combate](hud/README.md) |
| Cofres, premios y trampas | [Tesoros](treasure/README.md) |
| Mapa ilustrado, grupo y reliquias | [Mapa](map/README.md) |
| Elección de carta tras la batalla | [Recompensas](reward/README.md) |
| Primeros planos de ataque en cómic | [Cómic](comic/README.md) |
| Distribución actual del combate | [Mazmorra](dungeon/README.md) |

Las carpetas de cada sistema contienen sus prompts y fuentes generadas.
Las capturas se generan en `artifacts/` y se pueden eliminar; las históricas
fueron retiradas durante la limpieza. Los resultados escritos se conservan. Ante una diferencia visual, consultar la
entrada más reciente del historial y el documento del sistema correspondiente.

## Próximos trabajos identificados

- Ilustraciones individuales de cartas.
- Definir los edificios restantes y balancear las mejoras permanentes de herrería.
- Diseñar siguientes pisos y asignar estadísticas a los enemigos reservados.
- Balancear seis cartas por turno, equipamiento y consumibles con partidas humanas.
- Incorporar audio; el control de volumen ya existe, pero no hay música añadida.
- Cuando se solicite una nueva APK: actualizar el recorrido de interfaz de Android,
  exportar y comprobar controles táctiles, reanudación, legibilidad y rendimiento.
  Las pruebas antiguas basadas en posiciones no validan automáticamente el diseño nuevo.

## Cómo mantener esta documentación

Con cada cambio funcional o visual:

1. Actualizar el documento del sistema: comportamiento, decisiones, archivos y límites.
2. Añadir una entrada al historial con fecha, alcance y validación efectivamente realizada.
3. Registrar los prompts y procedencia de assets generados; conservar fuentes útiles.
4. Actualizar reglas y estado actual si cambian; distinguir implementado de propuesto.
5. Separar pruebas automáticas, revisión visual local, emulador y dispositivo físico.
6. Indicar si se compiló APK. No sumar resultados de distintas versiones como si
   toda la batería se hubiera ejecutado sobre la última.

No se requieren pruebas de juego por una corrección exclusivamente documental;
sí revisar los enlaces y la coherencia con los archivos del proyecto.
