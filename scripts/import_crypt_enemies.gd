extends SceneTree
const Pack = preload("res://scripts/enemy_art_import.gd")
func _initialize() -> void:
	var enemies = JSON.parse_string(FileAccess.get_file_as_string("res://data/crypt_enemies.json"))
	for enemy in enemies.values():
		var id = enemy.visual
		if not Pack.motion("res://docs/enemies/crypt_expansion/sources/%s_motion.png" % id, "res://assets/enemies/animations/%s.png" % id) or not Pack.cutin("res://docs/enemies/crypt_expansion/sources/%s_cutin.png" % id, "res://assets/comic/enemies/%s.png" % id):
			printerr("Cannot pack enemy: ", id)
			quit(1)
			return
	print("Imported six crypt motion sheets and six cut-ins")
	quit()
