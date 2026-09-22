extends SceneTree
# Deterministic packing of imagegen source illustrations into bounded card art.
func _initialize() -> void:
	var cards = JSON.parse_string(FileAccess.get_file_as_string("res://data/support_cards.json"))
	for id in cards:
		var image = Image.load_from_file("res://docs/cards/support/sources/" + id + ".png")
		if image == null:
			printerr("Missing illustration: ", id)
			quit(1)
			return
		var height = roundi(image.get_height() * 512.0 / image.get_width())
		image.resize(512, height, Image.INTERPOLATE_LANCZOS)
		image.save_png("res://assets/cards/art/" + id + ".png")
	print("Imported ", cards.size(), " support illustrations")
	quit()
