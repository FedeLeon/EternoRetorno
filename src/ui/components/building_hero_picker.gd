extends RefCounted
# Shared entry gallery: four face portraits fill the right-side building block.
static func build(ui: Control, heroes: Dictionary, heading: String, prefix: String, selected: Callable, right_grid: bool = false, parent: Control = null) -> void:
	var target = parent if parent != null else ui.layer
	var offset = target.position if parent != null else Vector2.ZERO
	var title_position = Vector2(728,102) if right_grid else Vector2(80,126)
	title_position -= offset
	var title = ui.label_at(heading, title_position.x, title_position.y, 528 if right_grid else 1120, 48, 22 if right_grid else 27, ui.TEXT, target)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	var ids = preload("res://src/rules/hero_roster.gd").ids(heroes)
	for i in range(ids.size()):
		var id = ids[i]
		var position = Vector2(738 + (i % 2) * 264, 164 + floori(i / 2.0) * 274) if right_grid else Vector2((1280 - ids.size()*204 + 14)/2.0 + i * 204, 256)
		var dimensions = Vector2(244,254) if right_grid else Vector2.ZERO
		var card = preload("res://src/ui/components/refuge_portrait.gd").build(ui, target, id, heroes[id].name, position-offset, func(): selected.call(id), right_grid, heroes[id].get("civilian",{}), dimensions)
		card.name = prefix + id
