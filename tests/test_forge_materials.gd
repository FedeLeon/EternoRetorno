extends SceneTree
const Game = preload("res://src/game.gd")
const Materials = preload("res://src/rules/forge_materials.gd")
var checks = 0
var failures = 0

func check(ok: bool, message: String) -> void:
	checks += 1
	if not ok:
		failures += 1
		printerr("FAIL: ", message)

func battle(game: RefCounted, floor_number: int, kind: String) -> void:
	game.new_run(["warrior", "guardian"], 82, {}, floor_number)
	game.enter_node(0)
	game.run.nodes[game.run.current].kind = kind
	game._start_combat(["rat", "skeleton"])
	preload("res://tests/room_fixture.gd").break_objective(game)
	for enemy in game.run.combat.enemies: enemy.hp = 0

func _initialize() -> void:
	var path = "user://forge-materials-test.save"
	for suffix in ["", ".bak", ".tmp"]: DirAccess.remove_absolute(path + suffix)
	var game = Game.new(path, true)
	var legacy = {"forge_upgrades":{"warrior":{"weapon":2,"armor":1}}, "souls":1500}
	check(game.Forge.migrate(legacy), "old profile gains empty material stock")
	check(legacy.forge_materials == {"scrap":0,"alloy":0} and legacy.forge_upgrades.warrior.weapon == 2 and legacy.souls == 1500, "legacy gear and cells preserved")
	check(not game.Forge.migrate(legacy), "material migration is idempotent")
	battle(game, 1, "combat")
	var before_inventory = game.run.inventory.duplicate(true)
	var rng_state = game.rng.state
	var preview_run = game.run.duplicate(true)
	var preview_profile = game.profile.duplicate(true)
	var expected = Materials.award(preview_profile, preview_run)
	check(game.rng.state == rng_state and preview_run.rng_state == game.run.rng_state, "salvage leaves adventure RNG untouched")
	check(expected.drops.size() == 2 and expected.scrap >= 2 and expected.scrap <= 6, "each defeated enemy drops common scrap")
	check(game._check_combat_end() and game.run.phase == "reward", "victory awards salvage before reward screen")
	check(game.run.reward_salvage == expected and game.profile.forge_materials.scrap == expected.scrap, "deterministic per-enemy drops match credited stock")
	check(game.run.inventory == before_inventory, "materials are never consumable items")
	var stock = game.profile.forge_materials.duplicate(true)
	check(not game._check_combat_end() and game.profile.forge_materials == stock, "repeated victory check cannot duplicate salvage")
	game.checkpoint()
	var restored = Game.new(path, true)
	check(restored.profile.forge_materials == stock and restored.run.reward_salvage == expected, "save restores reward receipt and permanent stock together")
	check(not restored._check_combat_end() and restored.profile.forge_materials == stock, "resuming rewards does not award twice")
	check(restored.choose_reward(-1) and restored.run.reward_salvage.is_empty(), "accepting or rejecting card clears receipt without removing materials")
	restored._finish(false)
	check(restored.profile.forge_materials == stock, "ending adventure preserves materials from won battles")
	restored.profile.buildings.forge = true
	restored.profile.forge_materials = {"scrap":10,"alloy":0}
	check(restored.smelt_forge(3), "smelting uses the saving game facade")
	var smelt_reload = Game.new(path, true)
	check(smelt_reload.profile.forge_materials == {"scrap":1,"alloy":3}, "smelting stock survives reload atomically")
	for kind in ["elite", "boss"]:
		var special = Game.new("user://unused-salvage-special", false)
		battle(special, 3, kind)
		var receipt = Materials.award(special.profile, special.run)
		check(receipt.scrap >= (10 if kind == "elite" else 16), "advanced " + kind + " yields more salvage")
	var training = Game.new("user://unused-salvage-training", false)
	battle(training, 1, "combat")
	training.run.training = true
	check(Materials.award(training.profile, training.run).is_empty() and training.profile.forge_materials.scrap == 0, "training cannot farm materials")
	var workshop = Game.new("user://unused-salvage-workshop", false)
	workshop.profile.forge_materials = {"scrap":10,"alloy":0}
	check(not workshop.smelt_forge(1), "smelting needs a built workshop")
	workshop.profile.buildings.forge = true
	check(not workshop.smelt_forge(0) and not workshop.smelt_forge(-1) and not workshop.smelt_forge(4), "invalid smelting requests leave stock untouched")
	var cells = workshop.profile.souls
	check(workshop.smelt_forge(3) and workshop.profile.forge_materials == {"scrap":1,"alloy":3}, "three-to-one smelting keeps remainder")
	check(not workshop.smelt_forge(3), "stale smelting request cannot duplicate alloy")
	check(workshop.buy_forge_upgrade("warrior","weapon",1), "alloy purchases the next gear level")
	check(workshop.profile.forge_materials == {"scrap":1,"alloy":0} and workshop.profile.souls == cells, "upgrade spends only alloy")
	check(not workshop.buy_forge_upgrade("warrior","armor",1), "cells cannot substitute missing alloy")
	workshop.checkpoint()
	for suffix in ["", ".bak", ".tmp"]: DirAccess.remove_absolute(path + suffix)
	print("FORGE MATERIALS: %d checks / %d failures" % [checks, failures])
	quit(1 if failures else 0)
