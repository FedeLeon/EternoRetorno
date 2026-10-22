class_name EREnemySprite
extends "res://src/presentation/static_combat_actor.gd"
## Static machine illustrations. Kept path/class for existing screen consumers.
const CATALOG_PATH = "res://data/enemy_visuals.json"
var visual_id = "crypt_bat"
var wreck_sparks: Node2D
static func entries() -> Dictionary:
	return Catalog.dictionary(CATALOG_PATH)
func pose_catalog() -> Dictionary:
	hide_when_fallen = false
	return Catalog.dictionary("res://data/static_combat.json").enemies[visual_id].duplicate(true)

func _ready() -> void:
	super._ready()
	wreck_sparks = preload("res://src/presentation/wreckage_sparks.gd").new()
	wreck_sparks.name = "WreckageSparks"
	wreck_sparks.actor = self
	add_child(wreck_sparks)

func set_fallen(value: bool) -> void:
	super.set_fallen(value)
	if is_instance_valid(wreck_sparks): wreck_sparks.refresh()

func begin_action(action: String) -> int:
	var revision = super.begin_action(action)
	if is_instance_valid(wreck_sparks): wreck_sparks.refresh()
	return revision
