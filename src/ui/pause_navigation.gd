extends RefCounted
const Dialog = preload("res://src/ui/components/dialog_view.gd")
static func open(ui: Control) -> void:
	if ui.combat_busy: return
	if ui.game.run.get("training", false):
		preload("res://src/ui/training_navigation.gd").leave(ui)
		return
	ui.game.checkpoint()
	ui.close_modal()
	var actions: Array = [
		{"id":"GoHome", "text":"Ir al inicio", "callback":func(): ui.close_modal(); ui.screen = "home"; ui.render()}]
	if ui.active_run():
		actions.append({"id":"EndAdventure", "text":"Terminar aventura", "callback":func(): confirm_end(ui)})
	actions.append({"id":"ResumeAdventure", "text":"Volver", "callback":ui.close_modal})
	ui.overlay = Dialog.build(ui, "Un respiro", "Tu avance queda guardado automáticamente.", actions)

static func confirm_end(ui: Control) -> void:
	ui.close_modal()
	ui.overlay = Dialog.build(ui, "Terminar aventura", "No podrás continuar esta aventura. Conservás tus celdas y mejoras permanentes.", [
		{"id":"ConfirmEndAdventure", "text":"Terminar e ir al campamento", "callback":func():
			if ui.game.end_adventure():
				ui.close_modal()
				ui.open_base_camp()},
		{"id":"CancelEndAdventure", "text":"Volver", "callback":func(): open(ui)}])
