extends SceneTree
func _initialize() -> void:
	var sheet=Image.create(1536,576,false,Image.FORMAT_RGBA8)
	sheet.fill(Color.TRANSPARENT)
	var heroes=["warrior","guardian","rogue","mage"]
	for i in range(4):
		var image=Image.load_from_file("res://docs/art_direction/postapocalyptic/sources/identity_%s.png"%heroes[i])
		image.resize(384,576,Image.INTERPOLATE_LANCZOS)
		image.convert(Image.FORMAT_RGBA8)
		sheet.blit_rect(image,Rect2i(Vector2i.ZERO,image.get_size()),Vector2i(i*384,0))
	sheet.save_png("res://docs/art_direction/postapocalyptic/sources/cast_reference.png")
	quit()
