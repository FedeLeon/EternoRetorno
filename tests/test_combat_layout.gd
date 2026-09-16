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
func shot(name: String) -> void:
	if DisplayServer.get_name() != "headless":
		await RenderingServer.frame_post_draw
		root.get_texture().get_image().save_png(preload("res://tests/artifacts.gd").path("dungeon/" + name + ".png"))
func run_tests() -> void:
	root.size = Vector2i(1280, 720)
	app = load("res://main.tscn").instantiate()
	app.game = Game.new("user://unused-layout.save", false)
	root.add_child(app)
	app.game.new_run(["warrior", "cleric"], 12)
	app.game.enter_node(0)
	app.continue_run()
	await process_frame
	check(app.game.run.combat.hand.size() == 6, "Six cards drawn")
	await shot("combat")
	var cards = app.layer.get_node("CombatHand").get_child(0).get_children()
	check(cards.size() == 6 and cards[2].position.y < cards[0].position.y and cards[0].rotation < 0 and cards[5].rotation > 0, "Six cards form a raised fan")
	for card in cards:
		for corner in [Vector2.ZERO, Vector2(card.size.x, 0), card.size, Vector2(0, card.size.y)]:
			var point = card.get_global_transform() * corner
			check(point.y >= 350 and point.y <= 720, "Entire rotated card fits vertically")
	check(app.hero_health[0].global_position.y < app.hero_art[0].global_position.y + app.hero_art[0].size.y / 2, "Hero health above artwork")
	var index = 0
	for i in range(6):
		if not app.game.valid_targets(i).is_empty():
			index = i
			break
	await click(cards[index].get_global_transform() * Vector2(55, 45))
	check(app.selected_card == index, "Touch selects peeking card")
	check(not app.layer.find_children("TargetGlow", "ColorRect", true, false).is_empty(), "Valid targets glow")
	var selected = app.layer.get_node("CombatHand").get_child(0).get_child(index)
	check(selected.global_position.y == 358 and selected.global_position.y + selected.size.y <= 720, "Selected card fully visible")
	check(selected.get_node("IllustrationSpace").position.x == 18, "Illustration has side margins")
	await shot("selected-card")
	var energy_before = app.game.run.combat.energy
	app.game.run.combat.energy = 0
	app.selected_card = -1
	app.render()
	await process_frame
	var blocked_card = app.layer.get_node("CombatHand").get_child(0).get_child(index)
	await click(blocked_card.get_global_transform() * Vector2(55, 45))
	check(app.selected_card == index, "Can inspect card without energy")
	check(app.layer.find_children("TargetGlow", "ColorRect", true, false).is_empty(), "No target glow without energy")
	var snapshot = app.game.run.duplicate(true)
	app.target_clicked(0)
	check(app.game.run == snapshot and not app.combat_busy, "Insufficient energy prevents play without changing state")
	var raised = app.layer.get_node("CombatHand").get_child(0).get_child(index)
	await click(raised.get_global_transform() * Vector2(55, 45))
	check(app.selected_card == -1, "Can deselect unaffordable card")
	app.game.run.combat.energy = energy_before
	app.selected_card = -1
	app.render()
	await process_frame
	await click(Vector2(100, 500))
	while app.combat_busy:
		await process_frame
	check(app.game.run.combat.turn == 2 and app.game.run.combat.hand.size() == 6, "End turn accessible above hand; draws six again")
	await click(Vector2(925, 32))
	check(app.screen == "items", "Top bag opens")
	app.back()
	await process_frame
	await click(Vector2(1060, 32))
	check(is_instance_valid(app.overlay), "Top menu opens")
	print("COMBAT LAYOUT CHECKS: %d | FAILURES: %d" % [checks, failures])
	quit(1 if failures else 0)
