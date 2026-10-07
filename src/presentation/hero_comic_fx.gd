extends Control
## Lightweight analytic particles: no gameplay RNG, textures, timers or persistence.
var area = Rect2()
var elapsed = 0.0
var accent = Color.WHITE
var defensive = false

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	var additive = CanvasItemMaterial.new()
	additive.blend_mode = CanvasItemMaterial.BLEND_MODE_ADD
	material = additive

func present(bounds: Rect2, time: float, color: Color, is_defense: bool) -> void:
	area = bounds
	elapsed = time
	accent = color
	defensive = is_defense
	queue_redraw()

func _draw() -> void:
	if area.size.y <= 0.0: return
	var unit = area.size.y
	var origin = area.position + area.size * Vector2(0.70, 0.43)
	var impact = exp(-pow((elapsed - 0.39) / 0.065, 2.0))
	var charge = sin(clampf(elapsed / 0.72, 0.0, 1.0) * PI)
	# Small nested glows stay local to the weapon; never a full-screen flash.
	var reduced = preload("res://src/presentation/preferences.gd").low_quality()
	for ring in range(3 if reduced else 7, 0, -1):
		draw_circle(origin, unit * (0.025 + ring * 0.017), Color(accent, (0.008 * charge + 0.015 * impact)))
	if elapsed >= 0.32:
		var age = elapsed - 0.32
		var radius = unit * (0.035 + age * 0.52)
		var opacity = maxf(0.0, 1.0 - age / 0.34)
		var start = -1.25 if defensive else -0.75
		var end = 1.25 if defensive else 0.65
		draw_arc(origin, radius, start, end, 28, Color(accent, opacity * 0.5), 2.0, true)
		draw_arc(origin, radius * 0.89, start + 0.1, end - 0.1, 28, Color(accent, opacity * 0.2), 1.0, true)
	# Staggered emission, acceleration, fading trails and luminous cores.
	for i in range(12 if reduced else 48):
		var birth = 0.12 + float((i * 17) % 31) * 0.010
		var age = elapsed - birth
		var lifetime = 0.17 + float(i % 5) * 0.043
		if age < 0.0 or age > lifetime: continue
		var phase = age / lifetime
		var alpha = sin(phase * PI) * (0.45 + impact * 0.3)
		var angle = float(i) * 2.399963 if defensive else -1.15 + float((i * 7) % 29) / 28.0 * 2.3
		var direction = Vector2.from_angle(angle)
		var velocity = direction * unit * (0.22 + float(i % 7) * 0.06)
		var spread = Vector2(sin(i * 1.7), cos(i * 2.3)) * unit * 0.028
		var point = origin + spread + velocity * age + Vector2(0, age * age * unit * 0.18)
		var radius = (1.0 + i % 3) * (1.0 - phase * 0.7)
		var tail = velocity.normalized() * (5.0 + i % 9) * (1.0 - phase)
		draw_line(point - tail, point, Color(accent, alpha * 0.6), radius, true)
		draw_circle(point, radius * 2.6, Color(accent, alpha * 0.065))
		draw_circle(point, radius, Color(accent.lerp(Color.WHITE, 0.5), alpha))
		if i % 6 == 0:
			var ray = radius * 3.0
			draw_line(point - Vector2(ray, 0), point + Vector2(ray, 0), Color(accent, alpha * 0.5), 1.0, true)
			draw_line(point - Vector2(0, ray), point + Vector2(0, ray), Color(accent, alpha * 0.5), 1.0, true)
