extends RefCounted
## Compact read-only inspection. Long effect lists scroll inside the frame.
static func open(ui: Control, title: String, rows: Array[Dictionary]) -> void:
	ui.close_modal()
	var overlay = Control.new()
	overlay.name = "EnemyInspection"
	overlay.z_as_relative = false
	overlay.z_index = 200
	ui.add_child(overlay)
	overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	ui.overlay = overlay
	var shade = ColorRect.new()
	shade.color = Color(0.02, 0.025, 0.04, 0.55)
	ui.rect(shade, 0, 0, 1280, 720, overlay)
	var font = preload("res://src/ui/components/polish_theme.gd").BODY
	var font_size = roundi(18 * preload("res://src/presentation/preferences.gd").text_scale())
	var heights: Array[float] = []
	var total = 0.0
	for row in rows:
		var height = maxf(36, font.get_multiline_string_size(row.text, HORIZONTAL_ALIGNMENT_LEFT, 444, font_size).y + 8)
		heights.append(height)
		total += height
	total += maxi(0, rows.size() - 1) * 8
	var body_height = minf(300, total)
	var height = body_height + 140
	var panel = ui.panel(360, (720 - height) / 2, 560, height, ui.GOLD, overlay)
	panel.name = "InspectionFrame"
	preload("res://src/ui/components/modal_frame.gd").decorate(panel)
	var heading = ui.label_at(title, 20, 14, 520, 44, 24, ui.GOLD, panel)
	heading.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	var scroll = ScrollContainer.new()
	scroll.name = "InspectionRows"
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	ui.rect(scroll, 20, 68, 520, body_height, panel)
	var contents = VBoxContainer.new()
	contents.custom_minimum_size.x = 500
	contents.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	contents.add_theme_constant_override("separation", 8)
	scroll.add_child(contents)
	for i in range(rows.size()):
		var row = HBoxContainer.new()
		row.name = rows[i].id
		row.custom_minimum_size.y = heights[i]
		row.add_theme_constant_override("separation", 12)
		contents.add_child(row)
		var icon = TextureRect.new()
		icon.name = "Icon"
		icon.texture = load(rows[i].icon)
		icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		icon.custom_minimum_size = Vector2(32, 32)
		icon.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
		row.add_child(icon)
		var text = ui.label_at(rows[i].text, 0, 0, 444, heights[i], font_size, ui.TEXT, row)
		text.add_theme_font_size_override("font_size", font_size)
		text.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var back = ui.button("Volver", 190, height - 54, 180, 38, ui.close_modal, true, panel)
	back.name = "CloseInspection"
	back.grab_focus()
