extends SceneTree
## Geometric packing of generated cutouts and icons; no drawing or game state.
const Pack = preload("res://scripts/sketchbook_sheet_packer.gd")
func _initialize() -> void:
	var jobs: Array = JSON.parse_string(FileAccess.get_file_as_string("res://art_sources/visual_polish_2026_10_16/jobs.json"))
	var manifest: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://art_sources/art_direction/postapocalyptic/assets.json"))
	for job in jobs:
		if job.kind == "cut_in":
			var source = Image.load_from_file("res://" + job.source)
			if source == null or source.detect_alpha() == Image.ALPHA_NONE: push_error("Invalid alpha cutout: " + job.id); quit(1); return
			store(fit(source, Vector2i(1536, 1024), 0), job.target, job, manifest)
		else:
			var cells = Pack.cells("res://" + job.source, job.columns, job.rows)
			if cells.size() != job.icons.size(): push_error("Invalid icon sheet: " + job.id); quit(1); return
			for i in range(cells.size()):
				if job.icons[i] in job.get("principal_crop", []): cells[i] = cells[i].get_region(Pack.principal_bounds(cells[i]))
				store(fit(cells[i], Vector2i(256, 256), 12), "assets/collection/unlocks/%s.png" % job.icons[i], job, manifest)
	FileAccess.open("res://art_sources/art_direction/postapocalyptic/assets.json", FileAccess.WRITE).store_string(JSON.stringify(manifest, "\t") + "\n")
	quit()

func fit(source: Image, dimensions: Vector2i, margin: int) -> Image:
	var image = source.duplicate()
	var ratio = minf(float(dimensions.x - margin * 2) / image.get_width(), float(dimensions.y - margin * 2) / image.get_height())
	image.convert(Image.FORMAT_RGBA8)
	image.resize(maxi(1, roundi(image.get_width() * ratio)), maxi(1, roundi(image.get_height() * ratio)), Image.INTERPOLATE_LANCZOS)
	var result = Image.create(dimensions.x, dimensions.y, false, Image.FORMAT_RGBA8)
	result.fill(Color.TRANSPARENT)
	result.blit_rect(image, Rect2i(Vector2i.ZERO, image.get_size()), (dimensions - image.get_size()) / 2)
	return result

func store(image: Image, path: String, job: Dictionary, manifest: Dictionary) -> void:
	if manifest.get(path,{}).get("comic_rebuild_revision",0)==1: return
	DirAccess.make_dir_recursive_absolute("res://" + path.get_base_dir())
	Pack.save(image, "res://" + path)
	manifest[path] = {"sha256":FileAccess.get_sha256("res://" + path), "source":job.source, "source_sha256":FileAccess.get_sha256("res://" + job.source), "style":"postapocalyptic_comic", "processing":"proportional fit, transparent padding; 16 October static variants/unlock icons"}
	print("VISUAL POLISH: ", path)
