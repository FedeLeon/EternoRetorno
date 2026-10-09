class_name ERDungeon
extends RefCounted

# Legacy coordinates remain for adventures saved before the extended layout.
const POSITIONS = [Vector2(86, 418), Vector2(58, 254), Vector2(162, 315), Vector2(154, 100), Vector2(315, 56), Vector2(321, 152), Vector2(502, 102), Vector2(594, 229), Vector2(485, 243), Vector2(487, 405), Vector2(306, 384), Vector2(317, 262)]
const LABELS = {"combat": "Combate", "event": "Encuentro", "treasure": "Tesoro", "elite": "Élite", "rest": "Descanso", "boss": "Guardián"}

static func definition(floor_number: int) -> Dictionary:
	return preload("res://src/data/json_catalog.gd").dictionary("res://data/dungeons.json")[str(floor_number)]

static func create(rng: RandomNumberGenerator, floor_number: int = 1) -> Array:
	return preload("res://src/rules/dungeon_generator.gd").create(rng, floor_number, definition(floor_number))

static func map_position(node: Dictionary) -> Vector2:
	if node.has("position"):
		return Vector2(node.position[0], node.position[1])
	return POSITIONS[node.id] * Vector2(1.7, 1) + Vector2(100, 145)
