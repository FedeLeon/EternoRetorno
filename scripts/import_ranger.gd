extends SceneTree
# Deterministic slicing and nearest scaling; source alpha is preserved.
func _initialize() -> void:
	var source = Image.load_from_file("res://docs/ranger/generated-sheet.png")
	var atlas = Image.create(384, 384, false, Image.FORMAT_RGBA8)
	atlas.fill(Color.TRANSPARENT)
	var rows = [0, 216, 415, 625, 819, 1008, 1168]
	var columns = [0, 229, 453, 679, 899, 1144, 1347]
	for row in range(6):
		for column in range(6):
			var cell = source.get_region(Rect2i(columns[column], rows[row], columns[column + 1] - columns[column], rows[row + 1] - rows[row]))
			cell.resize(roundi(cell.get_width() * 0.25), roundi(cell.get_height() * 0.25), Image.INTERPOLATE_NEAREST)
			var bottom = 0
			for y in range(cell.get_height()):
				for x in range(cell.get_width()):
					if cell.get_pixel(x, y).a >= 0.5:
						bottom = y + 1
			var frame = Image.create(64, 64, false, Image.FORMAT_RGBA8)
			frame.fill(Color.TRANSPARENT)
			frame.blit_rect(cell, Rect2i(Vector2i.ZERO, cell.get_size()), Vector2i((64 - cell.get_width()) / 2, 60 - bottom))
			atlas.blit_rect(frame, Rect2i(0, 0, 64, 64), Vector2i(column * 64, row * 64))
	atlas.save_png("res://assets/ranger/ranger-64.png")
	print("Ranger atlas: 36 frames, 64px, visible baseline y60")
	quit()
