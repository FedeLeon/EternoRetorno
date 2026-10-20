extends SceneTree
const Dungeon = preload("res://src/dungeon.gd")
const Geometry = preload("res://src/map_geometry.gd")
var checks = 0
var failures = 0
func check(ok: bool, message: String) -> void:
	checks += 1
	if not ok: failures += 1; printerr("FAIL: ",message)
func _initialize() -> void:
	var rng = RandomNumberGenerator.new()
	for floor_number in [1,2,3]:
		for seed_value in range(100):
			rng.seed = seed_value
			var nodes = Dungeon.create(rng,floor_number)
			rng.seed = seed_value
			check(nodes==Dungeon.create(rng,floor_number),"deterministic spiral")
			check(nodes.size()==35 and nodes[-1].kind=="boss","room inventory and guardian")
			check(Dungeon.map_position(nodes[-1]).distance_to(Geometry.CENTERS[-1])<5,"guardian in spiral center")
			var reached: Array = [0,1,2]
			for node in nodes:
				check(node.id in reached,"all rooms reachable")
				var pos = Dungeon.map_position(node)
				check(Rect2(85,108,1070,538).has_point(pos),"rooms within usable map")
				var area = Rect2(Vector2(54+(pos.x-54)*0.93,pos.y)-Vector2(29,29),Vector2(58,58))
				for other in nodes.slice(node.id+1):
					var other_pos = Dungeon.map_position(other)
					var other_area = Rect2(Vector2(54+(other_pos.x-54)*0.93,other_pos.y)-Vector2(29,29),Vector2(58,58))
					check(not area.intersects(other_area),"room buttons do not overlap")
				for next in node.next:
					if next not in reached: reached.append(next)
					check(nodes[next].stage==node.stage+1,"paths advance along spiral without skipping stages")
					var curve = Geometry.connection(node,nodes[next])
					check(curve[0]==pos and curve[-1]==Dungeon.map_position(nodes[next]) and curve.size()==17,"curves connect exact room centers")
					check(Array(curve).all(func(point):return Rect2(70,90,1090,565).has_point(point)),"curves stay in map")
	var old = {"id":0,"position":[90,100]}
	var next = {"id":1,"position":[300,400]}
	check(Geometry.connection(old,next)==PackedVector2Array([Vector2(90,100),Vector2(300,400)]),"previous saved layout keeps straight paths")
	print("SPIRAL MAP: %d checks / %d failures" % [checks,failures])
	quit(1 if failures else 0)
