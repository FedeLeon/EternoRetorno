extends SceneTree
const Game = preload("res://src/game.gd")
const Tactics = preload("res://src/rules/pair_tactics.gd")
var checks = 0
var failures = 0
func check(ok: bool, message: String) -> void:
	checks += 1
	if not ok: failures += 1; printerr("FAIL: ", message)
func fixture(recipe: Dictionary) -> RefCounted:
	var game = Game.new("user://unused-pair-tactics", false)
	game.new_run(recipe.heroes, 812)
	game.run.nodes[0].encounter = ["rat", "rat", "rat"]
	game.enter_node(0)
	game.run.combat.hand = []
	for id in recipe.cards: game.run.combat.hand.append({"id":id, "upgraded":false})
	for hero in game.run.heroes: hero.block = 6
	for enemy in game.run.combat.enemies:
		enemy.hp = 500; enemy.max_hp = 500; enemy.block = 10; enemy.poison = 2
		enemy.intent = {"damage":8, "block":0, "counter":4, "special":"embers", "target":0, "all":false}
	game.run.combat.energy = 3
	return game
func _initialize() -> void:
	var recipes = Game.new("user://unused-pair-recipes", false).content.synergies
	for recipe in recipes:
		var game = fixture(recipe)
		var lesson_game = fixture(recipe)
		lesson_game.run.training = true
		lesson_game.run.guided_lesson = {}
		var lessons = preload("res://src/rules/guided_lessons.gd")
		lessons.prepare(lesson_game, 0)
		var defense = lesson_game.content.card(lesson_game.run.combat.hand[0])
		check(defense.owner == recipe.heroes[0] and defense.block >= 6, "every pair can practice blocking")
		check(lesson_game.play_card(0, 0) and lessons.ready(lesson_game), "every civil can actually complete its block lesson")
		lessons.prepare(lesson_game, 4)
		check(lesson_game.available_synergies().size() == 1, "every pair can practice its own synergy")
		var combo: Dictionary = game.available_synergies()[0]
		check(Tactics.active(game, combo, 0), "conditional is active: " + recipe.id)
		check(not combo.tactic_text.is_empty(), "condition explained")
		var hp = game.run.heroes[0].hp
		check(game.play_synergy(recipe.id, 0), "commits conditional combo")
		var enemy: Dictionary = game.run.combat.enemies[0]
		match recipe.tactic:
			"cover", "interference":
				check(enemy.intent.get("counter", 0) == 0, "counter interrupted before damage")
				check(game.run.heroes[0].hp == hp, "counter does not hurt participant")
				if recipe.tactic == "interference": check(not enemy.intent.has("special"), "special interrupted")
				else: check(enemy.intent.get("special", "") == "embers", "cover cancels counter only; other pairs retain their own identity")
			"incision": check(enemy.block == 10 and enemy.hp == 500 - combo.damage, "corrosion allows penetration without consuming shield")
			"circuit": check(enemy.hp == 500 - combo.damage + 2, "8 shield removed before absorption")
			"screen": check(game.Modifiers.intent(enemy).damage == 6, "25 percent weakening applies to announced damage")
			"chain": check(game.run.combat.enemies[1].poison == 5 and game.run.combat.enemies[2].poison == 5, "corrosion propagates to both other targets")
		game = fixture(recipe)
		game.run.erase("pair_tactics_version")
		check(not Tactics.active(game, game.available_synergies()[0], 0), "old adventure keeps old effects")
		check(game.available_synergies()[0].tactic_text.is_empty(), "old adventure does not advertise new condition")
		check(game.play_synergy(recipe.id, 0), "old adventure combo still works")
		check(game.run.combat.enemies[1].poison == 2, "old adventure has no propagation")
		game = fixture(recipe)
		for hero in game.run.heroes: hero.block = 0
		var target = game.run.combat.enemies[0]
		target.block = 0; target.poison = 0; target.intent.counter = 0; target.intent.erase("special")
		check(not Tactics.active(game, game.available_synergies()[0], 0), "missing condition gives no bonus")
		check(game.play_synergy(recipe.id, 0), "base combo remains usable without condition")
	print("PAIR TACTICS: %d checks / %d failures" % [checks, failures])
	quit(1 if failures else 0)
