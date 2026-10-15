extends RefCounted
# Room presentation delegates every transaction to Game.
static func build(ui: Control) -> void:
	var node = ui.game.run.nodes[ui.game.run.current]
	if node.kind == "treasure":
		var view = ui.TreasureScreen.new()
		if int(ui.game.run.get("floor", 1)) >= 2: view.background_path = ui.BattleBackground.path_for(ui.game.run.seed, ui.game.run.current, ui.game.run.floor)
		view.name = "TreasureScreen"
		view.result = treasure_display(ui)
		view.open_requested.connect(func():
			if ui.game.take_treasure():
				ui.audio.play_sfx("treasure")
				view.reveal(treasure_display(ui)))
		view.continue_requested.connect(func(): ui.act(ui.game.leave_treasure))
		view.menu_requested.connect(ui.pause_menu)
		ui.rect(view, 0, 0, 1280, 720)
		return
	if node.kind == "rest":
		var view = preload("res://src/ui/screens/rest_screen.gd").new()
		if int(ui.game.run.get("floor", 1)) >= 2: view.background_path = "res://assets/forest/rest.png" if ui.game.run.floor == 2 else "res://assets/volcano/rest.png"
		view.heroes = ui.game.run.heroes.duplicate(true)
		view.can_upgrade = ui.game.run.deck.any(func(card): return not card.upgraded)
		view.heal_requested.connect(func(): ui.audio.play_sfx("heal"); ui.act(func(): ui.game.rest(true)))
		view.upgrade_requested.connect(func(): ui.upgrade_mode = true; ui.return_screen = "room"; ui.screen = "deck"; ui.render())
		view.menu_requested.connect(ui.pause_menu)
		ui.rect(view, 0, 0, 1280, 720)
		if not ui.game.run.get("curses", []).is_empty():
			ui.button("Limpiar una avería", 482, 82, 316, 44, func(): ui.act(func(): ui.game.polish_action("cleanse")))
		return
	if node.kind == "event":
		var view = preload("res://src/ui/screens/encounter_screen.gd").new()
		view.event_id = node.event
		view.event = preload("res://src/rules/adventure_choices.gd").definition(ui.game, node.event)
		if view.event.is_empty(): view.event = ui.game.content.events[node.event].duplicate(true)
		else: view.event_id = view.event.background
		var chains = {"forest_hunter":"Además, las provisiones esconden una contraseña de descuento para el mercader errante.", "forest_spirit":"Además, el siguiente descanso restaurará 5 PV extra.", "library":"Además, el siguiente cofre ocultará otra ampolla de curación."}
		if chains.has(node.event): view.event.text += " " + chains[node.event]
		if node.event == "lava_bridge": view.can_offer = ui.game.run.heroes.all(func(h): return h.hp > 8)
		if node.event == "altar":
			view.can_offer = ui.game.run.heroes.all(func(h): return h.hp > 5) and ui.game.run.deck.any(func(c): return not c.upgraded)
		view.choice_requested.connect(func(index): ui.act(func(): ui.game.choose_event(index)))
		view.menu_requested.connect(ui.pause_menu)
		ui.rect(view, 0, 0, 1280, 720)

static func treasure_display(ui: Control) -> Dictionary:
	var state = ui.game.Treasure.state(ui.game.run.treasure)
	var data = ui.game.content.items.get(state.get("item", ""), {})
	if state.has("legacy_relic"):
		data = ui.game.content.relics.get(state.legacy_relic, {})
	var text = data.get("description", "")
	if state.get("opened", false):
		if state.has("legacy_relic"):
			text += "\nComponente conservada de tu partida anterior."
		else:
			text += "\nAñadido a la bolsa: 1."
		if state.trapped:
			text += "\n¡Era una trampa!"
			for i in range(state.losses.size()):
				text += "\n%s: −%d de vida." % [ui.game.content.heroes[ui.game.run.heroes[i].id].name, state.losses[i]]
	return {"opened": state.opened, "trapped": state.trapped, "title": data.get("name", "Cofre vacío"), "description": text, "icon": data.get("icon", -1)}

