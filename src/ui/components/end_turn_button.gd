extends RefCounted
static func decorate(button: Button) -> void:
	button.set_script(preload("res://src/ui/components/round_button.gd"))
	button.name = "EndTurn"
	button.add_theme_font_size_override("font_size", 17)
	for state in ["normal", "hover", "pressed", "disabled"]:
		var style = StyleBoxTexture.new()
		style.texture = preload("res://assets/ui/end_turn_round.png")
		style.modulate_color = Color("d8c7ef") if state == "hover" else (Color("887d9a") if state == "pressed" or state == "disabled" else Color.WHITE)
		button.add_theme_stylebox_override(state, style)
	var focus = StyleBoxFlat.new()
	focus.bg_color = Color.TRANSPARENT
	focus.border_color = Color("8debdc")
	focus.set_border_width_all(2)
	focus.set_corner_radius_all(68)
	button.add_theme_stylebox_override("focus", focus)
