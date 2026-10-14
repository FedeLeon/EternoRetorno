extends SceneTree
const Game = preload("res://src/game.gd")
const Flow = preload("res://src/ui/combat_flow.gd")
var failures = 0
var checks = 0
func _initialize() -> void: call_deferred("run_tests")
func check(ok: bool, message: String) -> void:
	checks += 1
	if not ok:
		failures += 1
		printerr("FAIL: ", message)
func run_tests() -> void:
	root.size = Vector2i(1280, 720)
	var app = load("res://main.tscn").instantiate()
	app.game = Game.new("user://unused-poison-feedback.save", false)
	root.add_child(app)
	app.game.new_run(["warrior", "guardian"], 31)
	app.game.enter_node(0)
	app.game._start_combat(["goblin_warrior", "goblin_archer"])
	var enemies = app.game.run.combat.enemies
	enemies[0].hp = 2
	enemies[0].poison = 5
	enemies[1].poison = 3
	for enemy in enemies: enemy.intent = {"damage":0, "block":0, "target":0}
	var surviving_hp: int = enemies[1].hp
	app.continue_run()
	await process_frame
	Flow.run(app)
	check(enemies[0].hp == 0 and enemies[1].hp == surviving_hp - 3, "poison is resolved before animation")
	check(app.game.resolved_poison_hits[0].lost == 2 and app.game.resolved_poison_hits[1].lost == 3, "receipts separate actual poison damage from other damage")
	var green = [false, false]
	var red = false
	var during_discard = false
	var deadline = Time.get_ticks_msec() + 15000
	while app.combat_busy and Time.get_ticks_msec() < deadline:
		var ashes = app.layer.get_children().any(func(node): return node.get_script() == preload("res://src/presentation/card_ash.gd"))
		for i in range(2):
			var tint: Color = app.enemy_art[i].sprite.modulate
			if tint.g > tint.r + 0.1:
				green[i] = true
				during_discard = during_discard or ashes
			red = red or tint.r > tint.g + 0.1 or app.enemy_art[i].modulate.r > app.enemy_art[i].modulate.g + 0.1
		await process_frame
	check(not app.combat_busy, "presentation completes")
	check(green[0] and green[1], "lethal and surviving poison ticks flash green")
	check(not red, "poison never flashes red")
	check(not during_discard, "poison waits for outgoing cards")
	check(app.enemy_art[0].fallen, "lethal poison still plays death")
	check(app.enemy_art[1].sprite.modulate == Color.WHITE, "poison tint clears")
	app.enemy_art[1].play_once("hurt")
	check(app.enemy_art[1].sprite.modulate.r > app.enemy_art[1].sprite.modulate.g, "normal damage remains red")
	await create_timer(0.3).timeout
	app.game.end_turn()
	check(not app.game.resolved_poison_hits.has(0), "dead enemy has no repeated poison receipt")
	app.queue_free()
	await process_frame
	print("POISON FEEDBACK: %d checks / %d failures" % [checks, failures])
	quit(1 if failures else 0)
