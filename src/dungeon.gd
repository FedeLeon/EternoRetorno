class_name ERDungeon
extends RefCounted

# Directed acyclic graph: branches always rejoin; every route reaches node 11.
const KINDS = ["combat", "event", "combat", "treasure", "elite", "combat", "rest", "event", "combat", "combat", "rest", "boss"]
const LINKS = [[1, 2], [3], [3], [4, 5], [6], [6], [7, 8], [9], [9], [10], [11], []]
const POSITIONS = [Vector2(86, 418), Vector2(58, 254), Vector2(162, 315), Vector2(154, 100), Vector2(315, 56), Vector2(321, 152), Vector2(502, 102), Vector2(594, 229), Vector2(485, 243), Vector2(487, 405), Vector2(306, 384), Vector2(317, 262)]
const LABELS = {"combat": "Combate", "event": "Encuentro", "treasure": "Tesoro", "elite": "Élite", "rest": "Descanso", "boss": "Guardián"}

static func create(rng: RandomNumberGenerator) -> Array:
	var nodes: Array = []
	var common = ["rat", "skeleton", "cultist", "slime"]
	var events = ["well", "altar", "library"]
	for i in range(KINDS.size()):
		var encounter: Array = []
		if KINDS[i] == "combat":
			encounter.append(common[rng.randi_range(0, 3)])
			if i >= 5:
				encounter.append(common[rng.randi_range(0, 3)])
		elif KINDS[i] in ["boss", "elite"]:
			encounter.append(KINDS[i])
		nodes.append({"id": i, "kind": KINDS[i], "next": LINKS[i].duplicate(), "encounter": encounter, "event": events[rng.randi_range(0, 2)]})
	return nodes
