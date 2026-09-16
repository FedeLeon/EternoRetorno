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
func run_tests() -> void:
	root.size = Vector2i(1280, 720)
	var app = load("res://main.tscn").instantiate()
	app.game = Game.new("user://unused-cards.save", false)
	root.add_child(app)
	app.layer.hide()
	var gallery = Control.new()
	app.add_child(gallery)
	var index = 0
	for owner in ["warrior", "guardian", "rogue", "mage", "cleric", "ranger"]:
		app.game.new_run([owner, "warrior" if owner != "warrior" else "cleric"], 12)
		for id in app.game.content.cards:
			if app.game.content.cards[id].owner != owner:
				continue
			for upgraded in [false, true]:
				var card = app.card_panel({"id": id, "upgraded": upgraded}, 0, 0, 218, 244, func(): pass, false, true, gallery)
				await process_frame
				check(card.get_node("CostNumber").value == int(app.game.content.card({"id": id, "upgraded": upgraded}).cost), "Sprite cost: " + id)
				for node in card.get_children():
					if node is Label:
						check(node.get_line_count() * node.get_line_height() <= node.size.y + 1, "Text clipped: " + node.text)
				card.free()
		# One representative per class, matching reward dimensions.
		var id = app.game.content.heroes[owner].starter[0] if app.game.content.heroes[owner].has("starter") else ""
		if id == "":
			for key in app.game.content.cards:
				if app.game.content.cards[key].owner == owner:
					id = key
					break
		app.card_panel({"id": id, "upgraded": false}, 245 + (index % 3) * 264, 60 + (index / 3) * 292, 244, 272, func(): pass, false, true, gallery)
		index += 1
	await process_frame
	if DisplayServer.get_name() != "headless":
		await RenderingServer.frame_post_draw
		root.get_texture().get_image().save_png(preload("res://tests/artifacts.gd").path("cards/gallery.png"))
	gallery.free()
	app.game.new_run(["warrior", "cleric"], 12)
	app.game.enter_node(0)
	app.game.run.combat.hand = [{"id": "warrior_slash", "upgraded": false}]
	app.continue_run()
	await process_frame
	await click(Vector2(640, 630))
	check(app.selected_card == 0, "Illustration passes clicks to card")
	var hp = app.game.run.combat.enemies[0].hp
	await click(Vector2(990, 330))
	while app.combat_busy:
		await process_frame
	check(app.game.run.combat.enemies[0].hp < hp and app.game.run.combat.energy == 2, "Card and target resolve correctly")
	app.game.run.combat.hand = [{"id": "warrior_heavy", "upgraded": false}]
	app.game.run.combat.energy = 0
	app.continue_run()
	await process_frame
	await click(Vector2(640, 630))
	check(app.selected_card == -1, "Unaffordable card stays inactive")
	print("CARD CHECKS: %d | FAILURES: %d" % [checks, failures])
	quit(1 if failures else 0)
func click(point: Vector2) -> void:
	for pressed in [true, false]:
		var event = InputEventMouseButton.new()
		event.button_index = MOUSE_BUTTON_LEFT
		event.pressed = pressed
		event.position = point
		root.push_input(event)
	await process_frame
