extends RefCounted
## Presentation geometry from graph depth. Never changes saved node positions or RNG.
const WIDTH = 1100.0
const STEP = 156.0
const TOP = 126.0
var positions: Dictionary = {}
var height = 0.0

func build(nodes: Array) -> void:
	positions.clear()
	var depths: Dictionary = {}
	for node in nodes: depths[node.id] = 0
	# Bounded relaxation also supports older DAG saves without stage metadata.
	for pass_index in range(nodes.size()):
		var changed = false
		for node in nodes:
			for next in node.next:
				if depths.has(next) and depths[next] < depths[node.id] + 1:
					depths[next] = depths[node.id] + 1
					changed = true
		if not changed: break
	var layers: Dictionary = {}
	var last = 0
	for node in nodes:
		var depth: int = depths[node.id]
		last = maxi(last, depth)
		if not layers.has(depth): layers[depth] = []
		layers[depth].append(node.id)
	for depth in layers:
		var ids: Array = layers[depth]
		ids.sort()
		var spacing = minf(304.0, (WIDTH - 180.0) / maxf(1.0, ids.size() - 1))
		for lane in range(ids.size()):
			positions[ids[lane]] = Vector2(WIDTH / 2 + (lane - (ids.size()-1)/2.0)*spacing, TOP + (last-depth)*STEP)
	height = TOP + last*STEP + 112.0

func connection(from: int, to: int) -> PackedVector2Array:
	var a: Vector2 = positions[from]
	var b: Vector2 = positions[to]
	var points = PackedVector2Array()
	# Monotone cubic: leaves and joins vertically, always climbing toward the boss.
	var bend = (a.y-b.y)*.45
	for step in range(25):
		points.append(a.bezier_interpolate(a+Vector2(0,-bend), b+Vector2(0,bend), b, step/24.0))
	return points
