extends RefCounted
# Scenery only: never tint actors, cards, particles or HUD.
const SCENERY_TINT = Color(0.77, 0.79, 0.83, 1.0)
const PATHS = ["res://assets/dungeon/combat.png", "res://assets/dungeon/combat_columns.png", "res://assets/dungeon/combat_canal.png"]
const FOREST = ["res://assets/forest/combat_glade.png", "res://assets/forest/combat_ruins.png"]

static func combat_rect(floor_number: int = 1, ground: float = 310) -> Rect2:
	# Keep the scenery's floor junction behind the actual actor baseline.
	# The central plant has a much taller wall than the maintenance arenas.
	var horizon = 0.59 if floor_number == 3 else 0.56 if floor_number == 2 else 0.59
	var top = minf(-64, (ground - 30 - horizon * 720) / (1 - horizon))
	return Rect2(0, top, 1280, 720 - top)

static func path_for(seed_value: int, node_id: int, floor_number: int = 1) -> String:
	# Stable scenery without consuming gameplay RNG or changing saved encounters.
	var paths = ["res://assets/volcano/combat.png"] if floor_number == 3 else (FOREST if floor_number == 2 else PATHS)
	return paths[posmod(posmod(seed_value, paths.size()) + node_id, paths.size())]
