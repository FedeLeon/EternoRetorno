extends PanelContainer
var anchor: Control
static func show_for(source: Control, message: String) -> void:
	var existing = source.get_tree().get_nodes_in_group("combat_tip")
	var same = false
	for tip in existing:
		same = same or tip.anchor == source
		tip.queue_free()
	if same: return
	var popup = new()
	popup.name = "CombatTip"
	popup.anchor = source
	source.add_child(popup)
	popup.set_as_top_level(true)
	popup.z_as_relative = false
	popup.z_index = 180
	popup.add_to_group("combat_tip")
	var style = StyleBoxFlat.new()
	style.bg_color = Color("151c29")
	style.border_color = Color("c4a467")
	style.set_border_width_all(2)
	style.set_corner_radius_all(7)
	style.content_margin_left = 14
	style.content_margin_right = 14
	style.content_margin_top = 12
	style.content_margin_bottom = 12
	popup.add_theme_stylebox_override("panel", style)
	var label = Label.new()
	label.text = message
	label.custom_minimum_size = Vector2(270, 0)
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.add_theme_font_size_override("font_size", 17)
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	popup.add_child(label)
	popup.size = Vector2(298, 110)
	var bounds = source.get_viewport_rect().size
	popup.global_position = Vector2(clampf(source.global_position.x, 8, bounds.x - 306), clampf(source.global_position.y + 34, 8, bounds.y - 130))
func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed:
		if not get_global_rect().has_point(get_global_mouse_position()) and not anchor.get_global_rect().has_point(get_global_mouse_position()):
			queue_free()
