extends SceneTree
## Offline extraction of authored HD stills. No upscaling, rigging or runtime atlas.
const BASE = "res://art_sources/hero_actions_hd_2026_10_19/"
const FRAMES = "art_sources/static_combat_2026_10_19/source_frames/heroes/"
const Pack = preload("res://scripts/sketchbook_sheet_packer.gd")
const ACTIONS = ["attack", "guard", "skill", "hurt", "death"]

func read_json(path: String) -> Variant:
	return JSON.parse_string(FileAccess.get_file_as_string(path))
func write_json(path: String, value: Variant) -> void:
	FileAccess.open(path, FileAccess.WRITE).store_string(JSON.stringify(value, "\t", false) + "\n")

func _initialize() -> void:
	var jobs: Array = read_json(BASE + "jobs.json")
	var catalog: Dictionary = read_json("res://data/static_combat.json")
	var records: Dictionary = read_json("res://art_sources/static_combat_2026_10_19/extraction.json")
	var manifest: Dictionary = read_json("res://art_sources/art_direction/postapocalyptic/assets.json")
	var comic: Dictionary = read_json("res://data/comic_art.json")
	var prepared: Array = []
	for job in jobs:
		var source = Image.load_from_file("res://" + job.source)
		if source == null or source.detect_alpha() == Image.ALPHA_NONE:
			push_error("Expected transparent authored HD source: " + job.hero)
			quit(1); return
		source.convert(Image.FORMAT_RGBA8)
		var poses: Array[Image] = []
		var extent = Vector2i.ZERO
		for part in job.parts:
			var pose = component(source, part)
			poses.append(pose)
			extent = extent.max(pose.get_size())
		var factor = minf(1.0, minf(488.0 / extent.x, 456.0 / extent.y))
		var frames: Array[Image] = []
		for pose in poses:
			pose.fix_alpha_edges()
			if factor < 1.0:
				pose.resize(maxi(1, roundi(pose.get_width() * factor)), maxi(1, roundi(pose.get_height() * factor)), Image.INTERPOLATE_LANCZOS)
			var bounds = Pack.bounds(pose, .5)
			var frame = Image.create(512, 512, false, Image.FORMAT_RGBA8)
			frame.fill(Color.TRANSPARENT)
			var offset = Vector2i(256 - bounds.position.x - bounds.size.x / 2, 496 - bounds.end.y)
			frame.blit_rect(pose, Rect2i(Vector2i.ZERO, pose.get_size()), offset)
			frame.fix_alpha_edges()
			frames.append(frame)
		var reference = Pack.bounds(frames[5], .5)
		if reference.size.y < 350:
			push_error("Insufficient native detail after fitting: " + job.hero)
			quit(1); return
		var idle: Dictionary = catalog.heroes[job.hero].idle
		var logical_scale = float(idle.bounds[3]) * float(idle.scale) / reference.size.y
		prepared.append({"job":job, "frames":frames, "scale":logical_scale, "factor":factor, "reference_height":reference.size.y})
	var report: Array = []
	for item in prepared:
		var job: Dictionary = item.job
		for i in range(ACTIONS.size()):
			var action: String = ACTIONS[i]
			var key = "heroes/%s/%s" % [job.hero, action]
			var source_path = FRAMES + "%s/%s.png" % [job.hero, action]
			var target = "assets/combat_static/" + key + ".png"
			var frame: Image = item.frames[i]
			Pack.save(frame, "res://" + source_path)
			DirAccess.copy_absolute("res://" + source_path, "res://" + target)
			var bounds = Pack.bounds(frame, .5)
			var origin = {"source":job.source, "source_sha256":job.source_sha256, "generation":"art_sources/hero_actions_hd_2026_10_19/%s.json" % job.hero, "processing":job.processing, "hero_action_hd_revision":1, "outline_baked":true, "source_part":job.parts[i], "common_downscale":item.factor, "reference_height":item.reference_height}
			var digest = FileAccess.get_sha256("res://" + source_path)
			records[key] = {"original_atlas":job.source, "original_provenance":origin, "selected_frame":i, "scale":item.scale, "source":source_path, "source_sha256":digest, "outline_baked":true}
			catalog.heroes[job.hero][action] = {"path":"res://" + target, "scale":item.scale, "anchor":[256, bounds.end.y], "bounds":[bounds.position.x, bounds.position.y, bounds.size.x, bounds.size.y]}
			manifest[target] = {"source":source_path, "source_sha256":digest, "sha256":FileAccess.get_sha256("res://" + target), "style":"postapocalyptic_comic", "hero_action_hd_revision":1, "outline_baked":true, "processing":"New authored HD static action, common anatomical scale from reference idle, no upscaling", "origin":origin}
			comic.baked[target] = true
			report.append({"hero":job.hero, "action":action, "native_reference_height":item.reference_height, "native_action_height":bounds.size.y, "common_downscale":item.factor, "scale":item.scale})
	write_json("res://data/static_combat.json", catalog)
	write_json("res://data/comic_art.json", comic)
	write_json("res://art_sources/static_combat_2026_10_19/extraction.json", records)
	write_json("res://art_sources/art_direction/postapocalyptic/assets.json", manifest)
	write_json("res://artifacts/hero_actions_hd/import.json", report)
	print("HERO ACTION HD: ", report.size(), " authored static actions; idle untouched; no upscaling")
	quit()

func component(source: Image, part: Dictionary) -> Image:
	# Keep only the selected connected figure: an extended tool may cross a grid
	# gutter without belonging to the neighboring character. Preserve a 1px fringe.
	var b: Array = part.bounds
	var rect = Rect2i(int(b[0]), int(b[1]), int(b[2]), int(b[3])).grow(2).intersection(Rect2i(Vector2i.ZERO, source.get_size()))
	var image = source.get_region(rect)
	var bytes = image.get_data()
	var width = image.get_width()
	var height = image.get_height()
	var seen = PackedByteArray(); seen.resize(width * height)
	var mask = PackedByteArray(); mask.resize(width * height)
	var seed = Vector2i(int(part.seed[0]), int(part.seed[1])) - rect.position
	var pending: Array[int] = [seed.y * width + seed.x]
	seen[pending[0]] = 1
	while not pending.is_empty():
		var key: int = pending.pop_back()
		mask[key] = 1
		var point = Vector2i(key % width, key / width)
		for delta in [Vector2i.LEFT, Vector2i.RIGHT, Vector2i.UP, Vector2i.DOWN]:
			var next: Vector2i = point + delta
			if next.x < 0 or next.y < 0 or next.x >= width or next.y >= height: continue
			var index = next.y * width + next.x
			if seen[index]: continue
			seen[index] = 1
			if bytes[index * 4 + 3] > 51: pending.append(index)
	var output = PackedByteArray(); output.resize(bytes.size())
	for y in range(height):
		for x in range(width):
			var key = y * width + x
			var selected = mask[key] == 1
			if not selected and bytes[key * 4 + 3] > 0:
				for dy in range(-1, 2):
					for dx in range(-1, 2):
						var px = x + dx; var py = y + dy
						if px >= 0 and py >= 0 and px < width and py < height and mask[py * width + px] == 1: selected = true
			if selected:
				for channel in range(4): output[key * 4 + channel] = bytes[key * 4 + channel]
	return Image.create_from_data(width, height, false, Image.FORMAT_RGBA8, output)
