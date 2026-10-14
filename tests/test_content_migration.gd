extends SceneTree
const Game = preload("res://src/game.gd")
const Migration = preload("res://src/rules/content_migration.gd")
var checks = 0
var failures = 0
func check(value: bool, label: String) -> void:
	checks += 1
	if not value: failures += 1; printerr("FAIL: ", label)
func _initialize() -> void:
	var game = Game.new("user://unused-content-migration", false)
	game.new_run(["warrior", "guardian"], 29)
	game.enter_node(0)
	game.profile.forge_upgrades.warrior = {"weapon":2,"armor":1}
	var snapshot = game.run.duplicate(true)
	check(not Migration.clean(game.profile, game.run, game.content).changed, "current save migration is a no-op")
	check(game.run == snapshot, "valid combat and RNG remain identical")
	var profile = game.profile.duplicate(true)
	profile.souls = 912
	profile.unlocked_cards = ["warrior_slash", "missing_card"]
	profile.market_cards = ["guardian_lay_hands", "missing_card"]
	profile.reserved_card = "missing_card"
	profile.starter_attacks = {"warrior":6,"missing_hero":8}
	profile.forge_upgrades.missing_hero = {"weapon":3,"armor":3}
	profile.specializations = {"victorious":["warrior","missing_hero"],"owned":["warrior_executioner","missing_spec"],"active":{"warrior":"warrior_executioner","missing_hero":"missing_spec"}}
	profile.bonds = {"guardian_warrior":2,"missing_pair":4}
	profile.bond_variants = {"guardian_warrior":"balanced","missing_pair":"balanced"}
	profile.cinematics_seen = {"intro":true,"missing_story":true}
	profile.achievements.unlocked = ["first_steps","missing_achievement"]
	profile.achievements.totals.hero_missing_hero = 1
	profile.history = [{"won":true,"party":["warrior","guardian"],"deck":[{"id":"warrior_slash"},{"id":"missing_card"}]},{"won":true,"party":["warrior","missing_hero"]}]
	var cleaned = Migration.clean(profile, game.run, game.content)
	check(cleaned.changed and not cleaned.closed, "obsolete permanent entries do not close a valid run")
	check(profile.souls == 912 and profile.buildings == game.profile.buildings, "currency and buildings preserved")
	check(profile.unlocked_cards == ["warrior_slash"] and profile.market_cards == ["guardian_lay_hands"], "only valid card ownership retained")
	check(not profile.has("reserved_card") and profile.starter_attacks == {"warrior":6}, "obsolete reservation and starter setting removed")
	check(not profile.forge_upgrades.has("missing_hero") and profile.forge_upgrades.warrior == game.profile.forge_upgrades.warrior, "valid equipment preserved")
	check(profile.specializations.owned == ["warrior_executioner"] and profile.specializations.active == {"warrior":"warrior_executioner"}, "valid specialization ownership preserved")
	check(profile.specializations.victorious == ["warrior"], "unknown eligibility removed")
	check(profile.bonds == {"guardian_warrior":2} and profile.bond_variants.size() == 1, "valid bonds preserved")
	check(profile.cinematics_seen == {"intro":true}, "obsolete story removed")
	check(profile.achievements.unlocked == ["first_steps"] and not profile.achievements.totals.has("hero_missing_hero"), "obsolete achievement removed")
	check(profile.history.size() == 1 and profile.history[0].deck.size() == 1, "history has no dangling hero or card references")
	check(not Migration.clean(profile, game.run, game.content).changed, "cleanup is idempotent")
	var unsupported = game.run.duplicate(true)
	unsupported.party[1] = "missing_hero"
	check(Migration.clean(profile, unsupported, game.content).closed, "unknown hero closes adventure")
	unsupported = game.run.duplicate(true)
	unsupported.combat.hand.append({"id":"missing_card"})
	check(Migration.clean(profile, unsupported, game.content).closed, "unknown combat card closes adventure")
	print("CONTENT MIGRATION: %d checks / %d failures" % [checks, failures])
	quit(1 if failures else 0)
