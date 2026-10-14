extends SceneTree
const Game = preload("res://src/game.gd")
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
	var app = load("res://main.tscn").instantiate()
	app.game = Game.new("user://title-test.save", false)
	root.add_child(app)
	await process_frame
	check(app.screen == "home" and app.layer.get_node("StartGame").text == "Iniciar juego", "Initial menu")
	if DisplayServer.get_name() != "headless":
		await RenderingServer.frame_post_draw
		root.get_texture().get_image().save_png(preload("res://tests/artifacts.gd").path("title/home.png"))
	await click(app.layer.get_node("Options").get_global_rect().get_center())
	check(app.screen == "options", "Options button")
	app.layer.get_node("Volume").value = 0
	check(AudioServer.is_bus_mute(0) and app.game.profile.settings.volume == 0, "Mute and store setting")
	app.layer.get_node("Volume").value = 60
	check(not AudioServer.is_bus_mute(0) and is_equal_approx(db_to_linear(AudioServer.get_bus_volume_db(0)), 0.6), "Volume applies")
	check(app.game.store.write(app.game.profile, app.game.run), "Save options")
	var restored = Game.new("user://title-test.save", true)
	check(restored.profile.settings.volume == 0.6, "Options restored from disk")
	if DisplayServer.get_name() != "headless":
		app.layer.get_node("Fullscreen").button_pressed = true
		await create_timer(0.2).timeout
		check(DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN, "Fullscreen applies")
		app.layer.get_node("Fullscreen").button_pressed = false
		await create_timer(0.2).timeout
		check(DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_WINDOWED, "Windowed mode restored")
	if DisplayServer.get_name() != "headless":
		await RenderingServer.frame_post_draw
		root.get_texture().get_image().save_png(preload("res://tests/artifacts.gd").path("title/options.png"))
	app.back()
	check(app.screen == "home", "Back returns to title")
	await process_frame
	await click(Vector2(640, 565))
	check(app.has_node("CinematicPlayer"),"first start has an intro")
	app.get_node("CinematicPlayer").finish()
	await process_frame
	check(app.screen == "base_camp", "Start opens camp")
	app.game.new_run(["warrior", "guardian"], 42)
	var before = app.game.run.duplicate(true)
	app.back()
	await process_frame
	check(app.layer.get_node("StartGame").text == "Continuar aventura", "Saved adventure label")
	if DisplayServer.get_name() != "headless":
		await RenderingServer.frame_post_draw
		root.get_texture().get_image().save_png(preload("res://tests/artifacts.gd").path("title/active-run.png"))
	await click(Vector2(640, 603))
	check(app.screen == "base_camp" and app.game.run == before, "Main camp button preserves adventure")
	app.back()
	await process_frame
	await click(Vector2(640, 539))
	check(app.screen == "map" and app.game.run == before, "Continue preserves adventure")
	app.game.profile.settings.volume = 1.0
	app.apply_options()
	print("TITLE CHECKS: %d | FAILURES: %d" % [checks, failures])
	if failures:
		quit(1)
		return
	app.screen = "home"
	app.render()
	await process_frame
	await click(app.layer.get_node("ExitGame").get_global_rect().get_center())
	await create_timer(1.0).timeout
	printerr("Exit button did not close the native application")
	quit(1)
