extends RefCounted
# Contrast without intercepting targets or changing gameplay.
static func attach(parent: Control, area: Rect2) -> Panel:
	var plate = Panel.new()
	plate.name = "CombatBackplate"
	plate.mouse_filter = Control.MOUSE_FILTER_IGNORE
	plate.show_behind_parent = true
	plate.position = area.position
	plate.size = area.size
	# Same inked cartouche as the buttons, with a narrow border for small icons.
	var style = preload("res://src/ui/components/dark_skin.gd").button()
	for side in [SIDE_LEFT,SIDE_TOP,SIDE_RIGHT,SIDE_BOTTOM]:
		style.set_texture_margin(side,5)
		style.set_content_margin(side,0)
	plate.add_theme_stylebox_override("panel", style)
	parent.add_child(plate)
	return plate
