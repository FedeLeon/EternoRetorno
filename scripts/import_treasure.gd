extends SceneTree
# Slice generated alpha artwork; fixed scale and common floor across all poses.
func _initialize() -> void:
	var source = Image.load_from_file("res://docs/treasure/chest-source.png")
	var atlas = Image.create(1536, 256, false, Image.FORMAT_RGBA8)
	atlas.fill(Color.TRANSPARENT)
	for index in range(6):
		var cell = source.get_region(Rect2i((index % 3) * 512, (index / 3) * 512, 512, 512))
		cell.resize(256, 256, Image.INTERPOLATE_NEAREST)
		var bottom = 0
		for y in range(256):
			for x in range(256):
				if cell.get_pixel(x, y).a > 0.5:
					bottom = y + 1
		var frame = Image.create(256, 256, false, Image.FORMAT_RGBA8)
		frame.fill(Color.TRANSPARENT)
		frame.blit_rect(cell, Rect2i(0, 0, 256, 256), Vector2i(0, 240 - bottom))
		atlas.blit_rect(frame, Rect2i(0, 0, 256, 256), Vector2i(index * 256, 0))
	DirAccess.make_dir_recursive_absolute("res://assets/treasure")
	atlas.save_png("res://assets/treasure/chest.png")
	quit()
