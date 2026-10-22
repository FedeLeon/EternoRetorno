extends SceneTree
## Offline crop/registration of authored drawings, without deformation or inbetween synthesis.
const BASE = "res://art_sources/carpenter_sequences_2026_10_22/"
const Pack = preload("res://scripts/sketchbook_sheet_packer.gd")
const Geometry = preload("res://scripts/hero_sequence_geometry.gd")
const CELL = Vector2i(512,384)
const ANCHOR_X = 180
const GROUND = 368

func read_json(path: String) -> Variant:
	return JSON.parse_string(FileAccess.get_file_as_string(path))

func write_json(path: String, value: Variant) -> void:
	FileAccess.open(path,FileAccess.WRITE).store_string(JSON.stringify(value,"\t",false)+"\n")

func require(condition: bool, message: String) -> bool:
	if not condition:
		push_error(message)
		quit(1)
	return condition

func _initialize() -> void:
	var jobs: Array = read_json(BASE+"jobs.json")
	var extracted: Dictionary = {}
	var foot_data: Dictionary = {}
	var span = 170.0
	# Fit every authored frame, using the same distance between boot contacts.
	for job in jobs:
		print("EXTRACT ",job.id)
		var image = Image.load_from_file("res://"+job.source)
		if not require(image != null and image.detect_alpha()!=Image.ALPHA_NONE,"Transparent source required: "+job.id): return
		var boxes = Geometry.figures(image)
		if not require(boxes.size()==16,"Expected 16 connected full-body figures: "+job.id+" got "+str(boxes.size())): return
		extracted[job.id] = []
		foot_data[job.id] = []
		var death_origin = Vector2.ZERO
		for figure in boxes:
			var box: Rect2i = figure.bounds
			var pose = Image.create(box.size.x,box.size.y,false,Image.FORMAT_RGBA8)
			pose.fill(Color.TRANSPARENT)
			for point in figure.pixels:
				var pos = Vector2i(point%image.get_width(),point/image.get_width())
				pose.set_pixelv(pos-box.position,image.get_pixelv(pos))
			var index: int = extracted[job.id].size()
			var boots: Vector2
			if job.id=="death" and index>0:
				# Keep the camera/scale from the standing pose while knees fold.
				# Collapsed hands and the grounded weapon are not boot landmarks.
				boots = death_origin + Vector2.ONE*(float(index%4)*image.get_width()/4-box.position.x)
			else:
				boots = Geometry.feet(pose, job.id=="idle")
				if job.id=="death": death_origin = boots+Vector2.ONE*box.position.x
			var annotated: Array = job.get("foot_contacts",{}).get(str(extracted[job.id].size()),[])
			if annotated.size()==2: boots = Vector2(annotated[0],annotated[1])
			var distance = boots.y-boots.x
			if not require(distance > 35,"Invalid foot separation: "+job.id+"/"+str(index)): return
			span = minf(span,340.0*distance/pose.get_height())
			var center = (boots.x+boots.y)*.5
			span = minf(span,(ANCHOR_X-16)*distance/maxf(1,center))
			span = minf(span,(CELL.x-ANCHOR_X-16)*distance/maxf(1,pose.get_width()-center))
			extracted[job.id].append(pose)
			foot_data[job.id].append(boots)
	var bank = {"columns":4,"frame_size":[CELL.x,CELL.y],"anchor":[ANCHOR_X,GROUND],"scale":1.0,"clips":{}}
	var manifest: Dictionary = read_json("res://art_sources/art_direction/postapocalyptic/assets.json")
	var comic: Dictionary = read_json("res://data/comic_art.json")
	var provenance: Dictionary = {}
	for job in jobs:
		var atlas = Image.create(CELL.x*4,CELL.y*4,false,Image.FORMAT_RGBA8)
		atlas.fill(Color.TRANSPARENT)
		var clip = {"path":"res://assets/combat_sequences/warrior/"+job.id+".png","duration":job.duration,"loop":job.id=="idle","frames":[],"bounds":[]}
		if job.get("ping_pong",false): clip.ping_pong = true
		if job.id == "attack": clip.contact = .5
		var union = Rect2i()
		for i in 16:
			var pose: Image = extracted[job.id][i]
			var boots: Vector2 = foot_data[job.id][i]
			var ratio = span/(boots.y-boots.x)
			if job.id=="idle":
				var reference_boots: Vector2 = foot_data.idle[0]
				ratio = span/(reference_boots.y-reference_boots.x)
			var center = (boots.x+boots.y)*.5*ratio
			pose.resize(maxi(1,roundi(pose.get_width()*ratio)),maxi(1,roundi(pose.get_height()*ratio)),Image.INTERPOLATE_LANCZOS)
			var area = Pack.bounds(pose,.5)
			var offset = Vector2i(roundi(ANCHOR_X-center),GROUND-area.end.y)
			if not require(offset.x>=0 and offset.x+pose.get_width()<=CELL.x and offset.y>=0,"Frame would clip: "+job.id+str(i)): return
			atlas.blit_rect(pose,Rect2i(Vector2i.ZERO,pose.get_size()),Vector2i(i%4,i/4)*CELL+offset)
			area.position += offset
			union = area if i==0 else union.merge(area)
			clip.frames.append({"bounds":[area.position.x,area.position.y,area.size.x,area.size.y],"feet":[ANCHOR_X-span*.5,ANCHOR_X+span*.5,GROUND]})
		atlas.fix_alpha_edges()
		Pack.save(atlas,clip.path)
		clip.bounds = [union.position.x,union.position.y,union.size.x,union.size.y]
		bank.clips[job.id] = clip
		var relative: String = clip.path.trim_prefix("res://")
		var origin = {"job":job.id,"record":"art_sources/carpenter_sequences_2026_10_22/jobs.json"}
		manifest[relative] = {"sha256":FileAccess.get_sha256(clip.path),"source":job.source,"source_sha256":FileAccess.get_sha256("res://"+job.source),"style":"postapocalyptic_comic","processing":"16 authored poses, uniform boot registration and atlas packing; no synthesized motion","outline_baked":false,"origin":origin}
		comic.baked.erase(relative)
		provenance[job.id] = {"source":job.source,"source_sha256":manifest[relative].source_sha256,"runtime":relative,"runtime_sha256":manifest[relative].sha256,"frames":16,"boot_span":span}
	var old: Dictionary = read_json("res://data/static_combat.json").heroes.warrior.idle
	bank.scale = float(old.bounds[3])*float(old.scale)/float(bank.clips.idle.bounds[3])
	var idle_scale = bank.scale
	if FileAccess.file_exists("res://data/hero_sprite_sequences.json"):
		bank.scale = read_json("res://data/hero_sprite_sequences.json").warrior.scale
	bank.clips.idle.scale = idle_scale
	var banks: Dictionary = read_json("res://data/hero_sprite_sequences.json")
	banks.warrior = bank
	write_json("res://data/hero_sprite_sequences.json",banks)
	write_json(BASE+"extraction.json",provenance)
	write_json("res://art_sources/art_direction/postapocalyptic/assets.json",manifest)
	write_json("res://data/comic_art.json",comic)
	print("CARPENTER SEQUENCES: 6 clips / 96 authored frames; foot span ",span)
	quit()
