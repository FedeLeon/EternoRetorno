extends SceneTree
# Generated icon banks to separate HD resources; no mechanic values are authored here.
const Pack = preload("res://scripts/sketchbook_sheet_packer.gd")
var manifest: Dictionary
func _initialize() -> void:
	var ledger = "res://art_sources/art_direction/postapocalyptic/assets.json"
	manifest = JSON.parse_string(FileAccess.get_file_as_string(ledger))
	var jobs: Array = JSON.parse_string(FileAccess.get_file_as_string("res://art_sources/combat_equipment_assets/jobs.json"))
	for job in jobs:
		var image = Image.load_from_file("res://" + job.source)
		if image == null or image.detect_alpha() == Image.ALPHA_NONE:
			push_error("Expected RGBA source: " + job.id)
			quit(1)
			return
		if job.count == 1:
			install(image, job.target, job)
		else:
			var side = image.get_size() / Vector2i(3, 2)
			for i in range(job.count):
				var cell = image.get_region(Rect2i(Vector2i(i % 3, i / 3) * side, side))
				install(cell, job.target_dir + "/" + job.ids[i] + ".png", job)
	FileAccess.open(ledger, FileAccess.WRITE).store_string(JSON.stringify(manifest, "\t") + "\n")
	print("COMBAT EQUIPMENT: energy cell and 24 equipment badges")
	quit()
func install(image: Image, target: String, job: Dictionary) -> void:
	var bounds = Pack.bounds(image)
	if bounds.size == Vector2i.ZERO:
		push_error("Empty icon: " + target)
		return
	var crop = image.get_region(bounds)
	crop.convert(Image.FORMAT_RGBA8)
	var ratio = minf(480.0 / crop.get_width(), 480.0 / crop.get_height())
	crop.resize(roundi(crop.get_width() * ratio), roundi(crop.get_height() * ratio), Image.INTERPOLATE_LANCZOS)
	var output = Image.create(512, 512, false, Image.FORMAT_RGBA8)
	output.fill(Color.TRANSPARENT)
	output.blit_rect(crop, Rect2i(Vector2i.ZERO, crop.get_size()), (Vector2i(512, 512) - crop.get_size()) / 2)
	DirAccess.make_dir_recursive_absolute(("res://" + target).get_base_dir())
	Pack.save(output, "res://" + target)
	manifest[target] = {"sha256":FileAccess.get_sha256("res://" + target), "source":job.source, "source_sha256":FileAccess.get_sha256("res://" + job.source), "style":"postapocalyptic_comic", "tool":"image_gen.imagegen", "processing":"individual 512px icon, proportional alpha crop, no low-resolution atlas enlargement", "provenance":"art_sources/combat_equipment_assets/" + job.id + ".json"}
