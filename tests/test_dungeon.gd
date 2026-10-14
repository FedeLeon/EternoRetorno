extends SceneTree
const Game = preload("res://src/game.gd")
const Dungeon = preload("res://src/dungeon.gd")
var checks = 0
var failures = 0
var paths: Array = []
func check(ok: bool, message: String) -> void:
	checks += 1
	if not ok:
		failures += 1
		printerr(message)
func walk(nodes: Array, id: int, path: Array) -> void:
	var next_path = path + [id]
	if nodes[id].next.is_empty():
		paths.append(next_path)
		return
	for next in nodes[id].next:
		if next <= id or next >= nodes.size():
			check(false, "invalid edge")
			continue
		walk(nodes, next, next_path)
func _initialize() -> void:
	var g = Game.new("user://unused-dungeon-test.save", false)
	g.new_run(["warrior", "guardian"], 42)
	var nodes = g.run.nodes
	check(nodes.size() == 28, "28 rooms")
	check(nodes.any(func(n): return n.next.size() == 3), "three-way forks")
	check(nodes.filter(func(n): return n.kind == "elite").size() == 2, "two elites")
	walk(nodes, 0, [])
	check(paths.size() > 20, "many complete routes")
	check(paths.all(func(path): return path[-1] == 27 and 18 in path), "all routes cross late elite and guardian")
	var early = nodes.filter(func(n): return n.kind == "elite")[0].id
	check(paths.any(func(path): return early in path) and paths.any(func(path): return early not in path), "first elite optional")
	for n in nodes:
		check(paths.any(func(path): return n.id in path), "every room reachable")
		check(Rect2(60, 75, 1150, 565).has_point(Dungeon.map_position(n)), "room inside parchment")
	var legacy_kinds = ["combat", "event", "combat", "treasure", "elite", "combat", "rest", "event", "combat", "combat", "rest", "boss"]
	var legacy_links = [[1,2],[3],[3],[4,5],[6],[6],[7,8],[9],[9],[10],[11],[]]
	var legacy: Array = []
	for i in range(12):
		legacy.append({"id": i, "kind": legacy_kinds[i], "next": legacy_links[i], "encounter": ["rat"], "event": "well"})
	g.run.nodes = legacy
	g.run.current = 3
	g.run.visited = [0, 1, 3]
	var store = preload("res://src/save_store.gd").new("user://dungeon-compat-test.save")
	check(store.write(g.profile, g.run), "write legacy fixture")
	var reopened = Game.new(store.path)
	check(reopened.run.nodes == legacy and reopened.run.current == 3, "legacy graph and progress preserved on load")
	check(reopened.available_nodes() == [4, 5], "legacy exits preserved")
	check(Dungeon.map_position(legacy[11]) == Dungeon.POSITIONS[11] * Vector2(1.7, 1) + Vector2(100,145), "legacy rendering coordinates")
	for suffix in ["", ".bak", ".tmp"]:
		DirAccess.remove_absolute(store.path + suffix)
	print("DUNGEON: %d checks / %d failures" % [checks, failures])
	quit(1 if failures else 0)
