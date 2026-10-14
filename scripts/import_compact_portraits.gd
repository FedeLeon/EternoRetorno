extends SceneTree
## Mechanical, proportional portrait sizing. No synthesized artwork or face crops.
func _initialize() -> void:
	for hero in ["warrior", "guardian", "rogue", "mage"]:
		var source = "res://docs/portraits/2026-10-13/sources/%s.png" % hero
		var image = Image.load_from_file(source)
		if image == null:
			push_error("Missing portrait: " + source); quit(1); return
		image.resize(928, roundi(image.get_height()*928.0/image.get_width()), Image.INTERPOLATE_LANCZOS)
		if image.save_png("res://assets/heroes/identity/portraits/%s.png" % hero) != OK:
			push_error("Cannot pack portrait: " + hero);quit(1);return
	print("Four small-card portraits packed proportionally")
	quit()
