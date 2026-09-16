# Documentación de Eterno Retorno

Punto de entrada de la documentación del proyecto. Actualizado el **15/09/2026**.

## Estado actual

Prototipo de un piso, seis clases y parejas de dos héroes. Campamento inicial,
selección alrededor de la fogata, equipamiento previo, mapa en espiral, combate,
recompensas, descanso, eventos, jefe y escalera final. Funciona sin conexión.

- Combate: 3 de energía compartida y **6 cartas por turno**; mazo inicial de 12.
- Interfaz: fondo de cripta, personajes sobre el suelo sin recuadros, barra
  superior, energía abajo a la izquierda y cartas asomadas que se elevan al tocar.
- Cartas: seis colores; espacio de ilustración vacío, reservado para arte futuro.
- Equipamiento: ocho reliquias disponibles, una distinta por héroe; ocho consumibles.
- Enemigos: seis apariencias activas y 50 reservadas, con animaciones sencillas.
- Campamento: solares y refugio interactivos de presentación. Construcciones,
  costes, ventajas de edificios y mejoras permanentes de héroes **no implementados**.
- Godot 4.7.2, GDScript, Compatibility, orientación horizontal, interfaz en español.

La APK existente corresponde a una entrega anterior. Los cambios recientes se
probaron localmente; **no se exporta una APK por cada cambio**. La validación
Android histórica no certifica la interfaz actual.

## Guías por sistema

| Tema | Documentación |
| --- | --- |
| Ejecutar, reglas y compilación | [README principal](../README.md) |
| Arquitectura actual, organización objetivo y límites entre módulos | [ARQUITECTURA.md](ARQUITECTURA.md) |
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
| Reliquias y consumibles: valores y guardado | [Objetos](objects/README.md) |
| Marcos y colores de cartas | [Cartas](cards/README.md) |
| Inicio, botones y opciones | [Inicio](title/README.md) |
| Biblioteca de 56 enemigos | [Enemigos](enemies/README.md) |
| Distribución actual del combate | [Mazmorra](dungeon/README.md) |

Las carpetas de cada sistema contienen sus prompts, fuentes generadas y capturas.
Las capturas muestran el estado cuando se tomaron; las antiguas no representan
necesariamente la interfaz actual. Ante una diferencia visual, consultar la
entrada más reciente del historial y el documento del sistema correspondiente.

## Próximos trabajos identificados

- Ilustraciones individuales de cartas.
- Definir y desarrollar edificios y mejoras permanentes del campamento.
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
