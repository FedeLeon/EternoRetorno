extends RefCounted
# Home-only utility actions; settings retains its existing screen.
static func build(ui: Control, exit_y: float) -> void:
	ui.title_button("Salir del juego", exit_y, false, func(): exit_game(ui)).name = "ExitGame"
	var options = ui.button("", 1178, 24, 70, 70, func(): ui.screen = "options"; ui.render())
	options.name = "Options"
	options.tooltip_text = "Opciones"
	for state in ["normal", "hover", "pressed", "focus"]:
		var style = StyleBoxFlat.new()
		style.bg_color = Color("292a30") if state in ["hover", "focus"] else Color("141822")
		style.border_color = Color("c7bbd6") if state in ["hover", "focus"] else Color("5b5568")
		style.set_border_width_all(2)
		style.set_corner_radius_all(7)
		options.add_theme_stylebox_override(state, style)
	var gear = TextureRect.new()
	gear.texture = preload("res://assets/ui/settings.svg")
	gear.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	gear.mouse_filter = Control.MOUSE_FILTER_IGNORE
	ui.rect(gear, 9, 9, 52, 52, options)

static func exit_game(ui: Control) -> void:
	ui.game.checkpoint()
	if OS.has_feature("web"):
		ui.show_modal("Salir del juego", "Podés cerrar esta pestaña para salir del juego. Tu avance se guarda automáticamente.", "Entendido", ui.close_modal)
	else:
		ui.get_tree().quit()
