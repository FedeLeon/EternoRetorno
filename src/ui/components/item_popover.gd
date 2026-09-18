extends RefCounted
# Persistent anchored popup outside the item ring. Buttons invoke supplied actions.
static func build(ui: Control, item: Dictionary, amount: int, targets: Array, anchor: Vector2, in_combat: bool, consume: Callable) -> void:
	var right = anchor.x >= 640
	var height = 236 + targets.size() * 52
	var origin = Vector2(918 if right else 22, clampf(anchor.y - 100, 105, 635 - height))
	var panel = ui.panel(origin.x, origin.y, 340, height)
	panel.name = "ItemPopover"
	preload("res://src/ui/components/modal_frame.gd").decorate(panel)
	ui.label_at(item.name, 20, 20, 300, 54, 21, ui.GOLD, panel).horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	ui.label_at(item.description, 24, 79, 292, 62, 18, ui.TEXT, panel).horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	if targets.is_empty():
		var reason = "Se usa durante el combate" if not in_combat else "No hay un objetivo válido"
		var unavailable = ui.button("Consumir", 28, 168, 284, 42, func(): pass, false, panel)
		unavailable.name = "ConsumeUnavailable"
		if amount > 0:
			ui.label_at(reason, 22, 142, 296, 24, 15, ui.MUTED, panel).horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	else:
		for i in range(targets.size()):
			var target = targets[i]
			var caption = "Consumir" if target.name == "Equipo" else "Consumir · " + target.name
			var button = ui.button(caption, 24, 175 + i * 52, 292, 46, func(): consume.call(target.index), true, panel)
			button.name = "Consume_%d" % target.index
	var pointer = Polygon2D.new()
	var y = clampf(anchor.y - origin.y, 28, height - 28)
	var x = 0 if right else 340
	pointer.polygon = PackedVector2Array([Vector2(x, y - 8), Vector2(x - 12 if right else x + 12, y), Vector2(x, y + 8)])
	pointer.color = ui.GOLD
	panel.add_child(pointer)
