extends SceneTree
func _initialize() -> void:
	var source = Image.load_from_file("res://docs/title/generated-buttons.png")
	for entry in [["start", Rect2i(144, 230, 1248, 220)], ["options", Rect2i(144, 622, 1248, 210)]]:
		var plate = source.get_region(entry[1])
		plate.resize(416, 72, Image.INTERPOLATE_NEAREST)
		plate.save_png("res://assets/title/" + entry[0] + ".png")
	quit()
