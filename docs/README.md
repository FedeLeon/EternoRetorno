# Documentación de Eterno Retorno

Punto de entrada de la documentación del proyecto. Actualizado el **15/10/2026**.

## Estado actual

[Combate y parejas](combat_refinement/README.md): guardias continuas con 12 poses
por héroe, estocadas/barridos propios, seis emblemas y efectos condicionados,
práctica interactiva de bloqueo/reserva/sinergia y seis bancos enemigos renovados.

[Posición de héroes](battle_effects/README.md): personajes e iconos al pie 16 px
más abajo, con límite para mantener visibles los estados y la carta ampliada.

[Inspección de enemigos](battle_effects/README.md): cuadro compacto con icono
en cada fila de información, altura ajustada y scroll para muchos efectos.
Batalla visible alrededor; conserva clic de ataque al seleccionar carta.

[Reserva reversible](cards/pixel_retain/README.md): la carta queda boca abajo
en la mano; tocarla o pulsar Recuperar carta la devuelve de frente y permite
guardar otra gratis. Conserva mejoras, posición y guardados anteriores.

[Arrastre de cartas](cards/pixel_retain/README.md): eliminado el cartel oscuro
superpuesto; conserva carta flotante, objetivos iluminados y aplicación al soltar.

[Espacio de combate](battle_effects/README.md): suelo e intenciones 24 px más
abajo y personajes alrededor de un 12% más grandes en la distribución habitual.
Carta ampliada completa y efectos separados de la mano; pruebas y capturas actuales.

[Tipografía de cartas](cards/pixel_retain/README.md): corregido el hueco en la
«e» de la negrita sustituyendo MSDF por rasterizado con suavizado al doble de
resolución. Conserva fuente, peso y distribución; render local revisado.

[Distribución del combate](battle_effects/README.md): escenario industrial
corregido, personajes más grandes, barras elevadas e intenciones/estados bajo
los pies. Nombre/datos del enemigo al tocarlo sin carta seleccionada; los
ataques y enlaces conservan sus objetivos y las ayudas siguen siendo pulsables.

[Rayos enemigos](animation_review/README.md): los primeros planos enemigos
también extienden sus rayos de luz hasta fuera de la pantalla, igual que los
héroes, conservando la ilustración estática y sus partículas.

[Lectura de cartas](cards/pixel_retain/README.md): título, energía y categoría
alineados con el marco; descripción más grande y ajustada al espacio. La
pastilla inferior conserva efectos/enlaces y elimina iconos repetidos de
ataque/defensa. Comprobaciones de catálogo y render local sin fallos.

[Auditoría integral del 15/10](quality/AUDITORIA_2026_10_15.md): catálogos,
assets, arquitectura y limpieza; 98/98 suites headless, comprobaciones nativas
de combate/opciones (125/0) y edificios (84/0). Prioridades, candidatos de
limpieza y propuestas de diseño separados de cambios implementados.

[Colección a pantalla completa](collection/README.md): botón «Ver ilustración»
en los logros desbloqueados, incluidos secretos descubiertos; Volver/Escape
recupera la selección y el foco.


[Rayos de primeros planos](animation_review/README.md): ataques y defensas de
héroes con luz radial que llega más allá de los bordes de la pantalla, sin
puntas cortadas dentro de la vista.


[Menú lateral de mapa y caminos](map/sidebar_icons/README.md): tres nuevos
assets de cómic para Grupo, Mazo y Caminos/Mapa, transparentes y con tamaño
uniforme de 64 px.

[Iconos de mapa y caminos](map/comic_icons/README.md): seis ilustraciones de
cómic generadas individualmente, transparentes y con borde claro; destino
principal de caminos centrado a 76 px.


[Carrera de victoria](animation_review/README.md): los cuatro héroes conservan
su tamaño y la línea de suelo al abandonar el combate, con escala propia del
atlas actual y separación entre actores HD y clásicos.


[Tamaño de enemigos](animation_review/README.md): escala estable durante
contraataques pese al redondeo de contenedores, y recortes corregidos para
sabueso, supervisor y dos drones de una hoja con filas desiguales.


[Bloqueo activo](battle_effects/README.md): escudo carbón con borde claro fino
para que destaque el número sobre héroes y enemigos.


[Selección de héroes](camp/README.md): tacho fijo con la misma luz y chispas del
campamento, sin animación de llamas.


[Campamento con animales](base_camp/companions/README.md): refugio centrado sobre
el brasero, Aventuras cuadrado con Play grande y electricidad, perro y gato
con pasos, olfateo/comida y pausas sobre recorridos despejados.


[Cartas y reserva](cards/pixel_retain/README.md): frentes/reversos de metal y
papel por oficio, dibujos de cómic minimalistas y una carta guardada boca abajo
por turno que regresa junto al robo normal. Conserva mejoras y guardados.


[Configuración de inicio](ui_buttons/settings/README.md): engranaje ilustrado de
cómic con partículas y descargas cian, conservando acceso y ajustes existentes.

[Terminar turno](ui_buttons/README.md): arcos eléctricos y chispas cian alrededor
del aro del botón, con texto central despejado y preferencias de efectos respetadas.

[Intenciones enemigas](battle_effects/README.md): rostros HD centrados del héroe
objetivo, con borde del color que lo identifica; ataques de área muestran ambos.

[Colección](collection/README.md): 28 ilustraciones de cómic detalladas, una
generación propia por logro, con originales/prompts conservados y detalle a 184 px;
ocultación secreta con ilustración propia y seis iconos SVG auxiliares.

[Guardia intermitente](animation_review/README.md): los cuatro héroes de batalla
mueven manos/arma y flexionan ligeramente entre pausas propias, con pies apoyados
y prioridad para ataques, defensas, reacciones y carrera.

[Bolsa y accesos superiores](objects/README.md): nuevos iconos tecnológicos de
mazo/mochila y selección de consumibles mediante retratos contiguos de héroes o
enemigos, respetando los objetivos válidos y el consumo único.

[Registro del combate](ui_buttons/README.md): botón de libreta en el menú
superior entre Bolsa y Menú; escenario libre del antiguo botón textual.

**Dirección vigente:** mundo postapocalíptico de civiles contra máquinas, con
cómic de acción americano: tinta negra, sombras planas y colores vivos.
La sustitución de los **683 recursos visuales activos está completada** y verificada
por hash; la ficción publicada conserva IDs y estadísticas. [Diseños, alcance y procedencia](art_direction/postapocalyptic/README.md).


[Suelo corregido de las batallas de la tercera mazmorra](dungeon/volcano_ground.md):
registro histórico del apoyo; las batallas actuales usan escenarios industriales
con suelo visible bajo los personajes.

Dirección anterior (registro histórico): **sketchbook de grafito y lápices de colores**,
con trazos irregulares, negro/gris/violeta y buen contraste.

[Conversión sketchbook anterior](art_direction/migration/README.md): héroes,
enemigos y sus animaciones, mazmorras, mapas, cartas, iconos y cinemáticas.
628 imágenes actualizadas verificadas por hash; ninguna imagen activa pendiente.
[Inventario técnico de recursos](art_direction/2026-10-13/review/README.md).

[Campamento al atardecer](base_camp/dusk/README.md) e
[interiores con galerías 2×2](base_camp/interiors/README.md) conservan la distribución; sus dibujos fueron sustituidos por el nuevo cómic.
En el campamento, Mercado/Laboratorio tienen el cartel sobre el techo y el
[brasero centrado](base_camp/stable_fire/README.md) emite luz y chispas sin llamas.

Elenco: Nicolás **Carpintero**, Inés **Constructora**, Mauro **Boticario** y Vera **Profesora**. [Retiro definitivo y migración de guardados](cleanup/2026-10-13.md).

Aventuras nuevas de tres pisos aleatorios de 28 salas: red de mantenimiento, cinturón industrial y central del Reinicio; cuatro protagonistas con oficios civiles y parejas de dos héroes. Campamento inicial,
selección alrededor de la fogata, equipamiento previo, mapa en espiral con caminos variables hasta el guardián central, combate,
recompensas, descanso, eventos, jefe y escalera final. Funciona sin conexión.

- Navegación: después de las recompensas se elige en [Caminos en primera persona](paths/README.md), con salidas reales, vista previa y menú Grupo/Mazo/Mapa. Una aventura nueva entra directamente en la primera batalla tras la preparación.
- Mapa: [seis iconos propios de salas](map/README.md), de cómic tecnológico, para
  combate, descanso, encuentro, tesoro, élite y jefe; compartidos con los caminos.

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
  aliada, con iconos de cómic sencillos, volumen discreto y todas las filas visibles; tocar permite
  consultar cada explicación, sin carteles sobre las cartas. [Diseño y pruebas](battle_effects/README.md).
- Tesoros: cofres animados con un consumible; 15 % de trampas. Bolsa inicial vacía.
- Encuentros: 19 situaciones, incluido un mercader errante por piso nuevo; fondos propios, decisiones de mazo y beneficios según pareja.
- Cartas: [marcos tecnológicos propios por héroe](cards/tabletop/README.md), sin placa de nombre/oficio ni emblema superior; color, refuerzos y circuitos distinguen los cuatro diseños. Botón circular de terminar turno con aro mecánico.
- Legibilidad de cartas: títulos y descripciones en negrita, con ajuste de texto
  calculado usando el mismo peso tipográfico.
- Cartas: cuatro marcos con emblemas por héroe, coste superior derecho y pastilla de
  ataque/defensa. 88 ilustraciones minimalistas nuevas: objetos y trazos que
  representan el efecto, con poco detalle y fondo despejado. [Arte actual](cards/minimal/README.md).
- Preparación: [celdas, ocho componentes HD, iconos propios y play](preparation_assets/README.md); entrada directa al combate, con guardado antes de las cinemáticas.
- Energía en batalla: arcos y chispas eléctricas alrededor de la batería, con
  descarga al consumir energía y cifra central despejada; respeta ajustes de efectos.
- Equipamiento: ocho reliquias iniciales, una elegida por pareja; ocho consumibles.
  Los élites conceden una reliquia de aventura aleatoria sin duplicados de un catálogo
  de 24 para élites, más nueve exclusivas de guardianes, visible junto a la elección de carta.
- Tamaño de enemigos: cuadros pequeños de ataque compensados mediante métricas precalculadas, con apoyo en el suelo y vuelta al tamaño de reposo.
- Animaciones: [revisión de poses, selección y efectos de primer plano](animation_review/README.md); extracción corregida y reposo estable.
- Actores: héroes de batalla con doce poses por acción, base de 256×256 y ataques nuevos de 384×384; cuatro héroes y 56 enemigos animados con celdas de 256×256; 57 definiciones activas con 56 apariencias. Los nuevos conceptos tienen cuatro poses de reposo, cuatro de ataque y cuatro poses transparentes de ataque en primer plano; anticipación y recuperación por familia.
- Equipo de héroes: [celda de energía y 24 iconos de mejoras](combat_equipment_assets/README.md), propios por personaje/pista/nivel. Mejoras en el HUD y tintes del sprite; sin piezas de arma o
  armadura pegadas encima del personaje. Se mantiene el equipo dibujado en sus poses.
- Primeros planos de héroes: ocho ilustraciones estáticas (ataque y defensa por
  protagonista), transparentes y quietas con partículas detrás; se retiran los
  atlas anteriores. [Assets, limpieza y validación](comic/static/README.md).
- Campamento: [edificios ajustados a los solares y barril fijo](base_camp/stable_fire/README.md); 24 cuadros nuevos solo de llamas, sin desplazamiento del cuerpo.
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

Revisión y limpieza actuales: [batallas, vistas, mecánicas y archivos sustituidos](game_review_2026_10_14/README.md).

Limpieza anterior: [código, recursos y fuentes sustituidas del 14/10](cleanup/2026-10-14.md).
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
