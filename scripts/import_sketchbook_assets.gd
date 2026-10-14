extends SceneTree
# Image geometry only. Artwork and prompts remain in migration/sources and jobs.
const Pack = preload("res://scripts/sketchbook_sheet_packer.gd")
const ROOT = "res://docs/art_direction/migration/"
const PROCESSING_VERSION = 2
var manifest: Dictionary = {}
var catalog: Dictionary = {}
func _initialize() -> void:
	manifest = read_json(ROOT+"assets.json")
	catalog = read_json("res://data/enemy_visuals.json")
	var queue = read_json(ROOT+"queue.json")
	var selected = OS.get_cmdline_user_args()
	var count = 0
	for job in queue.jobs:
		if not selected.is_empty() and job.kind not in selected: continue
		if job.kind == "idle_refinement": continue
		if not FileAccess.file_exists("res://"+job.source): continue
		if not FileAccess.file_exists(ROOT+"jobs/"+job.id+".json"): continue
		if install(job): count += 1
	FileAccess.open(ROOT+"assets.json",FileAccess.WRITE).store_string(JSON.stringify(manifest,"\t")+"\n")
	FileAccess.open("res://data/enemy_visuals.json",FileAccess.WRITE).store_string(JSON.stringify(catalog,"\t")+"\n")
	print("SKETCHBOOK ASSETS integrated: ",count)
	quit()
func read_json(path: String) -> Dictionary:
	return JSON.parse_string(FileAccess.get_file_as_string(path)) if FileAccess.file_exists(path) else {}
func install(job: Dictionary) -> bool:
	var source = "res://"+job.source
	if job.transparent:
		var raw = Image.load_from_file(source)
		if raw.detect_alpha() == Image.ALPHA_NONE:
			push_error("Opaque cutout rejected: "+source);return false
	var source_hash = digest(source)
	if job.target != null: configure_import(job)
	if job.target != null and manifest.get(job.target,{}).get("source_sha256","") == source_hash and manifest.get(job.target,{}).get("processing_version",0) == PROCESSING_VERSION: return false
	if job.kind == "numbers":
		var digits = Pack.cells(source,5,2)
		if digits.size()!=10: push_error("Invalid digit grid: "+source);return false
		var ratio = 1000.0
		for digit in digits: ratio = minf(ratio,minf(28.0/digit.get_width(),40.0/digit.get_height()))
		for i in range(10):
			var glyph = Image.create(32,48,false,Image.FORMAT_RGBA8);glyph.fill(Color.TRANSPARENT)
			var digit = digits[i].duplicate()
			digit.resize(roundi(digit.get_width()*ratio),roundi(digit.get_height()*ratio),Image.INTERPOLATE_LANCZOS)
			glyph.blit_rect(digit,Rect2i(Vector2i.ZERO,digit.get_size()),Vector2i((32-digit.get_width())/2,46-Pack.bottom(digit)))
			store(glyph,"assets/ui/numbers/%d.png"%i,job,source_hash)
		return true
	var target: String = job.target
	var image: Image
	match job.kind:
		"enemy_actor":
			var poses = Pack.cells(source,4,2)
			if poses.size()!=8: push_error("Invalid enemy grid: "+source);return false
			var ratio = 1000.0
			for pose in poses: ratio = minf(ratio,minf(228.0/pose.get_width(),228.0/pose.get_height()))
			image = Pack.pack(poses,8,256,ratio,240)
			var id = target.get_file().get_basename()
			catalog[id].merge({"style":"sketchbook","frame_size":256,"idle_frames":4,"attack_frames":4},true)
			store(image.get_region(Rect2i(0,0,256,256)),"assets/enemies/hd/%s.png"%id,job,source_hash)
		"enemy_foreground":
			image = Image.load_from_file(source)
			catalog[target.get_file().get_basename()]["foreground_frames"] = 4
		"objects_atlas", "chest_atlas":
			var objects = job.kind == "objects_atlas"
			var poses = Pack.cells(source,4 if objects else 3,4 if objects else 2)
			if poses.size()!=(16 if objects else 6): push_error("Invalid prop grid: "+source);return false
			var cell_size = 64 if objects else 256
			var ratio = 1000.0
			for pose in poses: ratio = minf(ratio,minf((cell_size-12.0)/pose.get_width(),(cell_size-16.0)/pose.get_height()))
			image = Pack.pack(poses,4 if objects else 6,cell_size,ratio,cell_size-8)
		_:
			image = Image.load_from_file(source)
			var dimensions = Vector2i(job.dimensions[0],job.dimensions[1])
			# Preserve exact frame layout.
			if job.transparent and job.kind != "frame":
				var area = Pack.bounds(image)
				if area.size == Vector2i.ZERO: push_error("Empty asset: "+source);return false
				var crop = image.get_region(area)
				var ratio = minf((dimensions.x-4.0)/crop.get_width(),(dimensions.y-4.0)/crop.get_height())
				crop.resize(maxi(1,roundi(crop.get_width()*ratio)),maxi(1,roundi(crop.get_height()*ratio)),Image.INTERPOLATE_LANCZOS)
				image = Image.create(dimensions.x,dimensions.y,false,Image.FORMAT_RGBA8);image.fill(Color.TRANSPARENT)
				image.blit_rect(crop,Rect2i(Vector2i.ZERO,crop.get_size()),(dimensions-crop.get_size())/2)
			else:
				image.resize(dimensions.x,dimensions.y,Image.INTERPOLATE_LANCZOS)
	store(image,target,job,source_hash)
	return true
func digest(path: String) -> String:
	var hash = HashingContext.new();hash.start(HashingContext.HASH_SHA256);hash.update(FileAccess.get_file_as_bytes(path))
	return hash.finish().hex_encode()
func configure_import(job: Dictionary) -> void:
	var path = "res://"+job.target+".import"
	var config = ConfigFile.new()
	if config.load(path)!=OK: return
	# Atlas grids must never shrink, and the large map is not a small map icon.
	if job.kind in ["enemy_actor","objects_atlas","chest_atlas"]:
		config.set_value("params","process/size_limit",0)
		config.set_value("params","compress/mode",0)
	elif job.kind == "enemy_foreground":
		config.set_value("params","process/size_limit",0)
		config.set_value("params","compress/mode",1)
		config.set_value("params","compress/lossy_quality",0.9)
	elif job.target == "assets/map/minimal/parchment.png":
		config.set_value("params","process/size_limit",1280)
		config.set_value("params","compress/mode",0)
	elif job.kind == "scene" and not job.transparent:
		config.set_value("params","process/size_limit",1280)
		config.set_value("params","compress/mode",1)
		config.set_value("params","compress/lossy_quality",0.85)
	config.save(path)
func store(image: Image, target: String, job: Dictionary, source_hash: String) -> void:
	Pack.save(image,"res://"+target)
	manifest[target] = {"sha256":digest("res://"+target),"source":job.source,"source_sha256":source_hash,"job":job.id,"processing_version":PROCESSING_VERSION,"processing":"proportional alpha crop or original layout resize; atlas baseline preserved"}
