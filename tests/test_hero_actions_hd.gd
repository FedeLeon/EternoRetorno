extends SceneTree
const Game = preload("res://src/game.gd")
var checks = 0
var failures = 0
var app: Control
func _initialize() -> void: call_deferred("verify")
func check(ok: bool, message: String) -> void:
	checks += 1
	if not ok:
		failures += 1
		printerr("FAIL: ", message)
func capture(name: String) -> void:
	if DisplayServer.get_name() == "headless": return
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png(preload("res://tests/artifacts.gd").path("hero_actions_hd/" + name + ".png"))
func verify() -> void:
	root.size = Vector2i(1280, 720)
	app = load("res://main.tscn").instantiate()
	app.game = Game.new("user://hero-action-hd.save", false)
	app.game.profile.tutorial_complete = true
	root.add_child(app)
	var catalog: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://data/static_combat.json"))
	var records: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://art_sources/static_combat_2026_10_19/extraction.json"))
	for hero in ["warrior", "guardian", "rogue", "mage"]:
		var job: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://art_sources/hero_actions_hd_2026_10_19/%s.json" % hero))
		check(FileAccess.get_sha256("res://" + job.reference) == job.reference_sha256, "existing idle art unchanged: " + hero)
		check(FileAccess.get_sha256("res://" + job.source) == job.source_sha256 and not job.prompt.is_empty(), "new original and prompt preserved: " + hero)
		app.game.new_run([hero, "mage" if hero != "mage" else "warrior"], 42)
		app.game.enter_node(0)
		app.game._start_combat(["skeleton", "skeleton_shielder"])
		app.continue_run()
		await process_frame
		var state = app.game.run.duplicate(true)
		var rng = app.game.rng.state
		var actor: Control = app.hero_art[0]
		var transform = actor.get_transform()
		for action in ["attack", "guard", "skill", "hurt", "death"]:
			var record: Dictionary = records["heroes/%s/%s" % [hero, action]]
			var pose: Dictionary = catalog.heroes[hero][action]
			var image: Image = load(pose.path).get_image()
			check(image.get_size() == Vector2i(512, 512), "individual HD static canvas: " + hero + "/" + action)
			check(float(pose.scale) <= float(catalog.heroes[hero].idle.scale) * 1.01, "native pixels per logical unit match idle: " + hero + "/" + action)
			check(record.original_provenance.common_downscale <= 1.0 and record.original_provenance.reference_height >= 358, "authored detail instead of upscaling: " + hero + "/" + action)
			check(image.get_pixel(0, 0).a == 0 and image.get_pixel(511, 511).a == 0, "transparent background preserved")
			var revision: int = actor.begin_action(action)
			await create_timer(.025).timeout
			check(actor.get_transform() == transform, "body transform remains fixed with the new artwork")
			check(absf(actor.body_rect().end.y - actor.size.y) < .01, "pose keeps its feet on the same floor")
			check(actor.sprite.texture is AtlasTexture and not actor.is_processing(), "all heroes use authored sequences")
			if action in ["attack", "guard"]: await capture(hero + "-" + action)
			actor.finish_action(revision)
		check(app.game.run == state and app.game.rng.state == rng, "HD presentation leaves rules and RNG unchanged")
	app.queue_free()
	await process_frame
	await process_frame
	print("HERO ACTION HD: %d checks / %d failures" % [checks, failures])
	quit(1 if failures else 0)
