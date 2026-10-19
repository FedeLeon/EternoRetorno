extends RefCounted
## Battle bonuses read the adventure snapshot; old saves have no companion.
const DEFINITIONS = preload("res://data/pets.json")

static func definitions() -> Dictionary:
	return DEFINITIONS.data

static func valid(id: String) -> bool:
	return id == "" or definitions().has(id)

static func opening_bonus(run: Dictionary, kind: String) -> int:
	if int(run.get("combat", {}).get("turn", 0)) != 1:
		return 0
	return int(definitions().get(run.get("pet", ""), {}).get(kind, 0))
