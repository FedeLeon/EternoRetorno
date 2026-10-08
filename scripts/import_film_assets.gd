extends SceneTree
# Normalize new generated artwork for runtime; retain originals and provenance.
func _initialize() -> void:
	DirAccess.make_dir_recursive_absolute("res://assets/cinematics/shots")
	var sources: Array = JSON.parse_string(FileAccess.get_file_as_string("res://docs/cinematics/film/sources.json"))
	for source in sources:
		var image = Image.load_from_file("res://docs/cinematics/film/sources/%s.png" % source.id)
		if image == null: quit(1); return
		var width = mini(image.get_width(),floori(image.get_height()*16.0/9.0))
		var height = floori(width*9.0/16.0)
		image = image.get_region(Rect2i((image.get_width()-width)/2,(image.get_height()-height)/2,width,height))
		image.resize(1280,720,Image.INTERPOLATE_LANCZOS)
		image.save_png("res://"+source.asset)
	for pair in [["building","projects_building",512],["training","training_icon",192]]:
		var image = Image.load_from_file("res://docs/base_camp/projects/sources/%s.png" % pair[0])
		if image == null: quit(1); return
		image = image.get_region(image.get_used_rect())
		var factor = float(pair[2])/maxi(image.get_width(),image.get_height())
		image.resize(roundi(image.get_width()*factor),roundi(image.get_height()*factor),Image.INTERPOLATE_NEAREST)
		image.save_png("res://assets/base_camp/%s.png" % pair[1])
	print("21 cinematic shots and two camp assets imported; no game export")
	quit()
