extends SceneTree
const Game = preload("res://src/game.gd")
const Dungeon = preload("res://src/dungeon.gd")
var checks = 0
var failures = 0

func check(value: bool, description: String) -> void:
	checks += 1
	if not value:
		failures += 1
		printerr("FAIL: ", description)

func fresh(party: Array = ["warrior", "guardian"], seed_value: int = 42) -> RefCounted:
	var game = Game.new("user://unused-test.save", false)
	game.new_run(party, seed_value)
	return game

func combat(party: Array = ["warrior", "guardian"]) -> RefCounted:
	var game = fresh(party)
	game.enter_node(0)
	return game

func instance(id: String, upgraded: bool = false) -> Dictionary:
	return {"id": id, "upgraded": upgraded}

func set_hand(g: RefCounted, ids: Array) -> void:
	g.run.combat.hand = []
	for id in ids:
		g.run.combat.hand.append(instance(id))

func _initialize() -> void:
	content_and_map()
	card_rules()
	death_rules()
	reward_and_rooms()
	persistence()
	simulations()
	print("CHECKS: %d | FAILURES: %d" % [checks, failures])
	quit(1 if failures else 0)

func content_and_map() -> void:
	var g = fresh()
	check(g.content.heroes.size() == 4 and g.content.cards.size() == 88, "4 professions / 88 cards")
	check(g.content.enemies.size() == 57 and g.content.events.size() == 19 and g.content.relics.size() == 33, "enemy / event / relic catalog")
	check(not g.new_run(["mage", "mage"]), "no duplicate heroes")
	check(not g.new_run(["invalid", "mage"]), "invalid hero rejected")
	check(g.run.deck.size() == 20, "20 starter instances")
	check(not g.enter_node(27), "cannot jump to boss")
	check(not g.descend(), "staircase initially locked")
	check(g.run.nodes.size() == 28, "28 nodes")
	check(paths_end_at_boss(g.run.nodes, 0), "every branch terminates at boss")
	var same = fresh()
	check(g.run.nodes == same.run.nodes, "seed reproduces encounters")
	for id in g.content.heroes:
		check(g.content.heroes[id].starter.size() == 10, "ten starter cards " + id)
		var unique: Array = []
		for c in g.content.heroes[id].starter:
			if c not in unique: unique.append(c)
		check(unique.size() == 4, "four basic definitions " + id)
		var starter = g.content.heroes[id].starter
		check(starter.count(starter[0]) == 4 and starter.count(starter[4]) == 4, "four copies of each core basic " + id)
		check(g.content.cards[starter[0]].damage > 0 and g.content.cards[starter[4]].block > 0, "repeated attack and defense " + id)
		check(starter.all(func(key): return g.content.cards[key].cost == 1 and not g.content.cards[key].locked and g.content.cards[key].get("market_price", 0) == 0), "only modest unlocked starters " + id)

func paths_end_at_boss(nodes: Array, node: int) -> bool:
	if nodes[node].kind == "boss": return nodes[node].next.is_empty()
	if nodes[node].next.is_empty(): return false
	for next in nodes[node].next:
		if next <= node or not paths_end_at_boss(nodes, next): return false
	return true

func card_rules() -> void:
	var g = combat()
	check(g.run.combat.energy == 3 and g.run.combat.hand.size() == 6, "3 energy / 6 cards")
	set_hand(g, ["warrior_slash", "warrior_heavy"])
	var e = g.run.combat.enemies[0]
	e.hp = 100; e.max_hp = 100; e.block = 4
	check(not g.play_card(0, 9), "invalid target rejected")
	check(g.run.combat.energy == 3, "invalid action costs nothing")
	g.play_card(0, 0)
	check(e.hp == 95 and e.block == 0 and g.run.combat.energy == 2, "damage consumes block and energy")
	g.run.combat.energy = 1
	check(not g.play_card(0, 0), "insufficient energy rejected")
	set_hand(g, ["guardian_lay_hands"])
	g.run.heroes[0].hp = 20
	g.play_card(0, 0)
	check(g.run.heroes[0].hp == 26, "ally heal")
	g.run.combat.energy = 3
	g.run.heroes[0].block = 0
	set_hand(g, ["warrior_guard"])
	check(g.valid_targets(0) == [0], "self targets only owner")
	g.play_card(0, 0)
	check(g.run.heroes[0].block == 9, "self block")
	e.intent = {"damage": 3, "target": 0}
	g.end_turn()
	check(g.run.heroes[0].hp == 26 and g.run.heroes[0].block == 0, "block protects enemy phase then expires")
	g.run.heroes[0].block = 20
	g.run.heroes[1].block = 20
	e.intent = {"damage": 0, "target": 0}
	g.end_turn()
	check(g.run.heroes.all(func(h): return h.block == 0), "unused block expires even without incoming attacks")
	g = combat(["warrior", "rogue"])
	e = g.run.combat.enemies[0]; e.hp = 100; e.max_hp = 100; e.block = 30
	set_hand(g, ["rogue_assassin", "rogue_toxin"])
	g.play_card(0, 0)
	check(e.hp == 78 and e.block == 30, "precision bypasses block")
	g.play_card(0, 0)
	check(e.poison == 4 and e.block == 26, "poison applied")
	g.end_turn()
	check(e.hp == 74 and e.poison == 3, "poison ticks and decays")
	g = combat(["mage", "guardian"])
	g.run.combat.enemies.append(g.run.combat.enemies[0].duplicate(true))
	set_hand(g, ["mage_storm"])
	g.play_card(0, 0)
	check(g.run.combat.enemies.all(func(u): return u.hp == u.max_hp - 10), "area damage")
	g.run.combat.energy = 3
	set_hand(g, ["guardian_wall"])
	g.play_card(0, 1)
	check(g.run.heroes.all(func(h): return h.block == 13), "party block")
	g = combat(["mage", "rogue"])
	e = g.run.combat.enemies[0]; e.hp = 100; e.max_hp = 100
	g.run.relics = ["fang"]
	set_hand(g, ["mage_spark"])
	g.play_card(0, 0)
	check(e.hp == 90, "fang applies to each hit")
	g.run.combat.draw = []
	g.run.combat.hand = []
	g.run.combat.discard = [instance("mage_spark"), instance("rogue_cut")]
	g._draw(5)
	check(g.run.combat.hand.size() == 2 and g.run.combat.discard.is_empty(), "reshuffle handles short deck")
	var up = g.content.card(instance("rogue_cut", true))
	check(up.damage == 11, "upgrade damage")
	check(g.content.card(instance("rogue_toxin", true)).poison == 6, "upgrade poison")
	g = fresh(); g.run.relics = ["ember", "hourglass"]; g.enter_node(0)
	check(g.run.combat.energy == 4 and g.run.heroes[0].block == 4, "opening relics")
	g.end_turn()
	check(g.run.combat.energy == 3, "hourglass only first turn")

func death_rules() -> void:
	var g = combat()
	var e = g.run.combat.enemies[0]
	e.hp = 100; e.max_hp = 100
	g.run.heroes[0].hp = 1
	e.intent = {"damage": 2, "target": 0}
	g.end_turn()
	check(g.run.phase == "combat" and g.run.heroes[0].hp == 0, "one death does not end run")
	for pile in ["draw", "hand", "discard"]:
		check(g.run.combat[pile].all(func(c): return g.content.cards[c.id].owner != "warrior"), "dead owner removed from " + pile)
	check(g.run.combat.inactive.size() == 10, "ten inactive cards conserved")
	check(e.intent.target == 1, "intent only targets living heroes")
	g.run.combat.energy = 3
	set_hand(g, ["guardian_strike"])
	e.hp = 1
	g.play_card(0, 0)
	check(g.run.phase == "reward" and g.run.heroes[0].hp == 15, "fallen revives with ceil 25 percent")
	check(g.run.deck.size() == 20, "inactive cards remain in permanent run deck")
	g.choose_reward(-1)
	g.run.current = 0 # Reach treasure, then the joined fight.
	preload("res://tests/room_fixture.gd").enter(g, "treasure"); g.take_treasure(); g.leave_treasure(); preload("res://tests/room_fixture.gd").enter(g, "combat")
	var total = g.run.combat.draw + g.run.combat.hand
	check(total.filter(func(c): return g.content.cards[c.id].owner == "warrior").size() == 10, "revived cards return next combat")
	g = combat()
	g.run.heroes[0].hp = 1; g.run.heroes[1].hp = 1
	g.run.combat.enemies[0].intent = {"damage": 2, "target": 0, "all": true}
	g.end_turn()
	check(g.run.phase == "defeat" and g.profile.history.size() == 1, "both die immediate defeat")
	check(g.run.deck.is_empty() and g.run.relics.is_empty(), "loss clears acquired run assets")
	check(not g.end_turn(), "no actions after defeat")
	g = combat()
	g.run.heroes[0].hp = 0
	g.run.combat.enemies[0].intent = {"damage": 2, "target": 0}
	var hp = g.run.heroes[1].hp
	g.end_turn()
	check(g.run.heroes[1].hp == hp - 2, "stale enemy intent retargets survivor")

func reward_and_rooms() -> void:
	var g = fresh()
	g._make_reward()
	check(g.run.reward.size() == 3, "three rewards")
	check(g.run.reward.all(func(c): return g.content.cards[c.id].owner in g.run.party and not g.content.cards[c.id].locked), "compatible unlocked rewards")
	var size_before = g.run.deck.size()
	g.choose_reward(0)
	check(g.run.deck.size() == size_before + 1 and not g.choose_reward(0), "reward cannot be claimed twice")
	g.run.current = 0
	preload("res://tests/room_fixture.gd").enter(g, "treasure")
	var item = g.run.treasure.item
	g.take_treasure()
	check(g.run.inventory.get(item, 0) == 1 and not g.take_treasure(), "treasure once")
	g.leave_treasure()
	g.run.current = 8
	preload("res://tests/room_fixture.gd").enter(g, "rest")
	g.run.heroes[0].hp = 1
	g.rest(true)
	check(g.run.heroes[0].hp == 19 and not g.rest(true), "rest heals ceil 30 percent once")
	g.run.current = 8; preload("res://tests/room_fixture.gd").enter(g, "rest")
	g.rest(false, 0)
	check(g.run.deck[0].upgraded, "rest upgrades")
	g.run.current = 0; preload("res://tests/room_fixture.gd").enter(g, "event")
	g.run.nodes[g.run.current].event = "altar"
	g.run.heroes[0].hp = 5
	check(not g.choose_event(0), "altar cannot kill")
	g.choose_event(1)
	check(g.run.phase == "map", "event can be skipped")
	g.run.current = 0; preload("res://tests/room_fixture.gd").enter(g, "event"); g.run.nodes[g.run.current].event = "library"
	g.choose_event(0)
	check(g.run.phase == "reward", "library shares reward transaction")
	g.choose_reward(-1)
	g.run.relics.append("ember") # Existing group relic: elite must grant another.
	g.run.current = 5; preload("res://tests/room_fixture.gd").enter(g, "elite")
	g.run.combat.enemies[0].hp = 0
	g._check_combat_end()
	check("hourglass" in g.profile.unlocked_relics, "elite permanently unlocks relic")
	check(g.run.relics.size() == 2, "elite grants distinct relic")
	g.choose_reward(-1)
	g.run.current = 26; preload("res://tests/room_fixture.gd").enter(g, "boss")
	preload("res://tests/room_fixture.gd").break_objective(g)
	g.run.heroes[0].hp = 20
	g.run.relics = ["chalice"]
	g.run.combat.enemies[0].hp = 0
	g._check_combat_end()
	check(g.run.heroes[0].hp == 23, "chalice victory heal")
	check(not g.descend(), "must resolve boss reward before staircase")
	g.choose_reward(-1); preload("res://tests/room_fixture.gd").collect_boss_relic(g); g.descend()
	check(g.run.floor == 2 and g.profile.victories == 0, "first floor continues adventure")
	preload("res://tests/room_fixture.gd").enter(g, "boss")
	preload("res://tests/room_fixture.gd").break_objective(g)
	for enemy in g.run.combat.enemies: enemy.hp = 0
	g._check_combat_end(); g.choose_reward(-1); preload("res://tests/room_fixture.gd").collect_boss_relic(g); g.descend()
	check(g.run.floor == 3 and g.profile.victories == 0, "second floor continues to fortress")
	preload("res://tests/room_fixture.gd").enter(g, "boss")
	preload("res://tests/room_fixture.gd").break_objective(g)
	for enemy in g.run.combat.enemies: enemy.hp = 0
	g._check_combat_end(); g.choose_reward(-1); preload("res://tests/room_fixture.gd").collect_boss_relic(g); g.descend()
	check(g.profile.victories == 1 and g.profile.unlocked_cards.size() == 2, "pair victory unlocks")
	check(not g.descend() and g.profile.victories == 1, "victory cannot duplicate")
	g.new_run(["mage", "rogue"], 100)
	check(g.profile.unlocked_cards.size() == 2 and g.run.deck.size() == 20 and g.run.relics.is_empty(), "new run preserves only profile")

func persistence() -> void:
	var path = "user://test-transaction.save"
	for suffix in ["", ".bak", ".tmp"]:
		DirAccess.remove_absolute(path + suffix)
	var g = Game.new(path, true)
	g.new_run(["guardian", "rogue"], 287)
	g.enter_node(0)
	var restored = Game.new(path, true)
	check(g.run == restored.run, "exact combat snapshot after load")
	g.end_turn(); restored.end_turn()
	check(g.run == restored.run, "RNG and deck continue identically")
	g.run.combat.enemies[0].hp = 0
	g._check_combat_end(); g.checkpoint()
	restored = Game.new(path, true)
	check(g.run.reward == restored.run.reward and restored.run.phase == "reward", "pending reward restored")
	var before = restored.run.deck.size()
	restored.choose_reward(0)
	var again = Game.new(path, true)
	check(again.run.deck.size() == before + 1 and not again.choose_reward(0), "no reward duplication after restart")
	# Simulate a partial write: valid main remains authoritative.
	var f = FileAccess.open(path + ".tmp", FileAccess.WRITE); f.store_string("interrupted"); f.close()
	check(Game.new(path, true).run == again.run, "partial temporary write ignored")
	# Preserve a valid backup, then corrupt only main; read must recover backup.
	again.checkpoint()
	f = FileAccess.open(path, FileAccess.WRITE); f.store_var({"invalid": true}); f.close()
	check(Game.new(path, true).run == again.run, "backup recovers malformed main")
	for suffix in ["", ".bak", ".tmp"]:
		DirAccess.remove_absolute(path + suffix)

# A deterministic, greedy player exercises actual rules without modifying combat
# stats. It favors lethal attacks and useful healing; routes avoid the optional elite.
func autoplay(g: RefCounted) -> bool:
	var steps = 0
	while g.run.phase not in ["victory", "defeat"] and steps < 1500:
		steps += 1
		match g.run.phase:
			"map":
				if g.run.boss_defeated:
					g.descend()
				else:
					var available = g.available_nodes()
					var next = available[0]
					for i in available:
						if g.run.nodes[i].kind in ["event", "rest"]: next = i
						if g.run.nodes[next].kind == "elite": next = i
					g.enter_node(next)
			"room":
				match g.run.nodes[g.run.current].kind:
					"rest": g.rest(true)
					"treasure":
						g.take_treasure()
						g.leave_treasure()
					"event":
						if not g.choose_event(0): g.choose_event(1)
			"event_cards": g.modify_event_card(-1)
			"reward": g.choose_reward(-1)
			"boss_reward": g.polish_action("boss_relic", {"id":g.run.boss_offers[0]})
			"merchant": g.merchant_action("leave")
			"combat":
				var objective: Dictionary = g.run.combat.get("boss_objective", {})
				if (objective.get("kind", "") in ["source", "armor"] and not objective.broken) or objective.get("trapped", -1) >= 0:
					if g.polish_action("boss_objective"): continue
				var best_score = -1.0
				var best_card = -1
				var best_target = -1
				for i in range(g.run.combat.hand.size()):
					var c = g.content.card(g.run.combat.hand[i])
					for target in g.valid_targets(i):
						var score = float(c.damage * c.hits + c.poison * 2) / maxf(1, c.cost)
						if c.target == "enemy":
							var enemy = g.run.combat.enemies[target]
							if c.damage * c.hits >= enemy.hp + (0 if c.pierce else enemy.block): score += 30
						if c.target == "all_enemies": score *= g.run.combat.enemies.filter(func(e): return e.hp > 0).size()
						if c.target in ["ally", "self", "all_allies"]:
							var hero = g.run.heroes[target]
							score += mini(c.heal, hero.max_hp - hero.hp) * 2.0 / maxf(1, c.cost)
							for enemy in g.run.combat.enemies:
								if enemy.hp > 0 and (enemy.intent.target == target or enemy.intent.get("all", false) or c.target == "all_allies"):
									score += minf(c.block, maxf(0, enemy.intent.damage - hero.block)) * 0.8 / maxf(1, c.cost)
						if score > best_score:
							best_score = score; best_card = i; best_target = target
				if best_card >= 0: g.play_card(best_card, best_target)
				else: g.end_turn()
	check(steps < 1500, "autoplay terminates")
	return g.run.phase == "victory"

func simulations() -> void:
	var ids = fresh().content.heroes.keys()
	var wins = 0
	for i in range(ids.size()):
		for j in range(i + 1, ids.size()):
			var pair_wins = 0
			for seed_value in range(3):
				var g = fresh([ids[i], ids[j]], 800 + seed_value)
				if autoplay(g): pair_wins += 1
			print("PAIR %s + %s: %d/3 victories" % [ids[i], ids[j], pair_wins])
			# Completion rate is a balance observation: this bot skips rewards and upgrades.
			wins += pair_wins
	print("SIMULATIONS: %d/18 victories" % wins)
