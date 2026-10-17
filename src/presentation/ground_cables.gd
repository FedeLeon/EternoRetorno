extends Control
## Flat restraint cables on the ground. Visual only; no combat rules or RNG.
var elapsed = 0.0
var redraw_clock = 0.0

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE

func _process(delta: float) -> void:
	elapsed += delta
	redraw_clock += delta
	var interval = 1.0 / (15.0 if preload("res://src/presentation/preferences.gd").low_quality() else 30.0)
	if redraw_clock >= interval:
		redraw_clock = fmod(redraw_clock,interval)
		queue_redraw()

func cable_paths() -> Array[PackedVector2Array]:
	var paths: Array[PackedVector2Array] = []
	for row in range(3):
		var points = PackedVector2Array()
		for i in range(7):
			points.append(Vector2(4+i*(size.x-8)/6.0,2+row*2+(0.4 if (i+row)%2 else -0.4)))
		paths.append(points)
	return paths

func _draw() -> void:
	var paths = cable_paths()
	for row in range(paths.size()):
		var points = paths[row]
		draw_polyline(points,Color(0.03,0.05,0.07,0.9),3.5,true)
		draw_polyline(points,Color(0.36,0.43,0.47,0.95),1.5,true)
		# Short traveling electrical arcs, rather than a ring around the body.
		for spark in range(2):
			var t = fposmod(elapsed*0.27+row*0.23+spark*0.5,1.0)
			var start = Vector2(8+t*(size.x-30),points[0].y)
			var arc = PackedVector2Array([start,start+Vector2(4,-1.2),start+Vector2(8,1.2),start+Vector2(13,0)])
			draw_polyline(arc,Color(0.14,0.68,0.89,0.2),3.0,true)
			draw_polyline(arc,Color(0.57,0.94,1.0,0.65+0.25*sin(elapsed*7+row)),0.8,true)
	for x in [0.0,size.x-4]:
		draw_rect(Rect2(x,1,4,6),Color("293740"))
		draw_line(Vector2(x,1),Vector2(x+4,1),Color("81949b"),1)
