extends SceneTree
const Pack = preload("res://scripts/enemy_art_import.gd")
func _initialize() -> void:
	var catalog = JSON.parse_string(FileAccess.get_file_as_string("res://data/forest_enemies.json"))
	var ids = JSON.parse_string(FileAccess.get_file_as_string("res://docs/forest/expansion/enemies.json"))
	for id in ids:
		var visual = catalog[id].visual
		if not Pack.motion("res://docs/forest/expansion/sources/%s_motion.png" % visual, "res://assets/enemies/animations/%s.png" % visual) or not Pack.cutin("res://docs/forest/expansion/sources/%s_cutin.png" % visual, "res://assets/comic/enemies/%s.png" % visual):
			printerr("Cannot pack enemy: ", id)
			quit(1)
			return
	print("Imported six forest motion sheets and six cut-ins")
	quit()
