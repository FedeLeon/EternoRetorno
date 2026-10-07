extends RefCounted
# Rules only. Game facade retains public API and owns checkpoints.
static func start(game: RefCounted, party: Array, seed_value: int, equipment: Dictionary, starting_floor: int) -> bool:
	if starting_floor not in [1, 2, 3]:
		return false
	if party.size() != 2 or party[0] == party[1]:
		return false
	for id in party:
		if not game.content.heroes.has(id):
			return false
	if not game.valid_equipment(party, equipment):
		return false
	if seed_value == -1:
		game.rng.randomize()
	else:
		game.rng.seed = seed_value
	var initial_seed = game.rng.seed
	game.run = {"seed": initial_seed, "rng_state": game.rng.state, "phase": "map", "party": party.duplicate(), "heroes": [], "deck": [], "nodes": game.Dungeon.create(game.rng, starting_floor), "current": -1, "visited": [], "relics": [], "combat": {}, "reward": [], "boss_defeated": false, "log": [], "new_unlocks": []}
	game.run.tactics_version = 1
	game.run.event_flags = {}
	game.run.team_relic = equipment.get("team", "")
	game.run.floor = starting_floor
	game.run.floor_count = 3
	preload("res://src/rules/adventure_extensions.gd").prepare(game)
	game.run.rooms_completed = 0
	game.run.inventory = {}
	preload("res://src/rules/adventure_extensions.gd").apply_condition(game.run)
	game.Expeditions.start(game.profile, game.run)
	for id in party:
		game.run.heroes.append({"id": id, "hp": int(game.content.heroes[id].hp), "max_hp": int(game.content.heroes[id].hp), "block": 0})
		var hero = game.run.heroes.back()
		hero.forge = game.Forge.snapshot(game.profile, id)
		hero.specialization = game.Specializations.snapshot(game.profile, id)
		hero.equipped_relic = equipment.get("team", equipment.get(id, ""))
		hero.phoenix_used = false
		if game.relic_bonus(hero, "max_hp") > 0:
			hero.max_hp += game.relic_bonus(hero, "max_hp")
			hero.hp = hero.max_hp
		for card_id in preload("res://src/rules/starter_decks.gd").deck(game.content, game.profile, id):
			game.run.deck.append({"id": card_id, "upgraded": false})
	game.profile.erase("preparation")
	game.profile.attempts += 1
	game.message = ""
	return true


static func finish(game: RefCounted, won: bool) -> void:
	if game.run.phase in ["victory", "defeat"]:
		return
	game.run.phase = "victory" if won else "defeat"
	game.Expeditions.finish(game.profile, game.run, won)
	if won:
		game.Specializations.victory(game.profile, game.run.party)
		game.profile.victories += 1
		for id in game.content.cards:
			if game.content.cards[id].locked and game.content.cards[id].owner in game.run.party and id not in game.profile.unlocked_cards:
				game.profile.unlocked_cards.append(id)
				game.run.new_unlocks.append(game.content.cards[id].name)
	preload("res://src/rules/adventure_extensions.gd").settle(game, won)
	game.profile.history.push_front({"won": won, "party": game.run.party.duplicate(), "rooms": int(game.run.get("rooms_completed", 0)) + game.run.visited.size(), "seed": game.run.seed, "deck":game.run.deck.duplicate(true), "relics":game.run.relics.duplicate(), "killer":game.run.get("killer", ""), "summary":game.run.get("adventure_summary", {}).duplicate(true), "floor":game.run.get("floor", 1), "abandoned":game.run.get("abandoned", false)})
	if game.profile.history.size() > 30:
		game.profile.history.resize(30)
	# A concluded run only retains its summary, not its acquired deck or relics.
	game.run.summary_cards = game.run.deck.size()
	game.run.inventory = {}
	for hero in game.run.heroes:
		hero.equipped_relic = ""
		hero.turn_strength = 0
		hero.turn_magic = 0
	game.run.deck = []
	game.run.tactics_version = 1
	game.run.event_flags = {}
	game.run.team_relic = ""
	game.run.relics = []
	game.run.combat = {}
	game.run.reward = []


