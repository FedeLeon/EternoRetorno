extends SceneTree
# Deterministic packaging of generated art; originals and prompts live in docs.
func _initialize() -> void:
	for group in ["expeditions", "church"]:
		for file in DirAccess.get_files_at("res://docs/%s/sources" % group):
			if not file.ends_with(".png"): continue
			var image = Image.load_from_file("res://docs/%s/sources/%s" % [group, file])
			var width = 1280 if file == "interior.png" else (512 if file == "building.png" else 480)
			image.resize(width, roundi(image.get_height() * float(width) / image.get_width()), Image.INTERPOLATE_LANCZOS)
			image.save_png("res://assets/%s/%s" % [group, file])
	quit()
