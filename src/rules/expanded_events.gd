extends RefCounted
static func choose(game: RefCounted, id: String, choice: int) -> bool:
	var run: Dictionary = game.run
	if choice == 1:
		run.phase = "map"
		return true
	match id:
		"forest_spring":
			for hero in run.heroes: hero.hp = mini(hero.max_hp, hero.hp + (12 if "cleric" in run.party else 8))
		"forest_hunter", "forge_altar":
			run.card_event = "remove" if id == "forest_hunter" else "transform"
			run.phase = "event_cards"
			return true
		"forest_spirit":
			for hero in run.heroes: hero.hp = mini(hero.max_hp, hero.hp + (10 if "ranger" in run.party or "rogue" in run.party else 5))
			game.profile.souls += 15
			preload("res://src/rules/adventure_extensions.gd").statistic(run, "souls", 15)
		"ash_archive":
			run.card_event = "exchange"
			run.phase = "event_cards"
			return true
		"lava_bridge":
			if run.heroes.any(func(hero): return hero.hp <= 8): return false
			for hero in run.heroes: hero.hp -= 8
			game.profile.souls += 45
			preload("res://src/rules/adventure_extensions.gd").statistic(run, "souls", 45)
		_: return false
	run.phase = "map"
	return true

static func modify(game: RefCounted, index: int) -> bool:
	var run: Dictionary = game.run
	if run.get("phase", "") != "event_cards": return false
	if index < 0: run.phase = "map"; run.erase("card_event"); return true
	if index >= run.deck.size(): return false
	var owner: String = game.content.cards[run.deck[index].id].owner
	if run.card_event == "remove":
		if run.deck.size() <= 12 or run.deck.filter(func(card): return game.content.cards[card.id].owner == owner).size() <= 4: return false
		run.deck.remove_at(index)
		preload("res://src/rules/adventure_extensions.gd").statistic(run, "cards_removed")
	else:
		var candidates: Array = []
		for id in game.content.cards:
			var card = game.content.cards[id]
			if card.owner == owner and id != run.deck[index].id and card.cost <= 1 and game.Progression.available(game.profile, card): candidates.append(id)
		if candidates.is_empty(): return false
		var id = candidates[game.rng.randi_range(0, candidates.size() - 1)]
		run.deck[index] = {"id":id, "upgraded":run.card_event == "transform"}
	run.phase = "map"
	run.erase("card_event")
	return true
