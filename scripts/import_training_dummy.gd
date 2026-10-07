extends SceneTree
func _initialize():
	var image=Image.load_from_file("res://docs/combat_depth_2026_10/sources/dummy.png")
	var bounds=preload("res://scripts/import_detailed_heroes.gd").bounds(image)
	image=image.get_region(bounds)
	var ratio=minf(112.0/image.get_width(),112.0/image.get_height())
	image.resize(roundi(image.get_width()*ratio),roundi(image.get_height()*ratio),Image.INTERPOLATE_LANCZOS)
	var output=Image.create(128,128,false,Image.FORMAT_RGBA8);output.fill(Color.TRANSPARENT)
	output.blit_rect(image,Rect2i(Vector2i.ZERO,image.get_size()),Vector2i((128-image.get_width())/2,128-image.get_height()))
	output.save_png("res://assets/combat_depth/dummy.png")
	quit()
