extends "res://src/presentation/static_combat_actor.gd"
## Static civilian hero illustrations, one PNG for each action.
var hero_id = "warrior"
func pose_catalog() -> Dictionary:
	set_meta("hero_id",hero_id)
	set_meta("detailed",true)
	return Catalog.dictionary("res://data/static_combat.json").heroes[hero_id].duplicate(true)
