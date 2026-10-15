extends SceneTree
const Pack = preload("res://scripts/sketchbook_sheet_packer.gd")
const HEROES = ["warrior","guardian","rogue","mage"]
const ACTIONS = ["idle","attack","skill","guard","hurt","death","run","thrust","sweep","charged"]
var source_signatures: Dictionary = {}
const CLASSIC_ROWS = {"warrior":["idle","attack","skill","hurt","death"],"guardian":["idle","attack","skill","guard","hurt","death"],"rogue":["idle","attack","skill","guard","hurt","death"],"mage":["idle","attack","skill","guard","hurt","death"]}
func _initialize() -> void:
	var ids = OS.get_cmdline_user_args()
	ids.erase("--comic")
	if ids.is_empty(): ids = HEROES
	var metrics: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://data/detailed_heroes.json"))
	var gear_metrics: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://data/forge_visuals.json"))
	var manifest_path = "res://docs/art_direction/postapocalyptic/assets.json"
	var manifest: Dictionary = JSON.parse_string(FileAccess.get_file_as_string(manifest_path)) if FileAccess.file_exists(manifest_path) else {}
	for hero in ids:
		if hero not in HEROES: quit(1);return
		var bank_image = Image.load_from_file("res://docs/art_direction/postapocalyptic/sources/heroes__detail__%s_attack.png" % hero)
		if bank_image == null or bank_image.detect_alpha() == Image.ALPHA_NONE:
			push_error("Civilian pose bank must have transparent background: " + hero);quit(1);return
		var poses = {}
		var comic_bank: Array[Image] = []
		var comic_idle: Array[Image] = []
		var layout: Dictionary = {}
		comic_idle = Pack.cells("res://docs/art_direction/postapocalyptic/sources/heroes__detail__%s_idle.png" % hero,4,3)
		layout = JSON.parse_string(FileAccess.get_file_as_string("res://docs/animation_review/pose_layouts.json"))[hero]
		comic_bank = Pack.actor_cells("res://docs/art_direction/postapocalyptic/sources/heroes__detail__%s_attack.png" % hero,6,4,layout.columns)
		if comic_bank.size() == 23: comic_bank.append(comic_bank[0])
		if comic_idle.size()!=12 or comic_bank.size()!=24: push_error("Invalid civilian pose bank: "+hero);quit(1);return
		var idle_extent = 0.0
		for pose in comic_idle: idle_extent = maxf(idle_extent,pose.get_height())
		var bank_extent = (comic_bank[0].get_height()+comic_bank[1].get_height()+comic_bank[2].get_height())/3.0
		var normalization = idle_extent/maxf(bank_extent,1.0)
		for pose in comic_bank:
			pose.resize(maxi(1,roundi(pose.get_width()*normalization)),maxi(1,roundi(pose.get_height()*normalization)),Image.INTERPOLATE_LANCZOS)
		var widest = 1
		var tallest = 1
		var idle_height = 1
		for action in ACTIONS:
			var source = "pose bank: " + hero + " / " + action
			var cells: Array[Image] = []
			if action != "idle":
				var bank = comic_bank
				if bank.size()!=24: push_error("Missing civilian pose bank: "+hero);quit(1);return
				var keys: Array = layout.get("skill" if action == "charged" else "attack" if action in ["thrust","sweep"] else action)
				var timing = [0,0,0,1,1,2,2,2,3,3,-1,-1]
				if action == "guard": timing = [0,0,0,1,1,1,1,1,1,0,0,-1]
				elif action == "hurt": timing = [0,0,0,1,1,1,1,1,-1,-1,-1,-1]
				elif action == "death": timing = [0,0,0,0,1,1,1,1,2,2,2,2]
				elif action == "run": timing = [0,0,1,1,2,2,3,3,4,4,5,5]
				var sequence: Array = []
				for key in timing: sequence.append(0 if key < 0 else keys[key])
				for frame in sequence: cells.append(bank[frame])
			else:
				cells = comic_idle
			if cells.size() != 12: push_error("Missing/empty animation: "+source);quit(1);return
			poses[action] = cells
			for cell in cells:
				widest = maxi(widest,cell.get_width());tallest = maxi(tallest,cell.get_height())
				if action == "idle": idle_height = maxi(idle_height,cell.get_height())
		var ratio = minf(224.0/widest,minf(232.0/tallest,204.0/idle_height))
		metrics[hero] = {"idle_height":idle_height*ratio*0.5,"frames":12,"style":"postapocalyptic_comic"}
		for action in ACTIONS:
			var large = action in ["thrust","sweep","charged"]
			var folder = "actions" if large else "detail"
			var path = "res://assets/heroes/%s/%s_%s.png" % [folder,hero,action]
			Pack.save(Pack.pack(poses[action],4,384 if large else 256,ratio,368 if large else 240),path)
			manifest[path.trim_prefix("res://")] = record(path,hero,action)
		# Preserve old atlas dimensions for existing map/forge actors and saved IDs.
		var classic = Image.create(768,CLASSIC_ROWS[hero].size()*128,false,Image.FORMAT_RGBA8)
		classic.fill(Color.TRANSPARENT)
		for row in range(CLASSIC_ROWS[hero].size()):
			var selected: Array[Image] = []
			for i in range(6): selected.append(poses[CLASSIC_ROWS[hero][row]][i*2])
			var strip = Pack.pack(selected,6,128,ratio*0.5,120)
			classic.blit_rect(strip,Rect2i(Vector2i.ZERO,strip.get_size()),Vector2i(0,row*128))
		var path = "res://assets/%s/%s-128.png" % [hero,hero]
		Pack.save(classic,path);manifest[path.trim_prefix("res://")] = record(path,hero,"classic")
		var classic_height = 0
		for frame in range(6): classic_height = maxi(classic_height,Pack.bounds(classic.get_region(Rect2i(frame*128,0,128,128)),0.5).size.y)
		var gait: Array[Image] = []
		for frame in [0,1,3,4,6,7,9,10]: gait.append(poses.run[frame])
		path = "res://assets/heroes/running/%s.png" % hero
		Pack.save(Pack.pack(gait,8,128,ratio*0.5,120),path);manifest[path.trim_prefix("res://")] = record(path,hero,"run")
		for weapon in range(4):
			for armor in range(4):
				var equipped = classic.duplicate()
				for y in range(equipped.get_height()):
					for x in range(equipped.get_width()):
						var color = equipped.get_pixel(x,y)
						if color.a == 0: continue
						var tint = color.lerp(Color(0.49,0.41,0.57,color.a),weapon*0.0137+armor*0.0245)
						equipped.set_pixel(x,y,tint)
				path = "res://assets/forge/heroes/%s_w%d_a%d.png" % [hero,weapon,armor]
				Pack.save(equipped,path);manifest[path.trim_prefix("res://")] = record(path,hero,"equipment derivative")
				gear_metrics["%s_w%d_a%d" % [hero,weapon,armor]] = classic_height
		print("COMIC ACTOR: ", hero, " · civilian pose layouts, 12-frame clips and classic/gait/gear derived")
	FileAccess.open("res://data/detailed_heroes.json",FileAccess.WRITE).store_string(JSON.stringify(metrics,"\t")+"\n")
	FileAccess.open("res://data/forge_visuals.json",FileAccess.WRITE).store_string(JSON.stringify(gear_metrics,"\t")+"\n")
	FileAccess.open(manifest_path,FileAccess.WRITE).store_string(JSON.stringify(manifest,"\t")+"\n")
	quit()
func record(path: String, hero: String, action: String) -> Dictionary:
	var hash = HashingContext.new();hash.start(HashingContext.HASH_SHA256);hash.update(FileAccess.get_file_as_bytes(path))
	var result = {"sha256":hash.finish().hex_encode(),"hero":hero,"action":action,"source_folder":"docs/art_direction/postapocalyptic/sources","processing":"common proportional scale, adaptive gutters and principal-silhouette crop, baseline 240/368; old-size derivatives"}
	if not source_signatures.has(hero):
		var inputs = {}
		for kind in ["idle","attack"]:
			var source = "docs/art_direction/postapocalyptic/sources/heroes__detail__%s_%s.png" % [hero,kind]
			inputs[source] = FileAccess.get_sha256("res://"+source)
		inputs["docs/animation_review/pose_layouts.json"] = FileAccess.get_sha256("res://docs/animation_review/pose_layouts.json")
		source_signatures[hero] = inputs
	result["inputs_sha256"] = source_signatures[hero]
	result["processing_version"] = 5
	return result
