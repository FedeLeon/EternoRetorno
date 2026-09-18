extends RefCounted
# Shared camp/preparation header; souls are optional and only passed by camp.
static func build(ui: Control, title: String, menu: Callable, souls: int = -1, action_text: String = "Menú") -> void:
	var frame = ui.panel(0, 0, 1280, 84)
	frame.name = "PreparationHeader"
	frame.add_theme_stylebox_override("panel", preload("res://src/ui/components/button_skin.gd").style("header_frame"))
	ui.label_at(title, 100, 16, 723 if souls >= 0 else 998, 52, 27, ui.GOLD)
	if souls >= 0:
		preload("res://src/ui/components/soul_counter.gd").attach(ui, souls, Vector2(810 if action_text == "Campamento" else 866, 16))
	ui.button(action_text, 1070 if action_text == "Campamento" else 1134, 18, 166 if action_text == "Campamento" else 110, 48, menu)
