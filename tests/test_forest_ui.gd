extends SceneTree
const Game = preload("res://src/game.gd")
const Dungeon = preload("res://src/dungeon.gd")
const CutIn = preload("res://src/presentation/enemy_cut_in.gd")
var failures = 0
var checks = 0
var app: Control
func _initialize() -> void: call_deferred("run_tests")
func check(ok: bool, message: String) -> void:
	checks += 1
	if not ok:
		failures += 1
		printerr("FAIL: ", message)
func shot(name: String) -> void:
	if DisplayServer.get_name() == "headless": return
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png(preload("res://tests/artifacts.gd").path("forest/" + name + ".png"))
func run_tests() -> void:
	root.size = Vector2i(1280,720)
	app = load("res://main.tscn").instantiate()
	app.game = Game.new("user://unused-forest-ui.save", false)
	root.add_child(app)
	app.game.new_run(["warrior","guardian"], 52)
	app.game.run.floor = 2
	app.game.run.nodes = Dungeon.create(app.game.rng, 2)
	app.continue_run()
	await process_frame
	check(app.layer.get_node("MapScreen").dungeon_name == "Cinturón industrial", "forest title")
	await shot("map")
	app.game.run.current = 0
	app.game._start_combat(["goblin_warrior","goblin_archer","goblin_shaman"])
	for e in app.game.run.combat.enemies: e.block = 8
	app.continue_run()
	await process_frame
	check(app.enemy_art.size() == 3, "three actors")
	for index in app.enemy_art:
		var actor = app.enemy_art[index]
		var target = actor.get_parent()
		check(target.get_global_rect().end.x <= 1280 and target.get_global_rect().position.x >= 520, "enemy fully in right arena")
		check(actor.has_motion_frames and actor.sprite.hframes == 8, "drawn enemy frames")
		check(app.enemy_health[index].get_global_rect().end.x <= 1280, "health inside screen")
	await shot("three-goblins")
	var catalog = JSON.parse_string(FileAccess.get_file_as_string("res://data/forest_enemies.json"))
	var additions = ["goblin_lancer", "goblin_bomber", "goblin_raider", "goblin_rider", "forest_bat", "forest_raven"]
	var ids = catalog.values().map(func(enemy): return enemy.visual)
	for id in ids:
		var texture = load("res://assets/enemies/animations/%s.png" % id)
		var img = texture.get_image()
		check(img.get_size() == Vector2i(img.get_height()*8,img.get_height()), "eight-frame atlas " + id)
		var unique: Array = []
		for i in range(8):
			var frame = img.get_region(Rect2i(i*img.get_height(),0,img.get_height(),img.get_height()))
			var fingerprint = hash(frame.get_data())
			if fingerprint not in unique: unique.append(fingerprint)
		check(unique.size() == 4, "four authored keyposes " + id)
		check(img.get_pixel(0,0).a == 0, "transparent atlas " + id)
		var addition = additions.filter(func(key): return catalog[key].visual == id)
		if not addition.is_empty():
			for index in range(8):
				var size = img.get_height()
				var frame = img.get_region(Rect2i(index*size,0,size,size))
				var bounds = preload("res://scripts/sketchbook_sheet_packer.gd").bounds(frame,0.5)
				check(bounds.position.x >= 8 and bounds.end.x <= size-8, "packed pose keeps clear side margins " + id)
			app.game._start_combat([addition[0]])
			app.continue_run()
			await process_frame
			var actor = app.enemy_art[0]
			check(actor.visual_id == id and actor.has_motion_frames, "live new sprite " + id)
			await shot("idle-" + id)
			actor.play_once("attack")
			await create_timer(0.17).timeout
			check(actor.sprite.frame >= 4, "new enemy attack poses " + id)
			await shot("motion-" + id)
			await await_actions([actor])
			check(not actor.acting and actor.sprite.frame < 4, "new enemy returns to idle " + id)
		var cut = CutIn.play(app.layer, id)
		check(cut != null and cut.from_right, "right-to-left cutin " + id)
		var illustration = load(cut.texture_path).get_image()
		check(illustration.get_pixel(0,0).a < 0.05, "transparent cutin " + id)
		await create_timer(0.18).timeout
		await shot("attack-" + id)
		await cut.finished
	app.game._start_combat(["goblin_rider","forest_bat","forest_raven"])
	app.continue_run()
	await process_frame
	await shot("three-beasts")
	for actor in app.enemy_art.values(): actor.play_once("attack")
	await create_timer(0.18).timeout
	check(app.enemy_art.values().all(func(actor): return actor.sprite.frame >= 4), "attacks use drawn attack row")
	await shot("beasts-motion")
	await await_actions(app.enemy_art.values())
	check(app.enemy_art.values().all(func(actor): return not actor.acting and actor.sprite.frame < 4), "return to idle row")
	preload("res://tests/room_fixture.gd").enter(app.game, "rest")
	app.continue_run()
	await process_frame
	check(app.layer.get_node("RestScreen").background_path == "res://assets/forest/rest.png", "forest rest background")
	await shot("rest")
	preload("res://tests/room_fixture.gd").enter(app.game, "treasure")
	app.continue_run()
	await process_frame
	check(app.layer.get_node("TreasureScreen").background_path.contains("forest"), "forest treasure background")
	await shot("treasure")
	print("FOREST UI: %d checks / %d failures" % [checks, failures])
	quit(1 if failures else 0)

func await_actions(actors: Array) -> void:
	# Observe completion rather than racing the 0.46s tween by 10ms on llvmpipe.
	var deadline = Time.get_ticks_msec() + 2000
	while actors.any(func(actor): return actor.acting) and Time.get_ticks_msec() < deadline:
		await process_frame
