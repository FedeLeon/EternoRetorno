extends Control
## A subtle moving marker connects the current room to each available destination.
const Preferences = preload("res://src/presentation/preferences.gd")
var points = PackedVector2Array()
var distance = 0.0
var lengths: Array[float] = []
var total = 0.0
func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	for i in range(1,points.size()):
		total += points[i-1].distance_to(points[i])
		lengths.append(total)
	set_process(not Preferences.low_quality() and total > 0)
func _process(delta: float) -> void:
	distance = fmod(distance+delta*42,total)
	queue_redraw()
func _draw() -> void:
	if Preferences.low_quality() or total <= 0: return
	var previous = 0.0
	for i in range(lengths.size()):
		if distance <= lengths[i]:
			var t = (distance-previous)/maxf(0.001,lengths[i]-previous)
			var point = points[i].lerp(points[i+1],t)
			draw_circle(point,3.0,Color("766080"))
			draw_circle(point,1.2,Color("dfd3e9"))
			return
		previous = lengths[i]
