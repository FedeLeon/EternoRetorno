extends SceneTree
## Rasterize native vector symbols while preserving all PNG resource paths.
func _initialize() -> void:
	var base = "res://docs/art_direction/postapocalyptic/"
	var records: Array = JSON.parse_string(FileAccess.get_file_as_string(base+"vectors.json"))
	var manifest: Dictionary = JSON.parse_string(FileAccess.get_file_as_string(base+"assets.json")) if FileAccess.file_exists(base+"assets.json") else {}
	var imported = 0
	var frames_only = "--frames-only" in OS.get_cmdline_user_args()
	var map_icons_only = "--map-icons-only" in OS.get_cmdline_user_args()
	var hud_icons_only = "--hud-icons-only" in OS.get_cmdline_user_args()
	var collection_only = "--collection-only" in OS.get_cmdline_user_args()
	for record in records:
		if frames_only and record.symbol != "card frame": continue
		if map_icons_only and (not record.target.begins_with("assets/map/minimal/") or record.symbol == "route blueprint"): continue
		if hud_icons_only and record.target != "assets/dungeon/bag.png": continue
		if collection_only and not record.target.begins_with("assets/collection/icons/"): continue
		var image = Image.new()
		if image.load_svg_from_string(FileAccess.get_file_as_string("res://"+record.source),4.0)!=OK:
			push_error("Invalid native SVG: "+record.source);quit(1);return
		image.resize(int(record.dimensions[0]),int(record.dimensions[1]),Image.INTERPOLATE_LANCZOS)
		preload("res://scripts/sketchbook_sheet_packer.gd").save(image,"res://"+record.target)
		manifest[record.target] = {"sha256":FileAccess.get_sha256("res://"+record.target),"source":record.source,"source_sha256":FileAccess.get_sha256("res://"+record.source),"style":"postapocalyptic_comic","tool":"native SVG rasterization"}
		imported += 1
	for path in DirAccess.get_files_at("res://assets/ui"):
		if frames_only or map_icons_only or collection_only: continue
		if hud_icons_only and path not in ["deck.svg", "journal.svg"]: continue
		if path.ends_with(".svg"):
			var target = "assets/ui/"+path
			manifest[target] = {"sha256":FileAccess.get_sha256("res://"+target),"style":"postapocalyptic_comic","tool":"native SVG"}
	for path in ["assets/ui/polished/button.svg","assets/ui/polished/panel.svg","assets/icon.svg","assets/map/minimal/current_room.svg"]:
		if frames_only or map_icons_only or hud_icons_only or collection_only: continue
		manifest[path] = {"sha256":FileAccess.get_sha256("res://"+path),"style":"postapocalyptic_comic","tool":"native SVG"}
	if not frames_only and not map_icons_only and not hud_icons_only:
		for path in ["ui/achievements.svg", "ui/unlocks.svg", "ui/history.svg", "ui/hourglass.svg", "ui/victory.svg", "ui/return.svg"]:
			var target = "assets/collection/" + path
			manifest[target] = {"sha256": FileAccess.get_sha256("res://" + target), "style": "postapocalyptic_comic", "tool": "native SVG", "source": "scripts/collection_icons.py", "source_sha256": FileAccess.get_sha256("res://scripts/collection_icons.py")}
	FileAccess.open(base+"assets.json",FileAccess.WRITE).store_string(JSON.stringify(manifest,"\t")+"\n")
	print("COMIC VECTOR ICONS: ",imported)
	quit()
