extends SceneTree
const Pack = preload("res://scripts/sketchbook_sheet_packer.gd")
func _initialize() -> void:
	var jobs: Array = JSON.parse_string(FileAccess.get_file_as_string("res://docs/combat_refinement/enemy_jobs.json"))
	var manifest: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://docs/art_direction/postapocalyptic/assets.json"))
	for job in jobs:
		var poses = Pack.actor_cells("res://" + job.source, 4, 2)
		if poses.size() != 8: push_error("Invalid enemy bank: " + job.id); quit(1); return
		var ratio = 1000.0
		for pose in poses: ratio = minf(ratio, minf(228.0 / pose.get_width(), 228.0 / pose.get_height()))
		var atlas = Pack.pack(poses, 8, 256, ratio, 240)
		for kind in ["animations", "hd"]:
			var path = "assets/enemies/%s/%s.png" % [kind, job.id]
			Pack.save(atlas if kind == "animations" else atlas.get_region(Rect2i(0, 0, 256, 256)), "res://" + path)
			manifest[path] = {"sha256":FileAccess.get_sha256("res://" + path), "source":job.source, "source_sha256":FileAccess.get_sha256("res://" + job.source), "style":"postapocalyptic_comic", "fluid_revision":1, "processing":"8 authored poses, adaptive gutters, uniform proportional scale, opaque feet at 240"}
		print("EXPRESSIVE ENEMY: ", job.id)
	FileAccess.open("res://docs/art_direction/postapocalyptic/assets.json", FileAccess.WRITE).store_string(JSON.stringify(manifest, "\t") + "\n")
	quit()
