extends SceneTree
const Game = preload("res://src/game.gd")
var checks = 0
var failures = 0
func _initialize(): call_deferred("run_tests")
func check(ok: bool, caption: String):
	checks += 1
	if not ok: failures += 1; printerr("FAIL: ", caption)
func run_tests():
	root.size = Vector2i(1280,720)
	var app = load("res://main.tscn").instantiate()
	app.game = Game.new("user://unused-adventure-assets.save",false)
	root.add_child(app)
	app.game.new_run(["warrior","guardian"],19,{},3)
	app.game.enter_node(0)
	var additions: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://data/adventure_enemies.json"))
	var seen: Array = []
	for id in additions:
		var visual = additions[id].visual
		if visual in seen: continue
		seen.append(visual)
		app.game._start_combat([id]); app.continue_run(); await process_frame
		var actor = app.enemy_art[0]
		check(actor.has_motion_frames, "animated actor " + id)
		var image = actor.sprite.texture.get_image()
		var unique: Dictionary = {}
		for frame in range(8): unique[image.get_region(Rect2i(frame*image.get_height(),0,image.get_height(),image.get_height())).get_data().hex_encode().sha256_text()] = true
		check(unique.size() == 4, "four authored keyposes in eight timing frames " + id)
		actor.play_once("attack"); await create_timer(0.17).timeout
		check(actor.acting and actor.sprite.frame >= 4,"drawn attack " + id)
		await create_timer(0.3).timeout
		check(not actor.acting and actor.sprite.frame < 4,"idle restored " + id)
		var cut = preload("res://src/presentation/enemy_cut_in.gd").play(app.layer,visual)
		check(cut != null and cut.from_right,"right to left " + id)
		var art = cut.picture.texture.get_image()
		check(art.get_pixel(0,0).a < 0.05 and art.get_used_rect().size.x > 500,"transparent detailed cut-in " + id)
		await create_timer(0.3).timeout
		if DisplayServer.get_name() != "headless":
			await RenderingServer.frame_post_draw
			root.get_texture().get_image().save_png(preload("res://tests/artifacts.gd").path("expansion/enemy-" + id + ".png"))
		await cut.finished
	app.queue_free(); await process_frame
	print("ADVENTURE ASSETS: %d checks / %d failures" % [checks, failures]); quit(1 if failures else 0)
