extends RefCounted
# Action feedback remains readable without covering cards or footer navigation.
static func show(ui: Control, message: String) -> void:
	var panel = PanelContainer.new()
	panel.name = "ActionToast"
	panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	panel.z_index = 190
	panel.add_theme_stylebox_override("panel",preload("res://src/ui/components/dark_skin.gd").dialog())
	# Building actions belong beside the attendant, clear of the cards on the right.
	var beside_attendant = ui.screen in ["market","forge","church","expeditions","merchant"]
	ui.rect(panel,48 if beside_attendant else 360,132 if ui.screen == "merchant" else 105,430 if beside_attendant else 560,76 if beside_attendant else 65)
	var label = Label.new()
	label.text = message
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.add_theme_color_override("font_color",Color("f1c2b0"))
	label.add_theme_font_size_override("font_size",18)
	panel.add_child(label)
	var fade = panel.create_tween().set_ignore_time_scale(true)
	fade.tween_interval(3.5)
	fade.tween_property(panel,"modulate:a",0.0,0.4)
	fade.tween_callback(panel.queue_free)
