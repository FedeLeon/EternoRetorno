extends RefCounted
# Dispatches validated rules; Game performs the single checkpoint afterwards.
static func transact(game: RefCounted, action: String, payload: Dictionary) -> bool:
	match action:
		"boss_objective": return preload("res://src/rules/boss_mechanics.gd").player_action(game)
		"boss_relic": return preload("res://src/rules/boss_rewards.gd").choose(game, payload.get("id", ""))
		"project": return preload("res://src/rules/building_projects.gd").buy(game.profile, payload.get("id", ""))
		"reserve": return preload("res://src/rules/building_projects.gd").reserve(game, payload.get("id", ""))
		"refresh": return preload("res://src/rules/building_projects.gd").refresh(game)
		"scout": return preload("res://src/rules/building_projects.gd").scout(game)
		"cleanse": return preload("res://src/rules/adventure_choices.gd").cleanse(game)
	return false
