extends SceneTree
# Local visual gallery of the shared card component, without persistent saves.
func _initialize() -> void: call_deferred("preview")
func preview() -> void:
	root.size = Vector2i(1280, 720)
	var app = load("res://main.tscn").instantiate()
	app.game = preload("res://src/game.gd").new("user://unused-preview.save", false)
	root.add_child(app)
	for child in app.layer.get_children():
		app.layer.remove_child(child)
		child.queue_free()
	var column = 0
	for hero in app.game.content.heroes:
		var row = 0
		for id in app.game.content.cards:
			if app.game.content.cards[id].owner != hero: continue
			app.card_panel({"id": id, "upgraded": false}, 12 + column * 210, 20 + row * 340, 202, 320, func(): pass, false, true, app.layer, true)
			row += 1
			if row == 2: break
		column += 1
	await create_timer(0.5).timeout
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png(preload("res://tests/artifacts.gd").path("cards/frames.png"))
	quit()
