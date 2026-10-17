extends SceneTree
const Game = preload("res://src/game.gd")
var fails = 0
func _initialize() -> void: call_deferred("run_tests")
func check(ok: bool, text: String) -> void:
	if not ok: fails += 1; printerr(text)
func prepare() -> RefCounted:
	var g = Game.new("user://unused-counter.save", false)
	g.new_run(["mage", "warrior"], 42)
	g.enter_node(0)
	g.run.combat.enemies[0].hp = 100
	g.run.combat.enemies[0].max_hp = 100
	g.run.combat.enemies[0].block = 0
	g.run.combat.enemies[0].intent = {"damage":0,"counter":4,"target":0}
	g.content.cards["mage_spark"].damage = 5
	g.content.cards["mage_spark"].hits = 3
	g.run.combat.hand = [{"id":"mage_spark", "upgraded":false}]
	g.run.combat.energy = 9
	return g
func run_tests() -> void:
	var g = prepare()
	var hp = g.run.heroes[0].hp
	g.play_card(0,0)
	check(g.run.combat.enemies[0].hp == 85, "three five-damage hits")
	check(g.run.heroes[0].hp == hp - 12, "three four-damage counters")
	check(g.resolved_card_hits.map(func(e): return e.kind) == ["hit","counter","hit","counter","hit","counter"], "alternating receipt")
	g = prepare()
	g.run.heroes[0].block = 10
	g.play_card(0,0)
	check(g.run.heroes[0].hp == hp - 2 and g.run.heroes[0].block == 0, "block absorbs each counter")
	g = prepare()
	g.run.heroes[0].hp = 4
	g.play_card(0,0)
	check(g.run.heroes[0].hp == 0 and g.resolved_card_hits.size() == 2, "fallen attacker stops remaining hits")
	g = prepare()
	g.run.combat.enemies[0].hp = 5
	g.play_card(0,0)
	check(g.run.phase == "reward" and g.resolved_card_hits.size() == 1, "dead enemy never counters")
	g = prepare()
	g.run.heroes[0].hp = 4
	g.run.heroes[1].hp = 0
	g.play_card(0,0)
	check(g.run.phase == "defeat", "counter can end run")

	var app = load("res://main.tscn").instantiate()
	app.game = prepare()
	root.add_child(app)
	app.continue_run()
	await process_frame
	var enemy_steps: Array = []
	var hero_steps: Array = []
	var enemy_bar = app.enemy_health[0]
	var hero_bar = app.hero_health[0]
	enemy_bar.animation_finished.connect(func(): enemy_steps.append(enemy_bar.displayed_hp))
	hero_bar.animation_finished.connect(func(): hero_steps.append(hero_bar.displayed_hp))
	var cut_ins: Array = []
	app.layer.child_entered_tree.connect(func(node):
		if node.name == "HeroCutIn": cut_ins.append(node.texture_path))
	app.animate_combat_action(0, 0)
	while app.combat_busy: await process_frame
	var unique = {}
	for path in cut_ins: unique[path] = true
	check(cut_ins.size() == 3 and unique.size() == 3 and cut_ins.all(func(path): return "mage_attack" in path), "three different static foreground appearances for three hits")
	check(enemy_steps.slice(0, 3) == [95, 90, 85], "presentation shows three separate enemy HP reductions")
	check(hero_steps.slice(0, 3) == [hp-4, hp-8, hp-12], "presentation shows three separate counters")
	# A two-hit card must not add the old single introductory cut-in.
	app.game = prepare()
	app.game.content.cards["mage_spark"].hits = 2
	app.continue_run()
	await process_frame
	cut_ins.clear()
	app.layer.child_entered_tree.connect(func(node):
		if node.name == "HeroCutIn": cut_ins.append(node.texture_path))
	app.animate_combat_action(0, 0)
	while app.combat_busy: await process_frame
	check(cut_ins.size() == 2 and cut_ins[0] != cut_ins[1] and cut_ins.all(func(path): return "mage_attack" in path), "two different static foreground appearances for two hits")
	app.queue_free()
	await process_frame
	await create_timer(0.1).timeout
	print("COUNTER FAILURES: ", fails)
	quit(1 if fails else 0)
