extends RefCounted
# Shared pure geometry: generation stores coordinates; UI only draws them.
const CENTERS = [Vector2(180,184),Vector2(460,184),Vector2(780,184),Vector2(1060,280),Vector2(1060,530),Vector2(780,565),Vector2(460,565),Vector2(180,500),Vector2(180,335),Vector2(350,350),Vector2(680,340),Vector2(910,365),Vector2(610,470)]
const LEGACY_CENTERS = [Vector2(140,186),Vector2(430,186),Vector2(790,186),Vector2(1040,300),Vector2(1040,520),Vector2(800,570),Vector2(440,570),Vector2(170,425),Vector2(340,320),Vector2(500,365),Vector2(900,370),Vector2(720,430),Vector2(570,400)]
const NORMALS = [Vector2.UP,Vector2.DOWN,Vector2.DOWN,Vector2.RIGHT,Vector2.RIGHT,Vector2.UP,Vector2.UP,Vector2.LEFT,Vector2.LEFT,Vector2.DOWN,Vector2.DOWN,Vector2.DOWN,Vector2.DOWN]

static func position(stage: int, lane: int, width: int, rng: RandomNumberGenerator) -> Vector2:
	return CENTERS[stage] + NORMALS[stage] * (lane - (width - 1) / 2.0) * 70 + Vector2(rng.randi_range(-3,3),rng.randi_range(-3,3))

static func connection(from: Dictionary, to: Dictionary) -> PackedVector2Array:
	var a = Vector2(from.position[0],from.position[1])
	var b = Vector2(to.position[0],to.position[1])
	if from.get("layout", "") != "spiral" or to.get("layout", "") != "spiral": return PackedVector2Array([a,b])
	var stage = int(from.stage)
	var next_stage = int(to.stage)
	var centers = CENTERS if int(from.get("layout_version",1)) >= 2 else LEGACY_CENTERS
	var tangent_a = (centers[next_stage] - centers[maxi(0,stage-1)]) / 6.0
	var tangent_b = (centers[mini(12,next_stage+1)] - centers[stage]) / 6.0
	var control_a = (a+tangent_a).clamp(Vector2(85,108),Vector2(1155,646))
	var control_b = (b-tangent_b).clamp(Vector2(85,108),Vector2(1155,646))
	if stage == 11 and int(from.get("layout_version",1)) >= 2:
		# Curl below the inner branches before reaching the guardian; direct
		# diagonals here would cut across paths from the preceding layer.
		control_a = Vector2(a.x+80,456)
		control_b = Vector2(b.x+140,456)
	var points = PackedVector2Array()
	for i in range(17): points.append(a.bezier_interpolate(control_a,control_b,b,i/16.0))
	return points
