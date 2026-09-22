extends SceneTree
const Game = preload("res://src/game.gd")
const P = preload("res://src/rules/camp_progression.gd")
var checks = 0
var failures = 0
func check(ok: bool, caption: String) -> void:
	checks += 1
	if not ok:
		printerr("FAIL: ", caption)
		failures += 1
func _initialize() -> void:
	var path = "user://market-test.save"
	for suffix in ["", ".bak", ".tmp"]: DirAccess.remove_absolute(path + suffix)
	var g = Game.new(path, true)
	check(g.profile.souls == 5000, "one test grant")
	check(not P.migrate(g.profile), "migration idempotent")
	check(not g.buy_market_card("warrior_execution"), "construction required")
	check(g.build_market(), "build")
	check(g.profile.souls == 4700 and not g.build_market(), "charge once")
	for hero in g.content.heroes:
		var total = 0
		var market = 0
		for id in g.content.cards:
			var c = g.content.cards[id]
			if c.owner != hero: continue
			total += 1
			if int(c.get("market_price", 0)) > 0:
				market += 1
				check(not P.available(g.profile, c), "unbought excluded " + id)
		check(total == 19 and market == 10, "19 cards / 10 market " + hero)
		for id in g.content.heroes[hero].starter:
			check(g.content.cards[id].get("market_price", 0) == 0, "starter excludes market")
	var id = ""
	for key in g.content.cards:
		if g.content.cards[key].get("market_price", 0) > 0:
			id = key
			break
	var price = g.content.cards[id].market_price
	check(g.buy_market_card(id), "purchase")
	check(g.profile.souls == 4700 - price, "price")
	check(not g.buy_market_card(id), "duplicate rejected")
	check(not g.buy_market_card("bad"), "invalid rejected")
	check(P.available(g.profile, g.content.cards[id]), "purchased available")
	g.new_run(["warrior", "cleric"], 42)
	g.enter_node(0)
	var before = g.profile.souls
	for enemy in g.run.combat.enemies: enemy.hp = 0
	check(g._check_combat_end(), "win")
	check(g.profile.souls == before + 30, "combat souls")
	check(not g._check_combat_end(), "resolved battle ignored")
	g.checkpoint()
	var restored = Game.new(path, true)
	check(restored.profile == g.profile and restored.run == g.run, "atomic reload")
	check(P.award(restored.profile, restored.run) == 0, "reward ledger")
	for kind in ["elite", "boss"]:
		var mock = {"current": 0, "nodes": [{"kind": kind}]}
		check(P.award(restored.profile, mock) == (80 if kind == "elite" else 150), "souls " + kind)
	var seen = false
	for roll in range(100):
		restored._make_reward()
		for offer in restored.run.reward:
			var c = restored.content.cards[offer.id]
			check(P.available(restored.profile, c), "reward respects locks")
			if offer.id == id: seen = true
	check(seen, "purchased card can appear in rewards")
	var before_loss = restored.profile.souls
	restored._finish(false)
	check(restored.profile.souls == before_loss, "defeat preserves souls")
	for card_id in g.content.cards:
		var c = g.content.cards[card_id]
		if not c.has("tier"): continue
		for upgraded in [false, true]:
			var battle = Game.new("user://unused-card-rules.save", false)
			var companion = "cleric" if c.owner != "cleric" else "warrior"
			battle.new_run([c.owner, companion], 42)
			battle.enter_node(0)
			for enemy in battle.run.combat.enemies:
				enemy.hp = 200
				enemy.block = 2
			for hero in battle.run.heroes: hero.hp -= 20
			var instance = {"id": card_id, "upgraded": upgraded}
			battle.run.combat.hand = [instance]
			var effect = battle.content.card(instance)
			check(battle.play_card(0, 0), "new card playable " + card_id)
			check(battle.run.combat.energy == 3 - effect.cost, "energy " + card_id)
			if effect.damage > 0:
				check(battle.run.combat.enemies[0].hp == 200 - effect.damage * effect.hits + (0 if effect.pierce else (1 if effect.get("fracture_pct", 0) > 0 else 2)), "damage " + card_id)
			if effect.poison > 0:
				check(battle.run.combat.enemies[0].poison == effect.poison, "poison " + card_id)
			if effect.block > 0: check(battle.run.heroes[0].block == effect.block, "block " + card_id)
			if effect.heal > 0: check(battle.run.heroes[0].hp == mini(battle.run.heroes[0].max_hp, battle.run.heroes[0].max_hp - 20 + effect.heal), "heal " + card_id)
	var balance = restored.profile.souls
	restored.new_run(["mage", "ranger"], 5)
	check(restored.profile.souls == balance, "new run keeps balance")
	check(restored.profile.market_cards == [id], "unlocks persist")
	restored.profile.souls = 0
	check(not restored.buy_market_card("mage_comet"), "no funds for unowned card")
	check(not restored.buy_market_card("warrior_pommel"), "basic card not for sale")
	for suffix in ["", ".bak", ".tmp"]: DirAccess.remove_absolute(path + suffix)
	print("PROGRESSION CHECKS: %d / FAILURES: %d" % [checks, failures])
	quit(1 if failures else 0)
