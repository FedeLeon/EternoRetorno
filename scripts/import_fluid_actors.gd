extends SceneTree
## Packs authored poses without distorting bodies or changing saved actor IDs.
const Pack = preload("res://scripts/sketchbook_sheet_packer.gd")
func _initialize() -> void:
	var jobs: Array = JSON.parse_string(FileAccess.get_file_as_string("res://docs/combat_refinement/jobs.json"))
	var manifest: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://docs/art_direction/postapocalyptic/assets.json"))
	var metrics: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://data/detailed_heroes.json"))
	for job in jobs:
		var poses = Pack.actor_cells("res://" + job.source, 4, 3)
		if poses.size() != 12: push_error("Invalid pose bank: " + job.id); quit(1); return
		var large: bool = job.action != "idle"
		var extent = Vector2.ZERO
		for pose in poses: extent = extent.max(Vector2(pose.get_size()))
		# The first pose is a full-height neutral guard in all three banks.
		var ratio = minf(float(job.body_height) / poses[0].get_height(), minf((352.0 if large else 228.0) / extent.x, (352.0 if large else 228.0) / extent.y))
		var image = Pack.pack(poses, 4, 384 if large else 256, ratio, 368 if large else 240)
		var path = "assets/heroes/%s/%s.png" % ["actions" if large else "detail", job.id]
		Pack.save(image, "res://" + path)
		if not large: metrics[job.hero].idle_height = Pack.bounds(image.get_region(Rect2i(0, 0, 256, 256)), 0.5).size.y * 0.5
		manifest[path] = {"sha256":FileAccess.get_sha256("res://" + path), "source":job.source, "source_sha256":FileAccess.get_sha256("res://" + job.source), "style":"postapocalyptic_comic", "fluid_revision":1, "processing":"12 authored poses, adaptive gutters, common proportional scale, anchored opaque feet"}
		print("FLUID ACTOR: ", job.id)
	FileAccess.open("res://data/detailed_heroes.json", FileAccess.WRITE).store_string(JSON.stringify(metrics, "\t") + "\n")
	FileAccess.open("res://docs/art_direction/postapocalyptic/assets.json", FileAccess.WRITE).store_string(JSON.stringify(manifest, "\t") + "\n")
	quit()
