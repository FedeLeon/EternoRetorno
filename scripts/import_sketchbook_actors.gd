extends SceneTree
const Pack = preload("res://scripts/sketchbook_sheet_packer.gd")
const HEROES = ["warrior","guardian","rogue","mage"]
const ACTIONS = ["idle","attack","skill","guard","hurt","death","run","thrust","sweep","charged"]
const CLASSIC_ROWS = {"warrior":["idle","attack","skill","hurt","death"],"guardian":["idle","attack","skill","guard","hurt","death"],"rogue":["idle","attack","skill","guard","hurt","death"],"mage":["idle","attack","skill","guard","hurt","death"]}
func _initialize() -> void:
	var ids = OS.get_cmdline_user_args()
	if ids.is_empty(): ids = HEROES
	var metrics: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://data/detailed_heroes.json"))
	var gear_metrics: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://data/forge_visuals.json"))
	var manifest_path = "res://docs/art_direction/migration/actors.json"
	var manifest: Dictionary = JSON.parse_string(FileAccess.get_file_as_string(manifest_path)) if FileAccess.file_exists(manifest_path) else {}
	for hero in ids:
		if hero not in HEROES: quit(1);return
		var poses = {}
		var widest = 1
		var tallest = 1
		var idle_height = 1
		for action in ACTIONS:
			var source = "res://docs/art_direction/migration/sources/heroes/%s_%s.png" % [hero,action]
			var cells = Pack.cells(source,4,3)
			if cells.size() != 12: push_error("Missing/empty animation: "+source);quit(1);return
			poses[action] = cells
			for cell in cells:
				widest = maxi(widest,cell.get_width());tallest = maxi(tallest,cell.get_height())
				if action == "idle": idle_height = maxi(idle_height,cell.get_height())
		var ratio = minf(224.0/widest,minf(232.0/tallest,204.0/idle_height))
		metrics[hero] = {"idle_height":idle_height*ratio*0.5,"frames":12,"style":"sketchbook"}
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
		print("SKETCHBOOK ACTOR: ",hero," · 120 drawn poses; classic/gait/gear derived")
	FileAccess.open("res://data/detailed_heroes.json",FileAccess.WRITE).store_string(JSON.stringify(metrics,"\t")+"\n")
	FileAccess.open("res://data/forge_visuals.json",FileAccess.WRITE).store_string(JSON.stringify(gear_metrics,"\t")+"\n")
	FileAccess.open(manifest_path,FileAccess.WRITE).store_string(JSON.stringify(manifest,"\t")+"\n")
	quit()
func record(path: String, hero: String, action: String) -> Dictionary:
	var hash = HashingContext.new();hash.start(HashingContext.HASH_SHA256);hash.update(FileAccess.get_file_as_bytes(path))
	return {"sha256":hash.finish().hex_encode(),"hero":hero,"action":action,"source_folder":"docs/art_direction/migration/sources/heroes","processing":"common proportional scale, alpha crops, baseline 240/368; old-size derivatives"}
