extends RefCounted
## One face-down card is excluded from play, and can be recovered before ending.
static func can_reserve(game: RefCounted, index: int) -> bool:
	if game.run.is_empty() or game.run.get("phase", "") != "combat": return false
	var battle: Dictionary = game.run.combat
	if not battle.get("reserved", []).is_empty(): return false
	if index < 0 or index >= battle.hand.size(): return false
	var owner: int = game.owner_index(battle.hand[index])
	return game.run.heroes[owner].hp > 0 and not preload("res://src/rules/boss_mechanics.gd").trapped(game, owner)

static func reserve(game: RefCounted, index: int) -> bool:
	if not can_reserve(game, index): return false
	var battle: Dictionary = game.run.combat
	battle.reserved_index = index
	battle.reserved = [battle.hand.pop_at(index)]
	battle.reserve_used = true
	return true

static func can_unreserve(game: RefCounted) -> bool:
	return not game.run.is_empty() and game.run.get("phase", "") == "combat" and not game.run.combat.get("reserved", []).is_empty()

static func unreserve(game: RefCounted) -> bool:
	if not can_unreserve(game): return false
	var battle: Dictionary = game.run.combat
	var index = clampi(int(battle.get("reserved_index", 0)), 0, battle.hand.size())
	battle.hand.insert(index, battle.reserved[0])
	battle.reserved = []
	battle.reserve_used = false
	battle.erase("reserved_index")
	return true

static func before_remove(battle: Dictionary, index: int) -> void:
	if not battle.get("reserved", []).is_empty() and index < int(battle.get("reserved_index", 0)):
		battle.reserved_index -= 1

static func restore(game: RefCounted) -> void:
	var battle: Dictionary = game.run.combat
	for instance in battle.get("reserved", []):
		if game.run.heroes[game.owner_index(instance)].hp > 0:
			battle.hand.append(instance)
		else:
			battle.inactive.append(instance)
	battle.reserved = []
	battle.reserve_used = false
	battle.erase("reserved_index")
