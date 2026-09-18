extends SceneTree
# Only slices/resizes generated sprite sheets; no repainting or synthetic poses.
const HEIGHTS = preload("res://src/ui/components/combat_actor_scale.gd").IDLE_HEIGHT
func bounds(image: Image) -> Rect2i:
	var low = image.get_size()
	var high = Vector2i(-1, -1)
	for y in range(image.get_height()):
		for x in range(image.get_width()):
			if image.get_pixel(x, y).a > 0.2:
				low = low.min(Vector2i(x, y))
				high = high.max(Vector2i(x, y))
	return Rect2i(low, high - low + Vector2i.ONE)
func _initialize() -> void:
	for hero in HEIGHTS:
		var source = Image.load_from_file("res://docs/running/sources/%s.png" % hero)
		if source == null: quit(1); return
		var cells: Array[Image] = []
		var tallest = 1
		var widest = 1
		for i in range(8):
			var x0 = roundi((i % 4) * source.get_width() / 4.0)
			var x1 = roundi((i % 4 + 1) * source.get_width() / 4.0)
			var y0 = roundi((i / 4) * source.get_height() / 2.0)
			var y1 = roundi((i / 4 + 1) * source.get_height() / 2.0)
			var cell = source.get_region(Rect2i(x0, y0, x1-x0, y1-y0))
			var area = bounds(cell)
			if area.size.x <= 0 or area.size.y <= 0:
				push_error("Empty running frame: " + hero)
				quit(1); return
			cells.append(cell.get_region(area))
			tallest = maxi(tallest, area.size.y)
			widest = maxi(widest, area.size.x)
		var ratio = minf(float(HEIGHTS[hero]) / tallest, 120.0 / widest)
		var atlas = Image.create(1024, 128, false, Image.FORMAT_RGBA8)
		atlas.fill(Color.TRANSPARENT)
		for i in range(8):
			var cell = cells[i]
			cell.resize(maxi(1, roundi(cell.get_width()*ratio)), maxi(1, roundi(cell.get_height()*ratio)), Image.INTERPOLATE_NEAREST)
			# Passing/flight poses rise slightly; contacts land on the existing baseline.
			var lift = [0, 1, 3, 1, 0, 1, 3, 1][i]
			atlas.blit_rect(cell, Rect2i(Vector2i.ZERO, cell.get_size()), Vector2i(i*128+(128-cell.get_width())/2, 120-cell.get_height()-lift))
		atlas.save_png("res://assets/heroes/running/%s.png" % hero)
		print("Imported running: ", hero, " · 8 frames")
	quit()
