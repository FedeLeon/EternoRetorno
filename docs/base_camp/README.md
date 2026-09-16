# Campamento previo a la aventura

Fondo original del usuario `campamentoConstruccion.png`, copiado sin editar a
`assets/base_camp/background.png`. No se generaron imágenes nuevas.

Flujo: inicio → campamento → arco de piedra → selección de dos personajes →
aventura. Tras victoria o derrota se puede regresar al campamento.
Atrás desde selección vuelve al campamento; desde campamento vuelve al inicio.

Cuatro solares y la tienda tienen zonas pulsables con información. La tienda
reserva el lugar para futuras mejoras de personajes. No se han definido tipos
de edificio, recursos, costes, mejoras ni ventajas pasivas. Tampoco se modifica
el perfil o la estructura del guardado: no hay construcciones persistentes aún.

Con aventura activa hay un botón para continuar. Preparar una nueva exige la
confirmación existente; la anterior solo termina al iniciar la nueva pareja.
Visitar el campamento o cancelar la preparación conserva la aventura actual.

Pruebas: `./scripts/run.sh --script tests/test_base_camp.gd` (19 comprobaciones)
y pruebas de selección (47) e interfaz (121), todas sin fallos. Captura local
`base-camp.png`, tomada en Godot. Sin compilación de APK ni prueba en Android.
