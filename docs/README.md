# Documentación de Eterno Retorno

Punto de entrada de la documentación del proyecto. Actualizado el **07/10/2026**.

## Estado actual

Aventuras nuevas de tres pisos aleatorios de 28 salas: cripta, bosque y fortaleza volcánica; seis clases y parejas de dos héroes. Campamento inicial,
selección alrededor de la fogata, equipamiento previo, mapa con caminos variables, combate,
recompensas, descanso, eventos, jefe y escalera final. Funciona sin conexión.

- Controles: arrastrar o tocar cartas; preview, tutorial, velocidad 1–2× y efectos ajustables.
- Aventura: dificultades desbloqueables, condiciones, rechazo de carta por almas y resumen final.
- Combate: 3 de energía compartida y **6 cartas por turno**; mazo inicial de **20 cartas (10 por héroe)**.
- Interfaz: fondo de cripta, personajes sobre el suelo sin recuadros, barra
  superior, energía abajo a la izquierda y cartas asomadas que se elevan al tocar.
- Tesoros: cofres animados con un consumible; 15 % de trampas. Bolsa inicial vacía.
- Encuentros: diez situaciones, incluido un mercader errante por piso nuevo; fondos propios, decisiones de mazo y beneficios según pareja.
- Cartas: seis marcos con emblemas por clase, coste superior derecho, pastilla de
  ataque/defensa e ilustraciones minimalistas asignadas por ID.
- Equipamiento: ocho reliquias iniciales, una elegida por pareja; ocho consumibles.
  Los élites conceden una reliquia de aventura aleatoria sin duplicados de un catálogo
  de 24 (20 nuevas), visible junto a la elección de carta.
- Actores: héroes de batalla redibujados a 256×256 con doce poses por acción; seis héroes clásicos y 56 enemigos con sprites de 128×128; 45 definiciones activas con 44 apariencias. Las incorporaciones a ambas mazmorras tienen cuatro poses de reposo, cuatro de ataque y una ilustración transparente de ataque en primer plano.
- Ataques de héroes en primer plano: 24 ataques y seis defensas de 16 cuadros dibujados,
  con poses HD, luces y partículas locales; [assets y reproducción](comic/hd/README.md).
- Campamento: mercado construible en solar 1 por 300 almas, con 72 cartas comprables.
  Almas persistentes por victoria, visibles solo en campamento y edificios. Barra superior
  con saldo gráfico; arco para continuar/nueva aventura y edificio de mercado visible.
  Herrería en solar 3 por 400 almas: tres niveles independientes de arma y armadura
  por héroe, permanentes y aplicados al iniciar cada aventura. Iglesia en solar 4 (600 almas), con doce especializaciones; puesto de expediciones
  en solar 2, debajo de la fogata (500 almas), con treinta contratos y tres ofertas por aventura.
- Refugio: preparación persistente del mazo inicial y vínculos entre las quince parejas, historias y variantes de enlace; cambios solo para aventuras nuevas.
- Cartas: 126 en total, 21 por héroe; mazos iniciales modestos y desbloqueos de mercado.
- Colección: 30 logros persistentes, cinco secretos, desbloqueos e historial con fondo propio.
- Sinergias: 12 cartas con ENLACE, 15 combinaciones entre parejas por 2 de energía.
- Audio: cinco músicas, cuatro ambientes y 39 efectos CC0; volumen general, música y efectos ajustables; canales compatibles con Web. [Sistema y fuentes](audio/README.md).
- Godot 4.7.2, GDScript, Compatibility, orientación horizontal, interfaz en español.

- [Combate táctico y héroes detallados](combat_depth_2026_10/README.md): mejoras alternativas,
  preparación/interrupción, formación, parejas de reliquias, élites con modificadores,
  mecánicas propias de piso, encuentros encadenados, entrenamiento aislado, registro,
  historia detallada y bestiario descubierto.

La APK existente corresponde a una entrega anterior. Los cambios recientes se
probaron localmente; **no se exporta una APK por cada cambio**. La validación
Android histórica no certifica la interfaz actual.

Limpieza actual: [auditoría del 07/10](cleanup/2026-10-07.md).
Se retiraron recursos sustituidos, referencias regenerables y resultados temporales;
se mantienen las animaciones activas y las pruebas de regresión.

Auditoría histórica del 18/09: [limpieza y separación de módulos](cleanup/2026-09-18.md),
con 30/30 pruebas automatizadas aprobadas; sin nueva exportación.

## Guías por sistema

| Tema | Documentación |
| --- | --- |
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
| Guerrero y alineación del reposo | [Guerrero](warrior/README.md) |
| Guardiana | [Guardiana](guardian/README.md) |
| Pícaro | [Pícaro](rogue/README.md) |
| Maga | [Maga](mage/README.md) |
| Clériga | [Clériga](cleric/README.md) |
| Explorador | [Explorador](ranger/README.md) |
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

- Ilustraciones individuales de cartas.
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
