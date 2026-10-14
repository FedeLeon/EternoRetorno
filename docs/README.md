# Documentación de Eterno Retorno

Punto de entrada de la documentación del proyecto. Actualizado el **14/10/2026**.

## Estado actual

[Suelo corregido de las batallas de la tercera mazmorra](dungeon/volcano_ground.md):
patio continuo bajo los personajes, conservando el estilo a lápiz.

Dirección visual de todo el juego: **sketchbook de grafito y lápices de colores**,
con trazos irregulares, negro/gris/violeta y buen contraste.

[Conversión integral completada](art_direction/migration/README.md): héroes,
enemigos y sus animaciones, mazmorras, mapas, cartas, iconos y cinemáticas.
628 imágenes actualizadas verificadas por hash; ninguna imagen activa pendiente.
[Inventario y galería actuales](art_direction/2026-10-13/review/README.md).

[Campamento al atardecer](base_camp/dusk/README.md) e
[interiores con galerías 2×2](base_camp/interiors/README.md) conservan el arte aprobado.

Elenco: Nicolás **Carpintero**, Inés **Constructora**, Mauro **Boticario** y Vera **Profesora**. [Retiro definitivo y migración de guardados](cleanup/2026-10-13.md).

Aventuras nuevas de tres pisos aleatorios de 28 salas: cripta, bosque y fortaleza volcánica; cuatro protagonistas con oficios civiles y parejas de dos héroes. Campamento inicial,
selección alrededor de la fogata, equipamiento previo, mapa en espiral con caminos variables hasta el guardián central, combate,
recompensas, descanso, eventos, jefe y escalera final. Funciona sin conexión.

- Controles: arrastrar, tocar, teclado o mando; preview, tutorial, velocidad 1–2× y efectos ajustables.
- Aventura: dificultad y condición mediante tarjetas ilustradas, rechazo de carta por almas y resumen final.
- Enemigos comunes: 20 tipos en cripta, 22 en bosque y 18 en fortaleza; generación que prioriza variedad y evita repetir la formación del combate anterior de cada camino. Pisos ya guardados conservan sus encuentros.
- Combate: 3 de energía compartida y **6 cartas por turno**; mazo inicial de **20 cartas (10 por héroe)**.
- Interfaz: fondo de cripta, personajes sobre el suelo sin recuadros, barra
  superior, energía abajo a la izquierda y cartas asomadas que se elevan al tocar.
- Golpes cuerpo a cuerpo: el héroe se acerca al objetivo y vuelve a su puesto; HD simultáneo abajo a la izquierda, con combos y área por impacto.
- Impactos: cifras flotantes de 40 px, con contorno oscuro, sombra y desvanecimiento más lento.
- Daño de veneno al terminar el turno: parpadeo verde, antes de las cenizas si
  mata; los golpes normales mantienen el rojo. [Validación](battle_effects/README.md).
- Estados de combate: 36 iconos de efectos junto a las intenciones y sobre la vida
  aliada, con dibujos sencillos a lápiz, volumen discreto y todas las filas visibles; tocar permite
  consultar cada explicación, sin carteles sobre las cartas. [Diseño y pruebas](battle_effects/README.md).
- Tesoros: cofres animados con un consumible; 15 % de trampas. Bolsa inicial vacía.
- Encuentros: 19 situaciones, incluido un mercader errante por piso nuevo; fondos propios, decisiones de mazo y beneficios según pareja.
- Cartas: cuatro marcos con emblemas por héroe, coste superior derecho y pastilla de
  ataque/defensa. 88 ilustraciones minimalistas nuevas: objetos y trazos que
  representan el efecto, con poco detalle y fondo despejado. [Arte actual](cards/minimal/README.md).
- Equipamiento: ocho reliquias iniciales, una elegida por pareja; ocho consumibles.
  Los élites conceden una reliquia de aventura aleatoria sin duplicados de un catálogo
  de 24 para élites, más nueve exclusivas de guardianes, visible junto a la elección de carta.
- Tamaño de enemigos: cuadros pequeños de ataque compensados mediante métricas precalculadas, con apoyo en el suelo y vuelta al tamaño de reposo.
- Actores: héroes de batalla con doce poses por acción, base de 256×256 y ataques nuevos de 384×384; cuatro héroes y 56 enemigos animados con celdas de 256×256; 57 definiciones activas con 56 apariencias. Los nuevos conceptos tienen cuatro poses de reposo, cuatro de ataque y cuatro poses transparentes de ataque en primer plano; anticipación y recuperación por familia.
- Equipo de héroes: mejoras en el HUD y tintes del sprite; sin piezas de arma o
  armadura pegadas encima del personaje. Se mantiene el equipo dibujado en sus poses.
- Primeros planos de héroes: ocho ilustraciones estáticas (ataque y defensa por
  protagonista), transparentes y quietas con partículas detrás; se retiran los
  atlas anteriores. [Assets, limpieza y validación](comic/static/README.md).
- Campamento: mercado construible en solar 1 por 300 almas, con 52 cartas comprables.
  Almas persistentes por victoria, visibles solo en campamento y edificios. Barra superior
  con saldo gráfico; arco para continuar/nueva aventura y edificio de mercado visible.
  Herrería en solar 3 por 400 almas: tres niveles independientes de arma y armadura
  por héroe, permanentes y aplicados al iniciar cada aventura. Iglesia en solar 4 (600 almas), con ocho especializaciones; puesto de expediciones
  en solar 2, debajo de la fogata (500 almas), con 19 contratos y tres ofertas por aventura.
- Refugio: preparación persistente del mazo inicial y vínculos entre las seis parejas activas, historias y variantes de enlace; cambios solo para aventuras nuevas.
- Cartas: 88 definiciones, 22 por héroe; mazos iniciales modestos y desbloqueos de mercado.
- Colección: 28 logros persistentes, cinco secretos, desbloqueos e historial con fondo propio.
- Bestiario: botón solo en Inicio, encima de Colección, con regreso a Inicio; búsqueda, filtros por mazmorra y descubiertos primero, sin revelar nombres ocultos.
- Sinergias: seis combinaciones por 2 de energía.
- Audio: diez músicas/arreglos, cuatro ambientes y 41 efectos CC0; combate de bosque/fortaleza con arreglos propios, ambiente con fundidos y muestras de impactos alternadas. Volúmenes con porcentaje; canales compatibles con Web. [Sistema y fuentes](audio/README.md).
- Godot 4.7.2, GDScript, Compatibility, orientación horizontal, interfaz en español.

- [Combate táctico y héroes detallados](combat_depth_2026_10/README.md): mejoras alternativas,
  preparación/interrupción, formación, parejas de reliquias, élites con modificadores,
  mecánicas propias de piso, encuentros encadenados, entrenamiento aislado, registro,
  historia detallada y bestiario descubierto.

La APK existente corresponde a una entrega anterior. Los cambios recientes se
probaron localmente; **no se exporta una APK por cada cambio**. La validación
Android histórica no certifica la interfaz actual.

Limpieza actual: [código, recursos y fuentes sustituidas del 14/10](cleanup/2026-10-14.md).
Se retiraron recursos sustituidos, referencias regenerables y resultados temporales;
se mantienen las animaciones activas y las pruebas de regresión.

Auditoría histórica del 18/09: [limpieza y separación de módulos](cleanup/2026-09-18.md),
con 30/30 pruebas automatizadas aprobadas; sin nueva exportación.

- Cinemáticas: inicio, cuatro héroes y tres guardianes; galería Historias, pausa/salto,
  automatismos opcionales y descubrimiento compatible con guardados anteriores.
  [Entrega y revisión integral](cinematics/README.md).

## Guías por sistema

| Tema | Documentación |
| --- | --- |
| Rostros casi de perfil para tarjetas pequeñas | [Retratos compactos y conservación de verticales](portraits/2026-10-13/README.md) |
| Origen civil, oficios, personalidad y Pícaro sin máscara | [Historia inicial de los cuatro vecinos](story/2026-10-13/README.md) |
| Cuatro héroes y dirección de bocetos sobre papel | [Elenco, arte y límites de la primera etapa](art_direction/2026-10-13/README.md) |
| Caché, respaldo, reglas/UI y validación de contenido | [Revisión técnica del 09/10](architecture/TECHNICAL_REVIEW_2026_10_09.md) |
| Enemigos, impactos por acción, música y búsqueda del bestiario | [Revisión y pulido del juego del 08/10](whole_game_polish/README.md) |
| Viñetas más lentas, mapas claros y cine ilustrado | [Cambios y validación del 08/10](presentation_refinements/README.md) |
| Posiciones y legibilidad de las vistas | [Revisión local del 08/10](ui_layout/README.md) |
| Cinemáticas y revisión integral del juego | [Escenas, assets, audio y auditoría](cinematics/README.md) |
| Iconos y explicación de efectos de batalla | [Catálogo, arte y pruebas](battle_effects/README.md) |
| Pulido visual, riesgo, guardianes, proyectos, controles y rendimiento | [Entrega y pruebas del 07/10](polish_2026_10/README.md) |
| Tercera mazmorra, arrastre, vínculos, dificultad y opciones | [Ampliación del 07/10](expansion_2026_10/README.md) |
| Colección y 30 logros | [Vista, progreso y assets](collection/README.md) |
| Ejecutar, reglas y compilación | [README principal](../README.md) |
| Plantillas y errores de exportación Web | [Exportación Web](export/README.md) |
| 24 cartas nuevas de apoyo y debilitamiento | [Catálogo, imágenes y reglas](cards/support/README.md) |
| Ampliación de ambas mazmorras y cómics de ocho cuadros | [Catálogo, assets y presentación](combat_expansion/README.md) |
| Nueva variedad de la primera mazmorra | [Esqueletos y elementales](enemies/crypt_expansion/README.md) |
| Pisos aleatorios y segunda mazmorra | [Bosque y generación](forest/README.md) |
| Descansos | [Escena, poses y opciones](rest/README.md) |
| Salas de encuentro | [Fondos, animación y decisiones](encounters/README.md) |
| Carrera de héroes | [Sprites y ciclos](running/README.md) |
| Reliquias de élite y catálogo de efectos | [Reliquias de aventura](relics/README.md) |
| Contratos y puesto de expediciones | [Expediciones](expeditions/README.md) |
| Iglesia y especializaciones | [Iglesia](church/README.md) |
| Refugio y preparación del mazo | [Refugio](refuge/README.md) |
| Arquitectura actual, organización objetivo y límites entre módulos | [ARQUITECTURA.md](ARQUITECTURA.md) |
| Limpieza y archivos temporales | [LIMPIEZA.md](LIMPIEZA.md) |
| Historial y decisiones | [HISTORIAL.md](HISTORIAL.md) |
| Última comprobación local e informe Android histórico | [VALIDACION.md](VALIDACION.md) |
| Carpintero y alineación del reposo | [Carpintero](warrior/README.md) |
| Constructora | [Constructora](guardian/README.md) |
| Boticario | [Boticario](rogue/README.md) |
| Profesora | [Profesora](mage/README.md) |
| Selección y fogata animada | [Campamento de selección](camp/README.md) |
| Campamento previo y solares | [Campamento base](base_camp/README.md) |
| Encargados y globos ambientales | [Interiores y diálogos](base_camp/attendants.md) |
| Mercado, almas y cartas desbloqueables | [Mercado](market/README.md) |
| Herrería, equipo permanente y variantes animadas | [Herrería](forge/README.md) |
| Reliquias y consumibles: valores y guardado | [Objetos](objects/README.md) |
| Sinergias entre héroes | [Sinergias](synergies/README.md) |
| Marcos y colores de cartas | [Cartas](cards/README.md) |
| Botones compartidos y barras de preparación | [Botones](ui_buttons/README.md) |
| Inicio, botones y opciones | [Inicio](title/README.md) |
| Música, efectos, ambientes y licencias | [Audio](audio/README.md) |
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

- Balancear las mejoras permanentes, nuevas formaciones y tres pisos con partidas humanas.
- Evaluar nuevas familias entre los enemigos todavía reservados después de probar la fortaleza.
- Balancear seis cartas por turno, equipamiento y consumibles con partidas humanas.
- Ajustar la selección musical y los efectos después de escucharlos en partidas humanas.
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
