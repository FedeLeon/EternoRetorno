extends SceneTree
const Game = preload("res://src/game.gd")
const Pets = preload("res://src/rules/pet_companions.gd")
var checks = 0
var failures = 0

func check(ok: bool, message: String) -> void:
	checks += 1
	if not ok:
		failures += 1
		printerr("FAIL: ", message)

func fresh(pet: String) -> RefCounted:
	var game = Game.new("user://unused-pet-rules", false)
	check(game.new_run(["warrior", "guardian"], 82, {}, 1, pet), "create pet adventure")
	game.enter_node(0)
	return game

func _initialize() -> void:
	call_deferred("run_tests")

func run_tests() -> void:
	var plain = fresh("")
	var dog = fresh("dog")
	var cat = fresh("cat")
	for i in range(2):
		check(dog.run.heroes[i].block == plain.run.heroes[i].block + 3, "dog protects both heroes")
		check(cat.run.heroes[i].block == plain.run.heroes[i].block, "cat grants no block")
	check(cat.run.combat.hand.size() == plain.run.combat.hand.size() + 1, "cat draws one opening card")
	check(dog.run.combat.hand == plain.run.combat.hand, "dog leaves draw RNG unchanged")
	check(dog.run.combat.enemies == plain.run.combat.enemies, "pet leaves generated enemies and intentions unchanged")
	for game in [plain, dog, cat]:
		game.run.combat.hand.clear()
		game._start_turn()
	check(dog.run.heroes[0].block == plain.run.heroes[0].block, "dog bonus does not recur on later turns")
	check(cat.run.combat.hand.size() == plain.run.combat.hand.size(), "cat bonus does not recur on later turns")
	for game in [plain, dog, cat]: game._start_combat(["rat"])
	check(dog.run.heroes[0].block == plain.run.heroes[0].block + 3, "dog returns next battle")
	check(cat.run.combat.hand.size() == plain.run.combat.hand.size() + 1, "cat returns next battle")
	dog.run.heroes[1].hp = 0
	dog._start_combat(["rat"])
	check(dog.run.heroes[1].block == 0, "incapacitated hero receives no pet block")
	var before = cat.run.duplicate(true)
	check(not cat.new_run(["warrior", "guardian"], 42, {}, 1, "bad"), "reject unknown pet")
	check(cat.run == before, "invalid pet does not replace active adventure")
	plain.run.erase("pet")
	check(Pets.opening_bonus(plain.run, "opening_block") == 0, "old save grants no new passive")
	var path = "user://pet-companions-test.save"
	for suffix in ["", ".bak", ".tmp"]: DirAccess.remove_absolute(path + suffix)
	var saved = Game.new(path, true)
	saved.new_run(["warrior", "guardian"], 82, {}, 1, "dog")
	saved.enter_node(0)
	var expected = saved.run.duplicate(true)
	var loaded = Game.new(path, true)
	check(loaded.run.pet == "dog", "pet persists in save")
	check(loaded.run.combat == expected.combat and loaded.run.heroes == expected.heroes, "reload does not reapply opening passive")
	for suffix in ["", ".bak", ".tmp"]: DirAccess.remove_absolute(path + suffix)
	print("Pets: %d checks, %d failures" % [checks, failures])
	quit(1 if failures else 0)
