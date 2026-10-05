extends SceneTree
## Deterministic atlas packing only; drawings and alpha come from imagegen.
const Art = preload("res://scripts/enemy_art_import.gd")

func _initialize() -> void:
	var jobs = JSON.parse_string(FileAccess.get_file_as_string("res://docs/combat_expansion/prompts.json"))
	var imported = 0
	for job in jobs:
		var source = "res://docs/combat_expansion/sources/%s.png" % job.id
		if not FileAccess.file_exists(source):
			printerr("Missing source: ", job.id)
			quit(1)
			return
		var ok = false
		if job.type == "hero":
			ok = preload("res://scripts/import_hero_motion.gd").pack_hero(
				job.id,
				"res://assets/comic/motion/%s.png" % job.id)
		elif job.type == "enemy_motion":
			ok = Art.motion(source, "res://assets/enemies/animations/%s.png" % job.visual)
		else:
			ok = Art.cutin(source, "res://assets/comic/enemies/%s.png" % job.visual)
		if not ok:
			printerr("Invalid asset: ", job.id)
			quit(1)
			return
		imported += 1
	print("COMBAT EXPANSION: imported ", imported, " assets")
	quit()

