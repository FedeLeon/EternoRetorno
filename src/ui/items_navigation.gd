extends RefCounted
# Bridges the bag snapshot to the game's existing validation and checkpoint API.
static func build(ui: Control) -> void:
	var targets: Array = []
	if ui.game.content.items.has(ui.selected_item):
		var item = ui.game.content.items[ui.selected_item]
		for index in ui.game.item_targets(ui.selected_item):
			var title = "Equipo"
			var portraits: Array = []
			if item.target == "enemy":
				var enemy = ui.game.content.enemies[ui.game.run.combat.enemies[index].id]
				title = enemy.name
				portraits.append(enemy_portrait(enemy.visual))
			elif item.target != "team":
				var hero = ui.game.run.heroes[index].id
				title = ui.game.content.heroes[hero].name
				portraits.append(preload("res://src/ui/components/refuge_portrait.gd").portrait(hero, true))
			else:
				for hero in ui.game.run.heroes:
					portraits.append(preload("res://src/ui/components/refuge_portrait.gd").portrait(hero.id, true))
			targets.append({"index": index, "name": title, "portraits": portraits})
	preload("res://src/ui/screens/items_screen.gd").build(ui, ui.game.content.items, ui.game.run.get("inventory", {}), ui.selected_item, targets, ui.game.run.phase == "combat", {
		"back": ui.continue_run,
		"select": func(id): ui.selected_item = id; ui.render(),
		"consume": func(index):
			if ui.game.use_item(ui.selected_item, index):
				ui.audio.play_sfx("heal" if ui.game.content.items[ui.selected_item].get("effect", "") in ["heal", "revive"] else "confirm")
				ui.selected_item = ""
				ui.continue_run()
	})

static func enemy_portrait(visual: String) -> Texture2D:
	var source: Texture2D = load("res://assets/enemies/hd/%s.png" % visual)
	var crop = AtlasTexture.new()
	crop.atlas = source
	crop.region = Rect2(source.get_image().get_used_rect())
	return crop
