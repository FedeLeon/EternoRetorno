extends RefCounted
# Shared entry gallery for camp buildings, using the refuge comic portraits.
static func build(ui: Control, heroes: Dictionary, heading: String, prefix: String, selected: Callable, right_grid: bool = false) -> void:
	var title = ui.label_at(heading, 728 if right_grid else 80, 102 if right_grid else 126, 528 if right_grid else 1120, 48, 22 if right_grid else 27, ui.TEXT)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	var ids = heroes.keys()
	for i in range(ids.size()):
		var id = ids[i]
		var position = Vector2(738 + (i % 2) * 264, 164 + floori(i / 2.0) * 178) if right_grid else Vector2(35 + i * 204, 256)
		var card = preload("res://src/ui/components/refuge_portrait.gd").build(ui, ui.layer, id, heroes[id].name, position, func(): selected.call(id), right_grid)
		card.name = prefix + id
