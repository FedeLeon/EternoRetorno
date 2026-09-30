extends SceneTree
const Game = preload("res://src/game.gd")
const Achievements = preload("res://src/rules/achievements.gd")
const SAVE = "user://achievement-regression.save"
var checks = 0
var failures = 0
func check(ok: bool, message: String) -> void:
	checks += 1
	if not ok:
		failures += 1
		printerr(message)
func _initialize() -> void:
	var catalog = Achievements.catalog()
	check(catalog.size() == 30, "thirty achievements")
	check(catalog.filter(func(a): return a.secret).size() == 5, "five secrets")
	var ids: Array = []
	for entry in catalog:
		check(entry.id not in ids, "unique stable ID")
		ids.append(entry.id)
	for suffix in ["", ".bak", ".tmp"]: DirAccess.remove_absolute(SAVE + suffix)
	var g = Game.new(SAVE, true)
	check(g.profile.achievements.unlocked.is_empty(), "fresh profile has no achievements despite development souls")
	check(not g.new_run(["warrior", "warrior"]), "invalid party rejected")
	check(g.profile.achievements.unlocked.is_empty(), "invalid action grants nothing")
	g.new_run(["warrior", "guardian"], 73)
	check("first_steps" in g.profile.achievements.unlocked, "valid adventure unlocks first step")
	g.enter_node(0)
	for enemy in g.run.combat.enemies: enemy.hp = 0
	g._check_combat_end()
	g.checkpoint()
	check(g.profile.achievements.totals.battles == 1 and "first_battle" in g.profile.achievements.unlocked, "real battle completion records achievement")
	var reloaded = Game.new(SAVE, true)
	for i in range(4): reloaded.checkpoint()
	check(reloaded.profile.achievements.totals.battles == 1, "reload and checkpoints never duplicate battle")
	reloaded.run.expedition_stats.battles = 10
	reloaded.checkpoint()
	check(reloaded.profile.achievements.totals.battles == 10 and "ten_battles" in reloaded.profile.achievements.unlocked, "counts only new run delta")
	reloaded.end_adventure()
	reloaded.new_run(["mage", "rogue"], 74)
	reloaded.run.expedition_stats.battles = 1
	reloaded.checkpoint()
	check(reloaded.profile.achievements.totals.battles == 11, "new run adds to permanent totals")
	reloaded.run.contract_result = {"complete": true}
	reloaded.checkpoint()
	reloaded.checkpoint()
	check(reloaded.profile.achievements.totals.contracts == 1, "contract counted once")
	var legacy = {"attempts": 7, "victories": 2, "history": [{"won": true, "party": ["warrior", "guardian"]}], "market_cards": ["a"], "forge_upgrades": {"warrior": {"weapon": 3, "armor": 1}}}
	Achievements.sync(legacy, {})
	check("oathbound" in legacy.achievements.unlocked and "master_weapon" in legacy.achievements.unlocked, "known history and equipment backfilled")
	check(legacy.achievements.totals.get("battles", 0) == 0, "unknown historic battles not invented")
	check(not Achievements.sync(legacy, {}), "legacy migration idempotent")
	var full = {"attempts": 10, "victories": 10, "market_cards": range(10), "specializations": {"victorious": Achievements.HEROES.duplicate()}, "forge_upgrades": {"warrior": {"weapon": 3, "armor": 3}}, "buildings": {"market": true, "forge": true, "church": true, "expeditions": true}, "history": [{"won": true, "party": ["warrior", "guardian"]}, {"won": true, "party": ["mage", "rogue"]}]}
	var completed = {"phase": "victory", "heroes": [{"hp": 5}], "expedition_stats": {"battles": 50, "elites": 10, "bosses": 1, "treasures": 10, "upgrades": 10}, "contract_result": {"complete": true}}
	Achievements.sync(full, completed)
	check(full.achievements.unlocked.size() == 30, "all thirty achievements reachable")
	full.history.clear()
	Achievements.sync(full, completed)
	check(full.achievements.unlocked.size() == 30, "achievements survive history truncation")
	for profile in [g.profile, full]:
		for entry in Achievements.entries(profile):
			check(not entry.has("metric"), "UI never receives rule key")
			if entry.secret:
				check(entry.target == -1 and entry.progress == -1, "secret has no numerical hint even after unlock")
				if not entry.unlocked: check(entry.name == "Eco desconocido", "secret identity hidden")
	for suffix in ["", ".bak", ".tmp"]: DirAccess.remove_absolute(SAVE + suffix)
	print("ACHIEVEMENTS: %d checks / %d failures" % [checks, failures])
	quit(1 if failures else 0)
