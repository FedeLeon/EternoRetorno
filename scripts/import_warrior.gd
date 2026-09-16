extends SceneTree
# Deterministic atlas slicing of imagegen output; no background removal or repainting.
func _initialize() -> void:
	var source = Image.load_from_file("res://docs/warrior/generated-sheet.png")
	var atlas = Image.create(384, 320, false, Image.FORMAT_RGBA8)
	atlas.fill(Color.TRANSPARENT)
	# Transparent gutters in the generated source are not uniformly spaced.
	var row_edges = [0, 260, 490, 730, 942, 1145]
	for row in range(5):
		for column in range(6):
			var cell = source.get_region(Rect2i(column * source.get_width() / 6, row_edges[row], source.get_width() / 6, row_edges[row + 1] - row_edges[row]))
			cell.resize(64, roundi(cell.get_height() * 64.0 / cell.get_width()), Image.INTERPOLATE_NEAREST)
			var bounds = cell.get_used_rect()
			var baseline = bounds.end.y
			if row == 0:
				# Nearly invisible alpha specks below the boots must not lift idle poses.
				baseline = visible_bottom(cell)
			var frame = Image.create(64, 64, false, Image.FORMAT_RGBA8)
			frame.fill(Color.TRANSPARENT)
			frame.blit_rect(cell, bounds, Vector2i(bounds.position.x, 60 - baseline + bounds.position.y))
			atlas.blit_rect(frame, Rect2i(0, 0, 64, 64), Vector2i(column * 64, row * 64))
	atlas.save_png("res://assets/warrior/warrior-64.png")
	print("Warrior atlas: 384x320, 30 frames, transparent, grounded at y60")
	quit()

func visible_bottom(cell: Image) -> int:
	for y in range(cell.get_height() - 1, -1, -1):
		for x in range(cell.get_width()):
			if cell.get_pixel(x, y).a >= 0.5:
				return y + 1
	return cell.get_used_rect().end.y
