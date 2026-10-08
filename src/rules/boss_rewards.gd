extends RefCounted
static func prepare(game: RefCounted) -> void:
	game.run.boss_offers = game.content.relics.keys().filter(func(id): return game.content.relics[id].get("boss_only", false) and int(game.content.relics[id].floor) == int(game.run.get("floor",1)) and id not in game.run.relics)
	game.run.phase = "boss_reward" if not game.run.boss_offers.is_empty() else "map"

static func choose(game: RefCounted, id: String) -> bool:
	if game.run.get("phase", "") != "boss_reward" or id not in game.run.get("boss_offers", []): return false
	if not game.RunRelics.grant(game.run, game.content.relics, id): return false
	var discovered: Array = game.profile.get_or_add("boss_relics",[])
	if id not in discovered: discovered.append(id)
	game.run.erase("boss_offers")
	game.run.phase = "map"
	# Grant and floor transition share Game's checkpoint; no intermediate map
	# or extra staircase click can replay the reward after resuming a save.
	if int(game.run.get("floor", 1)) < int(game.run.get("floor_count", 1)):
		return preload("res://src/rules/room_actions.gd").descend(game)
	return true
