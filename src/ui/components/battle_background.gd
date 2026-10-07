extends RefCounted
const PATHS = ["res://assets/dungeon/combat.png", "res://assets/dungeon/combat_columns.png", "res://assets/dungeon/combat_canal.png"]
const FOREST = ["res://assets/forest/combat_glade.png", "res://assets/forest/combat_ruins.png"]

static func path_for(seed_value: int, node_id: int, floor_number: int = 1) -> String:
	# Stable scenery without consuming gameplay RNG or changing saved encounters.
	var paths = ["res://assets/volcano/combat.png"] if floor_number == 3 else (FOREST if floor_number == 2 else PATHS)
	return paths[posmod(posmod(seed_value, paths.size()) + node_id, paths.size())]
