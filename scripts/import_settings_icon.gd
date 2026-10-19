extends SceneTree
## Prepare the generated gear without redrawing it; keep the source intact.
func _initialize() -> void:
	var source = "res://art_sources/ui_buttons/settings/sources/gear.png"
	var image = Image.new()
	if image.load_png_from_buffer(FileAccess.get_file_as_bytes(source)) != OK or image.get_pixel(0, 0).a > 0.01:
		push_error("Settings gear requires a transparent generated source")
		quit(1)
		return
	image.resize(512, 512, Image.INTERPOLATE_LANCZOS)
	var target = "assets/ui/settings.png"
	preload("res://scripts/sketchbook_sheet_packer.gd").save(image, "res://" + target)
	var path = "res://art_sources/art_direction/postapocalyptic/assets.json"
	var manifest: Dictionary = JSON.parse_string(FileAccess.get_file_as_string(path))
	manifest.erase("assets/ui/settings.svg")
	manifest[target] = {"sha256": FileAccess.get_sha256("res://" + target), "source": source.trim_prefix("res://"), "source_sha256": FileAccess.get_sha256(source), "style": "postapocalyptic_comic", "tool": "image_gen.imagegen", "processing": "proportional resize to 512 square, generated alpha retained", "generation": "art_sources/ui_buttons/settings/generation.json"}
	FileAccess.open(path, FileAccess.WRITE).store_string(JSON.stringify(manifest, "\t", false) + "\n")
	print("COMIC SETTINGS GEAR: 512px, transparent")
	quit()
