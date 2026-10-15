extends Control
## Analytic comic light rays and sparks behind static artwork; no game RNG.
const Preferences = preload("res://src/presentation/preferences.gd")
var area = Rect2()
var elapsed = 0.0
var accent = Color.WHITE
var defensive = false
var from_right = false
var full_view_rays = false

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
	var strength = Preferences.flashes()
	if strength <= 0.0: return
	var phase = clampf(elapsed / 0.72, 0.0, 1.0)
	var envelope = sin(phase * PI) * strength
	var origin = area.position + area.size * Vector2(0.38 if from_right else 0.60, 0.48)
	var unit = area.size.y
	var reduced = Preferences.low_quality()
	# Broad rays extend beyond the silhouette; the dungeon remains visible between them.
	for i in range(8 if reduced else 16):
		var angle = float(i) * TAU / (8.0 if reduced else 16.0) + sin(elapsed * 2.0) * 0.07
		var reach = ray_reach(origin, unit, i)
		var width = 0.045 if defensive else 0.065
		var near = origin + Vector2.from_angle(angle) * unit * 0.12
		var tip = origin + Vector2.from_angle(angle) * reach * (0.85 + phase * 0.15)
		var edge = origin + Vector2.from_angle(angle + width) * reach
		draw_colored_polygon(PackedVector2Array([near, tip, edge]), Color(accent, envelope * 0.42))
		draw_line(near, tip, Color(accent.lightened(0.45), envelope * 0.85), 2.5, true)
	for i in range(6, 0, -1):
		draw_circle(origin, unit * (0.17 + i * 0.06), Color(accent, envelope * 0.025))
	if defensive:
		for i in range(2):
			var radius = unit * (0.43 + i * 0.13 + phase * 0.06)
			draw_arc(origin, radius, -2.7 + elapsed * 0.3, -0.25 + elapsed * 0.3, 40, Color(accent.lightened(0.25), envelope * 0.65), 2.5, true)
	for i in range(12 if reduced else 40):
		# Staggered births keep particles visible during the whole illustration.
		var birth = float((i * 17) % 31) * 0.012
		var age = elapsed - birth
		var lifetime = 0.32 + (i % 4) * 0.055
		if age <= 0 or age >= lifetime: continue
		var t = age / lifetime
		var angle = i * 2.399963
		var direction = Vector2.from_angle(angle)
		var point = origin + direction * unit * (0.38 + t * 0.65)
		var alpha = sin(t * PI) * strength
		draw_circle(point, 8.5, Color(accent, alpha * 0.2))
		draw_circle(point, 1.8, Color(accent.lightened(0.7), alpha))
		draw_line(point - direction * (8 + i % 8), point, Color(accent, alpha * 0.85), 2.0, true)
		if i % 3 == 0:
			var cross = Vector2(-direction.y, direction.x) * 3.5
			draw_line(point - cross, point + cross, Color.WHITE * Color(1, 1, 1, alpha), 1.5, true)

func ray_reach(origin: Vector2, unit: float, index: int) -> float:
	if not full_view_rays: return unit * (0.62 + (index % 4) * 0.12)
	# Cover the farthest viewport corner even at the shortest growth phase.
	# Both outer vertices remain off-screen, so no triangle cap is visible.
	var farthest = 0.0
	for corner in [Vector2.ZERO, Vector2(size.x,0), size, Vector2(0,size.y)]:
		farthest = maxf(farthest,origin.distance_to(corner))
	return (farthest + 32.0) / 0.85
