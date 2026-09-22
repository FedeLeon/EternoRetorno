extends RefCounted
# Temporary development entry point. Remove this picker to restore floor 1 starts.
static func open(ui: Control, start: Callable) -> void:
	ui.close_modal()
	ui.overlay = preload("res://src/ui/components/dialog_view.gd").build(ui,
		"Elegí la mazmorra · Desarrollo",
		"Selector temporal para pruebas.\nSe eliminará en la versión final del juego.", [
			{"id":"StartDungeon1", "text":"Mazmorra 1 · Cripta", "callback":func(): start.call(1)},
			{"id":"StartDungeon2", "text":"Mazmorra 2 · Bosque", "callback":func(): start.call(2)},
			{"id":"CancelDungeonChoice", "text":"Volver", "callback":ui.close_modal},
		])
