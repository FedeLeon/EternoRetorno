extends Control
## Inked panel margins and small halftone corners. Never consumes input.
var impact = false
var from_right = false
var floor_number = 1
var accent = Color("74638e")

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	resized.connect(queue_redraw)

func _draw() -> void:
	if size.x < 1 or size.y < 1: return
	if impact:
		_draw_impact()
	else:
		var box = Rect2(4,3,size.x-8,size.y-7)
		draw_rect(box,Color(0.015,0.018,0.03,0.9),false,6)
		draw_rect(box.grow(-0.5),Color(0.95,0.94,0.88,0.85),false,1.3)
		for corner in [Vector2(6,5),Vector2(size.x-6,5),Vector2(6,size.y-6),size-Vector2(6,6)]:
			var direction = Vector2(1 if corner.x<size.x/2 else -1,1 if corner.y<size.y/2 else -1)
			var triangle = PackedVector2Array([corner,corner+Vector2(direction.x*38,0),corner+Vector2(0,direction.y*25)])
			draw_colored_polygon(triangle,Color(0.025,0.03,0.045,0.72))
			for row in range(3):
				for col in range(4-row):
					draw_circle(corner+Vector2(direction.x*(4+col*6),direction.y*(4+row*6)),0.7,Color(0.92,0.9,0.84,0.3))

func _draw_impact() -> void:
	var mirror = -1.0 if from_right else 1.0
	var edge = size.x if from_right else 0.0
	# A narrow slanted gutter suggests an inset action panel, behind the cutout.
	var top = Vector2(edge + mirror * size.x * 0.65,size.y*0.37)
	var bottom = Vector2(edge + mirror * size.x * 0.50,size.y)
	draw_line(top,bottom,Color(0.015,0.02,0.04,0.7),8,true)
	draw_line(top,bottom,Color(1.0,0.98,0.91,0.75),2,true)
	var corner = Vector2(edge+mirror*15,size.y*0.57)
	var reduced = preload("res://src/presentation/preferences.gd").low_quality()
	for row in range(5 if reduced else 9):
		for col in range(10-row):
			var point = corner+Vector2(mirror*col*12,row*12)
			draw_circle(point,1.0+row*0.08,Color(accent,0.17))
	for i in range(4):
		var a = Vector2(edge+mirror*(18+i*28),size.y*0.42+i*7)
		draw_line(a,a+Vector2(mirror*(50+i*12),-12),Color(1.0,0.98,0.91,0.55),1.5,true)
