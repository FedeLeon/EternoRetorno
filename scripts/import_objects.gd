extends SceneTree
func _initialize() -> void:
	var source = Image.load_from_file("res://docs/objects/generated-sheet.png")
	var atlas = Image.create(256, 256, false, Image.FORMAT_RGBA8)
	atlas.fill(Color.TRANSPARENT)
	var rows = [0, 310, 580, 845, 1182]
	for i in range(16):
		var w = source.get_width() / 4
		var row = i / 4
		var h = rows[row + 1] - rows[row]
		var cell = source.get_region(Rect2i((i % 4) * w, rows[row], w, h))
		cell.resize(60, roundi(h * 60.0 / w), Image.INTERPOLATE_NEAREST)
		atlas.blit_rect(cell, Rect2i(Vector2i.ZERO, cell.get_size()), Vector2i((i % 4) * 64 + 2, row * 64 + (64 - cell.get_height()) / 2))
	atlas.save_png("res://assets/objects/icons.png")
	quit()
