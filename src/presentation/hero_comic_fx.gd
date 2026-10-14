extends Control
## Lightweight analytic particles: no gameplay RNG, textures, timers or persistence.
var area = Rect2()
var elapsed = 0.0
var accent = Color.WHITE
var defensive = false

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE

func present(bounds: Rect2, time: float, color: Color, is_defense: bool) -> void:
	area = bounds
	elapsed = time
	accent = color
	defensive = is_defense
	queue_redraw()

func _draw() -> void:
	if area.size.y <= 0.0: return
	draw_sketch_sparks()

func draw_sketch_sparks() -> void:
	var unit = area.size.y
	var origin = area.position + area.size * Vector2(0.70, 0.43)
	var reduced = preload("res://src/presentation/preferences.gd").low_quality()
	for i in range(10 if reduced else 28):
		var birth = 0.20 + float((i * 17) % 23) * 0.009
		var age = elapsed - birth
		var lifetime = 0.20 + float(i % 5) * 0.036
		if age < 0.0 or age > lifetime: continue
		var phase = age / lifetime
		var alpha = sin(phase * PI) * 0.65
		var angle = float(i) * 2.399963 if defensive else -1.0 + float((i * 7) % 29) / 28.0 * 2.1
		var direction = Vector2.from_angle(angle)
		var point = origin + direction * unit * (0.08 + age * (0.25 + (i % 7) * 0.05))
		var tail = direction * (5.0 + i % 11) * (1.0 - phase)
		# Broken pencil marks and crosshatching instead of smooth additive bloom.
		draw_line(point - tail, point - tail * 0.25, Color(accent, alpha), 1.0, true)
		draw_line(point - tail * 0.75 + Vector2(1, 2), point + Vector2(1, 2), Color("342c40", alpha * 0.6), 1.0, true)
		if i % 4 == 0:
			var cross = Vector2(-direction.y, direction.x) * 3
			draw_line(point - cross, point + cross, Color(accent.lightened(0.25), alpha), 1.0, true)
