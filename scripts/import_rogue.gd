extends SceneTree
# Deterministic slicing and nearest scaling; source alpha is preserved.
func _initialize() -> void:
	var source = Image.load_from_file("res://docs/rogue/generated-sheet.png")
	var actions = Image.load_from_file("res://docs/rogue/generated-actions.png")
	var atlas = Image.create(768, 768, false, Image.FORMAT_RGBA8)
	atlas.fill(Color.TRANSPARENT)
	var rows = [0, 230, 450, 677, 889, 1090, 1286]
	var columns = [0, 213, 417, 615, 820, 1023, 1223]
	for row in range(6):
		for column in range(6):
			var cell: Image
			if row in [1, 2]:
				cell = actions.get_region(Rect2i(column * 362, (row - 1) * 362, 362, 362))
				cell.resize(170, 170, Image.INTERPOLATE_NEAREST)
			else:
				cell = source.get_region(Rect2i(columns[column], rows[row], columns[column + 1] - columns[column], rows[row + 1] - rows[row]))
				cell.resize(roundi(cell.get_width() * 0.54), roundi(cell.get_height() * 0.54), Image.INTERPOLATE_NEAREST)
			var bottom = 0
			for y in range(cell.get_height()):
				for x in range(cell.get_width()):
					if cell.get_pixel(x, y).a >= 0.5:
						bottom = y + 1
			var frame = Image.create(128, 128, false, Image.FORMAT_RGBA8)
			frame.fill(Color.TRANSPARENT)
			frame.blit_rect(cell, Rect2i(Vector2i.ZERO, cell.get_size()), Vector2i((128 - cell.get_width()) / 2, 120 - bottom))
			atlas.blit_rect(frame, Rect2i(0, 0, 128, 128), Vector2i(column * 128, row * 128))
	atlas.save_png("res://assets/rogue/rogue-128.png")
	print("Rogue atlas: 36 frames, 128px, visible baseline y120")
	quit()
