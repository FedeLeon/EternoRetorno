extends RefCounted
# Home-only utility actions; settings retains its existing screen.
static func build(ui: Control, exit_y: float) -> void:
	ui.title_button("Salir del juego", exit_y, false, func(): exit_game(ui)).name = "ExitGame"
	var options = ui.button("", 1178, 24, 70, 70, func(): ui.screen = "options"; ui.render())
	options.name = "Options"
	options.tooltip_text = "Opciones"
	var gear = TextureRect.new()
	gear.name = "SettingsGear"
	gear.texture = preload("res://assets/ui/settings.png")
	gear.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	gear.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	gear.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
	gear.mouse_filter = Control.MOUSE_FILTER_IGNORE
	ui.rect(gear, 9, 9, 52, 52, options)
	var electricity = preload("res://src/presentation/end_turn_electricity.gd").new()
	electricity.name = "Electricity"
	options.add_child(electricity)
	electricity.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)

static func exit_game(ui: Control) -> void:
	ui.game.checkpoint()
	if OS.has_feature("web"):
		ui.show_modal("Salir del juego", "Podés cerrar esta pestaña para salir del juego. Tu avance se guarda automáticamente.", "Entendido", ui.close_modal)
	else:
		ui.get_tree().quit()
