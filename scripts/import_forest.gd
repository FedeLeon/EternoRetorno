extends SceneTree
const Pack = preload("res://scripts/enemy_art_import.gd")
const IDS = ["goblin_0", "goblin_2", "goblin_3", "goblin_7", "beast_0", "beast_1", "beast_5"]
func _initialize() -> void:
	for id in IDS:
		if not Pack.motion("res://docs/forest/sources/%s_motion.png" % id, "res://assets/enemies/animations/%s.png" % id) or not Pack.cutin("res://docs/forest/sources/%s_cutin.png" % id, "res://assets/comic/enemies/%s.png" % id):
			quit(1)
			return
	for name in ["combat_glade", "combat_ruins", "rest"]:
		var image = Image.load_from_file("res://docs/forest/sources/%s.png" % name)
		if image == null: continue
		image.resize(1280, 720, Image.INTERPOLATE_LANCZOS)
		image.save_png("res://assets/forest/%s.png" % name)
	quit()
