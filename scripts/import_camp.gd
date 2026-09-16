extends SceneTree

func _initialize() -> void:
	for kind in ["front", "fire"]:
		var source = Image.load_from_file("res://docs/camp/%s-source.png" % kind)
		var atlas = Image.create(384, 64, false, Image.FORMAT_RGBA8)
		atlas.fill(Color.TRANSPARENT)
		for index in range(6):
			var cell = source.get_region(Rect2i(index * 362, 0, 362, 724))
			# Common scale preserves body sizes and the flame's varying height.
			cell.resize(44, 88, Image.INTERPOLATE_NEAREST)
			var bottom = 0
			for y in range(cell.get_height()):
				for x in range(cell.get_width()):
					if cell.get_pixel(x, y).a >= 0.5:
						bottom = y + 1
			var frame = Image.create(64, 64, false, Image.FORMAT_RGBA8)
			frame.fill(Color.TRANSPARENT)
			frame.blit_rect(cell, Rect2i(Vector2i.ZERO, cell.get_size()), Vector2i(10, 60 - bottom))
			atlas.blit_rect(frame, Rect2i(0, 0, 64, 64), Vector2i(index * 64, 0))
		atlas.save_png("res://assets/camp/%s-64.png" % kind)
	quit()
