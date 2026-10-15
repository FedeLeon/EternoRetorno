extends SceneTree
const Art = preload("res://src/ui/components/card_art.gd")
var failures = 0
func _initialize() -> void: call_deferred("run_tests")
func run_tests() -> void:
	root.size = Vector2i(1280, 720)
	var holder = Control.new()
	root.add_child(holder)
	var backdrop = ColorRect.new()
	backdrop.color = Color("101019")
	backdrop.size = Vector2(1280, 720)
	holder.add_child(backdrop)
	var entries: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://data/card_art.json"))
	var ids = entries.keys()
	ids.sort()
	var i = 0
	for id in ids:
		var tile = Control.new()
		tile.position = Vector2(8 + (i % 11) * 115, 8 + (i / 11) * 88)
		holder.add_child(tile)
		var picture = Art.attach(tile, id, Rect2(0, 0, 112, 74))
		if picture.texture == null or picture.texture.get_size() != Vector2(512,340):
			failures += 1
			printerr("Invalid pixel illustration: " + id)
		var caption = Label.new()
		caption.text = id
		caption.position = Vector2(0, 72)
		caption.size = Vector2(112, 14)
		caption.add_theme_font_size_override("font_size", 9)
		tile.add_child(caption)
		i += 1
	await process_frame
	if DisplayServer.get_name() != "headless":
		await RenderingServer.frame_post_draw
		root.get_texture().get_image().save_png(preload("res://tests/artifacts.gd").path("pixel_cards/illustrations.png"))
	holder.free()
	print("PIXEL CARD CATALOG: ", i, " cards, ", failures, " failures")
	quit(1 if failures else 0)
