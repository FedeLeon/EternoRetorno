extends RefCounted
# Rules only. Game facade retains public API and owns checkpoints.
static func check_end(game: RefCounted) -> bool:
	if game.run.phase != "combat": return false
	if game.run.get("training", false):
		for hero in game.run.heroes:
			if hero.hp <= 0: hero.hp = hero.max_hp
		for enemy in game.run.combat.enemies:
			if enemy.hp <= 0: enemy.hp = enemy.max_hp
		return false
	if game.living_heroes().is_empty():
		game._finish(false)
		return true
	game._remove_inactive()
	preload("res://src/rules/boss_mechanics.gd").sustain(game)
	var surviving = false
	for enemy in game.run.combat.enemies:
		if enemy.hp > 0:
			surviving = true
			var definition: Dictionary = game.content.enemies[enemy.id]
			if definition.get("boss", false) and enemy.hp <= enemy.max_hp / 2 and not enemy.get("enraged", false):
				var previous_target = enemy.intent.get("target", 0)
				enemy.intent = preload("res://src/rules/adventure_extensions.gd").intent(enemy, definition, game.run.combat.turn, game.run.combat.enemies)
				enemy.intent.target = previous_target
				if game.run.get("polish_version",0)>0:
					preload("res://src/rules/combat_depth.gd").plan(game,enemy,enemy.intent)
					preload("res://src/rules/boss_mechanics.gd").plan(game,enemy,enemy.intent)
	if surviving: return false
	preload("res://src/rules/combat_telemetry.gd").battle(game)
	game.Expeditions.add(game.run, "battles")
	var room_kind = game.run.nodes[game.run.current].kind
	if room_kind == "elite": game.Expeditions.add(game.run, "elites")
	if room_kind == "boss": game.Expeditions.add(game.run, "bosses")
	if not game.run.combat.get("hero_fell", true): game.Expeditions.add(game.run, "clean_battles")
	for h in game.run.heroes:
		if h.hp <= 0:
			h.hp = maxi(1, int(ceil(h.max_hp * 0.25)))
		if "chalice" in game.run.relics:
			h.hp = mini(h.max_hp, h.hp + 3)
		h.hp = mini(h.max_hp, h.hp + game.RunRelics.amount(game.run, game.content.relics, "victory_heal"))
		h.block = 0
		h.turn_strength = 0
		h.turn_magic = 0
		game.Modifiers.clear(h)
	if game.run.nodes[game.run.current].has("risk"):
		game.profile.souls += 20
		game.run.inventory.healing_potion = int(game.run.inventory.get("healing_potion", 0)) + 1
	var souls_awarded = game.Progression.award(game.profile, game.run)
	preload("res://src/rules/adventure_extensions.gd").statistic(game.run, "souls", souls_awarded)
	preload("res://src/rules/adventure_extensions.gd").statistic(game.run, "battles")
	if room_kind in ["elite", "boss"]: preload("res://src/rules/adventure_extensions.gd").statistic(game.run, "elites" if room_kind == "elite" else "bosses")
	var kind = game.run.nodes[game.run.current].kind
	if kind == "elite":
		if "hourglass" not in game.profile.unlocked_relics:
			game.profile.unlocked_relics.append("hourglass")
			game.run.new_unlocks.append(game.content.relics.hourglass.name)
		var relic = game._roll_relic()
		if game.RunRelics.grant(game.run, game.content.relics, relic):
			game.run.reward_relic = relic
	if kind == "boss":
		game.run.boss_defeated = true
	game.Forge.Materials.award(game.profile, game.run)
	game._make_reward()
	return true


static func make(game: RefCounted) -> void:
	var pool: Array = []
	for id in game.content.cards:
		var c = game.content.cards[id]
		if c.owner in game.run.party and game.Progression.available(game.profile, c):
			pool.append({"id": id, "upgraded": false})
	game._shuffle(pool)
	game.run.reward = pool.slice(0, 3)
	for hero in game.run.heroes:
		if game.relic_bonus(hero, "reward") > 0:
			for offered in game.run.reward:
				if game.content.cards[offered.id].owner == hero.id:
					offered.upgraded = true
					break
	game.run.phase = "reward"
	preload("res://src/rules/combat_telemetry.gd").offers(game)


static func choose(game: RefCounted, index: int) -> bool:
	if game.run.is_empty() or game.run.phase != "reward" or index < -1 or index >= game.run.reward.size():
		return false
	preload("res://src/rules/combat_telemetry.gd").picked(game, index)
	if index >= 0:
		game.run.deck.append(game.run.reward[index].duplicate(true))
	else:
		game.profile.souls += 12
		preload("res://src/rules/adventure_extensions.gd").statistic(game.run, "souls", 12)
	game.run.reward = []
	game.run.reward_relic = ""
	game.run.reward_salvage = {}
	game.run.combat = {}
	game.run.phase = "map"
	if game.run.get("polish_version", 0) > 0 and game.run.boss_defeated: preload("res://src/rules/boss_rewards.gd").prepare(game)
	return true


