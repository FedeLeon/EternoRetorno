class_name ERDungeon
extends RefCounted

# Legacy coordinates remain for adventures saved before the extended layout.
const POSITIONS = [Vector2(86, 418), Vector2(58, 254), Vector2(162, 315), Vector2(154, 100), Vector2(315, 56), Vector2(321, 152), Vector2(502, 102), Vector2(594, 229), Vector2(485, 243), Vector2(487, 405), Vector2(306, 384), Vector2(317, 262)]
const LABELS = {"combat": "Combate", "event": "Encuentro", "treasure": "Tesoro", "elite": "Élite", "rest": "Descanso", "boss": "Guardián"}

static func create(rng: RandomNumberGenerator) -> Array:
	var nodes: Array = []
	var common = ["rat", "skeleton", "cultist", "slime"]
	var events = ["well", "altar", "library"]
	var layout: Array = JSON.parse_string(FileAccess.get_file_as_string("res://data/dungeon_floor1.json"))
	for definition in layout:
		var i = int(definition.id)
		var kind = definition.kind
		var encounter: Array = []
		if kind == "combat":
			encounter.append(common[rng.randi_range(0, 3)])
			if int(definition.get("enemy_count", 1)) == 2:
				encounter.append(common[rng.randi_range(0, 3)])
		elif kind in ["boss", "elite"]:
			encounter.append(kind)
		var exits: Array = definition.next.map(func(value): return int(value))
		nodes.append({"id": i, "kind": kind, "next": exits, "position": definition.position.duplicate(), "encounter": encounter, "event": events[rng.randi_range(0, 2)]})
	return nodes

static func map_position(node: Dictionary) -> Vector2:
	if node.has("position"):
		return Vector2(node.position[0], node.position[1])
	return POSITIONS[node.id] * Vector2(1.7, 1) + Vector2(100, 145)
