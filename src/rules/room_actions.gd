extends RefCounted
# Room rules and transitions; the facade saves accepted transactions.
static func take_treasure(game: RefCounted) -> bool:
	if not room_is(game, "treasure") or not game.Treasure.open(game.run):
		return false
	game.Expeditions.add(game.run, "treasures")
	return true

static func leave_treasure(game: RefCounted) -> bool:
	if not room_is(game, "treasure") or not game.Treasure.state(game.run.treasure).get("opened", false):
		return false
	game.run.phase = "map"
	return true

static func room_is(game: RefCounted, kind: String) -> bool:
	return not game.run.is_empty() and game.run.phase == "room" and game.run.nodes[game.run.current].kind == kind

static func rest(game: RefCounted, heal: bool, card_index: int = -1, variant: String = "power") -> bool:
	if not room_is(game, "rest"):
		return false
	if heal:
		var extra = preload("res://src/rules/travel_encounters.gd").rest_bonus(game)
		for h in game.run.heroes:
			h.hp = mini(h.max_hp, h.hp + int(ceil(h.max_hp * 0.3)) + extra)
	else:
		if card_index < 0 or card_index >= game.run.deck.size() or game.run.deck[card_index].upgraded:
			return false
		var choices = preload("res://src/rules/card_upgrades.gd").choices(game.content.cards[game.run.deck[card_index].id])
		if not choices.any(func(choice): return choice.id == variant): return false
		game.run.deck[card_index].upgraded = true
		game.run.deck[card_index].upgrade_variant = variant
		if game.run.get("polish_version",0)>0: game.run.deck[card_index].upgrade_rules = 2
		game.Expeditions.add(game.run, "upgrades")
	game.run.phase = "map"
	return true

static func choose_event(game: RefCounted, index: int) -> bool:
	if game.run.get("phase", "") == "merchant" and index == 1: return game.merchant_action("leave")
	if not room_is(game, "event") or index not in [0, 1]:
		return false
	var event_id = game.run.nodes[game.run.current].event
	if event_id.begins_with("pact_") or event_id.begins_with("pair_"):
		if not preload("res://src/rules/adventure_choices.gd").choose(game, event_id, index): return false
		return true
	if event_id not in ["well", "altar", "library"]:
		var applied = preload("res://src/rules/expanded_events.gd").choose(game, event_id, index)
		if applied:
			if index == 0: preload("res://src/rules/travel_encounters.gd").chain(game, event_id)
		return applied
	if index == 0:
		match event_id:
			"well":
				for h in game.run.heroes:
					h.hp = mini(h.max_hp, h.hp + 8)
			"altar":
				for h in game.run.heroes:
					if h.hp <= 5:
						return false
				var candidates: Array = []
				for i in range(game.run.deck.size()):
					if not game.run.deck[i].upgraded:
						candidates.append(i)
				if candidates.is_empty():
					return false
				for h in game.run.heroes:
					h.hp -= 5
				game.run.deck[candidates[game.rng.randi_range(0, candidates.size() - 1)]].upgraded = true
			"library":
				preload("res://src/rules/travel_encounters.gd").chain(game, event_id)
				game._make_reward()
				return true
	game.run.phase = "map"
	return true

static func descend(game: RefCounted) -> bool:
	if game.run.is_empty() or game.run.phase != "map" or not game.run.boss_defeated:
		return false
	if int(game.run.get("floor", 1)) < int(game.run.get("floor_count", 1)):
		preload("res://src/rules/dungeon_progression.gd").advance(game.run, game.rng)
		preload("res://src/rules/adventure_choices.gd").prepare(game)
	else:
		game._finish(true)
	return true

