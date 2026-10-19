extends SceneTree
## Offline SVG rasterization only. Existing runtime paths, sizes and UIDs stay intact.
func _initialize() -> void:
	var folder="res://art_sources/battle_effects/minimal_comic_2026_10_19/"
	var records: Array=JSON.parse_string(FileAccess.get_file_as_string(folder+"assets.json"))
	var path="res://art_sources/art_direction/postapocalyptic/assets.json"
	var manifest: Dictionary=JSON.parse_string(FileAccess.get_file_as_string(path))
	for record in records:
		var source="res://"+record.source
		var target="res://"+record.target
		if not record.get("native",false):
			var image=Image.new()
			if image.load_svg_from_string(FileAccess.get_file_as_string(source),4.0)!=OK:
				push_error("Invalid combat icon: "+record.id);quit(1);return
			image.resize(int(record.dimensions[0]),int(record.dimensions[1]),Image.INTERPOLATE_LANCZOS)
			preload("res://scripts/sketchbook_sheet_packer.gd").save(image,target)
		manifest[record.target]={"sha256":FileAccess.get_sha256(target),"source":record.source,"source_sha256":FileAccess.get_sha256(source),"style":"postapocalyptic_comic","tool":"native SVG; flat minimal comic silhouette","minimal_combat_revision":1}
	FileAccess.open(path,FileAccess.WRITE).store_string(JSON.stringify(manifest,"\t")+"\n")
	print("MINIMAL COMBAT ICONS: ",records.size()," assets updated")
	quit()
