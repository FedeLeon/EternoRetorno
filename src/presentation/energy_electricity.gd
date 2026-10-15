extends Control
## Peripheral electricity: the central energy number remains unobstructed.
const Preferences = preload("res://src/presentation/preferences.gd")
var energy = 3
var elapsed = 0.0
var discharge = 0.0

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE

func update_energy(amount: int) -> void:
	if amount < energy: discharge = 0.45
	energy = amount
	queue_redraw()

func _process(delta: float) -> void:
	elapsed += delta
	discharge = maxf(0, discharge - delta)
	queue_redraw()

func _draw() -> void:
	var strength = Preferences.flashes()
	if strength <= 0 or (energy <= 0 and discharge <= 0): return
	var intensity = strength * (0.65 + 0.35 * minf(energy / 3.0, 1.0))
	var count = 4 if Preferences.low_quality() else 12
	# Sparks leave the side tubes, never the number window.
	for i in range(count):
		var phase = fmod(elapsed * (0.5 + (i % 3) * 0.07) + i * 0.173, 1.0)
		var side = -1.0 if i % 2 == 0 else 1.0
		var x = 70 + side * (62 + phase * 10)
		var y = 98 - phase * 70 + sin(i * 4.3) * 8
		var point = Vector2(x, y)
		var opacity = sin(phase * PI) * intensity
		draw_circle(point, 3, Color(0.16, 0.75, 1, opacity * 0.12))
		draw_line(point, point + Vector2(side * 1.4, -2.8), Color(0.58, 0.95, 1, opacity), 1.2, true)
	# Short staggered arcs cling to the outside edge, with a soft cyan halo.
	for i in range(4):
		var cycle = fmod(elapsed * 0.9 + i * 0.29, 1.0)
		if cycle > 0.32 and discharge <= 0: continue
		var x = 8.0 if i % 2 == 0 else 132.0
		var y = 44.0 + (i / 2) * 40.0
		var phase = floorf(elapsed * 14) + i * 7
		var points = PackedVector2Array()
		for step in range(6):
			var bend = sin(phase * 2.3 + step * 4.8) * 4 if step in [1, 2, 3, 4] else 0.0
			points.append(Vector2(x + bend, y + step * 4))
		var opacity = intensity * (0.6 if discharge > 0 else sin(cycle / 0.32 * PI))
		draw_polyline(points, Color(0.1, 0.55, 1, opacity * 0.13), 7, true)
		draw_polyline(points, Color(0.18, 0.83, 1, opacity * 0.65), 2.8, true)
		draw_polyline(points, Color(0.8, 0.98, 1, opacity), 1, true)
