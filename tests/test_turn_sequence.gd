extends SceneTree
const Game = preload("res://src/game.gd")
const Flow = preload("res://src/ui/combat_flow.gd")
const Status = preload("res://src/ui/components/status_effects.gd")
var failures = 0
var checks = 0
var app: Control
func _initialize() -> void: call_deferred("run_tests")
func check(ok: bool, message: String) -> void:
	checks += 1
	if not ok:
		failures += 1
		printerr("FAIL: ", message)
func block_at(index: int) -> Control:
	for sibling in app.enemy_health[index].get_parent().get_children():
		if sibling.get_script() == Status: return sibling.get_node("Block")
	return null
func run_tests() -> void:
	root.size = Vector2i(1280,720)
	app = load("res://main.tscn").instantiate()
	app.game = Game.new("user://unused-turn-sequence.save", false)
	root.add_child(app)
	app.game.new_run(["warrior","guardian"], 31)
	app.game.enter_node(0)
	app.game._start_combat(["goblin_warrior","goblin_archer"])
	app.game.run.combat.enemies[0].intent = {"damage":6,"block":7,"target":0}
	app.game.run.combat.enemies[1].intent = {"damage":0,"block":5,"target":1}
	for hero in app.game.run.heroes: hero.block = 20
	app.continue_run()
	await process_frame
	var first = block_at(0)
	var second = block_at(1)
	check(first != null and not first.visible, "zero block starts hidden but can update")
	Flow.run(app)
	check(app.combat_busy and app.game.resolved_enemy_blocks == {0:7,1:5}, "committed action receipts")
	check(app.game.resolved_hero_defenses == {0:[0]}, "only attacked hero defends despite both shields expiring")
	var saw_ash = false
	var saw_block_before_attack = false
	var saw_attack = false
	var overlap = false
	var premature_block = false
	var second_attacked = false
	var deadline = Time.get_ticks_msec() + 15000
	while app.combat_busy and Time.get_ticks_msec() < deadline:
		var ashes = app.layer.get_children().any(func(node): return node.get_script() == preload("res://src/presentation/card_ash.gd"))
		var cut = app.layer.get_node_or_null("EnemyCutIn")
		var attacking = cut != null or app.enemy_art[0].acting
		saw_ash = saw_ash or ashes
		overlap = overlap or (ashes and attacking)
		premature_block = premature_block or (ashes and first.visible)
		if not ashes and first.visible and not attacking and not saw_attack: saw_block_before_attack = true
		if attacking:
			saw_attack = true
			check(first.visible and first.amount == 7, "block already visible at attack")
		second_attacked = second_attacked or (cut != null and cut.visual_id == "goblin_2")
		await process_frame
	check(not app.combat_busy, "sequence completes")
	check(saw_ash and saw_block_before_attack and saw_attack, "all ordered stages observed")
	check(not overlap and not premature_block, "no enemy action during card ashes")
	check(not second_attacked and app.game.run.combat.enemies[1].block == 5, "block-only enemy gains shield without attacking")
	# Enemies killed by poison, and enemies after a lethal action, must not gain block visually.
	var game = Game.new("user://unused-turn-receipts.save",false)
	game.new_run(["warrior","guardian"],31)
	game.enter_node(0)
	game._start_combat(["goblin_warrior","goblin_archer"])
	game.run.combat.enemies[0].hp = 1
	game.run.combat.enemies[0].poison = 1
	game.end_turn()
	check(not game.resolved_enemy_blocks.has(0), "poison kill has no action receipt")
	game._start_combat(["goblin_warrior","goblin_archer"])
	for hero in game.run.heroes: hero.hp = 1
	game.run.combat.enemies[0].intent = {"damage":999,"all":true,"block":3,"target":0}
	game.end_turn()
	check(game.resolved_enemy_blocks == {0:3}, "defeat does not present unexecuted shields")
	game.new_run(["warrior","guardian"],31)
	game.enter_node(0)
	game._start_combat(["goblin_warrior"])
	for hero in game.run.heroes: hero.block = 20
	game.run.combat.enemies[0].intent = {"damage":6,"all":true,"block":0,"target":0}
	game.end_turn()
	check(game.resolved_hero_defenses == {0:[0,1]}, "area attack allows both targets to defend")
	game.run.combat.enemies[0].intent = {"damage":0,"block":5,"target":0}
	game.end_turn()
	check(game.resolved_hero_defenses.is_empty(), "defense receipts cleared on next turn")
	app.queue_free()
	await process_frame
	await create_timer(0.1).timeout
	print("TURN SEQUENCE: %d checks / %d failures" % [checks,failures])
	quit(1 if failures else 0)
