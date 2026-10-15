extends SceneTree
## Uniform geometric packing of eight authored poses per animal.
const BASE = "res://docs/base_camp/companions/"
const INDEX = "res://docs/art_direction/postapocalyptic/"
const Pack = preload("res://scripts/sketchbook_sheet_packer.gd")
func _initialize() -> void:
	var jobs: Array = JSON.parse_string(FileAccess.get_file_as_string(BASE + "jobs.json"))
	var prepared: Dictionary = {}
	for job in jobs:
		var image = Image.new()
		if image.load_png_from_buffer(FileAccess.get_file_as_bytes("res://" + job.source)) != OK or image.detect_alpha() == Image.ALPHA_NONE:
			push_error("Missing transparent companion sheet: " + job.id)
			quit(1)
			return
		var cell: Vector2i = image.get_size() / Vector2i(4, 2)
		var poses: Array[Image] = []
		var ratio = 1000.0
		for i in range(8):
			var tile = image.get_region(Rect2i(Vector2i(i % 4, i / 4) * cell, cell))
			var area = Pack.bounds(tile)
			if area.size.x < 10 or area.size.y < 10:
				push_error("Empty companion pose: " + job.id)
				quit(1)
				return
			var pose = tile.get_region(area)
			poses.append(pose)
			ratio = minf(ratio, minf(164.0 / area.size.x, 144.0 / area.size.y))
		prepared[job.id] = Pack.pack(poses, 4, 192, ratio, 174)
	var manifest: Dictionary = JSON.parse_string(FileAccess.get_file_as_string(INDEX + "assets.json"))
	for job in jobs:
		Pack.save(prepared[job.id], "res://" + job.target)
		manifest[job.target] = {"sha256":FileAccess.get_sha256("res://" + job.target), "source":job.source, "source_sha256":FileAccess.get_sha256("res://" + job.source), "style":"postapocalyptic_comic", "tool":"image_gen.imagegen", "generation":"docs/base_camp/companions/%s.json" % job.id, "processing":"eight poses at one scale, 4x2 cells of 192px, feet baseline 174px"}
	FileAccess.open(INDEX + "assets.json", FileAccess.WRITE).store_string(JSON.stringify(manifest, "\t", false) + "\n")
	print("CAMP COMPANIONS: ", jobs.size(), " atlases / 16 poses")
	quit()
