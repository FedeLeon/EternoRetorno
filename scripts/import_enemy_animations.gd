extends SceneTree
# Atlas import only: preserve source alpha and use one scale for the entire cycle.
const IDS = ["crypt_bat", "crypt_slime", "crypt_lancer", "crypt_shaman", "crypt_automaton", "skeleton_6"]

func _initialize() -> void:
	DirAccess.make_dir_recursive_absolute("res://assets/enemies/animations")
	for id in IDS:
		var path = "res://docs/enemies/animations/" + id + ".png"
		if not FileAccess.file_exists(path):
			push_error("Missing animation source: " + path)
			quit(1)
			return
		var source = Image.load_from_file(path)
		var cells: Array[Image] = []
		var anchors: Array[Vector2] = []
		var union = Rect2()
		for index in range(8):
			var column = index % 4
			var row = index / 4
			var edges = [0, source.get_width() / 4, source.get_width() / 2, source.get_width() * 3 / 4, source.get_width()]
			# The bat's horizontal wing extends into the generated gutter.
			if id == "crypt_bat":
				edges[3] = 1350
			var top = row * source.get_height() / 2
			var bottom = (row + 1) * source.get_height() / 2
			var cell = source.get_region(Rect2i(edges[column], top, edges[column + 1] - edges[column], bottom - top))
			var bounds = cell.get_used_rect()
			var anchor = Vector2(cell.get_width() / 2.0, visible_bottom(cell))
			if id == "crypt_bat":
				anchor = eye_anchor(cell)
			var relative = Rect2(Vector2(bounds.position) - anchor, Vector2(bounds.size))
			union = relative if index == 0 else union.merge(relative)
			cells.append(cell)
			anchors.append(anchor)
		var factor = minf(108.0 / union.size.x, 110.0 / union.size.y)
		var pivot = Vector2(64 - union.get_center().x * factor, 120 - union.end.y * factor)
		var atlas = Image.create(1024, 128, false, Image.FORMAT_RGBA8)
		atlas.fill(Color.TRANSPARENT)
		for index in range(8):
			var source_index = [0, 7, 1, 2, 3, 4, 6, 5][index] if id == "crypt_bat" else index
			var cell = cells[source_index]
			var origin = (pivot - anchors[source_index] * factor).round()
			cell.resize(maxi(1, roundi(cell.get_width() * factor)), maxi(1, roundi(cell.get_height() * factor)), Image.INTERPOLATE_NEAREST)
			var frame = Image.create(128, 128, false, Image.FORMAT_RGBA8)
			frame.fill(Color.TRANSPARENT)
			frame.blit_rect(cell, Rect2i(Vector2i.ZERO, cell.get_size()), Vector2i(origin))
			# Grounded silhouettes share the visible floor; bat is aligned by its eye.
			if id != "crypt_bat":
				var grounded = Image.create(128, 128, false, Image.FORMAT_RGBA8)
				grounded.fill(Color.TRANSPARENT)
				grounded.blit_rect(frame, Rect2i(0, 0, 128, 128), Vector2i(0, 120 - visible_bottom(frame)))
				frame = grounded
			atlas.blit_rect(frame, Rect2i(0, 0, 128, 128), Vector2i(index * 128, 0))
		atlas.save_png("res://assets/enemies/animations/" + id + ".png")
		print(id + ": 8 transparent 128px frames")
	quit()

func visible_bottom(cell: Image) -> int:
	for y in range(cell.get_height() - 1, -1, -1):
		for x in range(cell.get_width()):
			if cell.get_pixel(x, y).a >= 0.5:
				return y + 1
	return cell.get_used_rect().end.y

func eye_anchor(cell: Image) -> Vector2:
	var total = Vector2.ZERO
	var count = 0
	for y in range(cell.get_height()):
		for x in range(int(cell.get_width() * 0.45)):
			var color = cell.get_pixel(x, y)
			if color.a > 0.5 and color.r > 0.85 and color.g < 0.55 and color.b < 0.35:
				total += Vector2(x, y)
				count += 1
	assert(count > 0, "Bat reference must retain its red eye")
	return total / maxf(count, 1)
