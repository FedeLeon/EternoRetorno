extends SceneTree
# Deterministic packaging of image_gen sources; preserve character alpha.
const HEROES = ["warrior", "guardian", "rogue", "mage", "cleric", "ranger"]
func _initialize() -> void:
	for id in ["background", "heal", "upgrade"] + HEROES:
		var image = Image.load_from_file("res://docs/rest/sources/%s.png" % id)
		if image == null:
			push_error("Missing rest source: " + id)
			quit(1)
			return
		if id in HEROES:
			image.convert(Image.FORMAT_RGBA8)
			# Ignore near-invisible generator padding when finding the silhouette.
			var bounds = Rect2i()
			for y in range(image.get_height()):
				for x in range(image.get_width()):
					if image.get_pixel(x, y).a > 0.125:
						var pixel = Rect2i(x, y, 1, 1)
						bounds = bounds.merge(pixel) if bounds.has_area() else pixel
			image = image.get_region(bounds)
			var ratio = minf(300.0 / image.get_width(), 244.0 / image.get_height())
			image.resize(roundi(image.get_width() * ratio), roundi(image.get_height() * ratio), Image.INTERPOLATE_NEAREST)
			var canvas = Image.create(320, 256, false, Image.FORMAT_RGBA8)
			canvas.fill(Color.TRANSPARENT)
			canvas.blit_rect(image, Rect2i(Vector2i.ZERO, image.get_size()), Vector2i((320 - image.get_width()) / 2, 250 - image.get_height()))
			image = canvas
		else:
			var width = 1280 if id == "background" else 384
			image.resize(width, roundi(image.get_height() * float(width) / image.get_width()), Image.INTERPOLATE_LANCZOS)
		image.save_png("res://assets/rest/%s.png" % id)
	quit()
