extends SceneTree
const Game = preload("res://src/game.gd")
const Relics = preload("res://src/rules/run_relics.gd")
var checks = 0
var failures = 0
func check(ok: bool, label: String) -> void:
	checks += 1
	if not ok:
		failures += 1
		printerr("FAIL: ", label)
func battle(hero: String = "warrior") -> RefCounted:
	var g = Game.new("user://unused-relic-test.save", false)
	g.new_run([hero, "guardian" if hero != "guardian" else "warrior"], 42)
	g.enter_node(0)
	g.run.combat.enemies[0].hp = 1000
	g.run.combat.enemies[0].max_hp = 1000
	g.run.combat.enemies[0].block = 0
	g.run.combat.enemies[0].intent = {}
	g.run.combat.energy = 10
	return g
func _initialize() -> void:
	var definitions: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://data/elite_relics.json"))
	check(definitions.size() == 20, "20 new relics")
	var g = battle()
	check(g.content.relics.size() == 33, "legacy relics retained")
	for kind in ["combat", "boss"]:
		var normal = battle()
		for node in normal.run.nodes:
			if node.kind != kind: continue
			normal.run.current = node.id
			normal._start_combat(node.encounter)
			break
		preload("res://tests/room_fixture.gd").break_objective(normal)
		for enemy in normal.run.combat.enemies: enemy.hp = 0
		normal._check_combat_end()
		check(normal.run.relics.is_empty() and normal.run.reward_relic == "", "only elite drops relic: " + kind)
	for id in definitions:
		var relic = definitions[id]
		if relic.stat == "": continue
		var found = false
		for card_id in g.content.cards:
			var raw = g.content.cards[card_id]
			if int(raw[relic.stat]) <= 0: continue
			var instance = {"id":card_id,"upgraded":relic.condition == "upgraded"}
			var candidate = g.content.card(instance)
			var unit = {"hp":10 if relic.condition == "wounded" else 50,"max_hp":50}
			var mock = {"relics":[id],"combat":{"turn":3 if relic.condition == "late" else 1}}
			var base = int(candidate[relic.stat])
			Relics.apply(candidate, instance, unit, mock, g.content.relics)
			if candidate[relic.stat] == base: continue
			found = true
			check(candidate[relic.stat] == base + int(relic.value), "bonus " + id)
			var live = battle(raw.owner)
			live.run.relics = [id]
			live.run.heroes[0].hp = 10 if relic.condition == "wounded" else live.run.heroes[0].max_hp
			if relic.stat == "heal": live.run.heroes[0].hp -= 5
			live.run.combat.turn = mock.combat.turn
			var initial_hp = live.run.heroes[0].hp
			var expected = live.effective_card(instance)
			live.run.combat.hand = [instance]
			check(live.play_card(0, 0), "real card accepted " + id)
			if relic.stat == "damage": check(live.run.combat.enemies[0].hp == 1000 - int(expected.damage) * int(expected.hits), "real damage " + id)
			elif relic.stat == "poison": check(live.run.combat.enemies[0].poison == expected.poison, "real poison")
			elif relic.stat == "block": check(live.run.heroes[0].block == expected.block, "real block " + id)
			elif relic.stat == "heal": check(live.run.heroes[0].hp == mini(live.run.heroes[0].max_hp, initial_hp + int(expected.heal)), "real heal " + id)
			candidate[relic.stat] = 0
			Relics.apply(candidate, instance, unit, mock, g.content.relics)
			check(candidate[relic.stat] == 0, "does not create missing stat " + id)
			break
		check(found, "existing card supports effect " + id)
		if relic.condition == "always": continue
		var negative = {"damage":5,"block":5,"poison":5,"heal":5,"hits":1,"target":"enemy","pierce":false,"cost":1}
		if relic.condition == "single": negative.hits = 2
		Relics.apply(negative, {"upgraded":false}, {"hp":30,"max_hp":50}, {"relics":[id],"combat":{"turn":2}}, g.content.relics)
		check(negative[relic.stat] == 5, "condition required " + id)
	g = battle()
	g.run.relics = ["sentinel_mask", "oath_chain", "raven_quill"]
	g._start_combat(["rat"])
	check(g.run.heroes[0].block == 8 and g.run.heroes[1].block == 8, "opening and recurring block")
	check(g.run.combat.hand.size() == 7, "extra opening card")
	g.end_turn()
	check(g.run.heroes[0].block == 2 and g.run.combat.hand.size() == 6, "next turn reset and normal draw")
	g.run.relics = ["spring_seed"]
	g.run.heroes[0].hp = 10
	for enemy in g.run.combat.enemies: enemy.hp = 0
	g._check_combat_end()
	check(g.run.heroes[0].hp == 14, "victory heal")
	g = battle()
	var before_max = g.run.heroes[0].max_hp
	g.run.heroes[0].hp = 10
	check(Relics.grant(g.run, g.content.relics, "giant_heart"), "grant heart")
	check(g.run.heroes[0].max_hp == before_max + 6 and g.run.heroes[0].hp == 16, "max HP and heal")
	check(not Relics.grant(g.run, g.content.relics, "giant_heart") and g.run.heroes[0].max_hp == before_max + 6, "grant idempotent")
	g.new_run(["warrior","guardian"], 4)
	check(g.run.relics.is_empty() and g.run.heroes[0].max_hp == before_max, "run relics reset on new adventure")
	g.profile.unlocked_relics = ["hourglass"]
	var seen: Array = []
	for i in range(24):
		var id = g._roll_relic()
		check(id != "" and id not in seen, "unique drop")
		seen.append(id)
		Relics.grant(g.run, g.content.relics, id)
	check(seen.size() == 24 and g._roll_relic() == "", "finite pool safely exhausted")
	var path = "user://elite-relic-save-test.save"
	for suffix in ["", ".bak", ".tmp"]: DirAccess.remove_absolute(path + suffix)
	var saved = Game.new(path, true)
	saved.new_run(["warrior","mage"], 11)
	for node in saved.run.nodes:
		if node.kind != "elite": continue
		saved.run.current = node.id
		saved._start_combat(node.encounter)
		for enemy in saved.run.combat.enemies: enemy.hp = 0
		saved._check_combat_end()
		saved.checkpoint()
		var dropped = saved.run.reward_relic
		check(dropped in saved.run.relics and saved.run.phase == "reward", "elite grants relic and card reward together")
		var loaded = Game.new(path, true)
		check(loaded.run.reward_relic == dropped and loaded.run.relics == saved.run.relics, "pending reward reload")
		check(not loaded._check_combat_end() and loaded.run.relics.size() == saved.run.relics.size(), "reload cannot grant twice")
		check(loaded.choose_reward(-1) and dropped in loaded.run.relics and loaded.run.reward_relic == "", "skip card retains relic")
		saved = loaded
	check(saved.run.relics.size() == 2, "two elites give distinct relics")
	# A reward saved by an older version has no receipt; it remains usable.
	saved.new_run(["warrior", "guardian"], 12)
	saved.enter_node(0)
	saved._make_reward()
	saved.run.erase("reward_relic")
	saved.checkpoint()
	var legacy = Game.new(path, true)
	check(legacy.choose_reward(-1) and legacy.run.relics.is_empty(), "legacy reward without receipt")
	for suffix in ["", ".bak", ".tmp"]: DirAccess.remove_absolute(path + suffix)
	print("ELITE RELICS: %d checks / %d failures" % [checks, failures])
	quit(1 if failures else 0)
