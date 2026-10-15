extends SceneTree
var checks = 0
var failures = 0
func _initialize(): call_deferred("verify")
func check(ok: bool, text: String):
	checks += 1
	if not ok:
		failures += 1
		printerr("FAIL: ",text)
func click(button: Button):
	for pressed in [true,false]:
		var event = InputEventMouseButton.new()
		event.button_index = MOUSE_BUTTON_LEFT
		event.pressed = pressed
		event.position = button.get_global_rect().get_center()
		root.push_input(event)
	await process_frame
func verify():
	root.size = Vector2i(1280,720)
	var app = load("res://main.tscn").instantiate()
	app.game = preload("res://src/game.gd").new("user://collection-artwork-test",false)
	app.game.profile.achievements.unlocked = ["first_steps","oathbound"]
	root.add_child(app)
	app.open_collection()
	await process_frame
	var view = app.layer.get_node("CollectionScreen")
	var profile = app.game.profile.duplicate(true)
	var run = app.game.run.duplicate(true)
	for id in ["first_steps","oathbound"]:
		var tile = view.find_child("Achievement_"+id,true,false)
		view.body.get_node("CollectionScroll").ensure_control_visible(tile)
		await process_frame
		await click(tile)
		var button = view.detail.get_node("ViewAchievementArt")
		check(button.get_global_rect().end.y<view.detail.get_global_rect().end.y,"art button stays inside detail")
		await click(button)
		check(is_instance_valid(app.overlay) and app.overlay.name=="ArtworkViewer","unlocked artwork opens viewer")
		check(app.overlay.size==Vector2(1280,720),"viewer fills viewport")
		var picture = app.overlay.get_node("Artwork")
		check(picture.size==app.overlay.size and picture.stretch_mode==TextureRect.STRETCH_KEEP_ASPECT_CENTERED,"full-screen artwork keeps proportions")
		check(picture.texture.resource_path.ends_with(id+".png"),"correct artwork, including discovered secret")
		var underlying = view.body
		# The overlay must consume clicks aimed at underlying collection tabs.
		await click(view.get_node("HistoryTab"))
		check(view.body==underlying and is_instance_valid(app.overlay),"viewer blocks collection behind artwork")
		if DisplayServer.get_name()!="headless":
			await RenderingServer.frame_post_draw
			root.get_texture().get_image().save_png(preload("res://tests/artifacts.gd").path("collection/artwork-"+id+".png"))
		if id=="first_steps":
			var escape = InputEventKey.new()
			escape.keycode = KEY_ESCAPE; escape.pressed = true
			root.push_input(escape)
			await process_frame
		else: await click(app.overlay.get_node("CloseArtwork"))
		check(not is_instance_valid(app.overlay) and app.screen=="collection","close returns to collection")
		check(view.selected.name=="Achievement_"+id and button.has_focus(),"selection and keyboard focus restored")
	for id in ["first_battle","last_breath"]:
		var entry = view.snapshot.achievements.filter(func(a): return a.id==id)[0]
		var tile = view.find_child("Achievement_"+id,true,false)
		view.body.get_node("CollectionScroll").ensure_control_visible(tile)
		await process_frame
		await click(tile)
		check(not view.detail.has_node("ViewAchievementArt"),"locked achievement has no art button")
		view._open_art(entry)
		check(not is_instance_valid(app.overlay),"locked illustration cannot be opened")
	check(app.game.profile==profile and app.game.run==run,"art viewer cannot change progress or saves")
	app.queue_free()
	await process_frame
	print("COLLECTION ARTWORK: %d checks / %d failures" % [checks,failures])
	quit(1 if failures else 0)
