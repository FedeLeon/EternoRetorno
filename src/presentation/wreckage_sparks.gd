extends Node2D
## Intermittent electrical discharge from a defeated machine, independent of its still art.
const Preferences = preload("res://src/presentation/preferences.gd")
var actor: Control
var rng = RandomNumberGenerator.new()
var elapsed = 0.0
var next_discharge = 0.0
var burst_age = 1.0
var phase = 0.0

func _ready() -> void:
	top_level = true
	z_as_relative = false
	z_index = 75
	rng.randomize()
	refresh()

func refresh() -> void:
	var enabled = is_instance_valid(actor) and actor.fallen and not actor.hide_when_fallen and not actor.get_meta("scrap_disabled",false)
	set_process(enabled)
	if enabled:
		next_discharge = elapsed + rng.randf_range(.1,.7)
	else:
		burst_age = 1.0
	queue_redraw()

func _process(delta: float) -> void:
	elapsed += delta
	burst_age += delta
	if elapsed >= next_discharge:
		burst_age = 0.0
		phase = rng.randf_range(0,TAU)
		next_discharge = elapsed + rng.randf_range(1.2,2.8)
	if burst_age <= .35: queue_redraw()
	elif burst_age - delta <= .35: queue_redraw()

func _draw() -> void:
	if not is_instance_valid(actor) or not actor.fallen or burst_age > .35 or Preferences.flashes() <= 0: return
	var body: Rect2 = get_global_transform().affine_inverse() * (actor.get_global_transform() * actor.body_rect())
	var t = burst_age / .35
	var strength = sin(t*PI) * Preferences.flashes()
	for i in range(1 if Preferences.low_quality() else 3):
		var origin = body.position + body.size * Vector2(.26+i*.22,.42+sin(phase+i)*.12)
		var direction = Vector2.from_angle(phase+i*2.3)
		var length = minf(28,body.size.x*.16)*(1-t*.3)
		var points = PackedVector2Array([origin,origin+direction*length*.35+Vector2(3,-4),origin+direction*length*.7-Vector2(2,2),origin+direction*length])
		draw_polyline(points,Color("59d8ef",strength*.25),5.0,true)
		draw_polyline(points,Color("80e6ff",strength),2.5,true)
		draw_polyline(points,Color("fff4cd",strength),1.0,true)
		for ray in range(3):
			var outward = Vector2.from_angle(phase+ray*TAU/3+i)
			var point = origin+outward*(5+t*18)
			draw_line(point,point+outward*4,Color("ffd59b",strength*(1-t)),1.5,true)
