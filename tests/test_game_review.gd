extends SceneTree
const Game = preload("res://src/game.gd")
const Depth = preload("res://src/rules/combat_depth.gd")
const Flow = preload("res://src/ui/combat_flow.gd")
var checks = 0
var failures = 0
var app: Control
func _initialize() -> void: call_deferred("verify")
func check(ok: bool, message: String) -> void:
	checks += 1
	if not ok:
		failures += 1
		printerr("FAIL: ", message)
func fixture() -> void:
	app.game.new_run(["warrior", "guardian"], 42)
	app.game.enter_node(0)
	app.game._start_combat(["goblin_warrior"])
	app.game.run.combat.enemies[0].intent = {"damage":1,"block":0,"target":0,"counter":0}
func verify() -> void:
	root.size = Vector2i(1280,720)
	app = load("res://main.tscn").instantiate()
	app.game = Game.new("user://unused-game-review",false)
	app.game.profile.settings = {"auto_cinematics":false}
	root.add_child(app)
	fixture()
	app.game.run.combat.enemies[0].hp = 10
	app.game.run.combat.hand = [{"id":"warrior_prepared","upgraded":false}]
	check(app.game.play_card(0,0), "prepare a real card without attacking yet")
	app.continue_run()
	var enemy = app.enemy_art[0]
	Flow.run(app)
	var saw_enemy = false
	var saw_prepared = false
	var premature_ash = false
	var deadline = Time.get_ticks_msec() + 20000
	while app.combat_busy and Time.get_ticks_msec() < deadline:
		if app.layer.has_node("EnemyCutIn"): saw_enemy = true
		if app.layer.has_node("HeroCutIn"): saw_prepared = true
		if is_instance_valid(enemy) and enemy.fallen and not saw_prepared: premature_ash = true
		await process_frame
	check(not app.combat_busy and app.screen == "reward", "lethal preparation finishes normally")
	check(saw_enemy and saw_prepared and not premature_ash, "enemy acts, prepared strike appears, then ashes")
	check(app.game.resolved_enemy_attacks == [0], "committed enemy attack is preserved")
	fixture()
	app.game.run.combat.enemies[0].hp = 999
	app.game.run.combat.enemies[0].max_hp = 999
	var card = app.game.effective_card({"id":"warrior_prepared","upgraded":false})
	for i in range(3): Depth.prepare(app.game,card,0,[0])
	app.continue_run()
	Flow.run(app)
	var committed = app.game.run.duplicate(true)
	var cutins = {}
	deadline = Time.get_ticks_msec() + 20000
	while app.combat_busy and Time.get_ticks_msec() < deadline:
		var cut = app.layer.get_node_or_null("HeroCutIn")
		if cut != null: cutins[cut.get_instance_id()] = true
		await process_frame
	check(not app.combat_busy and cutins.size() == 3, "three prepared cards each have their own attack presentation")
	check(app.game.run == committed, "replay does not resolve or save combat twice")
	check(app.game.resolved_prepared_hits.map(func(hit): return hit.action_index) == [0,1,2], "prepared receipts distinguish separate actions")
	fixture()
	app.game.run.heroes[0].block = 20
	app.game.run.combat.enemies[0].hp = 999
	app.game.run.combat.enemies[0].intent.counter = 4
	app.game.run.combat.hand = [{"id":"warrior_slash","upgraded":false}]
	var hp = app.game.run.heroes[0].hp
	app.continue_run()
	Flow.run(app,0,0)
	var blocked_feedback = false
	deadline = Time.get_ticks_msec() + 20000
	while app.combat_busy and Time.get_ticks_msec() < deadline:
		blocked_feedback = blocked_feedback or app.layer.find_children("FloatingDamage", "Label", true, false).any(func(label): return label.text == "4" and label.get_theme_color("font_color") == Color("d3efff"))
		await process_frame
	check(not app.combat_busy and blocked_feedback, "blocked counter shows actual absorbed damage in blue")
	var counter = app.game.resolved_card_hits.filter(func(hit): return hit.kind == "counter")[0]
	check(counter.absorbed == 4 and counter.lost == 0 and counter.hp == hp and counter.block == 16, "counter receipt reports actual block and life loss")
	app.game.new_run(["warrior","guardian"],42)
	preload("res://tests/room_fixture.gd").enter(app.game,"boss")
	app.game._start_combat(["boss"])
	app.game.run.combat.enemies[0].hp = 10
	app.game.run.combat.enemies[0].intent = {"damage":0,"block":0,"target":0,"counter":0}
	Depth.prepare(app.game,app.game.effective_card({"id":"warrior_prepared","upgraded":false}),0,[0])
	app.continue_run()
	Flow.run(app)
	deadline = Time.get_ticks_msec() + 20000
	while app.combat_busy and Time.get_ticks_msec() < deadline: await process_frame
	check(not app.combat_busy and app.game.run.phase == "combat", "prepared strike permits a real source revival")
	check(app.game.resolved_prepared_hits.any(func(hit): return hit.kind == "revive"), "revival belongs to prepared replay receipts")
	check(not app.enemy_art[0].fallen and app.enemy_art[0].sprite.visible and app.enemy_health[0].displayed_hp == app.game.run.combat.enemies[0].hp, "revived boss remains visible at actual health")
	app.queue_free()
	await process_frame
	print("GAME REVIEW: %d checks / %d failures" % [checks,failures])
	quit(1 if failures else 0)
