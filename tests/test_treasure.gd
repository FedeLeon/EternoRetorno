extends SceneTree
const Game = preload("res://src/game.gd")
const Treasure = preload("res://src/rules/treasure.gd")
const Background = preload("res://src/ui/components/battle_background.gd")
const SAVE = "user://treasure-test.save"
var checks = 0
var failures = 0
func check(ok: bool, text: String) -> void:
	checks += 1
	if not ok:
		failures += 1
		printerr(text)
func _initialize() -> void:
	var g = Game.new(SAVE, true)
	g.new_run(["warrior", "cleric"], 42)
	check(g.run.inventory.is_empty(), "new run has empty inventory")
	check(not g.take_treasure() and not g.leave_treasure(), "room actions require treasure")
	g.run.current = 0
	g.enter_node(3)
	var rolled = g.run.treasure.duplicate(true)
	var saved_rng = g.rng.state
	check(not g.leave_treasure(), "cannot acknowledge unopened chest")
	g = Game.new(SAVE, true)
	check(g.run.treasure == rolled and g.rng.state == saved_rng, "unopened result and RNG persist")
	check(g.take_treasure(), "open chest")
	check(g.run.inventory[rolled.item] == 1, "one item granted")
	var committed = g.run.duplicate(true)
	check(not g.take_treasure() and g.run == committed, "duplicate opening is atomic no-op")
	g = Game.new(SAVE, true)
	check(g.run == committed and not g.take_treasure(), "reopening during animation cannot replay")
	check(g.leave_treasure() and not g.leave_treasure(), "acknowledge pending result once")
	for trapped in [false, true]:
		g.new_run(["warrior", "cleric"], 23)
		g.run.current = 0
		g.enter_node(3)
		g.run.treasure.trapped = trapped
		g.run.heroes[0].hp = 2
		g.run.heroes[1].hp = 20
		g.take_treasure()
		check(g.run.heroes[0].hp == (1 if trapped else 2) and g.run.heroes[1].hp == (16 if trapped else 20), "trap damage is small and nonlethal")
		check(g.run.inventory.values() == [1], "traps also give item")
		check(g.run.phase == "room" and g.run.treasure.opened, "result remains pending")
	g.new_run(["warrior", "cleric"], 11)
	g.run.inventory = {"healing_potion": 3}
	g.run.current = 0
	g.enter_node(3)
	g.run.treasure.item = "healing_potion"
	g.run.treasure.trapped = false
	g.take_treasure()
	check(g.run.inventory.healing_potion == 4, "loot stacks existing items")
	g.checkpoint()
	g = Game.new(SAVE, true)
	check(g.run.inventory.healing_potion == 4, "old inventory survives loading")
	g.leave_treasure()
	g.run.current = 0
	g.enter_node(3)
	g.run.treasure = "ember"
	g.checkpoint()
	g = Game.new(SAVE, true)
	check(g.take_treasure() and "ember" in g.run.relics, "legacy pending relic preserved")
	check(not g.take_treasure() and g.leave_treasure(), "legacy chest one-time claim")
	var rng = RandomNumberGenerator.new()
	rng.seed = 995
	var traps = 0
	var items = {}
	for i in range(10000):
		var result = Treasure.prepare(rng, g.content.items.keys())
		traps += int(result.trapped)
		items[result.item] = true
	check(Treasure.TRAP_PERCENT == 15 and traps > 1300 and traps < 1700, "15 percent threshold and seeded distribution")
	check(items.size() == 8, "all eight items obtainable")
	print("TRAPS / 10000: ", traps)
	var paths = {}
	for node in [0, 2, 4, 5, 8, 9, 11]:
		paths[Background.path_for(42, node)] = true
	check(paths.size() == 3 and Background.path_for(42, 0) == Background.path_for(42, 0), "three deterministic environments")
	for suffix in ["", ".bak", ".tmp"]:
		DirAccess.remove_absolute(SAVE + suffix)
	print("TREASURE CHECKS: %d | FAILURES: %d" % [checks, failures])
	quit(1 if failures else 0)
