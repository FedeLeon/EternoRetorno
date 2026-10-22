extends SceneTree
## Merge new authored hero banks, retaining other heroes and all saved-game IDs.
const BASE = "res://art_sources/hero_sequences_2026_10_22/"
const Geometry = preload("res://scripts/hero_sequence_geometry.gd")
const Pack = preload("res://scripts/sketchbook_sheet_packer.gd")
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
	var partial = OS.get_cmdline_user_args().has("--partial")
	var selected_hero = ""
	var selected_clip = ""
	for argument in OS.get_cmdline_user_args():
		if argument.begins_with("--hero="): selected_hero = argument.trim_prefix("--hero=")
		if argument.begins_with("--clip="): selected_clip = argument.trim_prefix("--clip=")
	if not require(selected_hero.is_empty() or selected_hero in ["guardian","rogue","mage"],"Unknown hero: "+selected_hero): return
	if not require(selected_clip.is_empty() or (not selected_hero.is_empty() and selected_clip in ["idle","attack","guard","skill","hurt","death"]),"Select a valid hero and clip"): return
	var banks: Dictionary = read_json("res://data/hero_sprite_sequences.json")
	var stills: Dictionary = read_json("res://data/static_combat.json").heroes
	var manifest: Dictionary = read_json("res://art_sources/art_direction/postapocalyptic/assets.json")
	var comic: Dictionary = read_json("res://data/comic_art.json")
	var provenance: Dictionary = read_json(BASE+"extraction.json") if FileAccess.file_exists(BASE+"extraction.json") else {}
	var count = 0
	for hero in ["guardian","rogue","mage"]:
		if not selected_hero.is_empty() and hero != selected_hero: continue
		var prepared: Array = []
		var span = 160.0
		for job in jobs:
			if job.hero != hero or (not selected_clip.is_empty() and job.id != selected_clip): continue
			var source: String = "res://"+job.source
			if not FileAccess.file_exists(source):
				if partial: continue
				if not require(false,"Missing sequence: "+job.source): return
			print("EXTRACT ",hero,"/",job.id)
			var image = Image.load_from_file(source)
			if not require(image != null and image.detect_alpha()!=Image.ALPHA_NONE,"Transparent source required: "+job.source): return
			var figures = Geometry.figures(image)
			if not require(figures.size()==16,"Expected 16 figures: %s/%s, got %d"%[hero,job.id,figures.size()]): return
			var poses: Array = []
			var contacts: Array[Vector2] = []
			var death_origin = Vector2.ZERO
			for figure in figures:
				var box: Rect2i = figure.bounds
				var pose = Image.create(box.size.x,box.size.y,false,Image.FORMAT_RGBA8)
				pose.fill(Color.TRANSPARENT)
				for point in figure.pixels:
					var pos = Vector2i(point%image.get_width(),point/image.get_width())
					pose.set_pixelv(pos-box.position,image.get_pixelv(pos))
				var index = poses.size()
				var boots: Vector2
				if job.id=="death" and index>0:
					boots = death_origin+Vector2.ONE*(float(index%4)*image.get_width()/4-box.position.x)
				else:
					boots = Geometry.feet(pose,true)
					if job.id=="death": death_origin = boots+Vector2.ONE*box.position.x
				var annotation: Array = job.get("foot_contacts",{}).get(str(index),[])
				if annotation.size()==2: boots = Vector2(annotation[0],annotation[1])
				if not require(boots.y-boots.x>25,"Invalid feet: %s/%s/%d"%[hero,job.id,index]): return
				poses.append(pose)
				contacts.append(boots)
			var reference_span = contacts[0].y-contacts[0].x
			# A single import ratio per clip; NEVER resize frames independently.
			for i in poses.size():
				var center = (contacts[i].x+contacts[i].y)*.5
				span = minf(span,340.0*reference_span/poses[i].get_height())
				span = minf(span,(ANCHOR_X-16)*reference_span/maxf(1,center))
				span = minf(span,(CELL.x-ANCHOR_X-16)*reference_span/maxf(1,poses[i].get_width()-center))
			prepared.append({"job":job,"poses":poses,"feet":contacts,"reference_span":reference_span})
		if prepared.is_empty(): continue
		var bank = banks[hero].duplicate(true) if not selected_clip.is_empty() else {"columns":4,"frame_size":[CELL.x,CELL.y],"anchor":[ANCHOR_X,GROUND],"scale":1.0,"clips":{}}
		for item in prepared:
			var job: Dictionary = item.job
			var ratio: float = float(job.frame_height)/item.poses[0].get_height() if job.has("frame_height") else span/item.reference_span
			var atlas = Image.create(CELL.x*4,CELL.y*4,false,Image.FORMAT_RGBA8)
			atlas.fill(Color.TRANSPARENT)
			var path = "assets/combat_sequences/%s/%s.png"%[hero,job.id]
			var clip = {"path":"res://"+path,"duration":job.duration,"loop":job.id=="idle","frames":[],"bounds":[]}
			if job.get("ping_pong",false): clip.ping_pong = true
			if job.has("scale"): clip.scale = job.scale
			if job.id=="attack": clip.contact = .5
			var union = Rect2i()
			var audit: Array = []
			for i in 16:
				var pose: Image = item.poses[i]
				var boots: Vector2 = item.feet[i]
				var center = (boots.x+boots.y)*.5*ratio
				pose.resize(maxi(1,roundi(pose.get_width()*ratio)),maxi(1,roundi(pose.get_height()*ratio)),Image.INTERPOLATE_LANCZOS)
				var area = Pack.bounds(pose,.5)
				var offset = Vector2i(roundi(ANCHOR_X-center),GROUND-area.end.y)
				if not require(offset.x>=0 and offset.x+pose.get_width()<=CELL.x and offset.y>=0,"Clipped pose: %s/%s/%d"%[hero,job.id,i]): return
				atlas.blit_rect(pose,Rect2i(Vector2i.ZERO,pose.get_size()),Vector2i(i%4,i/4)*CELL+offset)
				area.position += offset
				union = area if i==0 else union.merge(area)
				var foot_positions = [boots.x*ratio+offset.x,boots.y*ratio+offset.x,GROUND]
				clip.frames.append({"bounds":[area.position.x,area.position.y,area.size.x,area.size.y],"feet":foot_positions})
				audit.append(foot_positions)
			atlas.fix_alpha_edges()
			DirAccess.make_dir_recursive_absolute("res://"+path.get_base_dir())
			Pack.save(atlas,"res://"+path)
			clip.bounds = [union.position.x,union.position.y,union.size.x,union.size.y]
			bank.clips[job.id] = clip
			manifest[path] = {"sha256":FileAccess.get_sha256("res://"+path),"source":job.source,"source_sha256":FileAccess.get_sha256("res://"+job.source),"style":"postapocalyptic_comic","processing":"16 authored drawings, one fixed scale per sequence, boot registration and atlas packing","outline_baked":false,"origin":{"hero":hero,"action":job.id,"record":"art_sources/hero_sequences_2026_10_22/jobs.json"}}
			comic.baked.erase(path)
			provenance[hero+"/"+job.id] = {"source":job.source,"source_sha256":manifest[path].source_sha256,"runtime":path,"sha256":manifest[path].sha256,"import_scale":ratio,"foot_contacts":audit,"frames":16}
			count += 1
		if not require(bank.clips.has("idle"),"Idle required for "+hero): return
		var old: Dictionary = stills[hero].idle
		if selected_clip.is_empty(): bank.scale = float(old.bounds[3])*float(old.scale)/float(bank.clips.idle.bounds[3])
		banks[hero] = bank
	write_json("res://data/hero_sprite_sequences.json",banks)
	write_json(BASE+"extraction.json",provenance)
	write_json("res://art_sources/art_direction/postapocalyptic/assets.json",manifest)
	write_json("res://data/comic_art.json",comic)
	print("HERO SEQUENCES: %d clips / %d authored frames"%[count,count*16])
	quit()
