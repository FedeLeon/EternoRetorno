extends SceneTree
# Preserve generated alpha; only resize the final game resources.
func _initialize() -> void:
	for file in DirAccess.get_files_at("res://docs/relics/sources"):
		if not file.ends_with(".png"): continue
		var image = Image.load_from_file("res://docs/relics/sources/" + file)
		image.resize(192, 192, Image.INTERPOLATE_LANCZOS)
		image.save_png("res://assets/relics/" + file)
	quit()
