extends RefCounted
const PATHS = ["res://assets/dungeon/combat.png", "res://assets/dungeon/combat_columns.png", "res://assets/dungeon/combat_canal.png"]

static func path_for(seed_value: int, node_id: int) -> String:
	# Stable scenery without consuming gameplay RNG or changing saved encounters.
	return PATHS[posmod(posmod(seed_value, PATHS.size()) + node_id, PATHS.size())]
