extends SceneTree
# Normalize generated gear sheets to the existing 128px animation contract.
# Cropping/resizing only; source artwork and alpha remain available in docs/forge.
const HEROES = ["warrior", "guardian", "rogue", "mage", "cleric", "ranger"]
func bounds(image: Image) -> Rect2i:
	var low = Vector2i(image.get_width(), image.get_height())
	var high = Vector2i(-1, -1)
	for y in range(image.get_height()):
		for x in range(image.get_width()):
			if image.get_pixel(x, y).a > 0.2:
				low = low.min(Vector2i(x, y))
				high = high.max(Vector2i(x, y))
	return Rect2i() if high.x < 0 else Rect2i(low, high - low + Vector2i.ONE)
func _initialize() -> void:
	DirAccess.make_dir_recursive_absolute("res://assets/forge/heroes")
	var count = 0
	for hero in HEROES:
		var rows = 5 if hero == "warrior" else 6
		var reference = Image.load_from_file("res://assets/%s/%s-128.png" % [hero, hero])
		for weapon in range(4):
			for armor in range(4):
				var name = "%s_w%d_a%d" % [hero, weapon, armor]
				var source_path = "res://docs/forge/sources/%s.png" % name
				var destination = "res://assets/forge/heroes/%s.png" % name
				if not FileAccess.file_exists(source_path) or FileAccess.file_exists(destination):
					continue
				var source = Image.load_from_file(source_path)
				var sheet = Image.create(768, rows * 128, false, Image.FORMAT_RGBA8)
				for row in range(rows):
					var cells: Array = []
					var reference_bounds: Array = []
					var tallest = 1.0
					var reference_height = 1.0
					var widest = 1.0
					for col in range(6):
						var x0 = roundi(col * source.get_width() / 6.0)
						var x1 = roundi((col + 1) * source.get_width() / 6.0)
						var y0 = roundi(row * source.get_height() / float(rows))
						var y1 = roundi((row + 1) * source.get_height() / float(rows))
						var cell = source.get_region(Rect2i(x0, y0, x1 - x0, y1 - y0))
						var area = bounds(cell)
						if area.size.x == 0:
							push_error("Empty frame: " + name)
							quit(1)
							return
						cells.append(cell.get_region(area))
						tallest = maxf(tallest, area.size.y)
						widest = maxf(widest, area.size.x)
						var old = bounds(reference.get_region(Rect2i(col * 128, row * 128, 128, 128)))
						reference_bounds.append(old)
						reference_height = maxf(reference_height, old.size.y)
					var ratio = minf(reference_height / tallest, 120.0 / widest)
					for col in range(6):
						var cell = cells[col]
						cell.resize(maxi(1, roundi(cell.get_width() * ratio)), maxi(1, roundi(cell.get_height() * ratio)), Image.INTERPOLATE_NEAREST)
						var old = reference_bounds[col]
						var x = clampi(roundi(old.get_center().x - cell.get_width() / 2.0), 0, 128 - cell.get_width())
						var y = clampi(old.end.y - cell.get_height(), 0, 128 - cell.get_height())
						sheet.blit_rect(cell, Rect2i(Vector2i.ZERO, cell.get_size()), Vector2i(col * 128 + x, row * 128 + y))
				sheet.save_png(destination)
				print("Imported ", name)
				count += 1
	print("Forge atlases imported: ", count)
	var metrics: Dictionary = {}
	for hero in HEROES:
		for weapon in range(4):
			for armor in range(4):
				var key = "%s_w%d_a%d" % [hero, weapon, armor]
				var path = "res://assets/forge/heroes/%s.png" % key
				if not FileAccess.file_exists(path): continue
				var atlas = Image.load_from_file(path)
				var height = 1
				for i in range(6):
					height = maxi(height, bounds(atlas.get_region(Rect2i(i * 128, 0, 128, 128))).size.y)
				metrics[key] = height
	FileAccess.open("res://data/forge_visuals.json", FileAccess.WRITE).store_string(JSON.stringify(metrics, "\t"))
	quit()
