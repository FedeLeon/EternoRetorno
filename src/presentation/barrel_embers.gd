extends Node2D

# Fixed mouth over the existing barrel; only light and embers move.
var elapsed = 0.0

func _process(delta: float) -> void:
	elapsed += delta
	queue_redraw()

func _draw() -> void:
	var pulse = 0.88 + 0.07 * sin(elapsed * 2.1) + 0.05 * sin(elapsed * 3.7)
	# The complete sprite already contains rim and coals; never paint a lid over it.
	for radius in [30, 21, 12]:
		draw_set_transform(Vector2(0, -96), 0, Vector2(1, 0.55))
		draw_circle(Vector2.ZERO, radius, Color(1, 0.35, 0.06, 0.035 * pulse))
	draw_set_transform(Vector2.ZERO)
	for i in range(18):
		var age = fmod(elapsed * (0.20 + (i % 5) * 0.019) + i * 0.137, 1.0)
		var x = sin(i * 7.1) * 22 + sin(age * 4 + i) * age * 16
		var point = Vector2(x, -94 - age * (85 + i % 4 * 18))
		var opacity = sin(age * PI) * 0.9
		draw_circle(point, 3.5, Color(1, 0.35, 0.02, opacity * 0.10))
		draw_line(point, point + Vector2(0.6, -2.3), Color(1, 0.69, 0.22, opacity), 1.4, true)
