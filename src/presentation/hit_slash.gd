extends Control
## Short comic impact overlay. No body transforms, textures, game RNG or GPU particles.
const Preferences = preload("res://src/presentation/preferences.gd")
const DURATION = 0.42
var elapsed = 0.0
var reach = 80.0
var hit_index = 0
var blocked = false
var strength = 0.6
var spark_count = 12

static func play(parent: Control, target: Control, strike: int = 0, absorbed: bool = false) -> Control:
	if Preferences.flashes() <= 0.0: return null
	var body = target.body_rect() if target.has_method("body_rect") else Rect2(Vector2.ZERO, target.size)
	body = parent.get_global_transform().affine_inverse() * (target.get_global_transform() * body)
	var effect = new()
	effect.name = "HitSlash"
	effect.hit_index = strike
	effect.blocked = absorbed
	effect.strength = Preferences.flashes()
	effect.spark_count = 6 if Preferences.low_quality() else 12
	effect.reach = clampf(body.size.y * .48, 48.0, 110.0)
	effect.size = Vector2.ONE * effect.reach * 2.8
	effect.position = body.get_center() - effect.size * .5 - Vector2(0, body.size.y * .06)
	parent.add_child(effect)
	return effect

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	z_as_relative = false
	z_index = 80 # Over bodies, below damage numbers (90) and foreground art (150).
	add_to_group("hit_slash")

func _process(delta: float) -> void:
	elapsed += delta
	if elapsed >= DURATION:
		queue_free()
		return
	queue_redraw()

func _draw() -> void:
	var t = clampf(elapsed / DURATION, 0.0, 1.0)
	var origin = size * .5
	var direction = Vector2(.73, -.68 if hit_index % 2 == 0 else .68).normalized()
	var normal = Vector2(-direction.y, direction.x)
	var accent = Color("93dfff") if blocked else Color("ffd68b")
	var fade = pow(1.0 - t, 1.6) * strength
	# A tapered, fast-growing slash: colored light around a sharp ivory core.
	var head = origin + direction * reach * lerpf(-.65, 1.0, clampf(t / .20, 0.0, 1.0))
	var tail = origin - direction * reach * (1.0 - t * .35)
	var middle = tail.lerp(head, .60)
	for width in [13.0, 6.0, 2.5]:
		var color = Color(accent, fade * (.16 if width > 6 else .5)) if width > 3 else Color("fff9df", fade)
		draw_colored_polygon(PackedVector2Array([tail, middle + normal * width, head, middle - normal * width]), color)
		draw_line(tail, head, color, maxf(1.0, width * .25), true)
	# Analytic, staggered sparks share one drawing node and never consume rule RNG.
	for i in range(spark_count):
		var age = maxf(0.0, t - (i % 3) * .035)
		var angle = float(i) * 2.399963 + hit_index * .7
		var outward = Vector2.from_angle(angle)
		var point = origin + outward * reach * (.18 + age * (.95 + (i % 4) * .17)) + Vector2(0, age * age * 22)
		var trail = outward * (8 + (i % 4) * 4) * (1.0 - age * .5)
		var alpha = pow(1.0 - t, 1.4) * strength
		draw_line(point - trail, point, Color("25192a", alpha), 5.0, true)
		draw_line(point - trail, point, Color(accent, alpha), 3.5, true)
		draw_line(point - trail * .7, point, Color("fff9df", alpha), 1.5, true)
		draw_circle(point, 2.0, Color("fff9df", alpha))
		if i % 3 == 0:
			var side = Vector2(-outward.y, outward.x) * 2.5
			draw_line(point - side, point + side, Color("fff9df", alpha), 1.0, true)
