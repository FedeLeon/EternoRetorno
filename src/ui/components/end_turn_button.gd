extends RefCounted
static func decorate(button: Button) -> void:
	button.name = "EndTurn"
	button.add_theme_font_size_override("font_size", 16)
	var plate = AtlasTexture.new()
	plate.atlas = load("res://assets/ui/end_turn.png")
	# Trim the generated transparent canvas; retain the complete pointed border.
	plate.region = Rect2(11, 177, 1752, 500)
	for state in ["normal", "hover", "pressed", "disabled"]:
		var style = StyleBoxTexture.new()
		style.texture = plate
		style.modulate_color = Color("d8c7ef") if state == "hover" else (Color("887d9a") if state == "pressed" else Color.WHITE)
		button.add_theme_stylebox_override(state, style)
