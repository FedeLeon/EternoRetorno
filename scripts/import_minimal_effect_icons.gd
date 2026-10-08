extends SceneTree
func _initialize() -> void:
	var catalog: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://data/battle_effects.json"))
	for id in catalog:
		var source = FileAccess.get_file_as_string("res://docs/battle_effects/minimal/%s.svg" % id)
		var image = Image.new()
		if image.load_svg_from_string(source) != OK:
			push_error("Invalid effect icon: " + id)
			quit(1)
			return
		image.save_png("res://assets/battle_effects/%s.png" % id)
	print("MINIMAL EFFECT ICONS: ", catalog.size())
	quit()
