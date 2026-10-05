extends RefCounted
# Bridges the bag snapshot to the game's existing validation and checkpoint API.
static func build(ui: Control) -> void:
	var targets: Array = []
	if ui.game.content.items.has(ui.selected_item):
		var item = ui.game.content.items[ui.selected_item]
		for index in ui.game.item_targets(ui.selected_item):
			var title = "Equipo"
			if item.target == "enemy":
				title = ui.game.content.enemies[ui.game.run.combat.enemies[index].id].name
			elif item.target != "team":
				title = ui.game.content.heroes[ui.game.run.heroes[index].id].name
			targets.append({"index": index, "name": title})
	preload("res://src/ui/screens/items_screen.gd").build(ui, ui.game.content.items, ui.game.run.get("inventory", {}), ui.selected_item, targets, ui.game.run.phase == "combat", {
		"back": ui.continue_run,
		"select": func(id): ui.selected_item = id; ui.render(),
		"consume": func(index):
			if ui.game.use_item(ui.selected_item, index):
				ui.audio.play_sfx("heal" if ui.game.content.items[ui.selected_item].get("heal", 0) > 0 else "confirm")
				ui.selected_item = ""
				ui.continue_run()
	})
