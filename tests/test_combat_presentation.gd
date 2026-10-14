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
	app.game.new_run(["warrior", "guardian"], 42)
	app.game.enter_node(0)
	var battle = app.game.run.combat
	battle.enemies[0].intent = {"damage":12, "block":8, "target":1}
	app.continue_run()
	await process_frame
	var intent = app.layer.get_node("EnemyIntent0")
	check(intent.get_node("Attack").amount == 12 and intent.get_node("Block").amount == 8, "both intent values")
	check(intent.has_node("Target_guardian") and not intent.has_node("Target_warrior"), "face matches target")
	await shot("intent")
	battle.enemies[0].intent.all = true
	app.render()
	await process_frame
	intent = app.layer.get_node("EnemyIntent0")
	check(intent.has_node("Target_guardian") and intent.has_node("Target_warrior"), "area attack shows both portraits")
	battle.enemies[0].intent.damage = 0
	app.render()
	await process_frame
	intent = app.layer.get_node("EnemyIntent0")
	check(not intent.has_node("Attack") and not intent.has_node("Target_guardian") and intent.has_node("Block"), "block-only intent has no sword or target")
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
	battle.energy = 0
	app.animate_combat_action(0, 0)
	check(not app.layer.has_node("CardAsh") and not app.layer.has_node("HeroCutIn") and battle.hand.size() == 1, "rejected play keeps card without ashes")
	battle.energy = 9
	app.animate_combat_action(0, 0)
	check(app.game.run.phase == "reward" and app.combat_busy, "victory resolves before effects")
	check(app.layer.has_node("HeroCutIn"), "offensive play shows hero comic after commit")
	check(app.layer.has_node("AttackFlash"), "attack creates white flash")
	check(app.layer.has_node("CardAsh") and not app.layer.get_node("CombatHand").get_child(0).get_child(0).visible, "accepted play hides original and creates ash effect")
	await create_timer(0.4).timeout
	await shot("card-ash")
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
	app.game.new_run(["warrior", "guardian"], 42)
	app.game.enter_node(0)
	for hero in app.game.run.heroes:
		hero.hp = 1
	app.game.run.combat.enemies[0].intent = {"damage":999, "target":0, "all":true}
	app.continue_run()
	await process_frame
	var doomed = app.hero_art[0]
	var starting_x = doomed.global_position.x
	app.animate_combat_action()
	# The outgoing hand dissolves before the enemy begins its attack.
	var saw_enemy_attack = false
	var fled = false
	while app.combat_busy:
		saw_enemy_attack = saw_enemy_attack or app.layer.has_node("EnemyCutIn")
		if is_instance_valid(doomed):
			fled = fled or doomed.global_position.x > starting_x + 100
		await process_frame
	check(saw_enemy_attack, "enemy turn shows foreground attack after hand dissolves")
	check(not fled and app.game.run.phase == "defeat", "defeat does not run to another room")
	var combo = app.game.content.synergies[0]
	app.game.new_run(combo.heroes, 42)
	app.game.enter_node(0)
	app.game.run.combat.hand = combo.cards.map(func(id): return {"id": id, "upgraded": false})
	app.game.run.combat.energy = 9
	app.continue_run()
	await process_frame
	app.animate_combat_action(-1, 0, combo.id)
	var effects = app.layer.get_children().filter(func(node): return node.get_script() == preload("res://src/presentation/card_ash.gd"))
	check(effects.size() == 2 and app.game.run.combat.hand.is_empty(), "synergy consumes and animates both cards")
	while app.combat_busy: await process_frame
	check(effects.all(func(effect): return not is_instance_valid(effect)), "ash effects cleaned after animation")
	app.game.new_run(["warrior", "guardian"], 42)
	app.game.enter_node(0)
	var defense_id = ""
	for id in app.game.content.cards:
		var data = app.game.content.cards[id]
		if data.owner == "warrior" and data.block > 0 and data.damage == 0 and data.poison == 0:
			defense_id = id
			break
	app.game.run.combat.hand = [{"id": defense_id, "upgraded": false}]
	app.game.run.combat.energy = 9
	app.continue_run()
	await process_frame
	app.animate_combat_action(0, app.game.valid_targets(0)[0])
	var defense = app.layer.get_node_or_null("HeroCutIn")
	check(defense != null and defense.action == "defense", "blocking card uses defensive illustration")
	check(app.game.run.heroes[0].block > 0, "block committed before defense cut-in")
	while app.combat_busy: await process_frame
	app.game.new_run(["warrior", "guardian"], 42)
	app.game.enter_node(0)
	app.game.run.combat.enemies[0].intent = {"damage":0, "block":2, "target":0}
	app.continue_run()
	await process_frame
	var outgoing = app.layer.get_node("CombatHand").get_child(0).get_children()
	var previous_turn = app.game.run.combat.turn
	app.animate_combat_action()
	var discarded_effects = app.layer.get_children().filter(func(node): return node.get_script() == preload("res://src/presentation/card_ash.gd"))
	check(discarded_effects.size() == outgoing.size() and outgoing.size() == 6, "end turn animates every unused card")
	check(outgoing.all(func(card): return not card.visible), "outgoing hand hidden under ash snapshots")
	check(app.game.run.combat.turn == previous_turn + 1, "turn resolved before discard animation")
	app.animate_combat_action()
	check(app.game.run.combat.turn == previous_turn + 1, "double end turn rejected while ashes play")
	await create_timer(0.4).timeout
	await shot("hand-ash")
	while app.combat_busy: await process_frame
	check(discarded_effects.all(func(effect): return not is_instance_valid(effect)), "discard ashes cleaned")
	check(app.layer.get_node("CombatHand").get_child(0).get_children().all(func(card): return card.visible), "new hand visible after ashes")
	app.game.run.combat.hand.clear()
	app.game.run.combat.enemies[0].intent = {"damage":0, "block":2, "target":0}
	app.render()
	await process_frame
	app.animate_combat_action()
	check(not app.layer.has_node("CardAsh"), "empty hand has no phantom ash")
	while app.combat_busy: await process_frame
	print("PRESENTATION CHECKS: %d | FAILURES: %d" % [checks, failures])
	quit(1 if failures else 0)
