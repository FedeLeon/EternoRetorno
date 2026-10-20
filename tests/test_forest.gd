extends SceneTree
const Game = preload("res://src/game.gd")
const Dungeon = preload("res://src/dungeon.gd")
const Room = preload("res://tests/room_fixture.gd")
var checks = 0
var failures = 0
func check(ok: bool, message: String) -> void:
	checks += 1
	if not ok:
		failures += 1
		printerr("FAIL: ", message)
func _initialize() -> void:
	var rng = RandomNumberGenerator.new()
	var signatures: Dictionary = {}
	var kind_orders: Dictionary = {}
	var edge_orders: Dictionary = {}
	var forest_types: Dictionary = {}
	for floor_number in [1, 2]:
		for seed_value in range(100):
			rng.seed = seed_value
			var nodes = Dungeon.create(rng, floor_number)
			rng.seed = seed_value
			check(nodes == Dungeon.create(rng, floor_number), "seed determinism")
			var kinds: Dictionary = {}
			var reached: Array = [0,1,2]
			var pending: Array = [0,1,2]
			while not pending.is_empty():
				for next in nodes[pending.pop_front()].next:
					if next not in reached:
						reached.append(next)
						pending.append(next)
			check(reached.size() == 35, "all rooms reachable")
			for n in nodes:
				kinds[n.kind] = int(kinds.get(n.kind, 0)) + 1
				check(n.next.all(func(i): return i > n.id and i < nodes.size()), "acyclic forward edges")
				check(n.id == nodes.size()-1 or not n.next.is_empty(), "no dead ends")
				check(Rect2(60,100,1090,545).has_point(Dungeon.map_position(n)), "inside map")
				if n.kind == "combat":
					check(n.encounter.size() in [1,2,3], "formation size")
					if floor_number == 2:
						var unique: Dictionary = {}
						var config = Dungeon.definition(2)
						for id in n.encounter:
							check(id in config.common and n.stage >= config.min_stage.get(id,0), "forest roster / stage " + id)
							unique[id] = true
							forest_types[id] = true
						check(unique.size() == n.encounter.size() and n.encounter.size() >= 2, "forest mixed groups")
			check(kinds == {"combat":18,"rest":7,"event":5,"treasure":2,"elite":2,"boss":1}, "expanded room inventory")
			check(nodes.filter(func(n): return n.kind == "combat" and n.encounter.size() >= 2).size() >= 7, "more group battles")
			check(nodes[0].kind == "combat" and nodes[-1].kind == "boss", "entry and guardian")
			kind_orders[str(nodes.map(func(n): return n.kind))] = true
			edge_orders[str(nodes.map(func(n): return n.next))] = true
			signatures[str(nodes)] = true
	check(kind_orders.size() > 90 and edge_orders.size() > 90 and signatures.size() == 200, "seeds change rooms and routes, floors differ")
	check(forest_types.size() == Dungeon.definition(2).common.size(), "all configured forest common enemies appear across seeds")
	var path = "user://forest-transition-test.save"
	for suffix in ["", ".bak", ".tmp"]: DirAccess.remove_absolute(path + suffix)
	var g = Game.new(path, true)
	g.new_run(["warrior", "guardian"], 5, {"team":"vital_amulet"})
	g.run.relics = ["iron_knot"]
	g.run.inventory = {"healing_potion":2}
	g.run.expedition_stats = {"battles":4}
	g.run.soul_rooms = [0,27]
	Room.enter(g, "boss")
	Room.break_objective(g)
	for enemy in g.run.combat.enemies: enemy.hp = 0
	g._check_combat_end()
	check(not g.descend(), "reward must be resolved")
	g.choose_reward(0)
	var rooms_before = g.run.visited.size()
	var heroes = g.run.heroes.duplicate(true)
	var deck = g.run.deck.duplicate(true)
	var contract_cycle = g.profile.expeditions.cycle
	Room.collect_boss_relic(g)
	check(g.run.floor == 2 and g.run.phase == "map" and not g.descend(), "relic selection opens forest without staircase")
	check(g.run.current == -1 and g.available_nodes() == [0,1,2] and g.run.visited.is_empty(), "new floor starts at entrance")
	check(g.run.deck == deck and g.run.heroes == heroes and g.run.relics == ["iron_knot", "crypt_blood"] and g.run.inventory.healing_potion == 2, "party inventory deck preserved")
	check(g.run.soul_rooms.is_empty() and g.run.rooms_completed == rooms_before, "room reward ledger separated by floor")
	check(g.profile.victories == 0 and g.profile.expeditions.cycle == contract_cycle, "floor one does not complete contracts or specialization victory")
	var loaded = Game.new(path, true)
	check(loaded.run == g.run and loaded.rng.state == g.rng.state, "forest and RNG persist")
	g.enter_node(0)
	var balance = g.profile.souls
	for enemy in g.run.combat.enemies: enemy.hp = 0
	g._check_combat_end()
	check(g.profile.souls == balance + 30, "first room of forest pays despite crypt room zero")
	g.choose_reward(-1); Room.collect_boss_relic(g)
	Room.enter(g, "boss")
	Room.break_objective(g)
	check(g.run.combat.enemies.size() == 2, "forest guardian has escort")
	for enemy in g.run.combat.enemies: enemy.hp = 0
	g._check_combat_end(); g.choose_reward(-1); Room.collect_boss_relic(g)
	check(g.run.floor == 3 and g.run.phase == "map" and not g.descend() and g.profile.victories == 0, "relic selection opens fortress without staircase")
	Room.enter(g, "boss")
	Room.break_objective(g)
	for enemy in g.run.combat.enemies: enemy.hp = 0
	g._check_combat_end(); g.choose_reward(-1); Room.collect_boss_relic(g)
	check(g.descend() and g.run.phase == "victory" and g.profile.victories == 1, "forest completes adventure")
	check(g.profile.expeditions.cycle == contract_cycle + 1 and "warrior" in g.profile.specializations.victorious, "settlement only at final victory")
	check(not g.descend() and g.profile.victories == 1, "final settlement once")
	g.new_run(["warrior", "guardian"], 8)
	g.run.erase("polish_version")
	g.run.erase("telemetry")
	g.run.erase("floor")
	g.run.erase("floor_count")
	g.run.erase("rooms_completed")
	Room.enter(g, "boss")
	Room.break_objective(g)
	for enemy in g.run.combat.enemies: enemy.hp = 0
	g._check_combat_end(); g.choose_reward(-1); Room.collect_boss_relic(g); g.checkpoint()
	loaded = Game.new(path, true)
	check(loaded.run.nodes == g.run.nodes and loaded.descend() and loaded.run.phase == "victory", "legacy adventure retains graph and original one-floor ending")
	for suffix in ["", ".bak", ".tmp"]: DirAccess.remove_absolute(path + suffix)
	print("FOREST / RANDOM FLOORS: %d checks / %d failures" % [checks, failures])
	quit(1 if failures else 0)
