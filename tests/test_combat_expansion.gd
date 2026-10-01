extends SceneTree
const Game = preload("res://src/game.gd")
const Dungeon = preload("res://src/dungeon.gd")
const CutIn = preload("res://src/presentation/enemy_cut_in.gd")
var checks = 0
var failures = 0

func _initialize() -> void: call_deferred("run_tests")
func check(ok: bool, message: String) -> void:
	checks += 1
	if not ok:
		failures += 1
		printerr("FAIL: ", message)

func run_tests() -> void:
	var additions = JSON.parse_string(FileAccess.get_file_as_string("res://data/enemy_expansion.json"))
	var visuals = preload("res://src/enemy_sprite.gd").entries()
	var found: Dictionary = {}
	var rng = RandomNumberGenerator.new()
	for floor_number in [1, 2]:
		var config = Dungeon.definition(floor_number)
		for seed_value in range(100):
			rng.seed = seed_value
			var nodes = Dungeon.create(rng, floor_number)
			rng.seed = seed_value
			check(nodes == Dungeon.create(rng, floor_number), "deterministic floor")
			for room in nodes:
				for id in room.encounter:
					if id not in additions: continue
					found[id] = true
					check(int(visuals[additions[id].visual].floor) == floor_number, "correct dungeon " + id)
					check(room.stage >= config.min_stage[id], "progressive debut " + id)
	check(found.size() == 6, "all six enemies appear across seeds")
	root.size = Vector2i(1280, 720)
	var app = load("res://main.tscn").instantiate()
	app.game = Game.new("user://unused-expansion-ui.save", false)
	root.add_child(app)
	app.game.new_run(["warrior", "guardian"], 31)
	app.game.enter_node(0)
	for id in additions:
		var definition = additions[id]
		app.game.run.floor = int(visuals[definition.visual].floor)
		app.game._start_combat([id])
		app.continue_run()
		await process_frame
		var actor = app.enemy_art[0]
		check(actor.visual_id == definition.visual and actor.has_motion_frames, "live animated actor " + id)
		actor.play_once("attack")
		await create_timer(0.17).timeout
		check(actor.acting and actor.sprite.frame >= 4, "attack frames " + id)
		await create_timer(0.3).timeout
		check(not actor.acting and actor.sprite.frame < 4, "returns to idle " + id)
		var cut = CutIn.play(app.layer, definition.visual)
		check(cut != null and cut.from_right, "right-to-left cut-in " + id)
		var image = cut.picture.texture.get_image()
		check(image.get_pixel(0, 0).a == 0 and image.get_used_rect().size.x > 100, "cut-in alpha/content " + id)
		await create_timer(0.3).timeout
		if DisplayServer.get_name() != "headless":
			await RenderingServer.frame_post_draw
			root.get_texture().get_image().save_png(preload("res://tests/artifacts.gd").path("combat_expansion/" + id + ".png"))
		await cut.finished
		for pattern in definition.pattern:
			var game = Game.new("user://unused-expansion-pattern.save", false)
			game.new_run(["warrior", "cleric"], 12)
			game.enter_node(0)
			game._start_combat([id])
			var intent: Dictionary = pattern.duplicate(true)
			intent.target = 0
			game.run.combat.enemies[0].intent = intent
			check(game.end_turn(), "pattern resolves " + id)
	print("COMBAT EXPANSION: %d checks / %d failures" % [checks, failures])
	quit(1 if failures else 0)
