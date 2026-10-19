class_name EREnemySprite
extends "res://src/presentation/static_combat_actor.gd"
## Static machine illustrations. Kept path/class for existing screen consumers.
const CATALOG_PATH = "res://data/enemy_visuals.json"
var visual_id = "crypt_bat"
static func entries() -> Dictionary:
	return Catalog.dictionary(CATALOG_PATH)
func pose_catalog() -> Dictionary:
	hide_when_fallen = true
	return Catalog.dictionary("res://data/static_combat.json").enemies[visual_id].duplicate(true)
