extends SceneTree
const Game = preload("res://src/game.gd")
const SAVE = "user://equipment-test.save"
var checks = 0
var failures = 0
var game
func check(ok: bool, message: String) -> void:
	checks += 1
	if not ok:
		failures += 1
		printerr("FAIL: " + message)
func fresh(party: Array, relics: Dictionary = {}) -> void:
	check(game.new_run(party, 42, relics), "create equipped run")
	# Explicit inventory fixture for consumable-effect tests. Runs start empty.
	for id in game.content.items:
		game.run.inventory[id] = 1
	game.enter_node(0)
	game.run.combat.enemies[0].hp = 200
	game.run.combat.enemies[0].max_hp = 200
func play(id: String) -> void:
	game.run.combat.energy = 9
	game.run.combat.hand = [{"id": id, "upgraded": false}]
	check(game.play_card(0, 0), "play " + id)
func _initialize() -> void:
	call_deferred("run_tests")
func run_tests() -> void:
	for suffix in ["", ".bak", ".tmp"]:
		DirAccess.remove_absolute(SAVE + suffix)
	game = Game.new(SAVE, true)
	fresh(["warrior", "mage"], {"warrior":"vital_amulet"})
	check(game.run.heroes[0].max_hp == 68 and game.run.heroes[0].hp == 68 and game.run.heroes[1].max_hp == 42, "amulet only affects wearer")
	fresh(["warrior", "mage"], {"mage":"vigor_ring"})
	check(game.run.combat.energy == 4, "ring grants shared opening energy")
	game.end_turn()
	check(game.run.combat.energy == 3, "ring not every turn")
	game._start_combat(["rat"])
	check(game.run.combat.energy == 4, "ring resets next combat")
	var snapshot = game.run.duplicate(true)
	check(not game.new_run(["warrior","mage"], 1, {"warrior":"vital_amulet","mage":"vital_amulet"}) and game.run == snapshot, "duplicate equipment rejected atomically")
	check(not game.new_run(["warrior","mage"], 1, {"warrior":"vital_amulet","mage":"vigor_ring"}) and game.run == snapshot, "two distinct relics rejected atomically")
	check(not game.new_run(["warrior","mage"], 1, {"warrior":"missing"}), "unknown relic rejected")
	check(not game.new_run(["warrior","mage"], 1, {"rogue":"wind_boots"}), "non-party equipment rejected")
	fresh(["warrior","mage"], {"mage":"wind_boots"})
	check(game.run.heroes[1].block == 3, "boots start block")
	fresh(["warrior","mage"], {"warrior":"phoenix_idol"})
	game._damage(game.run.heroes[0], 999)
	check(game.run.heroes[0].hp == 1 and game.run.heroes[0].phoenix_used, "phoenix saves fatal hit")
	game.checkpoint()
	game = Game.new(SAVE, true)
	game._damage(game.run.heroes[0], 999)
	check(game.run.heroes[0].hp == 0, "phoenix not reset by reload")
	game._remove_inactive()
	var inactive = game.run.combat.inactive.size()
	check(inactive > 0, "fallen cards inactive")
	check(game.use_item("phoenix_feather", 0), "feather revives")
	check(game.run.heroes[0].hp == 15 and game.run.combat.inactive.is_empty(), "revival hp and reactivated cards")
	check(game.run.combat.discard.size() >= inactive, "revived cards return to discard")
	check(not game.use_item("phoenix_feather", 0), "feather consumed once")
	game._start_combat(["rat"])
	game._damage(game.run.heroes[0], 999)
	check(game.run.heroes[0].hp == 0, "phoenix not reset next combat")
	fresh(["rogue","mage"], {"rogue":"poison_fang"})
	play("rogue_toxin")
	check(game.run.combat.enemies[0].poison == 6, "fang adds poison stacks")
	fresh(["rogue","mage"], {"mage":"arcane_orb"})
	var hp = game.run.combat.enemies[0].hp
	play("mage_spark")
	check(game.run.combat.enemies[0].hp == hp - 12, "orb affects each magical hit")
	check(game.effective_card({"id":"rogue_cut"}).damage == 8, "orb does not affect companion")
	fresh(["warrior","guardian"], {"warrior":"pilgrim_shield"})
	game.run.heroes[0].block = 5
	game._damage(game.run.heroes[0], 10)
	check(game.run.heroes[0].hp == 55 and game.run.heroes[0].block == 0, "shield reduction before block")
	fresh(["warrior","guardian"], {"guardian":"merchant_coin"})
	game._make_reward()
	check(game.run.reward.any(func(c): return c.upgraded and game.content.cards[c.id].owner == "guardian"), "seeded coin reward includes upgraded wearer card")
	for card in game.run.reward:
		if game.content.cards[card.id].owner == "guardian":
			check(game.run.reward.any(func(c): return c.upgraded and game.content.cards[c.id].owner == "guardian"), "coin upgrades wearer reward")
			break
	game.checkpoint()
	snapshot = game.run.duplicate(true)
	game = Game.new(SAVE, true)
	check(game.run == snapshot, "pending improved reward restores exactly")
	fresh(["warrior","mage"])
	game.run.heroes[0].hp = 20
	check(not game.use_item("healing_potion", 9) and game.run.inventory.healing_potion == 1, "invalid target never consumes")
	check(game.use_item("healing_potion", 0) and game.run.heroes[0].hp == 32, "potion heals chosen ally")
	check(game.use_item("energy_flask", 0) and game.run.combat.energy == 5, "energy flask adds energy")
	check(game.use_item("strength_tonic", 0) and game.effective_card({"id":"warrior_slash"}).damage == 12, "strength buff")
	check(not game.use_item("arcane_elixir", 0) and game.run.inventory.arcane_elixir == 1, "elixir requires caster")
	check(game.use_item("arcane_elixir", 1) and game.effective_card({"id":"mage_spark"}).damage == 6, "arcane buff")
	check(game.use_item("concentrated_poison", 0) and game.run.combat.enemies[0].poison == 6, "poison item")
	var energy = game.run.combat.energy
	check(game.use_item("agility_brew", 0) and game.run.combat.hand.size() == 8, "agility draws two")
	check(game.use_item("defense_balm", 0) and game.run.heroes[0].block == 12, "balm grants block")
	check(game.run.combat.energy == energy, "items do not spend energy")
	snapshot = game.run.duplicate(true)
	game = Game.new(SAVE, true)
	check(game.run == snapshot, "inventory, buffs and deck order persist")
	check(not game.use_item("agility_brew", 0), "reload does not refill items")
	game.end_turn()
	check(game.effective_card({"id":"warrior_slash"}).damage == 9 and game.effective_card({"id":"mage_spark"}).damage == 4, "temporary buffs expire next turn")
	game._start_combat(["rat"])
	check(game.run.inventory.healing_potion == 0, "new room does not refill bag")
	game._finish(false)
	check(game.run.inventory.is_empty(), "defeat clears inventory")
	check(game.new_run(["warrior","mage"], 42) and game.enter_node(0), "new empty adventure")
	check(game.run.inventory.is_empty() and game.run.heroes[0].max_hp == 58, "new adventure starts empty and resets hp")
	# Simulate old save fields, retaining all original game state.
	game.run.erase("inventory")
	for hero in game.run.heroes:
		hero.erase("equipped_relic")
		hero.erase("phoenix_used")
	game.checkpoint()
	game = Game.new(SAVE, true)
	check(game.item_targets("healing_potion").is_empty() and game.end_turn(), "legacy save remains playable without granting items")
	game.profile.preparation = {"party":["warrior","mage"], "relics":{"mage":"arcane_orb"}}
	game.checkpoint()
	game = Game.new(SAVE, true)
	check(game.profile.preparation.relics.mage == "arcane_orb", "preparation survives reopening")
	# Existing adventures keep legacy equipment when reopened.
	game.run.heroes[0].equipped_relic = "vital_amulet"
	game.run.heroes[1].equipped_relic = "arcane_orb"
	game.checkpoint()
	snapshot = game.run.duplicate(true)
	game = Game.new(SAVE, true)
	check(game.run == snapshot, "legacy two-relic adventure preserved")
	fresh(["warrior","mage"], {"team":"vital_amulet"})
	check(game.run.heroes[0].max_hp == 68 and game.run.heroes[1].max_hp == 52, "team amulet affects both")
	fresh(["warrior","mage"], {"team":"vigor_ring"})
	check(game.run.combat.energy == 4, "team ring grants only one energy")
	game.run.heroes[0].hp = 0
	check(game.turn_energy() == 4, "survivor retains team ring")
	fresh(["warrior","mage"], {"team":"phoenix_idol"})
	for hero in game.run.heroes:
		game._damage(hero, 999)
		check(hero.hp == 1 and hero.phoenix_used, "independent phoenix protection")
	game.checkpoint()
	snapshot = game.run.duplicate(true)
	game = Game.new(SAVE, true)
	check(game.run == snapshot, "team relic and per-hero phoenix persist")
	fresh(["warrior","mage"], {"team":"arcane_orb"})
	check(game.effective_card({"id":"warrior_slash"}).damage == 11 and game.effective_card({"id":"mage_spark"}).damage == 6, "orb boosts both classes")
	fresh(["warrior","mage"], {"team":"pilgrim_shield"})
	for hero in game.run.heroes:
		var before = hero.hp
		game._damage(hero, 5)
		check(hero.hp == before - 3, "shield protects each hero")
	fresh(["rogue","mage"], {"team":"poison_fang"})
	play("rogue_toxin")
	check(game.run.combat.enemies[0].poison == 6, "shared fang boosts poison cards")
	fresh(["warrior","mage"], {"team":"merchant_coin"})
	game._make_reward()
	for hero in game.run.heroes:
		var offered = game.run.reward.filter(func(c): return game.content.cards[c.id].owner == hero.id)
		check(offered.is_empty() or offered.any(func(c): return c.upgraded), "coin upgrades each represented hero")
	var ids = game.content.heroes.keys()
	for i in range(ids.size()):
		for j in range(i + 1, ids.size()):
			var equipment = {"team":"wind_boots"}
			check(game.new_run([ids[i], ids[j]], 42, equipment) and game.enter_node(0) and game.run.heroes.all(func(h): return h.block == 3), "equipped pair %s + %s" % [ids[i], ids[j]])
	for suffix in ["", ".bak", ".tmp"]:
		DirAccess.remove_absolute(SAVE + suffix)
	print("EQUIPMENT CHECKS: %d | FAILURES: %d" % [checks, failures])
	quit(1 if failures else 0)
