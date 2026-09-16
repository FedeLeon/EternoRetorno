extends SceneTree
const Art = preload("res://src/ui/components/card_art.gd")
const Game = preload("res://src/game.gd")
var checks = 0
var failures = 0
func _initialize() -> void: call_deferred("run_tests")
func check(ok: bool, caption: String) -> void:
	checks += 1
	if not ok:
		failures += 1
		printerr("FAIL: ", caption)
func run_tests() -> void:
	root.size = Vector2i(1280, 720)
	var game = Game.new("user://unused-art.save", false)
	var manifest = JSON.parse_string(FileAccess.get_file_as_string(Art.MANIFEST))
	check(manifest.size() == game.content.cards.size(), "all cards mapped")
	var regions: Array = []
	for id in game.content.cards:
		var texture = Art.texture_for(id)
		check(texture != null, "illustration " + id)
		if texture == null: continue
		check(texture.get_width() > 0 and texture.get_height() > 0, "dimensions " + id)
		check(Art.texture_for(id) == texture, "cached " + id)
		if texture is AtlasTexture:
			check(Rect2(Vector2.ZERO, texture.atlas.get_size()).encloses(texture.region), "atlas bounds " + id)
			check(texture.region not in regions, "unique original crop " + id)
			regions.append(texture.region)
		else:
			check(maxi(texture.get_width(), texture.get_height()) <= 512, "runtime resolution bounded " + id)
	for hero in game.content.heroes:
		var page = Control.new()
		root.add_child(page)
		var bg = ColorRect.new()
		bg.color = Color("10141f")
		bg.size = Vector2(1280, 720)
		page.add_child(bg)
		var index = 0
		for id in game.content.cards:
			var card = game.content.cards[id]
			if card.owner != hero: continue
			var x = 15 + index % 5 * 252
			var y = 15 + index / 5 * 230
			var picture = Art.attach(page, id, Rect2(x, y, 240, 135))
			check(picture.mouse_filter == Control.MOUSE_FILTER_IGNORE, "does not intercept card taps")
			check(picture.size == Vector2(240, 135), "illustration respects slot dimensions")
			var caption = Label.new()
			caption.text = card.name + "\n" + id
			caption.position = Vector2(x, y + 140)
			caption.size = Vector2(240, 70)
			caption.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
			caption.add_theme_font_size_override("font_size", 16)
			page.add_child(caption)
			index += 1
		await process_frame
		if DisplayServer.get_name() != "headless":
			await RenderingServer.frame_post_draw
			root.get_texture().get_image().save_png(preload("res://tests/artifacts.gd").path("card_art/" + hero + ".png"))
		page.free()
	print("CARD ART: %d checks / %d failures" % [checks, failures])
	quit(1 if failures else 0)
