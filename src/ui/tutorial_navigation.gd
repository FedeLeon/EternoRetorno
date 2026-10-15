extends RefCounted
const STEPS = [
	["Tu pareja, una energía compartida", "Cada turno robás seis cartas. El coste está arriba a la derecha. La energía se descuenta al jugar; una carta sin energía no se puede usar."],
	["Arrastrá o tocá para jugar", "Arrastrá un ataque hasta un enemigo o una defensa hasta su héroe. Se iluminan los objetivos válidos. Soltar afuera cancela. También podés tocar carta y objetivo."],
	["Teclado y mando", "1–9 o flechas izquierda/derecha: elegir carta. Arriba/abajo: cambiar objetivo. Enter: jugar. Espacio: terminar turno. L: enlace; O: objetivo del guardián. Mando: LB/RB cartas, cruceta objetivo, A jugar, Y terminar, B volver, X objetivo del guardián, pulsar stick izquierdo enlace, Start menú."],
	["Anticipá el próximo ataque", "Las intenciones anuncian daño, bloqueo y contraataque. El bloqueo absorbe daño durante el turno. Cada golpe de un combo puede provocar una respuesta."],
	["Elegí cómo crecer", "Podés aceptar una carta o rechazarla por celdas. Los componentes del élite cambian tu aventura. El campamento conserva equipo, mazos y especializaciones entre intentos."]
]
static func maybe(ui: Control) -> void:
	if not ui.game.save_enabled or ui.game.profile.get("tutorial_complete",false) or is_instance_valid(ui.overlay): return
	open(ui)
static func open(ui: Control, step: int = 0) -> void:
	ui.close_modal()
	ui.overlay = preload("res://src/ui/components/dialog_view.gd").build(ui, STEPS[step][0], STEPS[step][1], [
		{"text":"Listo" if step == STEPS.size()-1 else "Siguiente", "callback":func():
			if step < STEPS.size()-1: open(ui,step+1)
			else: finish(ui)},
		{"text":"Omitir introducción", "callback":func(): finish(ui)}])
static func finish(ui: Control) -> void:
	ui.game.profile.tutorial_complete = true
	ui.game.checkpoint()
	ui.close_modal()
