extends SceneTree
const Game = preload("res://src/game.gd")
const Pack = preload("res://scripts/sketchbook_sheet_packer.gd")
const Motion = preload("res://src/presentation/enemy_motion.gd")
var checks = 0
var failures = 0
var app: Control
func _initialize() -> void: call_deferred("run_tests")
func check(ok: bool, caption: String) -> void:
	checks += 1
	if not ok: failures += 1; printerr("FAIL: ", caption)
func shot(id: String) -> void:
	if DisplayServer.get_name() == "headless": return
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png(preload("res://tests/artifacts.gd").path("combat_refinement/" + id + ".png"))
func run_tests() -> void:
	root.size = Vector2i(1280, 720)
	app = load("res://main.tscn").instantiate()
	app.game = Game.new("user://unused-refinement-visuals", false)
	root.add_child(app)
	var jobs: Array = JSON.parse_string(FileAccess.get_file_as_string("res://docs/combat_refinement/enemy_jobs.json"))
	var ids = ["rat", "skeleton", "goblin_warrior", "boss", "forest_boss", "volcano_boss"]
	for i in range(ids.size()):
		var floor_number = 1 if i < 2 or i == 3 else 2 if i < 5 else 3
		app.game.new_run(["warrior", "guardian"] if i % 2 == 0 else ["rogue", "mage"], 123, {}, floor_number)
		app.game.enter_node(0); app.game._start_combat([ids[i]])
		app.screen = "combat"; app.render(); await process_frame
		var actor: Control = app.enemy_art[0]
		check(actor.visual_id == jobs[i].id, "renewed bank used by real enemy")
		var image = actor.sprite.texture.get_image()
		var unique = {}
		for frame in range(8):
			var cell = image.get_region(Rect2i(frame * 256, 0, 256, 256))
			unique[hash(cell.get_data())] = true
			var bounds = Pack.bounds(cell, 0.5)
			check(bounds.end.y == 240 and bounds.position.x >= 8 and bounds.end.x <= 248, "full silhouette and planted baseline")
		check(unique.size() == 8, "eight distinct enemy poses")
		var origin = actor.position
		var scale_before = actor.scale
		actor.set_process(false)
		actor.play_once("attack")
		await create_timer(0.08).timeout
		check(actor.acting and actor.sprite.frame == 4, "anticipation has its own visible pose")
		await shot(ids[i] + "_anticipation")
		await create_timer(0.25).timeout
		check(actor.acting and actor.sprite.frame >= 5, "strike follows windup")
		for hero in app.hero_art.values():
			hero.set_process(false)
			hero.sprite.play("thrust" if i % 2 == 0 else "sweep"); hero.sprite.pause(); hero.sprite.frame = 6
		await shot(ids[i] + "_strike")
		await create_timer(0.6).timeout
		check(not actor.acting and actor.sprite.frame == 0, "recovery returns to neutral")
		check(actor.position == origin and actor.scale == scale_before, "root size and ground anchor preserved")
		for hero in app.hero_art.values():
			var frames = hero.sprite.sprite_frames
			check(frames.get_frame_texture("thrust", 6).get_image().get_data() != frames.get_frame_texture("sweep", 6).get_image().get_data(), "thrust and sweep are different artwork")
	# Crowded battles keep the pair control out of enemy hit areas.
	var recipe = app.game.content.synergies[0]
	app.game.new_run(recipe.heroes, 4); app.game.enter_node(0)
	app.game._start_combat(["rat", "skeleton", "goblin_warrior"])
	app.game.run.combat.hand = []
	for id in recipe.cards: app.game.run.combat.hand.append({"id":id, "upgraded":false})
	app.selected_synergy = recipe.id; app.render(); await process_frame
	var button: Control = app.layer.get_node("Synergy_" + recipe.id)
	for target in app.layer.find_children("EnemyTarget*", "Button", true, false):
		check(not button.get_global_rect().intersects(target.get_global_rect()), "synergy never covers enemy targets")
	await shot("three_targets_ready")
	print("COMBAT REFINEMENT VISUALS: %d checks / %d failures" % [checks, failures])
	app.queue_free(); await process_frame
	quit(1 if failures else 0)
