extends RefCounted
# Shared deterministic packing for 4x2 motion sheets and transparent cut-ins.
static func motion(source_path: String, output_path: String) -> bool:
	var source = Image.load_from_file(source_path)
	if source == null or source.get_width() % 4 != 0 or source.get_height() % 2 != 0: return false
	var cells: Array[Image] = []
	var widest = 1
	var tallest = 1
	for i in range(8):
		var cell = source.get_region(Rect2i((i % 4) * source.get_width() / 4, (i / 4) * source.get_height() / 2, source.get_width() / 4, source.get_height() / 2))
		var bounds = opaque_bounds(cell)
		if bounds.size == Vector2i.ZERO: return false
		widest = maxi(widest, bounds.size.x)
		tallest = maxi(tallest, bounds.size.y)
		cells.append(cell.get_region(bounds))
	var factor = minf(112.0 / widest, 110.0 / tallest)
	var atlas = Image.create(1024, 128, false, Image.FORMAT_RGBA8)
	atlas.fill(Color.TRANSPARENT)
	for i in range(8):
		var cell = cells[i]
		cell.resize(maxi(1, roundi(cell.get_width() * factor)), maxi(1, roundi(cell.get_height() * factor)), Image.INTERPOLATE_NEAREST)
		var bottom = visible_bottom(cell)
		atlas.blit_rect(cell, Rect2i(Vector2i.ZERO, cell.get_size()), Vector2i(i * 128 + (128 - cell.get_width()) / 2, 120 - bottom))
	return atlas.save_png(output_path) == OK

static func cutin(source_path: String, output_path: String) -> bool:
	var image = Image.load_from_file(source_path)
	if image == null: return false
	image.resize(900, roundi(image.get_height() * 900.0 / image.get_width()), Image.INTERPOLATE_LANCZOS)
	return image.save_png(output_path) == OK

static func opaque_bounds(image: Image) -> Rect2i:
	var left = image.get_width()
	var top = image.get_height()
	var right = 0
	var bottom = 0
	for y in range(image.get_height()):
		for x in range(image.get_width()):
			if image.get_pixel(x, y).a < 0.5: continue
			left = mini(left, x)
			top = mini(top, y)
			right = maxi(right, x + 1)
			bottom = maxi(bottom, y + 1)
	return Rect2i() if right <= left or bottom <= top else Rect2i(left, top, right - left, bottom - top)
static func visible_bottom(image: Image) -> int:
	for y in range(image.get_height() - 1, -1, -1):
		for x in range(image.get_width()):
			if image.get_pixel(x, y).a >= 0.5: return y + 1
	return image.get_height()
