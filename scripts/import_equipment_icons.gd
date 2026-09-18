extends SceneTree
# Crop the generated transparent sheets; preserve alpha and normalize to HUD size.
func _initialize() -> void:
	var groups = [["warrior", "guardian"], ["rogue", "mage"], ["cleric", "ranger"], ["armor"]]
	for sheet in range(4):
		var source = Image.load_from_file("res://docs/forge/hud-sources/sheet%d.png" % (sheet + 1))
		if source == null:
			push_error("Missing equipment sheet")
			quit(1)
			return
		var cell_width = source.get_width() / 3
		var cell_height = source.get_height() / groups[sheet].size()
		for row in range(groups[sheet].size()):
			for column in range(3):
				var item = source.get_region(Rect2i(column * cell_width, row * cell_height, cell_width, cell_height))
				item = item.get_region(silhouette_bounds(item))
				var factor = 112.0 / maxi(item.get_width(), item.get_height())
				item.resize(maxi(1, roundi(item.get_width() * factor)), maxi(1, roundi(item.get_height() * factor)), Image.INTERPOLATE_LANCZOS)
				var output = Image.create(128, 128, false, Image.FORMAT_RGBA8)
				output.blit_rect(item, Rect2i(Vector2i.ZERO, item.get_size()), (Vector2i(128, 128) - item.get_size()) / 2)
				output.save_png("res://assets/forge/icons/%s_%d.png" % [groups[sheet][row], column + 1])
	quit()

func silhouette_bounds(image: Image) -> Rect2i:
	var left = image.get_width()
	var top = image.get_height()
	var right = 0
	var bottom = 0
	for y in range(image.get_height()):
		for x in range(image.get_width()):
			if image.get_pixel(x, y).a < 0.25: continue
			left = mini(left, x)
			top = mini(top, y)
			right = maxi(right, x + 1)
			bottom = maxi(bottom, y + 1)
	return Rect2i(left, top, right - left, bottom - top)
