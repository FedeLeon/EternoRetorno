extends SceneTree
const Dungeon = preload("res://src/dungeon.gd")
var checks = 0
var failures = 0

func check(ok: bool, message: String) -> void:
	checks += 1
	if not ok:
		failures += 1
		printerr("FAIL: ", message)

func _initialize() -> void:
	var content = preload("res://src/content.gd").new()
	var rng = RandomNumberGenerator.new()
	for floor_number in [1, 2, 3]:
		var config = Dungeon.definition(floor_number)
		var observed: Dictionary = {}
		for id in config.common:
			var visual = content.enemies[id].visual
			check(ResourceLoader.exists("res://assets/combat_static/enemies/%s/idle.png" % visual), "motion asset " + id)
			check(ResourceLoader.exists("res://assets/comic/enemies/%s.png" % visual), "cut-in asset " + id)
		for seed_value in range(200):
			rng.seed = seed_value
			var nodes = Dungeon.create(rng, floor_number)
			rng.seed = seed_value
			check(nodes == Dungeon.create(rng, floor_number), "deterministic formations")
			var seen: Dictionary = {}
			for room in nodes:
				if room.kind != "combat": continue
				var unique: Dictionary = {}
				for id in room.encounter:
					unique[id] = true
					seen[id] = true
					observed[id] = true
					check(content.enemies.has(id) and id in config.common and room.stage >= config.min_stage.get(id, 0), "valid enemy and progressive debut")
				check(unique.size() == room.encounter.size(), "distinct members within a formation")
				# Every reachable path must change its formation after an ordinary battle.
				var pending: Array = room.next.duplicate()
				var visited: Dictionary = {}
				while not pending.is_empty():
					var next = pending.pop_front()
					if visited.has(next): continue
					visited[next] = true
					if nodes[next].kind == "combat":
						var before: Array = room.encounter.duplicate(); before.sort()
						var after: Array = nodes[next].encounter.duplicate(); after.sort()
						check(before != after, "no repeated next formation along a playable path")
					else: pending.append_array(nodes[next].next)
			check(seen.size() >= mini(12, config.common.size()), "broad variety in every generated floor")
		check(observed.size() == config.common.size(), "full roster remains reachable")
	print("ENEMY FORMATIONS: %d checks / %d failures" % [checks, failures])
	quit(1 if failures else 0)
