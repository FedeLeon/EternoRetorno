extends Node2D

# Fixed mouth over the existing barrel; only light and embers move.
var elapsed = 0.0

func _process(delta: float) -> void:
	elapsed += delta
	queue_redraw()

func _draw() -> void:
	var pulse = 0.88 + 0.07 * sin(elapsed * 2.1) + 0.05 * sin(elapsed * 3.7)
	# Cover the flame fragments baked into the original body's open top.
	draw_set_transform(Vector2(-6, -100), 0, Vector2(1, 0.19))
	draw_circle(Vector2.ZERO, 53, Color("211b25"))
	for radius in [47, 38, 28, 16]:
		draw_circle(Vector2.ZERO, radius, Color(1.0, 0.31, 0.035, 0.14 * pulse))
	draw_arc(Vector2.ZERO, 53, 0, PI, 36, Color("74574b"), 2, true)
	draw_set_transform(Vector2.ZERO)
	for i in range(13):
		var phase = float(i) * 2.399
		var coal = Vector2(-6 + sin(phase) * 38, -100 + cos(phase) * 5)
		draw_circle(coal, 1.4, Color(1, 0.40 + 0.12 * sin(elapsed * 2 + phase), 0.06, pulse))
	# Broad faint warmth above the opening, without any flame silhouettes.
	for radius in [54, 36, 20]:
		draw_set_transform(Vector2(-6, -112), 0, Vector2(1, 0.6))
		draw_circle(Vector2.ZERO, radius, Color(1, 0.35, 0.06, 0.025 * pulse))
	draw_set_transform(Vector2.ZERO)
	for i in range(18):
		var age = fmod(elapsed * (0.20 + (i % 5) * 0.019) + i * 0.137, 1.0)
		var x = -6 + sin(i * 7.1) * 28 + sin(age * 4 + i) * age * 22
		var point = Vector2(x, -101 - age * (85 + i % 4 * 18))
		var opacity = sin(age * PI) * 0.9
		draw_circle(point, 3.5, Color(1, 0.35, 0.02, opacity * 0.10))
		draw_line(point, point + Vector2(0.6, -2.3), Color(1, 0.69, 0.22, opacity), 1.4, true)
