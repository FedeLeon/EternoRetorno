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
func shot() -> void:
	if DisplayServer.get_name() != "headless":
		await RenderingServer.frame_post_draw
		root.get_texture().get_image().save_png(preload("res://tests/artifacts.gd").path("map/initial.png"))
func run_tests() -> void:
	root.size = Vector2i(1280, 720)
	app = load("res://main.tscn").instantiate()
	app.game = Game.new("user://unused-map-test.save", false)
	root.add_child(app)
	app.game.new_run(["warrior", "cleric"], 42, {"team": "vital_amulet"})
	app.game.run.relics.append("ember")
	app.continue_run()
	await process_frame
	await process_frame
	var view = app.layer.get_node("MapScreen")
	check(view.relics.size() == 2 and view.relics[0].name == "Amuleto Vital", "equipped and found relics shown")
	check(view.get_node("Hero0").size.y > 80 and view.get_node("Health0") != null, "larger actor with health")
	check(not view.has_node("Descend"), "stairs hidden before boss victory")
	for i in range(12):
		check(view.get_node("Room%d" % i).disabled == (i != 0), "only reachable rooms enabled")
	var before = app.game.run.duplicate(true)
	await shot()
	await click(Vector2(383, 407))
	check(app.screen == "map" and app.game.run == before, "unreachable boss click has no effect")
	await click(Vector2(832, 667))
	check(app.screen == "deck" and app.game.run == before, "deck asset opens without changing run")
	app.back()
	await process_frame
	await click(Vector2(152, 563))
	check(app.screen == "combat" and app.game.run.current == 0, "room art click enters available encounter")
	app.game.run.phase = "map"
	app.game.run.current = 0
	app.continue_run()
	await process_frame
	view = app.layer.get_node("MapScreen")
	check(not view.get_node("Room1").disabled and not view.get_node("Room2").disabled, "branch availability retained")
	app.game.run.boss_defeated = true
	app.continue_run()
	await process_frame
	check(app.layer.get_node("MapScreen").has_node("Descend"), "stairs appear after boss")
	# Legacy personal equipment is still shown, once per bearer.
	app.game.run.erase("team_relic")
	app.continue_run()
	await process_frame
	check(app.layer.get_node("MapScreen").relics.size() == 3, "legacy personal equipment and found relic retained")
	print("MAP CHECKS: %d | FAILURES: %d" % [checks, failures])
	quit(1 if failures else 0)
