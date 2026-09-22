extends SceneTree
# Keep fixed cell coordinates: independently cropping poses makes limbs jump.
func _initialize() -> void:
	var jobs = JSON.parse_string(FileAccess.get_file_as_string("res://docs/comic/motion/prompts.json"))
	for job in jobs:
		var image = Image.load_from_file("res://docs/comic/motion/sources/%s.png" % job.id)
		if image == null or image.get_size() != Vector2i(1536, 1024):
			printerr("Invalid comic sheet: ", job.id)
			quit(1)
			return
		var bounds = Rect2i()
		var cells: Array[Image] = []
		for index in range(4):
			var cell = image.get_region(Rect2i(index%2*768,index/2*512,768,512))
			cells.append(cell)
			var visible = preload("res://scripts/enemy_art_import.gd").opaque_bounds(cell).grow(12).intersection(Rect2i(0,0,768,512))
			bounds = visible if index == 0 else bounds.merge(visible)
		var factor = minf(584.0 / bounds.size.x, 384.0 / bounds.size.y)
		var scaled = Vector2i(Vector2(bounds.size) * factor)
		image = Image.create(1200,800,false,Image.FORMAT_RGBA8)
		image.fill(Color.TRANSPARENT)
		for index in range(4):
			var cell = cells[index].get_region(bounds)
			cell.resize(scaled.x,scaled.y,Image.INTERPOLATE_LANCZOS)
			image.blit_rect(cell,Rect2i(Vector2i.ZERO,scaled),Vector2i(index%2*600,index/2*400)+(Vector2i(600,400)-scaled)/2)
		if image.save_png("res://assets/comic/motion/%s.png" % job.id) != OK:
			quit(1)
			return
	print("Imported 24 comic attack sheets / 96 frames")
	quit()
