extends SceneTree
## Mechanical normalization of generated transparent masters; no art synthesis.
func _initialize() -> void:
	var catalog: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://data/battle_effects.json"))
	for id in catalog:
		var image = Image.load_from_file("res://docs/battle_effects/refined/sources/%s.png" % id)
		if image == null or image.is_empty():
			push_error("Missing generated effect icon: " + id)
			quit(1)
			return
		image.convert(Image.FORMAT_RGBA8)
		if image.get_pixel(0, 0).a > 0.01:
			push_error("Effect icon requires transparent background: " + id)
			quit(1)
			return
		# Remove near-invisible alpha noise from generated padding before cropping.
		for y in image.get_height():
			for x in image.get_width():
				var alpha = image.get_pixel(x, y).a
				if alpha > 0 and alpha <= 0.01:
					image.set_pixel(x, y, Color.TRANSPARENT)
		var bounds = image.get_used_rect()
		if bounds.size == Vector2i.ZERO or image.get_pixel(0, 0).a > 0:
			push_error("Effect icon requires transparent background: " + id)
			quit(1)
			return
		image = image.get_region(bounds)
		var ratio = 116.0 / maxf(image.get_width(), image.get_height())
		image.resize(maxi(1, roundi(image.get_width() * ratio)), maxi(1, roundi(image.get_height() * ratio)), Image.INTERPOLATE_LANCZOS)
		var canvas = Image.create(128, 128, false, Image.FORMAT_RGBA8)
		canvas.fill(Color.TRANSPARENT)
		canvas.blit_rect(image, Rect2i(Vector2i.ZERO, image.get_size()), (Vector2i(128, 128) - image.get_size()) / 2)
		if canvas.save_png("res://assets/battle_effects/%s.png" % id) != OK:
			push_error("Could not save effect icon: " + id)
			quit(1)
			return
	print("REFINED EFFECT ICONS: ", catalog.size())
	quit()
