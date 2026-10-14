extends SceneTree
const Game = preload("res://src/game.gd")
var checks = 0
var failures = 0
func check(ok: bool, message: String) -> void:
	checks += 1
	if not ok:
		failures += 1
		printerr("FAIL: ", message)
func battle(recipe: Dictionary, upgrades: bool = false) -> RefCounted:
	var g = Game.new("user://unused-synergy.save", false)
	g.new_run(recipe.heroes, 42)
	g.enter_node(0)
	g.run.combat.hand = []
	for id in recipe.cards: g.run.combat.hand.append({"id": id, "upgraded": upgrades})
	for h in g.run.heroes:
		h.hp -= 15
		h.block = 0
	for e in g.run.combat.enemies:
		e.hp = 200
		e.block = 5
	return g
func _initialize() -> void:
	var content = Game.new("user://unused.save", false).content
	check(content.synergies.size() == 6, "all six hero pairs")
	var participants: Dictionary = {}
	var pairs: Array = []
	for recipe in content.synergies:
		var pair = recipe.heroes.duplicate()
		pair.sort()
		check(pair not in pairs, "unique pair")
		pairs.append(pair)
		for i in range(2):
			var card = content.cards[recipe.cards[i]]
			check(card.owner == recipe.heroes[i], "owners match")
			if not participants.has(card.owner): participants[card.owner] = []
			if card.id not in participants[card.owner]: participants[card.owner].append(card.id)
		for upgraded in [false, true]:
			var g = battle(recipe, upgraded)
			check(g.available_synergies().size() == 1, "available " + recipe.id)
			var before = g.run.duplicate(true)
			check(not g.play_synergy(recipe.id, -1) and g.run == before, "invalid target atomic")
			g.run.combat.energy = 1
			before = g.run.duplicate(true)
			check(not g.play_synergy(recipe.id, 0) and g.run == before, "insufficient energy atomic")
			check(g.available_synergies().size() == 1, "inspect with insufficient energy")
			g.run.combat.energy = 3
			var discard_count = g.run.combat.discard.size()
			check(g.play_synergy(recipe.id, 0), "resolve " + recipe.id)
			check(g.run.combat.hand.is_empty() and g.run.combat.discard.size() == discard_count + 2, "consumes both")
			check(g.run.combat.energy == 1, "shared cost")
			var damage = recipe.damage + (6 if upgraded else 0)
			check(g.run.combat.enemies[0].hp == 200 - damage + (0 if recipe.pierce else 5), "special damage")
			check(g.run.combat.enemies[0].poison == recipe.poison, "poison")
			for h in g.run.heroes:
				check(h.block == recipe.block and h.hp == h.max_hp - 15 + recipe.heal, "both allies benefit")
			before = g.run.duplicate(true)
			check(not g.play_synergy(recipe.id, 0) and g.run == before, "cannot replay")
		var g = battle(recipe)
		g.run.heroes[1].hp = 0
		check(g.available_synergies().is_empty(), "fallen partner disables")
		g.run.heroes[1].hp = 1
		g.run.combat.hand.pop_back()
		check(g.available_synergies().is_empty(), "missing card disables")
		g = battle(recipe)
		check(g.play_card(0, g.valid_targets(0)[0]), "individual play remains possible")
		check(g.available_synergies().is_empty(), "individual play removes opportunity")
	for hero in content.heroes:
		check(participants[hero].size() == 2, "only two cards per hero")
	var recipe = content.synergies[0]
	var g = battle(recipe, true)
	g.run.combat.hand.append(g.run.combat.hand[0].duplicate())
	check(g.play_synergy(recipe.id, 0) and g.run.combat.hand.size() == 1, "duplicates consume one copy only")
	g = battle(recipe)
	g.run.heroes[0].turn_strength = 3
	g.run.relics = ["fang"]
	check(g.available_synergies()[0].damage == recipe.damage + 4, "strength and fang reflected in preview")
	check(g.play_synergy(recipe.id, 0) and g.run.combat.enemies[0].hp == 200 - recipe.damage - 4 + 5, "preview matches boosted result")
	var poison_recipe = content.synergies[1]
	g = battle(poison_recipe)
	for hero in g.run.heroes: hero.equipped_relic = "poison_fang"
	var expected_poison = poison_recipe.poison + int(content.equipment.poison_fang.value)
	check(g.available_synergies()[0].poison == expected_poison, "shared poison bonus applied once")
	var path = "user://synergy-persistence-test.save"
	g = battle(recipe, true)
	g.store = preload("res://src/save_store.gd").new(path)
	g.save_enabled = true
	g.checkpoint()
	var restored = Game.new(path, true)
	check(restored.available_synergies() == g.available_synergies(), "pending combo restored")
	for enemy in restored.run.combat.enemies: enemy.hp = 0
	restored.run.combat.enemies[0].hp = 1
	var souls = restored.profile.souls
	check(restored.play_synergy(recipe.id, 0), "lethal combo")
	check(restored.run.phase == "reward" and restored.profile.souls == souls + 30, "normal victory rewards")
	var again = Game.new(path, true)
	check(again.run == restored.run and again.profile == restored.profile, "committed result saved")
	check(not again.play_synergy(recipe.id, 0), "reload cannot repeat")
	for suffix in ["", ".bak", ".tmp"]: DirAccess.remove_absolute(path + suffix)
	print("SYNERGY CHECKS: %d / FAILURES: %d" % [checks, failures])
	quit(1 if failures else 0)
