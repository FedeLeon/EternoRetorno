extends PanelContainer

# A small anchored description; no actions, game state or persistence.
func setup(relic: Dictionary, anchor: Rect2) -> void:
	name = "RelicPopover"
	position = Vector2(clampf(anchor.position.x, 8, 932), anchor.end.y + 10)
	custom_minimum_size = Vector2(340, 0)
	size.x = 340
	z_index = 50
	var style = StyleBoxFlat.new()
	style.bg_color = Color("171d29")
	style.border_color = Color("b99b65")
	style.set_border_width_all(1)
	style.set_corner_radius_all(5)
	style.content_margin_left = 14
	style.content_margin_right = 14
	style.content_margin_top = 12
	style.content_margin_bottom = 12
	add_theme_stylebox_override("panel", style)
	var column = VBoxContainer.new()
	column.add_theme_constant_override("separation", 8)
	add_child(column)
	for caption in [relic.owner + " · " + relic.name, relic.description]:
		var label = Label.new()
		label.text = caption
		label.custom_minimum_size.x = 312
		label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		label.add_theme_font_size_override("font_size", 17)
		label.mouse_filter = Control.MOUSE_FILTER_IGNORE
		column.add_child(label)
	column.get_child(0).add_theme_color_override("font_color", Color("e5c48d"))
	var pointer = Polygon2D.new()
	pointer.polygon = PackedVector2Array([Vector2(18, 0), Vector2(28, -9), Vector2(38, 0)])
	pointer.color = Color("b99b65")
	add_child(pointer)
