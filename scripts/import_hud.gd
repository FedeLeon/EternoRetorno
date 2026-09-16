extends SceneTree
func _initialize() -> void:
	var orb = Image.load_from_file("res://docs/hud/energy-source.png")
	orb = orb.get_region(orb.get_used_rect())
	orb.resize(128, 128, Image.INTERPOLATE_NEAREST)
	orb.save_png("res://assets/ui/energy.png")
	var sheet = Image.load_from_file("res://docs/hud/digits-source.png")
	for digit in range(10):
		var left = int((digit % 5) * sheet.get_width() / 5.0)
		var right = int((digit % 5 + 1) * sheet.get_width() / 5.0)
		var row_height = sheet.get_height() / 2
		var cell = sheet.get_region(Rect2i(left, (digit / 5) * row_height, right - left, row_height))
		cell = cell.get_region(cell.get_used_rect())
		var factor = minf(30.0 / cell.get_width(), 44.0 / cell.get_height())
		cell.resize(roundi(cell.get_width() * factor), roundi(cell.get_height() * factor), Image.INTERPOLATE_NEAREST)
		var glyph = Image.create(32, 48, false, Image.FORMAT_RGBA8)
		glyph.fill(Color.TRANSPARENT)
		glyph.blit_rect(cell, Rect2i(Vector2i.ZERO, cell.get_size()), Vector2i((32 - cell.get_width()) / 2, 46 - cell.get_height()))
		glyph.save_png("res://assets/ui/numbers/%d.png" % digit)
	quit()
