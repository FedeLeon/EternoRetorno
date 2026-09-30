extends RefCounted

static func build(ui: Control) -> void:
	var snapshot = {"achievements": preload("res://src/rules/achievements.gd").entries(ui.game.profile),
		"attempts": ui.game.profile.attempts, "victories": ui.game.profile.victories, "unlocks": [], "history": []}
	for id in ui.game.content.cards:
		var card: Dictionary = ui.game.content.cards[id]
		if not card.locked: continue
		snapshot.unlocks.append({"name": card.name, "unlocked": id in ui.game.profile.unlocked_cards,
			"requirement": "Ganá una aventura con " + ui.game.content.heroes[card.owner].name + ".",
			"icon": "res://assets/collection/icons/%s_victory.png" % card.owner})
	snapshot.unlocks.append({"name": "Reloj sin arena", "unlocked": "hourglass" in ui.game.profile.unlocked_relics,
		"requirement": "Derrotá a un élite. Primer turno: +1 de energía.", "icon": "res://assets/collection/icons/ten_victories.png"})
	for entry in ui.game.profile.history:
		var row: Dictionary = entry.duplicate(true)
		var names: Array[String] = []
		for id in row.party: names.append(ui.game.content.heroes.get(id, {"name": id}).name)
		row.party_names = " + ".join(names)
		snapshot.history.append(row)
	var view = preload("res://src/ui/screens/collection_screen.gd").new()
	view.name = "CollectionScreen"
	view.ui = ui
	view.snapshot = snapshot
	view.home = func(): ui.screen = "home"; ui.render()
	ui.rect(view, 0, 0, 1280, 720)
