extends SceneTree
const Game = preload("res://src/game.gd")
const E = preload("res://src/rules/expeditions.gd")
const S = preload("res://src/rules/specializations.gd")
const C = preload("res://src/rules/camp_expansion.gd")
var checks = 0
var failures = 0
func check(ok: bool, caption: String) -> void:
	checks += 1
	if not ok:
		failures += 1
		printerr("FAIL: ", caption)
func _initialize() -> void:
	var path = "user://camp-expansion-test.save"
	for suffix in ["", ".bak", ".tmp"]: DirAccess.remove_absolute(path + suffix)
	var g = Game.new(path, true)
	check(E.catalog().size() == 19 and S.catalog().size() == 8, "catalog sizes")
	var ids: Array = []
	var pairs = 0
	for contract in E.catalog():
		check(contract.id not in ids and contract.target > 0 and contract.reward > 0, "valid unique contract")
		ids.append(contract.id)
		if contract.party.size() == 2: pairs += 1
	check(pairs == 6, "all hero pairs represented")
	for cycle in range(20):
		var previous = g.profile.expeditions.offers.duplicate()
		E.refresh(g.profile)
		var offers = g.profile.expeditions.offers
		check(offers.size() == 3 and offers[0] != offers[1] and offers[1] != offers[2] and offers[0] != offers[2], "three distinct offers")
		for id in offers: check(id not in previous, "new offers do not repeat previous")
	check(not g.camp_action("contract", {"id":g.profile.expeditions.offers[0]}), "building required")
	g.profile.souls = 0
	check(not g.camp_action("build", {"id":"church"}), "insufficient funds")
	g.profile.souls = 10000
	check(g.camp_action("build", {"id":"expeditions"}), "construct expeditions")
	check(g.camp_action("build", {"id":"church"}), "construct church")
	check(g.profile.souls == 8900 and not g.camp_action("build", {"id":"church"}), "cost once")
	check(not g.camp_action("contract", {"id":"invalid"}), "invalid contract")
	var selected = g.profile.expeditions.offers[0]
	var contract = E.definition(selected)
	check(g.camp_action("contract", {"id":selected}), "accept")
	g.new_run(contract.party, 42)
	check(g.run.contract == selected, "snapshot contract")
	check(not g.camp_action("contract", {"id":""}), "cannot cancel during run")
	var before = g.profile.souls
	var old_offers = g.profile.expeditions.offers.duplicate()
	g._finish(true)
	check(g.run.contract_result.complete and g.profile.souls == before + int(contract.reward), "pair victory pays")
	check(g.profile.specializations.victorious.size() == 2, "victory grants both heroes eligibility")
	check(g.profile.expeditions.offers != old_offers, "victory refresh")
	before = g.profile.souls
	var cycle = g.profile.expeditions.cycle
	g._finish(true)
	check(g.profile.souls == before and g.profile.expeditions.cycle == cycle, "finish idempotent")
	g.checkpoint()
	var restored = Game.new(path, true)
	check(restored.profile == g.profile and restored.run == g.run, "atomic settlement reload")
	g.new_run(["warrior", "guardian"], 10)
	g.enter_node(0)
	for enemy in g.run.combat.enemies: enemy.hp = 0
	g._check_combat_end()
	check(g.run.expedition_stats.battles == 1 and g.run.expedition_stats.clean_battles == 1, "battle hooks")
	g._check_combat_end()
	check(g.run.expedition_stats.battles == 1, "no duplicate battle count")
	cycle = g.profile.expeditions.cycle
	g._finish(false)
	check(g.profile.expeditions.cycle == cycle + 1, "defeat refresh")
	var legacy = {"history":[{"won":true,"party":["warrior","mage"]},{"won":false,"party":["rogue","guardian"]}]}
	S.migrate(legacy)
	check(legacy.specializations.victorious == ["warrior","mage"] and not S.migrate(legacy), "legacy victory migration idempotent")
	g.profile.specializations.victorious = []
	check(not g.camp_action("buy_specialization", {"id":"warrior_whirlwind"}), "victory required")
	S.victory(g.profile, ["warrior"])
	check(not g.camp_action("buy_specialization", {"id":"mage_focus"}), "eligibility per hero")
	before = g.profile.souls
	check(g.camp_action("buy_specialization", {"id":"warrior_whirlwind"}), "buy eligible")
	check(g.profile.souls == before - 450 and not g.camp_action("buy_specialization", {"id":"warrior_whirlwind"}), "spec charge once")
	g.new_run(["warrior","guardian"], 1)
	check(g.run.heroes[0].specialization.id == "warrior_whirlwind", "new run specialization snapshot")
	check(g.camp_action("buy_specialization", {"id":"warrior_executioner"}), "buy alternative")
	check(g.run.heroes[0].specialization.id == "warrior_whirlwind", "active run unchanged")
	before = g.profile.souls
	check(g.camp_action("activate_specialization", {"hero":"warrior","id":"warrior_whirlwind"}) and g.profile.souls == before, "switch free")
	check(not g.camp_action("activate_specialization", {"hero":"mage","id":"warrior_whirlwind"}), "reject wrong hero")
	for hero in g.content.heroes:
		var count = 0
		for id in S.catalog():
			var spec = S.catalog()[id]
			if spec.hero != hero: continue
			count += 1
			var card = {"damage":5,"block":5,"poison":5,"heal":5,"hits":1,"target":"enemy","pierce":true}
			if spec.condition == "multi": card.hits = 3
			if spec.condition == "area": card.target = "all_enemies"
			if spec.condition == "ally": card.target = "ally"
			S.apply(card, {"specialization":spec,"block":4}, 1)
			check(card[spec.stat] == 5 + int(spec.bonus), "effect " + id)
			card[spec.stat] = 0
			S.apply(card, {"specialization":spec,"block":4}, 1)
			check(card[spec.stat] == 0, "does not invent effect " + id)
		check(count == 2, "two specs per hero")
	# Exercise real card resolution, including per-hit bonuses and turn conditions.
	S.victory(g.profile, ["mage"])
	g.camp_action("buy_specialization", {"id":"mage_focus"})
	g.new_run(["mage", "guardian"], 12)
	g.enter_node(0)
	var shot = {"id":"mage_shard", "upgraded":false}
	var basic = g.content.card(shot)
	check(g.effective_card(shot).damage == basic.damage + 2, "single-hit card preview")
	g.run.combat.enemies[0].hp = 200
	g.run.combat.enemies[0].block = 0
	g.run.combat.hand = [shot]
	check(g.play_card(0, 0), "specialized attack played")
	check(g.run.combat.enemies[0].hp == 200 - (basic.damage + 2) * basic.hits, "specialization applied in actual damage")
	g.run.combat.turn = 2
	check(g.effective_card(shot).damage == basic.damage + 2, "focused bonus persists across turns")
	for id in S.catalog():
		var spec = S.catalog()[id]
		if spec.condition == "always": continue
		var card = {"damage":5,"block":5,"heal":5,"poison":5,"hits":1,"target":"self","pierce":false}
		if spec.condition in ["single", "focused"]: card.hits = 2
		S.apply(card, {"specialization":spec,"block":0}, 2)
		check(card[spec.stat] == 5, "unmet condition " + id)
	for kind in ["elite", "boss"]:
		g.new_run(["warrior", "guardian"], 22)
		for node in g.run.nodes:
			if node.kind != kind: continue
			g.run.current = node.id
			g._start_combat(node.encounter)
			break
		g.run.combat.hero_fell = true
		preload("res://tests/room_fixture.gd").break_objective(g)
		for enemy in g.run.combat.enemies: enemy.hp = 0
		g._check_combat_end()
		check(g.run.expedition_stats.get("elites" if kind == "elite" else "bosses", 0) == 1, "objective hook " + kind)
		check(g.run.expedition_stats.get("clean_battles", 0) == 0, "fallen hero excludes clean battle")
	g.new_run(["warrior", "guardian"], 22)
	for node in g.run.nodes:
		if node.kind == "treasure":
			g.run.current = node.id
			g.run.phase = "room"
			g.run.treasure = {"item":g.content.items.keys()[0],"trapped":true,"opened":false,"losses":[]}
			check(g.take_treasure() and not g.take_treasure(), "treasure once")
			check(g.run.expedition_stats.treasures == 1, "trapped treasure counts")
			break
	for node in g.run.nodes:
		if node.kind == "rest":
			g.run.current = node.id
			g.run.phase = "room"
			check(g.rest(false, 0) and not g.rest(false, 0), "upgrade once")
			check(g.run.expedition_stats.upgrades == 1, "upgrade objective")
			break
	var pair_contract = E.definition("pair_warrior_guardian")
	check(E.progress({"party":["warrior","mage"],"expedition_stats":{"victory":1}}, pair_contract) == 0, "wrong pair cannot fulfill contract")
	g.checkpoint()
	restored = Game.new(path, true)
	check(restored.profile == g.profile and restored.run == g.run, "progress and specs reload")
	for suffix in ["", ".bak", ".tmp"]: DirAccess.remove_absolute(path + suffix)
	print("CAMP EXPANSION: %d checks / %d failures" % [checks, failures])
	quit(1 if failures else 0)
