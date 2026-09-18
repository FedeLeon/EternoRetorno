extends SceneTree
var app: Control
var failures = 0
func _initialize() -> void: call_deferred("run_tests")
func check(ok: bool, message: String) -> void:
	if not ok: failures += 1; printerr(message)
func tap(node: Control) -> void:
	for down in [true, false]:
		var event = InputEventMouseButton.new()
		event.button_index = MOUSE_BUTTON_LEFT
		event.pressed = down
		event.position = node.get_global_rect().get_center()
		root.push_input(event)
	await process_frame
func run_tests() -> void:
	root.size = Vector2i(1280, 720)
	app = load("res://main.tscn").instantiate()
	app.game = preload("res://src/game.gd").new("user://unused-bag.save", false)
	root.add_child(app)
	app.game.new_run(["warrior", "cleric"], 42)
	app.game.enter_node(0)
	app.screen = "items"
	app.render()
	for id in app.game.content.items:
		var button = app.layer.get_node("Item_" + id)
		check(not button.disabled, "empty item remains inspectable")
		check(is_equal_approx(button.get_rect().get_center().distance_to(Vector2(640,358)),190), "circular position")
		await tap(button)
		check(app.selected_item == id and app.layer.has_node("ItemPopover"), "item opens anchored popup")
		check(app.layer.get_node("Quantity_" + id).value == 0, "zero quantity")
		check(app.layer.get_node("ItemPopover/ConsumeUnavailable").disabled, "empty cannot consume")
		var popup = app.layer.get_node("ItemPopover")
		check(popup.position.x + popup.size.x < 400 or popup.position.x > 880, "popup outside circle")
	app.game.run.inventory.agility_brew = 2
	app.screen = "items"
	app.render()
	await tap(app.layer.get_node("Item_agility_brew"))
	check(app.layer.get_node("Quantity_agility_brew").value == 2, "quantity comes from inventory")
	if DisplayServer.get_name() != "headless":
		await create_timer(0.2).timeout
		await RenderingServer.frame_post_draw
		root.get_texture().get_image().save_png(preload("res://tests/artifacts.gd").path("objects/circular-bag.png"))
	await tap(app.layer.get_node("ItemPopover/Consume_0"))
	check(app.screen == "combat" and app.game.run.inventory.agility_brew == 1, "consume once and return")
	app.game._make_reward()
	app.screen = "items"
	app.render()
	await tap(app.layer.get_node("Item_agility_brew"))
	check(app.layer.get_node("ItemPopover/ConsumeUnavailable").disabled, "outside combat cannot consume")
	await tap(app.layer.get_node("BackFromBag"))
	check(app.screen == "reward", "return to pending reward")
	print("BAG UI FAILURES: ", failures)
	quit(1 if failures else 0)
