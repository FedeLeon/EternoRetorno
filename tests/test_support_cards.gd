extends SceneTree
const Game = preload("res://src/game.gd")
const Mods = preload("res://src/rules/combat_modifiers.gd")
const Progress = preload("res://src/rules/camp_progression.gd")
var checks = 0
var failures = 0
func check(ok: bool, message: String) -> void:
	checks += 1
	if not ok:
		failures += 1
		printerr("FAIL: ", message)
func battle(party: Array = ["warrior", "ranger"]) -> RefCounted:
	var g = Game.new("user://unused-support.save", false)
	g.new_run(party, 37)
	g.enter_node(0)
	g.run.combat.enemies = [{"id":"skeleton", "hp":300, "max_hp":300, "block":0, "poison":0, "intent":{"damage":12,"block":12,"target":0}}]
	g.run.combat.energy = 99
	return g
func play(g: RefCounted, id: String, target: int = 0, upgraded: bool = false) -> bool:
	g.run.combat.hand = [{"id":id,"upgraded":upgraded}]
	return g.play_card(0, target)
func _initialize() -> void:
	var additions = JSON.parse_string(FileAccess.get_file_as_string("res://data/support_cards.json"))
	var g = battle()
	check(additions.size() == 24 and g.content.cards.size() == 114, "24 unique additions")
	var originals = JSON.parse_string(FileAccess.get_file_as_string("res://data/content.json")).cards
	check(additions.keys().all(func(id): return not originals.has(id)), "no existing ID overwritten")
	for hero in g.content.heroes:
		check(additions.values().filter(func(c): return c.owner == hero).size() == 4, "four per hero")
		check(g.content.heroes[hero].starter.all(func(id): return not additions.has(id)), "basic starter unchanged")
		g.new_run([hero, "warrior" if hero != "warrior" else "cleric"], 37)
		g.profile.buildings.market = true
		g.profile.souls = 10000
		for id in additions:
			if additions[id].owner != hero: continue
			check(not Progress.available(g.profile, g.content.cards[id]), "purchase required " + id)
			var souls = g.profile.souls
			check(g.buy_market_card(id) and g.profile.souls == souls - additions[id].market_price, "buy " + id)
			check(not g.buy_market_card(id), "no double purchase")
		var seen: Array = []
		for roll in range(100):
			g._make_reward()
			for offer in g.run.reward:
				check(Progress.available(g.profile, g.content.cards[offer.id]), "reward respects purchase")
				if offer.id not in seen: seen.append(offer.id)
		check(additions.values().filter(func(c): return c.owner == hero).all(func(c): return c.id in seen), "all four can be awarded")
	# An ally's buff changes only their cards, rounds once per hit and expires.
	g = battle()
	check(play(g, "warrior_rally", 1), "empower ally")
	check(g.effective_card({"id":"ranger_arrow"}).damage == floori(g.content.cards.ranger_arrow.damage * 1.25), "ally boosted")
	check(g.effective_card({"id":"warrior_slash"}).damage == g.content.cards.warrior_slash.damage, "owner unboosted")
	play(g, "warrior_rally", 1)
	check(g.run.heroes[1].strength_pct == 25, "buff does not stack")
	play(g, "warrior_rally", 1, true)
	check(g.run.heroes[1].strength_pct == 35, "upgrade replaces with stronger buff")
	g.end_turn()
	check(g.run.heroes.all(func(h): return h.get("strength_pct", 0) == 0), "buff expires next turn")
	# Weakness affects all targets of that enemy's normal action, not counters.
	g = battle()
	g.run.combat.enemies[0].intent.all = true
	play(g, "warrior_disarm")
	check(Mods.intent(g.run.combat.enemies[0]).damage == 9, "preview is reduced")
	var hp = g.run.heroes.map(func(h): return h.hp)
	g.end_turn()
	check(g.run.heroes[0].hp == hp[0] - 9 and g.run.heroes[1].hp == hp[1] - 9, "same reduced attack reaches both heroes")
	check(g.run.combat.enemies[0].get("weak_pct", 0) == 0, "weakness consumed")
	g = battle(["cleric", "mage"])
	g.run.combat.enemies.append(g.run.combat.enemies[0].duplicate(true))
	play(g, "cleric_censure", 1)
	check(g.run.combat.enemies.all(func(e): return e.weak_pct == 25), "area debuff all enemies")
	# Fracture removes current block once and reduces the next gain.
	g = battle(["rogue", "warrior"])
	var enemy = g.run.combat.enemies[0]
	enemy.block = 20
	play(g, "rogue_corrosive")
	check(enemy.block == 15 and enemy.poison == 4, "fracture before hits/poison")
	play(g, "rogue_corrosive")
	check(enemy.block == 15, "repeat fracture does not remove more block")
	play(g, "rogue_corrosive", 0, true)
	check(enemy.block == 13 and enemy.fracture_pct == 35, "stronger fracture only applies difference")
	check(Mods.intent(enemy).block == 7, "future shield reduced")
	g.end_turn()
	check(enemy.block == 7 and enemy.get("fracture_pct", 0) == 0, "reduced shield gained and fracture expires")
	# Multihit retains ordered hits and the fixed four-point counter rule.
	g = battle(["ranger", "warrior"])
	enemy = g.run.combat.enemies[0]
	enemy.intent.counter = 4
	enemy.weak_pct = 25
	play(g, "ranger_hunters_focus")
	var health = g.run.heroes[0].hp
	play(g, "ranger_split_arrow")
	check(enemy.hp == 288, "two empowered hits of six")
	check(g.resolved_card_hits.size() == 4, "two hits and two counters")
	check(g.run.heroes[0].hp == health - 3, "counter four twice minus five block")
	# Healing is capped, uses the selected ally and never revives fallen heroes.
	for entry in [["warrior_second_wind","warrior",0,6],["guardian_lay_hands","guardian",1,6],["mage_siphon","mage",0,4],["ranger_field_aid","ranger",1,7]]:
		g = battle([entry[1], "cleric"])
		g.run.heroes[entry[2]].hp -= 10
		var old_hp = g.run.heroes[entry[2]].hp
		play(g, entry[0], 0 if entry[0] == "mage_siphon" else entry[2])
		check(g.run.heroes[entry[2]].hp == old_hp + entry[3], "new healer " + entry[1])
		play(g, entry[0], 0 if entry[0] == "mage_siphon" else entry[2], true)
		check(g.run.heroes[entry[2]].hp <= g.run.heroes[entry[2]].max_hp, "no overheal")
	g.run.heroes[1].hp = 0
	g.run.combat.hand = [{"id":"ranger_field_aid"}]
	check(1 not in g.valid_targets(0) and not g.play_card(0,1), "healing rejects fallen ally")
	# Checkpoint/reload preserves active percentages and purchases, not duplicates.
	var path = "user://support-persist-test.save"
	for suffix in ["", ".bak", ".tmp"]: DirAccess.remove_absolute(path + suffix)
	g = Game.new(path, true)
	g.profile.buildings.market = true
	g.buy_market_card("warrior_rally")
	g.new_run(["warrior","ranger"], 12)
	g.enter_node(0)
	play(g, "warrior_rally", 1)
	var restored = Game.new(path, true)
	check(restored.run == g.run and "warrior_rally" in restored.profile.market_cards, "save/reload exact")
	check(restored.effective_card({"id":"ranger_arrow"}).damage == g.effective_card({"id":"ranger_arrow"}).damage, "same buff after reload")
	restored._start_combat(["skeleton"])
	check(restored.run.heroes[1].get("strength_pct", 0) == 0, "no buff leaks into next battle")
	for suffix in ["", ".bak", ".tmp"]: DirAccess.remove_absolute(path + suffix)
	print("SUPPORT CARDS: %d checks / %d failures" % [checks, failures])
	quit(1 if failures else 0)
