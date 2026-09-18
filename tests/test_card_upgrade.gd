extends SceneTree
var failures = 0
func _initialize() -> void: call_deferred("run_tests")
func check(ok: bool, message: String) -> void:
	if not ok: failures += 1; printerr(message)
func click(button: Control) -> void:
	for pressed in [true, false]:
		var event = InputEventMouseButton.new()
		event.button_index = MOUSE_BUTTON_LEFT
		event.pressed = pressed
		event.position = button.get_global_rect().get_center()
		root.push_input(event)
	await process_frame
func run_tests() -> void:
	root.size = Vector2i(1280, 720)
	var app = load("res://main.tscn").instantiate()
	app.game = preload("res://src/game.gd").new("user://unused-upgrade.save", false)
	root.add_child(app)
	app.game.new_run(["warrior", "cleric"], 42)
	app.game.run.current = app.game.run.nodes.filter(func(node): return node.kind == "rest")[0].id
	app.game.run.phase = "room"
	app.game.run.deck[2].upgraded = true
	var original = app.game.run.duplicate(true)
	app.upgrade_mode = true
	app.return_screen = "room"
	app.screen = "deck"
	app.render()
	await process_frame
	var view = app.layer.get_node("CardUpgradeScreen")
	check(view.confirm.disabled, "confirmation starts disabled")
	await click(view.contents.get_node("UpgradeCard0"))
	check(not view.confirm.disabled and view.contents.get_node("UpgradeCard0").has_node("UpgradeGlow"), "first choice highlighted and enables confirm")
	check(app.game.run == original, "preview does not mutate run")
	check(view.contents.get_node("UpgradeCard0").tooltip_text.contains(app.game.content.card({"id": original.deck[0].id, "upgraded": true}).name), "preview shows upgraded card")
	await click(view.contents.get_node("UpgradeCard1"))
	check(not view.contents.get_node("UpgradeCard0").get_meta("upgrade_preview") and view.contents.get_node("UpgradeCard1").has_node("UpgradeGlow"), "selection moves to second card")
	check(app.game.run == original, "switching remains non destructive")
	check(view.contents.get_node("UpgradeCard2").disabled, "already upgraded card unavailable")
	if DisplayServer.get_name() != "headless":
		await RenderingServer.frame_post_draw
		root.get_texture().get_image().save_png(preload("res://tests/artifacts.gd").path("cards/upgrade-preview.png"))
	await click(view.confirm)
	check(app.game.run.phase == "map" and app.game.run.deck[1].upgraded and not app.game.run.deck[0].upgraded, "only confirmed card is upgraded and rest ends")
	print("UPGRADE FAILURES: ", failures)
	quit(1 if failures else 0)
