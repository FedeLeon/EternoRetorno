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
func shot(filename: String) -> void:
	await create_timer(0.15).timeout
	if DisplayServer.get_name() != "headless":
		await RenderingServer.frame_post_draw
		root.get_texture().get_image().save_png(preload("res://tests/artifacts.gd").path("treasure/" + filename + ".png"))
func run_tests() -> void:
	root.size = Vector2i(1280, 720)
	app = load("res://main.tscn").instantiate()
	app.game = Game.new("user://unused-treasure-ui.save", false)
	root.add_child(app)
	app.game.new_run(["warrior", "cleric"], 42)
	app.game.run.current = 0
	preload("res://tests/room_fixture.gd").enter(app.game, "treasure")
	app.game.run.treasure.trapped = false
	app.continue_run()
	await process_frame
	var view = app.layer.get_node("TreasureScreen")
	check(not view.has_node("RewardModal"), "closed chest hides reward")
	await shot("closed")
	await click(Vector2(640, 420))
	check(view.busy and app.game.run.treasure.opened, "resolve before animation")
	check(not view.has_node("RewardModal"), "animation before modal")
	var inventory = app.game.run.inventory.duplicate()
	await click(Vector2(640, 420))
	app.back()
	check(app.game.run.inventory == inventory and is_instance_valid(view), "busy blocks repeat and back")
	await create_timer(1.3).timeout
	check(view.has_node("RewardModal"), "reward shown after opening")
	await shot("opened")
	app.continue_run()
	await process_frame
	view = app.layer.get_node("TreasureScreen")
	check(view.has_node("RewardModal") and app.game.run.inventory == inventory, "rebuild restores pending result without duplication")
	await click(Vector2(640, 560))
	await process_frame
	check(app.screen == "map", "continue returns to map")
	app.game.run.current = 0
	preload("res://tests/room_fixture.gd").enter(app.game, "treasure")
	app.game.run.treasure.trapped = true
	app.game.run.heroes[0].hp = 2
	app.continue_run()
	await process_frame
	view = app.layer.get_node("TreasureScreen")
	await click(Vector2(640, 420))
	await create_timer(1.4).timeout
	check(app.game.run.heroes[0].hp == 1 and view.has_node("RewardModal"), "trap is nonlethal and gives reward")
	await shot("trap")
	for node in [0, 2, 4]:
		app.game.run.current = -1
		app.game.run.phase = "map"
		app.game.enter_node(0)
		app.game.run.current = node
		app.continue_run()
		await process_frame
		await shot("battle-" + str(node))
	print("TREASURE UI: %d checks | %d failures" % [checks, failures])
	quit(1 if failures else 0)
