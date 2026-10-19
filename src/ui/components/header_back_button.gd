extends RefCounted
## One consistent return affordance for reversible screens; gameplay phases have no back.
static func build(ui: Control) -> void:
	if not ui.navigation.can_return(ui): return
	var button = ui.button("",24,22,56,40,ui.back)
	button.name = "HeaderBack"
	button.tooltip_text = "Volver a la vista anterior"
	button.icon = preload("res://assets/ui/arrow_left.svg")
	button.expand_icon = true
	button.icon_alignment = HORIZONTAL_ALIGNMENT_CENTER
	button.add_theme_constant_override("icon_max_width",26)
	button.z_index = 60
