extends SceneTree
## Geometric preparation of individually generated transparent map illustrations.
const ROOMS = "res://art_sources/map/comic_icons/"
const SIDEBAR = "res://art_sources/map/sidebar_icons/"
const INVENTORY = "res://art_sources/art_direction/postapocalyptic/"
const Pack = preload("res://scripts/sketchbook_sheet_packer.gd")
func _initialize() -> void:
	var sidebar = "--sidebar" in OS.get_cmdline_user_args()
	var base = SIDEBAR if sidebar else ROOMS
	var jobs: Array = JSON.parse_string(FileAccess.get_file_as_string(base+"jobs.json"))
	var expected: Array = ["group","deck","paths"] if sidebar else ["combat","rest","event","treasure","elite","boss"]
	var images: Dictionary = {}
	for job in jobs:
		if job.id not in expected or images.has(job.id):
			push_error("Unexpected/duplicate map illustration: " + job.id); quit(1); return
		var image = Image.new()
		if image.load_png_from_buffer(FileAccess.get_file_as_bytes("res://"+job.source)) != OK or image.detect_alpha()==Image.ALPHA_NONE:
			push_error("Missing transparent map illustration: " + job.id); quit(1); return
		if FileAccess.get_sha256("res://"+job.source) != job.source_sha256:
			push_error("Map illustration source changed: " + job.id); quit(1); return
		var area = Pack.bounds(image,0.05)
		if area.size==Vector2i.ZERO:
			push_error("Empty map illustration: " + job.id); quit(1); return
		images[job.id] = image.get_region(area)
	if images.size()!=expected.size():
		push_error("Incomplete map illustration set"); quit(1); return
	var manifest: Dictionary = JSON.parse_string(FileAccess.get_file_as_string(INVENTORY+"assets.json"))
	var targets: Array = []
	for job in jobs:
		var image: Image = images[job.id]
		var ratio = 240.0/maxi(image.get_width(),image.get_height())
		image.resize(maxi(1,roundi(image.get_width()*ratio)),maxi(1,roundi(image.get_height()*ratio)),Image.INTERPOLATE_LANCZOS)
		var icon = Image.create(256,256,false,Image.FORMAT_RGBA8)
		icon.fill(Color.TRANSPARENT)
		icon.blit_rect(image,Rect2i(Vector2i.ZERO,image.get_size()),(icon.get_size()-image.get_size())/2)
		Pack.save(icon,"res://"+job.target)
		targets.append(job.target)
		manifest[job.target] = {"sha256":FileAccess.get_sha256("res://"+job.target),"source":job.source,"source_sha256":job.source_sha256,"style":"postapocalyptic_comic","tool":"image_gen.imagegen","generation":base.trim_prefix("res://")+"jobs/%s.json"%job.id,"processing":"alpha bounds crop, proportional Lanczos fit within 240px, centered on transparent 256px canvas"}
	FileAccess.open(INVENTORY+"assets.json",FileAccess.WRITE).store_string(JSON.stringify(manifest,"\t",false)+"\n")
	# Preserve these authored images when native-vector tools rebuild UI symbols.
	var vectors: Array = JSON.parse_string(FileAccess.get_file_as_string(INVENTORY+"vectors.json"))
	vectors = vectors.filter(func(record): return record.target not in targets)
	FileAccess.open(INVENTORY+"vectors.json",FileAccess.WRITE).store_string(JSON.stringify(vectors,"  ",false)+"\n")
	var queue: Dictionary = JSON.parse_string(FileAccess.get_file_as_string(INVENTORY+"queue.json"))
	for job in jobs:
		var matches: Array = queue.derived.filter(func(entry): return entry.target==job.target)
		var entry: Dictionary
		if matches.is_empty():
			entry = {"id":"map__sidebar__"+job.id,"target":job.target}
			queue.derived.append(entry)
		else: entry = matches[0]
		entry.kind = "map_sidebar_illustration" if sidebar else "map_illustration"
		entry.dimensions = [256,256]
		entry.transparent = true
		entry.source = job.source
		entry.prompt = job.prompt
	FileAccess.open(INVENTORY+"queue.json",FileAccess.WRITE).store_string(JSON.stringify(queue,"  ",false)+"\n")
	print("COMIC MAP ILLUSTRATIONS: ",images.size())
	quit()
