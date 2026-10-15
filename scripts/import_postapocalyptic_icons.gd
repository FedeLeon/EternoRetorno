extends SceneTree
## Rasterize native vector symbols while preserving all PNG resource paths.
func _initialize() -> void:
	var base = "res://docs/art_direction/postapocalyptic/"
	var records: Array = JSON.parse_string(FileAccess.get_file_as_string(base+"vectors.json"))
	var manifest: Dictionary = JSON.parse_string(FileAccess.get_file_as_string(base+"assets.json")) if FileAccess.file_exists(base+"assets.json") else {}
	for record in records:
		var image = Image.new()
		if image.load_svg_from_string(FileAccess.get_file_as_string("res://"+record.source),4.0)!=OK:
			push_error("Invalid native SVG: "+record.source);quit(1);return
		image.resize(int(record.dimensions[0]),int(record.dimensions[1]),Image.INTERPOLATE_LANCZOS)
		preload("res://scripts/sketchbook_sheet_packer.gd").save(image,"res://"+record.target)
		manifest[record.target] = {"sha256":FileAccess.get_sha256("res://"+record.target),"source":record.source,"source_sha256":FileAccess.get_sha256("res://"+record.source),"style":"postapocalyptic_comic","tool":"native SVG rasterization"}
	for path in DirAccess.get_files_at("res://assets/ui"):
		if path.ends_with(".svg"):
			var target = "assets/ui/"+path
			manifest[target] = {"sha256":FileAccess.get_sha256("res://"+target),"style":"postapocalyptic_comic","tool":"native SVG"}
	for path in ["assets/ui/polished/button.svg","assets/ui/polished/panel.svg","assets/icon.svg","assets/collection/secret.svg","assets/map/minimal/current_room.svg"]:
		manifest[path] = {"sha256":FileAccess.get_sha256("res://"+path),"style":"postapocalyptic_comic","tool":"native SVG"}
	FileAccess.open(base+"assets.json",FileAccess.WRITE).store_string(JSON.stringify(manifest,"\t")+"\n")
	print("COMIC VECTOR ICONS: ",records.size())
	quit()
