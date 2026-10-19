extends SceneTree
const Game = preload("res://src/game.gd")
const Feedback = preload("res://src/presentation/impact_feedback.gd")
const Preferences = preload("res://src/presentation/preferences.gd")
var checks = 0
var failures = 0
var app: Control
func _initialize() -> void: call_deferred("verify")
func check(ok: bool, message: String) -> void:
	checks += 1
	if not ok:
		failures += 1
		printerr("FAIL: ", message)
func shot(effect: Control, name: String) -> void:
	if DisplayServer.get_name() == "headless": return
	effect.set_process(false)
	effect.elapsed = .08
	effect.queue_redraw()
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png(preload("res://tests/artifacts.gd").path("hit_slash/" + name + ".png"))
	effect.set_process(true)
func verify() -> void:
	root.size = Vector2i(1280, 720)
	app = load("res://main.tscn").instantiate()
	app.game = Game.new("user://hit-slash.save", false)
	app.game.profile.tutorial_complete = true
	root.add_child(app)
	app.game.new_run(["warrior", "mage"], 42)
	app.game.enter_node(0)
	app.game._start_combat(["skeleton", "skeleton_shielder"])
	app.continue_run()
	app.game.profile.settings = {"flash_intensity": .6, "low_effects": false}
	app.apply_options()
	await process_frame
	var before = app.game.run.duplicate(true)
	var rng = app.game.rng.state
	var target: Control = app.enemy_art[0]
	var transform = target.get_transform()
	for blocked in [false, true]:
		Feedback.play(app, target, {"damage":8, "lost":0 if blocked else 8, "absorbed":8 if blocked else 0, "hit_index":1 if blocked else 0})
		var effects = get_nodes_in_group("hit_slash")
		check(effects.size() == 1, "one overlay per enemy impact")
		var effect: Control = effects[0]
		check(effect.blocked == blocked and effect.hit_index == (1 if blocked else 0), "blocked impact and slash direction use receipt")
		check(effect.spark_count == 12 and effect.mouse_filter == Control.MOUSE_FILTER_IGNORE, "bounded sparks do not intercept input")
		var body: Rect2 = target.get_global_transform() * target.body_rect()
		check(effect.get_global_rect().has_point(body.get_center()), "impact is anchored over the visible enemy")
		check(effect.z_index > target.z_index and effect.z_index < 90, "impact overlays enemy below floating numbers")
		var texture = target.sprite.texture
		await create_timer(.08).timeout
		check(target.sprite.texture == texture and target.get_transform() == transform, "light effect never animates the body")
		await shot(effect, "blocked" if blocked else "damage")
		await create_timer(.9).timeout
		check(get_nodes_in_group("hit_slash").is_empty(), "impact frees itself after its short lifetime")
		check(app.game.run == before and app.game.rng.state == rng, "visual impact preserves committed state and RNG")
	Feedback.play(app, app.hero_art[0], {"damage":4, "lost":4})
	check(get_nodes_in_group("hit_slash").is_empty(), "enemy-only overlay does not add hero slashes")
	Preferences.settings.flash_intensity = 0.0
	Feedback.play(app, target, {"damage":4, "lost":4})
	check(get_nodes_in_group("hit_slash").is_empty(), "disabled flashes suppress light overlay")
	Preferences.settings.flash_intensity = .6
	Preferences.settings.low_effects = true
	Feedback.play(app, target, {"damage":4, "lost":4})
	check(get_nodes_in_group("hit_slash")[0].spark_count == 6, "low effects halves spark budget")
	Feedback.play(app, app.enemy_art[1], {"damage":4, "lost":4})
	check(get_nodes_in_group("hit_slash").size() == 2, "area impacts keep separate overlays per target")
	await create_timer(.9).timeout
	check(get_nodes_in_group("hit_slash").is_empty(), "all overlays expire without lingering particles")
	app.queue_free()
	await process_frame
	print("HIT SLASH: %d checks / %d failures" % [checks, failures])
	quit(1 if failures else 0)
