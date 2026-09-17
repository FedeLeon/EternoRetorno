extends RefCounted
# Persistent, non-modal description in the free space outside the relic circle.
static func attach(ui: Control, relic: Dictionary, anchor: Vector2) -> void:
	var right_side = anchor.x >= 640 and anchor.y < 560
	var origin = Vector2(922 if right_side else 28, clampf(anchor.y - 95, 130, 439))
	var panel = ui.panel(origin.x, origin.y, 330, 190)
	panel.name = "EquipmentDescription"
	preload("res://src/ui/components/modal_frame.gd").decorate(panel)
	panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	ui.label_at(relic.name, 24, 23, 282, 42, 20, ui.GOLD, panel)
	ui.label_at(relic.description, 24, 68, 282, 96, 17, ui.TEXT, panel)
	var pointer = Polygon2D.new()
	var y = clampf(anchor.y - origin.y, 30, 160)
	var x = 0 if right_side else 330
	var tip = -12 if right_side else 342
	pointer.polygon = PackedVector2Array([Vector2(x, y - 8), Vector2(tip, y), Vector2(x, y + 8)])
	pointer.color = ui.GOLD
	panel.add_child(pointer)
