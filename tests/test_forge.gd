extends SceneTree
const Game = preload("res://src/game.gd")
var checks = 0
var failures = 0
func check(value: bool, description: String) -> void:
	checks += 1
	if not value:
		failures += 1
		printerr("FAIL: ", description)
func _initialize() -> void:
	var path = "user://forge-test.save"
	for suffix in ["", ".bak", ".tmp"]: DirAccess.remove_absolute(path + suffix)
	var g = Game.new(path, true)
	check(not g.buy_forge_upgrade("warrior", "weapon", 1), "requires forge")
	g.profile.souls = 399
	check(not g.build_forge(), "construction funds")
	g.profile.souls = 20000
	check(g.build_forge() and g.profile.souls == 19600, "construction price")
	check(not g.build_forge(), "no duplicate construction")
	check(not g.buy_forge_upgrade("bad", "weapon", 1), "valid hero")
	check(not g.buy_forge_upgrade("warrior", "bad", 1), "valid track")
	g.new_run(["warrior", "cleric"], 42)
	var initial = g.run.duplicate(true)
	for id in g.content.heroes:
		for track in ["weapon", "armor"]:
			check(not g.buy_forge_upgrade(id, track, 2), "no skipping " + id)
			for level in range(1, 4):
				var before = g.profile.souls
				check(g.buy_forge_upgrade(id, track, level), "buy " + id + track)
				check(g.profile.souls == before - int(g.Forge.config().prices[level - 1]), "exact price")
				check(not g.buy_forge_upgrade(id, track, level), "stale purchase rejected")
			check(not g.buy_forge_upgrade(id, track, 4), "maximum three")
	check(g.run == initial, "active adventure keeps snapshot")
	var upgrades = g.profile.forge_upgrades.duplicate(true)
	g._finish(false)
	check(g.profile.forge_upgrades == upgrades, "defeat preserves permanent gear")
	g.checkpoint()
	var restored = Game.new(path, true)
	check(restored.profile == g.profile and restored.run == g.run, "purchases and run reload")
	for id in g.content.heroes:
		var other = "cleric" if id != "cleric" else "warrior"
		g.new_run([id, other], 42)
		check(g.run.heroes[0].forge.strength == 3 and g.run.heroes[0].forge.block == 6, "new run bonuses")
		for card_id in g.content.cards:
			var card = g.content.cards[card_id]
			if card.owner != id: continue
			var instance = {"id": card_id, "upgraded": false}
			var effective = g.effective_card(instance)
			check(effective.damage == card.damage + (3 if card.damage > 0 else 0), "damage " + card_id)
			check(effective.block == card.block + (6 if card.block > 0 else 0), "block " + card_id)
	g.run.heroes[0].erase("forge")
	check(g.attack_bonus(g.run.heroes[0], g.run.heroes[0].id) == 0, "legacy run no bonus")
	var legacy = {"souls": 99, "buildings": {}}
	check(g.Forge.migrate(legacy) and not g.Forge.migrate(legacy), "idempotent migration")
	g.profile.forge_upgrades = {}
	g.profile.souls = 149
	check(not g.buy_forge_upgrade("warrior", "weapon", 1) and g.profile.souls == 149, "insufficient purchase funds")
	for suffix in ["", ".bak", ".tmp"]: DirAccess.remove_absolute(path + suffix)
	print("FORGE: %d checks / %d failures" % [checks, failures])
	quit(1 if failures else 0)
