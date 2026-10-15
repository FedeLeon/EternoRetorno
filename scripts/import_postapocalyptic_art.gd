extends SceneTree
## Geometric import of generated comic art. No drawing, gameplay or persistence.
const Pack = preload("res://scripts/sketchbook_sheet_packer.gd")
const ROOT = "res://docs/art_direction/postapocalyptic/"
var manifest: Dictionary = {}
var visuals: Dictionary = {}
var installed = 0

func _initialize() -> void:
	manifest = read_json(ROOT + "assets.json")
	visuals = read_json("res://data/enemy_visuals.json")
	var queue = read_json(ROOT + "queue.json")
	for job in queue.jobs:
		if "--actors-only" in OS.get_cmdline_user_args() and job.kind not in ["machine_bank", "enemy_bank"]: continue
		if job.kind in ["hero_action", "hero_bank"]: continue # Shared actor scale is imported separately.
		if not FileAccess.file_exists("res://" + job.source): continue
		var source_hash = FileAccess.get_sha256("res://" + job.source)
		if job.kind in ["machine_bank", "enemy_bank"] and manifest.get(job.target, {}).get("processing_version", 0) != 5:
			install(job, source_hash)
			continue
		if job.kind == "card_bank" and manifest.get("assets/cards/art/minimal/%s.png" % job.cards[0],{}).get("source_sha256", "") == source_hash and manifest.get("assets/cards/art/minimal/%s.png" % job.cards[0],{}).get("fit_mode", "") == "symbol_bounds": continue
		if job.kind not in ["card_bank", "portrait"] and manifest.get(job.target, {}).get("source_sha256", "") == source_hash: continue
		if not FileAccess.file_exists(ROOT + "jobs/" + job.id + ".json"): continue
		var record = read_json(ROOT + "jobs/" + job.id + ".json")
		if record.get("prompt", "") != job.prompt: continue
		install(job, source_hash)
	for hero in ["warrior", "guardian", "rogue", "mage"]:
		var path = ROOT + "jobs/identity_" + hero + ".json"
		if not FileAccess.file_exists(path): continue
		var job = read_json(path)
		var source_hash = FileAccess.get_sha256("res://" + job.source)
		if job.kind not in ["card_bank", "portrait"] and manifest.get(job.target, {}).get("source_sha256", "") == source_hash: continue
		var image = Image.load_from_file("res://" + job.source)
		store(image, job.target, job, source_hash)
	FileAccess.open(ROOT + "assets.json", FileAccess.WRITE).store_string(JSON.stringify(manifest,"\t")+"\n")
	FileAccess.open("res://data/enemy_visuals.json", FileAccess.WRITE).store_string(JSON.stringify(visuals,"\t")+"\n")
	print("POSTAPOCALYPTIC COMIC: ", installed, " assets integrated")
	quit()

func read_json(path: String) -> Dictionary:
	return JSON.parse_string(FileAccess.get_file_as_string(path)) if FileAccess.file_exists(path) else {}

func install(job: Dictionary, source_hash: String) -> void:
	var image = Image.load_from_file("res://" + job.source)
	if image == null: push_error("Unreadable generated art: " + job.id); return
	if job.transparent and image.detect_alpha() == Image.ALPHA_NONE:
		push_error("Opaque cutout rejected: " + job.id); return
	var dimensions = Vector2i(int(job.dimensions[0]), int(job.dimensions[1]))
	match job.kind:
		"machine_bank":
			var drawings = Pack.actor_cells("res://"+job.source,4,4)
			if drawings.size()!=16: push_error("Invalid machine pose bank: "+job.id); return
			for row in range(4):
				var poses: Array[Image] = []
				for phase in [0,0,0,0,0,1,2,3]: poses.append(drawings[row*4+phase])
				var ratio = 1000.0
				for pose in poses: ratio = minf(ratio,minf(228.0/pose.get_width(),228.0/pose.get_height()))
				var atlas = Pack.pack(poses,8,256,ratio,240)
				var id: String = job.machines[row]
				visuals[id].merge({"style":"postapocalyptic_comic","frame_size":256,"idle_frames":4,"attack_frames":4},true)
				store(atlas,"assets/enemies/animations/%s.png"%id,job,source_hash)
				store(atlas.get_region(Rect2i(0,0,256,256)),"assets/enemies/hd/%s.png"%id,job,source_hash)
			return
		"machine_foreground_bank":
			var cell = image.get_size()/2
			for i in range(4):
				var foreground = image.get_region(Rect2i(Vector2i((i%2)*cell.x,(i/2)*cell.y),cell))
				var id: String = job.machines[i]
				store(foreground,"assets/comic/enemies/%s.png"%id,job,source_hash)
				visuals[id]["foreground_frames"] = 1
			return
		"enemy_bank":
			var drawings = Pack.actor_cells("res://" + job.source, 2, 2)
			if drawings.size() != 4: push_error("Invalid enemy atlas: " + job.id); return
			var poses: Array[Image] = []
			for index in [0,0,0,0,1,1,2,3]: poses.append(drawings[index])
			var ratio = 1000.0
			for pose in poses: ratio = minf(ratio, minf(228.0/pose.get_width(), 228.0/pose.get_height()))
			image = Pack.pack(poses,8,256,ratio,240)
			var id = job.target.get_file().get_basename()
			visuals[id].merge({"style":"postapocalyptic_comic","frame_size":256,"idle_frames":4,"attack_frames":4},true)
			store(image.get_region(Rect2i(0,0,256,256)),"assets/enemies/hd/%s.png"%id,job,source_hash)
			var foreground = Image.load_from_file("res://"+job.source)
			var cell = foreground.get_size()/2
			foreground = foreground.get_region(Rect2i(Vector2i(0,cell.y),cell))
			store(foreground,"assets/comic/enemies/%s.png"%id,job,source_hash)
			visuals[id]["foreground_frames"] = 1
		"card_bank":
			var cell = image.get_size()/Vector2i(6,4)
			for i in range(job.cards.size()):
				var center = Vector2i((i%6)*cell.x,(i/6)*cell.y)
				var tile = image.get_region(Rect2i(center,cell))
				var bounds = symbol_bounds(tile)
				var drawing = tile.get_region(bounds)
				var ratio = minf(484.0/drawing.get_width(),268.0/drawing.get_height())
				drawing.resize(maxi(1,roundi(drawing.get_width()*ratio)),maxi(1,roundi(drawing.get_height()*ratio)),Image.INTERPOLATE_LANCZOS)
				drawing.convert(Image.FORMAT_RGBA8)
				var picture = Image.create(512,288,false,Image.FORMAT_RGBA8)
				picture.fill(tile.get_pixel(2,2))
				picture.blit_rect(drawing,Rect2i(Vector2i.ZERO,drawing.get_size()),(picture.get_size()-drawing.get_size())/2)
				store(picture,"assets/cards/art/minimal/%s.png"%job.cards[i],job,source_hash)
			return
		"enemy_foreground":
			visuals[job.target.get_file().get_basename()]["foreground_frames"] = 1
			image.resize(1536,1024,Image.INTERPOLATE_LANCZOS)
		"objects_atlas", "chest_atlas", "numbers":
			var columns = 4 if job.kind == "objects_atlas" else (3 if job.kind == "chest_atlas" else 5)
			var rows = 4 if job.kind == "objects_atlas" else 2
			var poses = Pack.cells("res://" + job.source,columns,rows)
			if poses.size() != columns*rows: push_error("Invalid prop atlas: " + job.id); return
			var ratio = 1000.0
			var extent = 52.0 if job.kind == "objects_atlas" else (28.0 if job.kind == "numbers" else 228.0)
			for pose in poses: ratio = minf(ratio,minf(extent/pose.get_width(),(40.0 if job.kind == "numbers" else extent)/pose.get_height()))
			if job.kind == "numbers":
				for i in range(10):
					var glyph = Image.create(32,48,false,Image.FORMAT_RGBA8); glyph.fill(Color.TRANSPARENT)
					var pose = poses[i].duplicate()
					pose.resize(maxi(1,roundi(pose.get_width()*ratio)),maxi(1,roundi(pose.get_height()*ratio)),Image.INTERPOLATE_LANCZOS)
					glyph.blit_rect(pose,Rect2i(Vector2i.ZERO,pose.get_size()),Vector2i((32-pose.get_width())/2,46-Pack.bottom(pose)))
					store(glyph,"assets/ui/numbers/%d.png"%i,job,source_hash)
				return
			image = Pack.pack(poses,4 if job.kind == "objects_atlas" else 6,64 if job.kind == "objects_atlas" else 256,ratio,56 if job.kind == "objects_atlas" else 248)
		"fire":
			image.resize(1536,1024,Image.INTERPOLATE_LANCZOS)
			var baselines = []
			for i in range(24): baselines.append(Pack.bottom(image.get_region(Rect2i((i%6)*256,(i/6)*256,256,256))))
			FileAccess.open("res://data/camp_fire_dusk.json",FileAccess.WRITE).store_string(JSON.stringify({"baselines":baselines},"\t")+"\n")
		_:
			if job.transparent and job.kind != "frame":
				var area = Pack.bounds(image)
				if area.size == Vector2i.ZERO: push_error("Empty generated art: "+job.id); return
				var crop = image.get_region(area)
				var ratio = minf((dimensions.x-8.0)/crop.get_width(),(dimensions.y-8.0)/crop.get_height())
				crop.resize(maxi(1,roundi(crop.get_width()*ratio)),maxi(1,roundi(crop.get_height()*ratio)),Image.INTERPOLATE_LANCZOS)
				image = Image.create(dimensions.x,dimensions.y,false,Image.FORMAT_RGBA8); image.fill(Color.TRANSPARENT)
				image.blit_rect(crop,Rect2i(Vector2i.ZERO,crop.get_size()),(dimensions-crop.get_size())/2)
			else:
				if job.kind == "portrait":
					var size = image.get_size()
					var aspect = float(dimensions.x)/dimensions.y
					var crop = Vector2i(mini(size.x,roundi(size.y*aspect)),mini(size.y,roundi(size.x/aspect)))
					var offset = Vector2i((size.x-crop.x)/2,roundi((size.y-crop.y)*0.1))
					image = image.get_region(Rect2i(offset,crop))
				if job.kind == "card":
					var size = image.get_size()
					var wanted = Vector2i(mini(size.x,roundi(size.y*16.0/9.0)),mini(size.y,roundi(size.x*9.0/16.0)))
					image = image.get_region(Rect2i((size-wanted)/2,wanted))
				image.resize(dimensions.x,dimensions.y,Image.INTERPOLATE_LANCZOS)
	store(image,job.target,job,source_hash)

func store(image: Image, path: String, job: Dictionary, source_hash: String) -> void:
	DirAccess.make_dir_recursive_absolute(("res://"+path).get_base_dir())
	Pack.save(image,"res://"+path)
	manifest[path] = {"sha256":FileAccess.get_sha256("res://"+path),"source_sha256":source_hash,"source":job.source,"job":job.id,"style":"postapocalyptic_comic"}
	if job.kind == "card_bank": manifest[path]["fit_mode"] = "symbol_bounds"
	if job.kind in ["machine_bank", "enemy_bank"]:
		manifest[path]["processing_version"] = 5
		manifest[path]["processing"] = "adaptive gutters, principal silhouette crop, common scale and baseline"
	installed += 1

func symbol_bounds(image: Image) -> Rect2i:
	# Locate colored ink against the atlas' matte background, then retain its border.
	var low = image.get_size()
	var high = Vector2i(-1,-1)
	for y in range(image.get_height()):
		for x in range(image.get_width()):
			var color = image.get_pixel(x,y)
			if color.v > 0.34 or (color.v > 0.21 and color.s > 0.38):
				low = low.min(Vector2i(x,y)); high = high.max(Vector2i(x,y))
	if high.x < 0: return Rect2i(Vector2i.ZERO,image.get_size())
	return Rect2i(low,high-low+Vector2i.ONE).grow(6).intersection(Rect2i(Vector2i.ZERO,image.get_size()))
