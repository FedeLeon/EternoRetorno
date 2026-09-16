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
func shot(name: String) -> void:
	if DisplayServer.get_name() != "headless":
		await RenderingServer.frame_post_draw
		root.get_texture().get_image().save_png(preload("res://tests/artifacts.gd").path("combat/" + name + ".png"))
func run_tests() -> void:
	root.size = Vector2i(1280, 720)
	app = load("res://main.tscn").instantiate()
	app.game = Game.new("user://unused-presentation.save", false)
	root.add_child(app)
	app.game.new_run(["warrior", "cleric"], 42)
	app.game.enter_node(0)
	var battle = app.game.run.combat
	battle.enemies[0].intent = {"damage":12, "block":8, "target":1}
	app.continue_run()
	await process_frame
	var intent = app.layer.get_node("EnemyIntent0")
	check(intent.get_node("Attack").amount == 12 and intent.get_node("Block").amount == 8, "both intent values")
	check(intent.has_node("Target_cleric") and not intent.has_node("Target_warrior"), "face matches target")
	await shot("intent")
	battle.enemies[0].intent.all = true
	app.render()
	await process_frame
	intent = app.layer.get_node("EnemyIntent0")
	check(intent.has_node("Target_cleric") and intent.has_node("Target_warrior"), "area attack shows both portraits")
	battle.enemies[0].intent.damage = 0
	app.render()
	await process_frame
	intent = app.layer.get_node("EnemyIntent0")
	check(not intent.has_node("Attack") and not intent.has_node("Target_cleric") and intent.has_node("Block"), "block-only intent has no sword or target")
	battle.hand = [{"id":"warrior_slash", "upgraded":false}]
	# Use the catalog to avoid relying on a particular attack card ID.
	for id in app.game.content.cards:
		var card = app.game.content.cards[id]
		if card.owner == "warrior" and card.damage > 0 and card.target == "enemy":
			battle.hand[0].id = id
			break
	battle.energy = 9
	battle.enemies[0].hp = 1
	battle.enemies[0].block = 0
	app.game.run.heroes[1].hp = 0
	app.render()
	await process_frame
	check(app.layer.get_node("CombatHand").get_child(0).get_child(0).has_node("CardType0"), "attack card has symbol")
	app.animate_combat_action(0, 0)
	check(app.game.run.phase == "reward" and app.combat_busy, "victory resolves before effects")
	check(app.layer.has_node("AttackFlash"), "attack creates white flash")
	var actor = app.hero_art[0]
	var initial = actor.global_position.x
	var moved = false
	var outside = false
	while app.combat_busy:
		if is_instance_valid(actor):
			moved = moved or actor.global_position.x > initial + 100
			outside = outside or actor.global_position.x > 1280
		await process_frame
	check(moved and outside and app.screen == "reward", "party runs offscreen before reward UI")
	check(app.game.run.heroes[1].hp > 0, "fallen companion revived before exit")
	app.game.new_run(["warrior", "cleric"], 42)
	app.game.enter_node(0)
	for hero in app.game.run.heroes:
		hero.hp = 1
	app.game.run.combat.enemies[0].intent = {"damage":999, "target":0, "all":true}
	app.continue_run()
	await process_frame
	var doomed = app.hero_art[0]
	var starting_x = doomed.global_position.x
	app.animate_combat_action()
	var fled = false
	while app.combat_busy:
		if is_instance_valid(doomed):
			fled = fled or doomed.global_position.x > starting_x + 100
		await process_frame
	check(not fled and app.game.run.phase == "defeat", "defeat does not run to another room")
	print("PRESENTATION CHECKS: %d | FAILURES: %d" % [checks, failures])
	quit(1 if failures else 0)
