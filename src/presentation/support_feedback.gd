extends Control
## Local healing/guard particles, generated from confirmed differences only.
const Preferences = preload("res://src/presentation/preferences.gd")
var kind = "heal"
var age = 0.0
var tint = Color("91e6ae")
static func play(parent: Control, target: Control, effect: String) -> Control:
	if Preferences.low_quality() or Preferences.flashes() <= 0: return null
	var node = new()
	node.kind = effect
	node.tint = Color("9dd6f0") if effect == "block" else Color("91e6ae")
	node.mouse_filter = Control.MOUSE_FILTER_IGNORE
	node.z_index = 75
	node.position = parent.get_global_transform().affine_inverse() * target.get_global_rect().get_center()
	node.name = "SupportFeedback"
	parent.add_child(node)
	return node
func _process(delta: float) -> void:
	age += delta
	if age >= 0.65: queue_free()
	else: queue_redraw()
func _draw() -> void:
	var t = age / 0.65
	var color = Color(tint, sin(PI*t)*Preferences.flashes())
	if kind == "block":
		draw_arc(Vector2.ZERO,32+t*36,0.2,PI-0.2,24,color,2,true)
	for i in range(10):
		var x = sin(i*2.39996)*46
		var point = Vector2(x,22-t*75+(i%3)*12)
		if kind == "heal":
			draw_line(point-Vector2(3,0),point+Vector2(3,0),color,2,true)
			draw_line(point-Vector2(0,3),point+Vector2(0,3),color,2,true)
		else: draw_circle(point,1.7,color)
