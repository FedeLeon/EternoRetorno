extends Control
# Small biome particles behind the actors. Independent of adventure RNG/state.
var floor_number = 1
var elapsed = 0.0

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	size = Vector2(1280,720)
	if preload("res://src/presentation/preferences.gd").low_quality(): set_process(false)

func _process(delta: float) -> void:
	elapsed += delta
	queue_redraw()

func _draw() -> void:
	if preload("res://src/presentation/preferences.gd").low_quality(): return
	var tint = Color("ffad59") if floor_number==3 else Color("7ac8aa") if floor_number==2 else Color("6bd5e0")
	for i in range(24):
		var x = fmod(91.0*i+sin(elapsed*0.3+i)*17+elapsed*(6 if floor_number==2 else 2),1280)
		var y = 470-fmod(i*61.0+elapsed*(14 if floor_number==3 else 4),350)
		var point = Vector2(x,y)
		var color = tint
		color.a = 0.12+0.16*pow(sin(elapsed*0.65+i),2)
		if floor_number==2:
			draw_line(point,point+Vector2(3,sin(elapsed+i)*3),color,2,true)
		else:
			draw_circle(point,1.0+i%2,color)
			if floor_number==3: draw_circle(point,4,Color(color,color.a*0.12))
