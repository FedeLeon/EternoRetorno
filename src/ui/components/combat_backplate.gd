extends RefCounted
# Contrast without intercepting targets or changing gameplay.
static func attach(parent: Control, area: Rect2) -> Panel:
	var plate = Panel.new()
	plate.name = "CombatBackplate"
	plate.mouse_filter = Control.MOUSE_FILTER_IGNORE
	plate.show_behind_parent = true
	plate.position = area.position
	plate.size = area.size
	var style = StyleBoxFlat.new()
	style.bg_color = Color(0.025, 0.035, 0.055, 0.65)
	style.set_corner_radius_all(5)
	plate.add_theme_stylebox_override("panel", style)
	parent.add_child(plate)
	return plate
