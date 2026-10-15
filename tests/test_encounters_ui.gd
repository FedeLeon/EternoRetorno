extends SceneTree
const Game = preload("res://src/game.gd")
var app: Control
var checks = 0
var failures = 0
func check(ok: bool, message: String) -> void:
	checks += 1
	if not ok:
		failures += 1
		printerr(message)
func _initialize() -> void:
	call_deferred("run_tests")
func click(node: Control) -> void:
	for pressed in [true, false]:
		var event = InputEventMouseButton.new()
		event.button_index = MOUSE_BUTTON_LEFT
		event.pressed = pressed
		event.position = node.get_global_rect().get_center()
		root.push_input(event)
	await process_frame
func prepare(id: String, floor_index: int = 1) -> void:
	app.game.new_run(["warrior", "guardian"], 42, {}, floor_index)
	for node in app.game.run.nodes:
		if node.kind == "event":
			app.game.run.current = node.id
			node.event = id
			break
	app.game.run.phase = "room"
	for hero in app.game.run.heroes: hero.hp -= 12
	app.continue_run()
	await create_timer(0.3).timeout
func run_tests() -> void:
	root.size = Vector2i(1280, 720)
	app = load("res://main.tscn").instantiate()
	app.game = Game.new("user://unused-encounters-ui.save", false)
	root.add_child(app)
	for floor_index in [1, 2]:
		for id in ["well", "altar", "library"]:
			await prepare(id, floor_index)
			var view = app.layer.get_node("EncounterScreen")
			var dialog = view.get_node("EncounterDialog")
			var background = view.get_node("EncounterBackground")
			check(background.texture.resource_path == "res://assets/encounters/%s.png" % id, "dedicated encounter artwork")
			check(background.material is ShaderMaterial, "local atmosphere shader attached")
			check(dialog.size == Vector2(660, 280) and dialog.position.y >= 400, "compact lower dialog leaves focal area visible")
			check(dialog.find_children("*", "Label", true, false).all(func(l): return l.horizontal_alignment == HORIZONTAL_ALIGNMENT_CENTER), "all dialog text centered")
			check(app.layer.find_children("*", "Label", true, false).all(func(l): return "ETERNO RETORNO" not in l.text and "Sala " not in l.text and l.text != "Encuentro"), "old room headings removed")
			if DisplayServer.get_name() != "headless" and floor_index == 1:
				await RenderingServer.frame_post_draw
				var before = root.get_texture().get_image()
				before.save_png(preload("res://tests/artifacts.gd").path("encounters/" + id + ".png"))
				await create_timer(0.6).timeout
				await RenderingServer.frame_post_draw
				var after = root.get_texture().get_image()
				check(before.get_region(Rect2i(400, 100, 480, 230)).get_data() != after.get_region(Rect2i(400, 100, 480, 230)).get_data(), "encounter atmosphere visibly animates")
				check(before.get_region(Rect2i(80, 550, 80, 80)).get_data() == after.get_region(Rect2i(80, 550, 80, 80)).get_data(), "distant masonry stays still")
			var hp = app.game.run.heroes[0].hp
			await click(dialog.get_node("EventChoice0"))
			if id == "well": check(app.screen == "paths" and app.game.run.heroes[0].hp == hp + 8, "well choice heals once and returns to paths")
			elif id == "altar": check(app.screen == "paths" and app.game.run.heroes[0].hp == hp - 5 and app.game.run.deck.filter(func(c): return c.upgraded).size() == 1, "altar pays health and upgrades one card")
			else: check(app.screen == "reward" and app.game.run.reward.size() > 0, "library opens existing card reward")
	await prepare("altar")
	app.game.run.heroes[0].hp = 5
	app.render()
	await process_frame
	var view = app.layer.get_node("EncounterScreen")
	var accept = view.get_node("EncounterDialog/EventChoice0")
	check(accept.disabled, "altar offering blocked when health is insufficient")
	await click(accept)
	check(app.screen == "room" and app.game.run.heroes[0].hp == 5, "disabled offer leaves state unchanged")
	await click(view.get_node("Menu"))
	check(is_instance_valid(app.overlay), "pause menu remains accessible")
	app.close_modal()
	await process_frame
	await click(view.get_node("EncounterDialog/EventChoice1"))
	check(app.screen == "paths", "leaving encounter remains possible")
	await prepare("altar")
	for card in app.game.run.deck: card.upgraded = true
	app.render()
	await process_frame
	check(app.layer.get_node("EncounterScreen/EncounterDialog/EventChoice0").disabled, "altar blocked when no cards can be improved")
	print("ENCOUNTER UI: %d checks / %d failures" % [checks, failures])
	quit(1 if failures else 0)
