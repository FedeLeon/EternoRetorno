extends SceneTree
## Offline import: transparent generated wreckage -> one 512px still per model.
const BASE = "res://art_sources/enemy_wreckage_2026_10_21/"
const Pack = preload("res://scripts/sketchbook_sheet_packer.gd")
func read_json(path: String) -> Variant:
	return JSON.parse_string(FileAccess.get_file_as_string(path))
func write_json(path: String, data: Variant) -> void:
	FileAccess.open(path,FileAccess.WRITE).store_string(JSON.stringify(data,"\t",false)+"\n")
func _initialize():
	var jobs: Array = read_json(BASE+"jobs.json")
	var catalog: Dictionary = read_json("res://data/static_combat.json")
	var records: Dictionary = read_json("res://art_sources/static_combat_2026_10_19/extraction.json")
	var manifest: Dictionary = read_json("res://art_sources/art_direction/postapocalyptic/assets.json")
	var comic: Dictionary = read_json("res://data/comic_art.json")
	var imported = 0
	for job in jobs:
		var source_path = "res://"+job.source
		if not FileAccess.file_exists(source_path):
			if OS.get_cmdline_user_args().has("--partial"): continue
			push_error("Missing wreckage source: "+job.id); quit(1); return
		var source = Image.load_from_file(source_path)
		if source == null or source.detect_alpha() == Image.ALPHA_NONE:
			push_error("Wreckage needs transparency: "+job.id); quit(1); return
		source.convert(Image.FORMAT_RGBA8)
		var bounds = Pack.bounds(source,.08)
		var pose = source.get_region(bounds)
		var shrink = minf(1,minf(472.0/pose.get_width(),460.0/pose.get_height()))
		if shrink < 1: pose.resize(maxi(1,roundi(pose.get_width()*shrink)),maxi(1,roundi(pose.get_height()*shrink)),Image.INTERPOLATE_LANCZOS)
		bounds = Pack.bounds(pose,.5)
		var frame = Image.create(512,512,false,Image.FORMAT_RGBA8)
		frame.fill(Color.TRANSPARENT)
		frame.blit_rect(pose,Rect2i(Vector2i.ZERO,pose.get_size()),Vector2i(256-bounds.position.x-bounds.size.x/2,496-bounds.end.y))
		frame.fix_alpha_edges()
		bounds = Pack.bounds(frame,.5)
		var relative = "assets/combat_static/enemies/%s/death.png"%job.id
		var source_frame = "art_sources/static_combat_2026_10_19/source_frames/enemies/%s/death.png"%job.id
		Pack.save(frame,"res://"+relative)
		Pack.save(frame,"res://"+source_frame)
		var idle: Dictionary = catalog.enemies[job.id].idle
		var width = maxf(float(idle.bounds[3])*float(idle.scale)*.75,float(idle.bounds[2])*float(idle.scale)*.95)
		var factor = width / bounds.size.x
		catalog.enemies[job.id].death = {"path":"res://"+relative,"scale":factor,"anchor":[256,bounds.end.y],"bounds":[bounds.position.x,bounds.position.y,bounds.size.x,bounds.size.y]}
		var origin = {"job":"wreckage_"+job.id,"source":job.source,"source_sha256":FileAccess.get_sha256(source_path),"wreckage_revision":1}
		records["enemies/%s/death"%job.id] = {"source":source_frame,"source_sha256":FileAccess.get_sha256("res://"+source_frame),"scale":factor,"original_atlas":job.source,"original_provenance":origin,"outline_baked":true,"wreckage":true}
		manifest[relative] = {"sha256":FileAccess.get_sha256("res://"+relative),"source":source_frame,"source_sha256":FileAccess.get_sha256("res://"+source_frame),"inputs_sha256":{job.source:origin.source_sha256},"style":"postapocalyptic_comic","processing":"Generated machine-specific wreckage; transparent crop and proportional reduction only","origin":origin,"outline_baked":true,"wreckage_revision":1}
		comic.baked[relative] = true
		imported += 1
	write_json("res://data/static_combat.json",catalog)
	write_json("res://art_sources/static_combat_2026_10_19/extraction.json",records)
	write_json("res://art_sources/art_direction/postapocalyptic/assets.json",manifest)
	write_json("res://data/comic_art.json",comic)
	print("ENEMY WRECKAGE: %d / %d imported"%[imported,jobs.size()])
	quit()
