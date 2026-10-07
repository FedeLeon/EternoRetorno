extends RefCounted
# Optional run snapshots preserve old saves and never read live preferences mid-run.
static func difficulty_limit(profile: Dictionary) -> int:
	return clampi(int(profile.get("difficulty_unlocked", 1 if profile.get("victories", 0) > 0 else 0)), 0, 3)

static func prepare(game: RefCounted) -> void:
	var run: Dictionary = game.run
	run.difficulty = clampi(int(game.profile.get("preferred_difficulty", 0)), 0, difficulty_limit(game.profile))
	run.variant = game.profile.get("preferred_variant", "normal")
	if run.variant not in ["normal", "tainted", "dangerous"]: run.variant = "normal"
	run.statistics = {"battles":0, "elites":0, "bosses":0, "souls":0, "damage_taken":0, "fallen":0, "cards_removed":0}
	run.bond_variant = game.profile.get("bond_variants", {}).get(pair_key(run.party), "balanced")
	if int(game.profile.get("bonds", {}).get(pair_key(run.party), 0)) < 1: run.bond_variant = "balanced"

static func pair_key(party: Array) -> String:
	var sorted = party.duplicate(); sorted.sort()
	return "_".join(sorted)

static func strengthen(run: Dictionary, enemies: Array, _content: RefCounted) -> void:
	var tier = int(run.get("difficulty", 0))
	var danger = run.get("variant", "normal") == "dangerous"
	for enemy in enemies:
		enemy.hp = ceili(enemy.hp * (1.0 + tier * 0.06))
		enemy.max_hp = enemy.hp
		enemy.difficulty = tier
		if tier >= 2 or danger: enemy.counter_chance = true
		if run.get("variant", "normal") == "tainted": enemy.poison = 0; enemy.tainted = true

static func intent(enemy: Dictionary, definition: Dictionary, turn: int, _enemies: Array) -> Dictionary:
	var enraged = definition.get("boss", false) and enemy.hp <= enemy.max_hp / 2
	var patterns = definition.get("phase_two", definition.pattern) if enraged else definition.pattern
	var action = patterns[(turn - 1) % patterns.size()].duplicate(true)
	action.damage = int(action.get("damage", 0)) + (int(enemy.get("difficulty", 0)) if int(action.get("damage", 0)) > 0 else 0)
	if enemy.get("counter_chance", false) and turn % 3 == 0: action.counter = 4
	if enemy.get("tainted", false) and turn % 3 == 0: action.block = int(action.get("block", 0)) + 3
	enemy.enraged = enraged
	return action

static func settle(game: RefCounted, won: bool) -> void:
	var run: Dictionary = game.run
	var profile: Dictionary = game.profile
	statistic(run, "souls", int(run.get("contract_result", {}).get("reward", 0)))
	if won:
		profile.difficulty_unlocked = mini(3, maxi(difficulty_limit(profile), int(run.get("difficulty", 0)) + 1))
		if not profile.has("bonds"): profile.bonds = {}
		var key = pair_key(run.party)
		profile.bonds[key] = int(profile.bonds.get(key, 0)) + 1
	run.adventure_summary = {"party":run.party.duplicate(), "floor":run.get("floor", 1), "difficulty":run.get("difficulty", 0), "variant":run.get("variant", "normal"), "statistics":run.get("statistics", {}).duplicate(true), "relics":run.relics.duplicate(), "contract":run.get("contract_result", {}).duplicate(true), "won":won, "abandoned":run.get("abandoned", false)}

static func statistic(run: Dictionary, key: String, amount: int = 1) -> void:
	if not run.has("statistics"): run.statistics = {}
	run.statistics[key] = int(run.statistics.get(key, 0)) + amount

static func role_support(game: RefCounted, index: int, _action: Dictionary) -> void:
	var enemies: Array = game.run.combat.enemies
	var role: String = game.content.enemies[enemies[index].id].get("role", "attacker")
	if role == "protector":
		for other in range(enemies.size()):
			if other != index and enemies[other].hp > 0: enemies[other].block += 3
	elif role == "support":
		for enemy in enemies:
			if enemy.hp > 0: enemy.hp = mini(enemy.max_hp, enemy.hp + 3)

static func apply_condition(run: Dictionary) -> void:
	if run.get("variant", "normal") != "dangerous": return
	# One additional elite on every floor, regardless of the random room order.
	var candidates = run.nodes.filter(func(node): return node.kind == "combat" and node.stage in [5,6,7])
	if candidates.is_empty(): candidates = run.nodes.filter(func(node): return node.kind == "combat" and node.stage > 0)
	if candidates.is_empty(): return
	var chosen: Dictionary = candidates[0]
	chosen.kind = "elite"
	chosen.encounter = [preload("res://src/dungeon.gd").definition(run.get("floor",1)).elite]
