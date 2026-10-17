extends Control
## Lightweight weather behind actors; deterministic, no adventure RNG or textures.
const Preferences = preload("res://src/presentation/preferences.gd")
var floor_number = 1
var weather_variant = 0
var elapsed = 0.0
var draw_clock = 0.0

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	size = Vector2(1280,720)

func _process(delta: float) -> void:
	elapsed += delta
	draw_clock += delta
	if draw_clock >= 1.0 / (15.0 if Preferences.low_quality() else 30.0):
		draw_clock = fmod(draw_clock, 1.0 / (15.0 if Preferences.low_quality() else 30.0))
		queue_redraw()

func rainy() -> bool:
	return floor_number > 1 and weather_variant == 2

func particle_count() -> int:
	return 8 if Preferences.low_quality() else 24

func particle_position(index: int) -> Vector2:
	var gust = 32.0 + sin(elapsed * 0.4) * 8.0
	return Vector2(fposmod(index * 173.0 + elapsed * gust,1280),90+fposmod(index*47.0+sin(elapsed*0.8+index)*14+elapsed*7,310))

func _draw() -> void:
	var low = Preferences.low_quality()
	for i in range(particle_count()):
		var point = particle_position(i)
		if floor_number == 2:
			# Inked leaf silhouettes tumble in a shallow arc on the breeze.
			var angle = elapsed * (0.6 + (i%3)*0.15) + i
			var axis = Vector2.from_angle(angle) * (4.0 + i%3)
			var side = axis.orthogonal() * (0.3 + 0.3*absf(sin(elapsed+i)))
			var ink = Color("615c40") if i%2 else Color("596952")
			ink.a = 0.65
			draw_colored_polygon(PackedVector2Array([point-axis,point+side,point+axis,point-side]),ink)
			draw_line(point-axis,point+axis,Color(0.15,0.19,0.17,0.55),1)
		else:
			var tint = Color(0.77,0.43,0.28,0.35) if floor_number==3 else Color(0.58,0.67,0.70,0.26)
			draw_circle(point,1.0+i%2,tint)
	# A few quiet wind streaks, confined to the battlefield above the cards.
	for i in range(2 if low else 5):
		var point = Vector2(fposmod(i*281+elapsed*74,1420)-100,130+i*48)
		draw_line(point,point+Vector2(34, -2),Color(0.58,0.67,0.70,0.08),1,true)
	if rainy():
		for i in range(16 if low else 48):
			var point = Vector2(fposmod(i*97-elapsed*65,1280),80+fposmod(i*59+elapsed*310,304))
			draw_line(point,point+Vector2(-3,12),Color(0.57,0.69,0.76,0.19),1,true)
	elif floor_number == 1 and weather_variant == 2:
		# A leaking ceiling indoors, rather than outdoor rain in a sealed tunnel.
		for i in range(4):
			var point = Vector2(160+i*297,90+fposmod(i*61+elapsed*130,290))
			draw_line(point,point+Vector2(0,5),Color(0.56,0.72,0.76,0.18),1)
