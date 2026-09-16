# Historial de desarrollo

Registro consolidado el **15/09/2026** a partir de los cambios de esta sesión y
la documentación del repositorio. El orden refleja las etapas de trabajo;
no se atribuyen horas ni fechas de compilación que no estén verificadas.

## Prototipo inicial

- Godot, un piso de 12 salas en espiral, seis clases y selección de dos héroes.
- Mazo compartido, turnos, enemigos con intención, recompensas, eventos y descanso.
- Caída individual, recuperación al ganar, derrota conjunta y desbloqueos.
- Guardado atómico de perfil y aventura; semilla y estado aleatorio persistidos.
- El informe original registra exportación e instalación en emulador Android;
  no hubo prueba en teléfono físico. [Informe histórico](VALIDACION.md#informe-histórico-del-prototipo-inicial).

## Personajes y animaciones

- Integración progresiva de guerrero, guardiana, pícaro, maga, clériga y explorador
  a partir de los conceptos aportados por el usuario.
- Sprites de 64 × 64, animaciones de reposo, acciones, daño, caída y recuperación.
- Corrección del salto vertical al final del reposo del guerrero mediante alineación
  de la silueta de los pies, documentada en su importador y pruebas.
- Las acciones se resuelven y guardan antes de presentar las animaciones.

## Selección y campamento previo

- Fondo nocturno, personajes de frente alrededor de fogata animada, brillo y chispas.
- Campamento base con arco para preparar la aventura, cuatro solares y refugio.
- Solares y refugio informan sobre funciones futuras; todavía no conceden ventajas.
- Visitar el campamento o cancelar preparación conserva la aventura activa.

## Equipamiento y consumibles

- Decisión del usuario: ocho reliquias disponibles; una distinta por héroe.
- Decisión del usuario: implementar también los ocho consumibles desde esta etapa.
- Preparación guardada, efectos pasivos durante la aventura y bolsa compartida.
- Valor de prototipo: una unidad inicial de cada consumible por aventura nueva.
- Compatibilidad con aventuras anteriores sin otorgar equipamiento retroactivo.
- [Efectos y comprobaciones de esta etapa](objects/README.md).

## Diseño de cartas

- Marcos por clase: rojo, turquesa, verde, violeta, dorado y azul.
- El pistolero del concepto se adaptó al pícaro; se agregó el marco de guardiana.
- Coste, nombre y descripción dibujados desde los datos reales del juego.
- Inicialmente se usaron poses de héroes como ilustración. La última revisión
  las reemplaza por espacios vacíos con márgenes para imágenes futuras.

## Pantalla inicial

- Asset del usuario como splash de arranque y fondo del menú.
- Botones generados de iniciar/continuar y opciones; acceso al campamento y colección.
- Volumen y pantalla completa para escritorio guardados en el perfil.
- 31 comprobaciones locales en esta etapa, revisión visual; sin nueva APK.

## Biblioteca de enemigos

- 56 sprites transparentes desde siete plantillas. Seis se usan en la primera cripta:
  murciélago, lancero, chamán de ceniza, baba ácida, guardián élite y autómata jefe.
- Otros 50 reservados para futuros pisos. Variantes similares se conservan separadas.
- Animaciones procedurales del sprite completo: reposo, flotación, ataque, daño y caída.
- Se mantienen IDs de encuentros, estadísticas y compatibilidad del guardado.
- Ajustes de recorte de armas y línea de suelo; pruebas de héroes adaptadas a la
  secuencia ataque enemigo → reacción del héroe.
- 1.132 comprobaciones locales en esa etapa, más revisión visual; sin nueva APK.

## Última revisión del combate

- Fondo de mazmorra derivado del concepto; héroes y enemigos sobre el suelo.
- Eliminados recuadros de personajes, «VS», marca del juego y texto de instrucciones.
- Barra superior con sala, mazo, bolsa con icono, menú y turno a la derecha.
- Energía abajo a la izquierda. Seis cartas por turno, sustituyendo las cinco iniciales.
- Mano parcialmente visible; tocar eleva y amplía una carta. Costes sin solaparse;
  desplazamiento para manos mayores y posición de desplazamiento conservada al seleccionar.
- Espacio vacío para imagen y bloque de descripción con márgenes.
- 584 comprobaciones locales: lógica 137, interfaz 121, cartas 243, equipamiento 64,
  interfaz de equipamiento 11 y distribución 8. Las 45 simulaciones terminaron en
  victoria; esto no sustituye pruebas de dificultad con jugadores.
- Revisión de capturas de combate y carta elevada. Sin APK ni nueva prueba Android.
- [Detalle y capturas](dungeon/README.md).

## Organización de documentación

- Índice general, estado actual, pendientes e historial consolidados.
- README principal actualizado y validación Android marcada como histórica.
- Pauta de mantenimiento en `AGENTS.md`: documentar cambios y pruebas, mantener
  decisiones y no exportar APK salvo pedido explícito.
- Cambio documental; revisión de enlaces locales, sin ejecutar juego ni compilar.

## Arquitectura y mantenimiento del código

- Documentadas responsabilidades actuales, dependencias y estructura objetivo
  en [ARQUITECTURA.md](ARQUITECTURA.md).
- Identificados `main.gd` (887 líneas) y `game.gd` (493) como archivos a dividir
  progresivamente; pautas para pantallas, componentes, presentación y reglas.
- Registrados contratos de guardado, IDs/UIDs, fuentes de datos y organización
  de assets, además del orden propuesto de extracción y sus comprobaciones.
- Pautas añadidas a `AGENTS.md` para aplicarlas en trabajos posteriores.
- Esta entrega documenta la arquitectura; no mueve archivos de juego ni ejecuta
  la refactorización propuesta. Validación de enlaces y formato, sin APK.
