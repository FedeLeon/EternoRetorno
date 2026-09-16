extends SceneTree
func _initialize() -> void:
	var source = Image.load_from_file("res://docs/cards/generated-frames.png")
	var ids = ["warrior", "guardian", "rogue", "mage", "cleric", "ranger"]
	for i in range(6):
		# Extract only the rectangular frame, excluding the presentation backdrop.
		var frame = source.get_region(Rect2i(24 + (i % 3) * 338, 234 + (i / 3) * 610, 302, 482))
		frame.resize(96, 144, Image.INTERPOLATE_NEAREST)
		frame.save_png("res://assets/cards/" + ids[i] + ".png")
	quit()
