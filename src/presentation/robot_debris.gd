extends Node
## Bounded cosmetic debris. No physics bodies, image readbacks, gameplay RNG or save fields.
const Preferences = preload("res://src/presentation/preferences.gd")
const MAX_PER_ROBOT = 24
const LOW_PER_ROBOT = 10
const BOUNCE_TIME = .22
var battle: Dictionary = {}
var anchors: Dictionary = {}
var particles: Array[Dictionary] = []
var damage_stages: Dictionary = {}
var health_seen: Dictionary = {}
var rng = RandomNumberGenerator.new()
var canvas: ScrapCanvas
var airborne_canvas: ScrapCanvas

class ScrapCanvas extends Node2D:
	var debris: Node
	var airborne = false
	func _draw() -> void:
		for piece in debris.particles:
			if (piece.time < piece.flight + debris.BOUNCE_TIME) != airborne: continue
			if not debris.anchors.has(piece.enemy): continue
			var anchor: Vector2 = debris.anchors[piece.enemy].floor
			var landed = clampf((piece.time - piece.flight) / debris.BOUNCE_TIME, 0.0, 1.0)
			var point: Vector2 = anchor + piece.position
			point.y = minf(point.y,anchor.y-lerpf(22,10,landed))
			# Ground shadows remain inside the reserved band above health/status rows.
			if piece.time >= piece.flight:
				draw_set_transform(anchor + piece.landing + Vector2(0,4), 0, Vector2(1,.23))
				draw_circle(Vector2.ZERO, 11 * piece.scale, Color(0.025,.025,.045,.45))
			var transform = Transform2D(piece.angle, Vector2.ONE * piece.scale, 0, Vector2.ZERO)
			var flatten = lerpf(1.0, .65, landed)
			transform.x.y *= flatten
			transform.y.y *= flatten
			transform.origin = point
			draw_set_transform_matrix(transform)
			match piece.kind:
				0: plate(piece.color)
				1: cable(piece.color)
				2: washer()
				3: bolt()
		draw_set_transform(Vector2.ZERO)

	func plate(color: Color) -> void:
		var points = PackedVector2Array([Vector2(-13,-7),Vector2(6,-9),Vector2(13,-2),Vector2(9,8),Vector2(-10,6)])
		draw_colored_polygon(points, color.darkened(.12))
		draw_polyline(points + PackedVector2Array([points[0]]), Color("e5dfca"), 3.2, true)
		draw_polyline(points + PackedVector2Array([points[0]]), Color("202636"), 1.5, true)
		draw_line(Vector2(-8,-4),Vector2(5,-6),Color("e7debd"),1.6,true)
		draw_circle(Vector2(7,1),2.3,Color("1b2331"))
		draw_line(Vector2(-5,1),Vector2(1,3),Color("394658"),1.3,true)

	func cable(color: Color) -> void:
		var points = PackedVector2Array([Vector2(-15,2),Vector2(-10,-3),Vector2(-3,-4),Vector2(3,3),Vector2(10,4),Vector2(16,0)])
		draw_polyline(points,Color("e4d9be"),5.2,true)
		draw_polyline(points,Color("171d2b"),3.7,true)
		draw_polyline(points,color,1.5,true)
		for x in [-1,1]:
			var tip = Vector2(x*16,0)
			draw_line(tip,tip+Vector2(x*3,-3),Color("d8a36d"),1.7,true)
			draw_line(tip,tip+Vector2(x*4,1),Color("f0c98a"),1.1,true)

	func washer() -> void:
		var points = PackedVector2Array()
		for i in range(12): points.append(Vector2.from_angle(i*TAU/12)*(10 if i%2 == 0 else 8))
		draw_colored_polygon(points,Color("677984"))
		draw_polyline(points+PackedVector2Array([points[0]]),Color("e1dfcd"),2.8,true)
		draw_polyline(points+PackedVector2Array([points[0]]),Color("1c2532"),1.3,true)
		draw_circle(Vector2.ZERO,4,Color("1b2530"))
		draw_arc(Vector2.ZERO,5,.2,2.5,8,Color("b7c2bc"),1.1,true)

	func bolt() -> void:
		draw_line(Vector2(-7,0),Vector2(9,0),Color("dfddca"),7,true)
		draw_line(Vector2(-7,0),Vector2(9,0),Color("283242"),4.5,true)
		draw_line(Vector2(-7,-1),Vector2(9,-1),Color("89989b"),2,true)
		draw_circle(Vector2(-7,0),5.5,Color("e0dfcd"))
		draw_circle(Vector2(-7,0),4,Color("3c4f5c"))
		for i in range(4): draw_line(Vector2(i*3,-2),Vector2(i*3-1,2),Color("bac0b5"),1,true)

static func bind(ui: Control) -> Node:
	var state = ui.get_node_or_null("RobotDebrisState")
	if state == null:
		state = new()
		state.name = "RobotDebrisState"
		ui.add_child(state)
	# Recompose controls freely, while keeping the same battle's cosmetic pieces.
	if not is_same(state.battle, ui.game.run.combat):
		state.battle = ui.game.run.combat
		state.particles.clear()
		state.damage_stages.clear()
		state.health_seen.clear()
	state.anchors.clear()
	state.canvas = ScrapCanvas.new()
	state.canvas.name = "RobotDebrisGround"
	state.canvas.debris = state
	ui.layer.add_child(state.canvas) # Added after background, before actors and HUD.
	state.airborne_canvas = ScrapCanvas.new()
	state.airborne_canvas.name = "RobotDebrisAirborne"
	state.airborne_canvas.debris = state
	state.airborne_canvas.airborne = true
	state.airborne_canvas.z_as_relative = false
	state.airborne_canvas.z_index = 70 # In front of bodies, below slashes/damage/cut-ins.
	ui.layer.add_child(state.airborne_canvas)
	state.canvas.queue_redraw()
	state.airborne_canvas.queue_redraw()
	return state

func _ready() -> void:
	rng.randomize()
	set_process(false)

func track(index: int, actor: Control) -> void:
	if actor.get_meta("scrap_disabled",false): return
	var body: Rect2 = actor.get_global_transform() * actor.body_rect()
	body = canvas.get_global_transform().affine_inverse() * body
	var floor_point = canvas.get_global_transform().affine_inverse() * (actor.get_global_transform() * Vector2(actor.size.x*.5,actor.size.y))
	anchors[index] = {"body":body, "floor":Vector2(body.get_center().x,floor_point.y)}
	# Damage from items/corrosion can return through a rebuild without hit playback.
	var hp = int(battle.enemies[index].hp)
	var previous = int(health_seen.get(index,hp))
	if hp < previous: burst(index,{"lost":previous-hp,"hp":hp})
	health_seen[index] = hp

func burst(index: int, event: Dictionary) -> void:
	var lost = maxi(0,int(event.get("lost",0)))
	if lost == 0 or not anchors.has(index): return
	var enemy: Dictionary = battle.enemies[index]
	var maximum = maxf(1.0, float(enemy.max_hp))
	var hp = int(event.get("hp",enemy.hp))
	health_seen[index] = hp
	var stage = clampi(floori((1.0 - float(hp)/maximum)*4),0,4)
	var count = clampi(2+ceili(lost/maximum*8)+maxi(0,stage-int(damage_stages.get(index,0))),2,6)
	damage_stages[index] = maxi(stage,int(damage_stages.get(index,0)))
	if Preferences.low_quality(): count = mini(count,2)
	var limit = LOW_PER_ROBOT if Preferences.low_quality() else MAX_PER_ROBOT
	while particles.filter(func(p): return p.enemy == index).size() + count > limit:
		var oldest = particles.find_custom(func(p): return p.enemy == index)
		particles.remove_at(oldest)
	var anchor: Vector2 = anchors[index].floor
	var body: Rect2 = anchors[index].body
	for i in range(count):
		var origin = body.position + body.size*Vector2(rng.randf_range(.25,.75),rng.randf_range(.42,.72)) - anchor
		var spread = rng.randf_range(25, minf(100,body.size.x*.45+30)) * (-1 if rng.randf() < .5 else 1)
		var landing_x = clampf(anchor.x+spread,556,1244)-anchor.x
		particles.append({
			"enemy":index, "kind":i if i < 2 else rng.randi_range(0,3),
			"origin":origin, "landing":Vector2(landing_x,rng.randf_range(-12,-8)),
			"position":origin, "time":0.0, "flight":rng.randf_range(.48,.8),
			"arc":rng.randf_range(30,65), "spin":rng.randf_range(-9,9),
			"start_angle":rng.randf_range(-PI,PI), "angle":0.0,
			"scale":rng.randf_range(.85,1.3),
			"color":[Color("b5774e"),Color("65868b"),Color("8b9291"),Color("aaa06d")][rng.randi_range(0,3)]
		})
	set_process(true)
	canvas.queue_redraw()
	airborne_canvas.queue_redraw()

func _process(delta: float) -> void:
	var active = false
	for piece in particles:
		if piece.time >= piece.flight+BOUNCE_TIME: continue
		piece.time += delta
		var phase = clampf(piece.time / piece.flight,0,1)
		piece.position = piece.origin.lerp(piece.landing,phase) - Vector2(0,sin(phase*PI)*piece.arc)
		piece.angle = piece.start_angle+piece.spin*minf(piece.time,piece.flight)
		if piece.time >= piece.flight:
			var bounce = clampf((piece.time-piece.flight)/BOUNCE_TIME,0,1)
			piece.position = piece.landing - Vector2(0,sin(bounce*PI)*7*(1-bounce))
		piece.position.y = maxf(piece.position.y,144-anchors.get(piece.enemy,{"floor":Vector2.ZERO}).floor.y)
		active = active or piece.time < piece.flight+BOUNCE_TIME
	if is_instance_valid(canvas): canvas.queue_redraw()
	if is_instance_valid(airborne_canvas): airborne_canvas.queue_redraw()
	set_process(active) # Settled debris costs no per-frame update/redraw.
