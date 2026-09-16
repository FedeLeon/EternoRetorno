extends SceneTree
const Game = preload("res://src/game.gd")
var app: Control
var checks = 0
var failures = 0
func _initialize() -> void:
	call_deferred("run_tests")
func check(ok: bool, message: String) -> void:
	checks += 1
	if not ok:
		failures += 1
		printerr(message)
func click(point: Vector2) -> void:
	for pressed in [true, false]:
		var event = InputEventMouseButton.new()
		event.button_index = MOUSE_BUTTON_LEFT
		event.pressed = pressed
		event.position = point
		root.push_input(event)
	await process_frame
func run_tests() -> void:
	root.size = Vector2i(1280, 720)
	app = load("res://main.tscn").instantiate()
	app.game = Game.new("user://unused-base-camp-test.save", false)
	root.add_child(app)
	await process_frame
	await click(Vector2(640, 565))
	check(app.screen == "base_camp", "home opens base camp")
	await create_timer(0.2).timeout
	if DisplayServer.get_name() != "headless":
		await RenderingServer.frame_post_draw
		root.get_texture().get_image().save_png(preload("res://tests/artifacts.gd").path("base_camp/base-camp.png"))
	var profile = app.game.profile.duplicate(true)
	for id in ["Plot0", "Plot1", "Plot2", "Plot3", "CampTent"]:
		var area = app.layer.get_node(id).get_global_rect()
		await click(area.get_center())
		check(is_instance_valid(app.overlay), id + " responds to input")
		app.back()
		check(app.screen == "base_camp", "back closes information")
	check(app.game.profile == profile, "placeholders do not grant upgrades")
	await click(Vector2(1030, 190))
	check(app.screen == "select", "stone arch opens character selection")
	app.back()
	check(app.screen == "base_camp", "selection back returns to camp")
	app.game.new_run(["warrior", "cleric"], 42)
	app.game.enter_node(0)
	var run = app.game.run.duplicate(true)
	app.open_base_camp()
	await process_frame
	await click(Vector2(1030, 190))
	check(is_instance_valid(app.overlay), "existing adventure requires confirmation")
	app.back()
	check(app.game.run == run, "cancel preserves active adventure")
	await click(Vector2(1060, 679))
	check(app.screen == "combat" and app.game.run == run, "continue restores exact combat")
	app.open_base_camp()
	app.open_selection()
	app.back()
	check(app.game.run == run, "leaving preparation preserves active adventure")
	app.back()
	check(app.screen == "home", "base camp back returns home")
	print("BASE CAMP CHECKS: %d | FAILURES: %d" % [checks, failures])
	quit(1 if failures else 0)
