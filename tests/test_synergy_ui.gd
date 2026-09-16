extends SceneTree
const Game = preload("res://src/game.gd")
var app: Control
var checks = 0
var failures = 0
func _initialize() -> void: call_deferred("run_tests")
func check(ok: bool, caption: String) -> void:
	checks += 1
	if not ok:
		failures += 1
		printerr("FAIL: ", caption)
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
	app.game = Game.new("user://unused-synergy-ui.save", false)
	root.add_child(app)
	var recipe = app.game.content.synergies[0]
	app.game.new_run(recipe.heroes, 42)
	app.game.enter_node(0)
	app.game.run.combat.hand = []
	for id in recipe.cards: app.game.run.combat.hand.append({"id": id, "upgraded": false})
	for enemy in app.game.run.combat.enemies: enemy.hp = 200
	app.continue_run()
	await process_frame
	check(app.layer.has_node("Synergy_" + recipe.id), "combination offered")
	await click(Vector2(640, 145))
	check(app.selected_synergy == recipe.id, "click selects combination")
	check(app.enemy_art[0].has_node("TargetGlow"), "enemy highlighted")
	await create_timer(0.2).timeout
	if DisplayServer.get_name() != "headless":
		await RenderingServer.frame_post_draw
		root.get_texture().get_image().save_png(preload("res://tests/artifacts.gd").path("synergies/combat.png"))
	app.back()
	check(app.selected_synergy == "", "back cancels")
	app.game.run.combat.energy = 1
	app.render()
	await process_frame
	await click(Vector2(640, 145))
	check(app.selected_synergy == recipe.id, "inspect without energy")
	check(not app.enemy_art[0].has_node("TargetGlow"), "no invalid glow")
	app.game.run.combat.energy = 3
	app.render()
	await process_frame
	var hp = app.game.run.combat.enemies[0].hp
	var turn = app.game.run.combat.turn
	await click(app.enemy_art[0].global_position + Vector2(40, 40))
	check(app.game.run.combat.enemies[0].hp < hp, "target resolves combo")
	check(app.game.run.combat.energy == 1, "spends two energy")
	for frame in range(900):
		if not app.combat_busy: break
		await process_frame
	check(not app.combat_busy and app.selected_synergy == "", "animation completes")
	check(app.game.run.combat.turn == turn, "combination does not end turn")
	check(not app.layer.has_node("Synergy_" + recipe.id), "offer gone after consuming cards")
	print("SYNERGY UI: %d checks / %d failures" % [checks, failures])
	quit(1 if failures else 0)
