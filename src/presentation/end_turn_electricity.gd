extends Control
## Shared cyan rim arcs for circular or square controls; keep the centre clear.
const Preferences = preload("res://src/presentation/preferences.gd")
var elapsed = 0.0
var rectangular = false

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE

func _process(delta: float) -> void:
	elapsed += delta
	queue_redraw()

func _draw() -> void:
	var button = get_parent() as Button
	var strength = Preferences.flashes()
	if button == null or button.disabled or strength <= 0: return
	var radius = minf(size.x, size.y) * 0.45
	var intensity = strength * (1.0 if button.is_hovered() or button.has_focus() else 0.75)
	for i in range(1 if Preferences.low_quality() else 3):
		var cycle = fmod(elapsed * 0.7 + i * 0.31, 1.0)
		if cycle > 0.42: continue
		var start = i * TAU / 3 + elapsed * 0.22
		var points = PackedVector2Array()
		for step in range(9):
			var angle = start + step * 0.055
			var jitter = sin(floorf(elapsed * 12) * 2.7 + step * 5.1 + i) * 2.2
			if step == 0 or step == 8: jitter = 0
			points.append(rim_point(angle, radius) + Vector2.from_angle(angle) * jitter)
		var opacity = sin(cycle / 0.42 * PI) * intensity
		draw_polyline(points, Color(0.12, 0.57, 1, opacity * 0.13), 7, true)
		draw_polyline(points, Color(0.16, 0.85, 1, opacity * 0.7), 2.8, true)
		draw_polyline(points, Color(0.8, 0.98, 1, opacity), 1, true)
	for i in range(4 if Preferences.low_quality() else 12):
		var phase = fmod(elapsed * (0.4 + (i % 3) * 0.05) + i * 0.177, 1.0)
		var angle = i * 2.399 + phase * 0.22
		var direction = Vector2.from_angle(angle)
		var point = rim_point(angle, radius) + direction * phase * 10
		var opacity = sin(phase * PI) * intensity
		draw_circle(point, 3, Color(0.2, 0.75, 1, opacity * 0.10))
		draw_line(point, point + direction * 2, Color(0.6, 0.95, 1, opacity), 1.2, true)

func rim_point(angle: float, radius: float) -> Vector2:
	var direction = Vector2.from_angle(angle)
	if not rectangular: return size / 2 + direction * radius
	var extent = size / 2 - Vector2(8, 8)
	var distance = minf(extent.x / maxf(absf(direction.x), 0.0001), extent.y / maxf(absf(direction.y), 0.0001))
	return size / 2 + direction * distance
