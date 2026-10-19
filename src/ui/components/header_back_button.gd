extends RefCounted
## One consistent return affordance for reversible screens; gameplay phases have no back.
const POSITION = Vector2(24, 20)
const SIZE = Vector2(44, 44)

static func build(ui: Control) -> void:
	if not ui.navigation.can_return(ui): return
	var button = ui.button("", POSITION.x, POSITION.y, SIZE.x, SIZE.y, ui.back)
	button.name = "HeaderBack"
	button.tooltip_text = "Volver a la vista anterior"
	button.icon = preload("res://assets/ui/arrow_left.svg")
	button.expand_icon = true
	button.icon_alignment = HORIZONTAL_ALIGNMENT_CENTER
	button.add_theme_constant_override("icon_max_width", 24)
	button.add_theme_constant_override("h_separation", 0)
	# The general button skin has wider horizontal padding. Keep this control
	# square even after Godot recalculates its minimum size for the arrow icon.
	for state in ["normal", "hover", "pressed", "disabled"]:
		var style = preload("res://src/ui/components/button_skin.gd").state_style("wood_button", state)
		for side in [SIDE_LEFT, SIDE_TOP, SIDE_RIGHT, SIDE_BOTTOM]:
			style.set_content_margin(side, 8)
		button.add_theme_stylebox_override(state, style)
	button.add_theme_stylebox_override("focus", preload("res://src/ui/components/dark_skin.gd").focus())
	button.custom_minimum_size = SIZE
	button.size = SIZE
	button.z_index = 60
