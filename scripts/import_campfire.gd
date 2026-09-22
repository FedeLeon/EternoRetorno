extends SceneTree
# Pack an evenly spaced 4x2 image_gen sheet into an eight-frame runtime strip.
func _initialize() -> void:
	var source = Image.load_from_file("res://docs/camp/sources/fire-detailed.png")
	if source == null:
		quit(1)
		return
	source.convert(Image.FORMAT_RGBA8)
	var cell = Vector2i(source.get_width() / 4, source.get_height() / 2)
	var sheet = Image.create(1024, 128, false, Image.FORMAT_RGBA8)
	sheet.fill(Color.TRANSPARENT)
	for i in range(8):
		var frame = source.get_region(Rect2i(Vector2i(i % 4, i / 4) * cell, cell))
		frame.resize(128, 128, Image.INTERPOLATE_NEAREST)
		sheet.blit_rect(frame, Rect2i(0, 0, 128, 128), Vector2i(i * 128, 0))
	sheet.save_png("res://assets/camp/fire-128.png")
	quit()
