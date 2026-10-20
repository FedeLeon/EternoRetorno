extends RefCounted
# Dispatches validated rules; Game performs the single checkpoint afterwards.
static func transact(game: RefCounted, action: String, payload: Dictionary) -> bool:
	match action:
		"boss_objective": return preload("res://src/rules/boss_mechanics.gd").player_action(game)
		"boss_relic": return preload("res://src/rules/boss_rewards.gd").choose(game, payload.get("id", ""))
		"cleanse": return preload("res://src/rules/adventure_choices.gd").cleanse(game)
	return false
