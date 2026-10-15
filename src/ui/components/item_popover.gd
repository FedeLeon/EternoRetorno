extends RefCounted
# Persistent anchored popup outside the item ring. Buttons invoke supplied actions.
static func build(ui: Control, item: Dictionary, amount: int, targets: Array, anchor: Vector2, in_combat: bool, consume: Callable) -> void:
	var right = anchor.x >= 640
	var height = 350 if not targets.is_empty() else 236
	var origin = Vector2(918 if right else 22, clampf(anchor.y - 100, 105, 635 - height))
	var panel = ui.panel(origin.x, origin.y, 340, height)
	panel.name = "ItemPopover"
	preload("res://src/ui/components/modal_frame.gd").decorate(panel)
	ui.label_at(item.name, 20, 20, 300, 54, 21, ui.GOLD, panel).horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	var description = ui.label_at(item.description, 24, 79, 292, 62, 18, ui.TEXT, panel)
	description.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	var font_size = 18
	while font_size > 14 and description.get_theme_font("font").get_multiline_string_size(item.description, HORIZONTAL_ALIGNMENT_CENTER, 292, font_size).y > 62:
		font_size -= 1
	description.add_theme_font_size_override("font_size", font_size)
	if targets.is_empty():
		var reason = "Se usa durante el combate" if not in_combat else "No hay un objetivo válido"
		var unavailable = ui.button("Consumir", 28, 168, 284, 42, func(): pass, false, panel)
		unavailable.name = "ConsumeUnavailable"
		if amount > 0:
			ui.label_at(reason, 22, 142, 296, 24, 15, ui.MUTED, panel).horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	else:
		var width = (292.0 - (targets.size() - 1) * 8) / targets.size()
		for i in range(targets.size()):
			var target = targets[i]
			var button = ui.button("", 24 + i * (width + 8), 157, width, 166, func(): consume.call(target.index), true, panel)
			button.name = "Consume_%d" % target.index
			button.tooltip_text = ("Usar contra " if item.target == "enemy" else "Consumir · ") + target.name
			var portraits: Array = target.get("portraits", [])
			for j in range(portraits.size()):
				var picture = TextureRect.new()
				picture.name = "TargetPortrait%d" % j
				picture.texture = portraits[j]
				picture.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
				picture.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
				picture.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
				picture.mouse_filter = Control.MOUSE_FILTER_IGNORE
				var portrait_width = (width - 12) / maxi(1, portraits.size())
				ui.rect(picture, 6 + j * portrait_width, 6, portrait_width, 94, button)
			ui.label_at(target.name, 4, 103, width - 8, 34, 14 if targets.size() < 3 else 12, ui.TEXT, button).horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
			ui.label_at("Usar" if item.target == "enemy" else "Consumir", 4, 140, width - 8, 22, 14, ui.GOLD, button).horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	var pointer = Polygon2D.new()
	var y = clampf(anchor.y - origin.y, 28, height - 28)
	var x = 0 if right else 340
	pointer.polygon = PackedVector2Array([Vector2(x, y - 8), Vector2(x - 12 if right else x + 12, y), Vector2(x, y + 8)])
	pointer.color = ui.GOLD
	panel.add_child(pointer)
