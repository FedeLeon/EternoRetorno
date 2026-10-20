extends SceneTree
const Game = preload("res://src/game.gd")
const Dungeon = preload("res://src/dungeon.gd")
const CutIn = preload("res://src/presentation/enemy_cut_in.gd")
var checks = 0
var failures = 0
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
	root.get_texture().get_image().save_png(preload("res://tests/artifacts.gd").path("crypt_variety/" + name + ".png"))
func run_tests() -> void:
	var extra = JSON.parse_string(FileAccess.get_file_as_string("res://data/crypt_enemies.json"))
	var config = Dungeon.definition(1)
	var rng = RandomNumberGenerator.new()
	var encountered: Dictionary = {}
	for seed_value in range(100):
		rng.seed = seed_value
		var nodes = Dungeon.create(rng, 1)
		rng.seed = seed_value
		check(nodes == Dungeon.create(rng, 1), "deterministic generation")
		check(nodes.size() == 35 and nodes[0].encounter.size() == 1, "same graph size and solo entrance")
		for room in nodes:
			if room.kind != "combat": continue
			check(room.encounter.size() in [1,2,3], "formation size")
			var unique: Dictionary = {}
			for id in room.encounter:
				check(id in config.common and room.stage >= config.min_stage.get(id,0), "roster and gradual debut " + id)
				unique[id] = true
				encountered[id] = true
			check(unique.size() == room.encounter.size(), "mixed formations")
	check(extra.size() == 6 and extra.keys().all(func(id): return id in config.common), "six original additions remain in expanded crypt roster")
	check(extra.keys().all(func(id): return encountered.has(id)), "all additions appear")
	check(Dungeon.definition(2).common.all(func(id): return id not in extra), "forest roster unchanged")
	var path = "user://crypt-variety-test.save"
	for suffix in ["", ".bak", ".tmp"]: DirAccess.remove_absolute(path + suffix)
	var saved = Game.new(path, true)
	saved.new_run(["warrior","guardian"], 31)
	saved.run.nodes[0].encounter = ["rat"]
	saved.checkpoint()
	var loaded = Game.new(path, true)
	check(loaded.run.nodes == saved.run.nodes and loaded.rng.state == saved.rng.state, "load never rerolls saved encounters")
	for suffix in ["", ".bak", ".tmp"]: DirAccess.remove_absolute(path + suffix)
	root.size = Vector2i(1280,720)
	app = load("res://main.tscn").instantiate()
	app.game = Game.new("user://unused-crypt-ui.save", false)
	root.add_child(app)
	app.game.new_run(["warrior","guardian"], 12)
	app.game.enter_node(0)
	for id in extra:
		var def = extra[id]
		app.game._start_combat([id])
		app.continue_run()
		await process_frame
		var actor = app.enemy_art[0]
		check(actor.visual_id == def.visual and actor.sprite is TextureRect, "live sprite " + id)
		check(actor.poses.size()==6,"six static action assets "+id)
		await shot(id + "-idle")
		actor.play_once("attack")
		check(actor.current_action == "attack" and actor.acting, "drawn attack poses " + id)
		await shot(id + "-motion")
		await create_timer(0.65).timeout
		check(not actor.acting and actor.current_action == "idle", "returns to idle " + id)
		var cut = CutIn.play(app.layer, def.visual)
		check(cut != null and cut.from_right, "cut-in from right " + id)
		var art = load(cut.texture_path).get_image()
		check(art.get_pixel(0,0).a == 0 and art.get_used_rect().size.x > 100, "transparent attack illustration")
		await create_timer(0.18).timeout
		await shot(id + "-cutin")
		await cut.finished
		# Every pattern is usable by the existing end-turn resolver.
		for pattern in def.pattern:
			var game = Game.new("user://unused-pattern.save",false)
			game.new_run(["warrior","guardian"], 12)
			game.enter_node(0)
			game._start_combat([id])
			var intent: Dictionary = pattern.duplicate(true)
			intent.target = 0
			game.run.combat.enemies[0].intent = intent
			check(game.end_turn() and game.run.phase == "combat", "pattern resolves " + id)
	app.game._start_combat(["skeleton_archer","rock_elemental","shadow_elemental"])
	app.continue_run()
	await process_frame
	for actor in app.enemy_art.values(): check(actor.get_parent().get_global_rect().end.x <= 1280, "mixed group fits arena")
	await shot("mixed-group")
	print("CRYPT VARIETY: %d checks / %d failures" % [checks,failures])
	quit(1 if failures else 0)
