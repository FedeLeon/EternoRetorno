extends RefCounted
# Inventory presentation only: explicit snapshot and callbacks, no gameplay mutation.
static func build(ui: Control, items: Dictionary, inventory: Dictionary, selected: String, targets: Array, in_combat: bool, actions: Dictionary) -> void:
	preload("res://src/ui/components/inventory_background.gd").build(ui)
	preload("res://src/ui/components/preparation_header.gd").build(ui, "Bolsa compartida · Objetos para el camino", actions.back, -1, "Volver")
	var ids = items.keys()
	var selected_anchor = Vector2.ZERO
	for i in range(ids.size()):
		var id = ids[i]
		var item = items[id]
		var angle = -PI / 2.0 + TAU * i / ids.size()
		var center = Vector2(640, 358) + Vector2(cos(angle), sin(angle)) * 190.0
		var button = ui.button("", center.x - 52, center.y - 52, 104, 104, func(): actions.select.call(id))
		button.name = "Item_" + id
		button.tooltip_text = item.name
		for state in ["normal", "hover", "pressed", "disabled", "focus"]:
			button.add_theme_stylebox_override(state, StyleBoxEmpty.new())
		ui.object_icon(item.icon, 0, 0, 104, button)
		if id == selected:
			button.modulate = Color(1.2, 1.15, 1.05)
			selected_anchor = center
		var amount = preload("res://src/ui/components/number_view.gd").new()
		amount.name = "Quantity_" + id
		amount.value = int(inventory.get(id, 0))
		ui.rect(amount, center.x - 38, center.y + 43, 76, 28)
	if items.has(selected):
		preload("res://src/ui/components/item_popover.gd").build(ui, items[selected], int(inventory.get(selected, 0)), targets, selected_anchor, in_combat, actions.consume)
