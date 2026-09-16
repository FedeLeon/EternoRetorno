extends SceneTree
func _initialize() -> void:
	var catalog = JSON.parse_string(FileAccess.get_file_as_string("res://data/enemy_visuals.json"))
	for id in catalog:
		var entry = catalog[id]
		var source = Image.load_from_file("res://docs/enemies/sheet-%d.png" % entry.sheet)
		var column = int(entry.index) % 4
		var row = int(entry.index) / 4
		var edges = [0, 443, 887, 1330, source.get_width()]
		# Spears and axes slightly cross the nominal generated grid.
		if int(entry.sheet) == 4 and row == 1:
			edges = [0, 430, 805, 1300, source.get_width()]
		if int(entry.sheet) == 6:
			edges = [0, 443, 900, 1300 if row == 1 else 1330, source.get_width()]
		var h = source.get_height() / 2
		var cell = source.get_region(Rect2i(edges[column], row * h, edges[column + 1] - edges[column], h))
		var bounds = cell.get_used_rect()
		var figure = cell.get_region(bounds)
		var factor = minf(54.0 / figure.get_width(), 52.0 / figure.get_height())
		figure.resize(maxi(1, roundi(figure.get_width() * factor)), maxi(1, roundi(figure.get_height() * factor)), Image.INTERPOLATE_NEAREST)
		# Resampling can drop faint edge pixels; align the actual final silhouette.
		figure = figure.get_region(figure.get_used_rect())
		var out = Image.create(64, 64, false, Image.FORMAT_RGBA8)
		out.fill(Color.TRANSPARENT)
		out.blit_rect(figure, Rect2i(Vector2i.ZERO, figure.get_size()), Vector2i((64 - figure.get_width()) / 2, 60 - figure.get_height()))
		out.save_png("res://assets/enemies/" + id + ".png")
	quit()
