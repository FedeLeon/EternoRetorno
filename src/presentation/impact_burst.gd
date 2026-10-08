extends Control
# Deterministic local sparks and shock rings; no gameplay or global screen shake.
const Preferences = preload("res://src/presentation/preferences.gd")
var age = 0.0
var blocked = false
var heavy = false
var tint = Color("f6b985")

static func play(parent: Control, target: Control, event: Dictionary) -> Control:
	if Preferences.low_quality() or Preferences.flashes() <= 0: return null
	var burst = load("res://src/presentation/impact_burst.gd").new()
	burst.blocked = int(event.get("absorbed",0)) > 0 and int(event.get("lost",0)) == 0
	burst.heavy = int(event.get("damage",0)) >= 16
	burst.tint = Color("8dcfe5") if burst.blocked else Color("f4d98c") if event.get("pierce",false) else Color("f6b985")
	burst.name = "ImpactBurst"
	burst.position = target.get_global_rect().get_center()-parent.global_position
	burst.z_index = 85
	burst.mouse_filter = Control.MOUSE_FILTER_IGNORE
	parent.add_child(burst)
	return burst

func _process(delta: float) -> void:
	age += delta
	if age >= 0.48: queue_free()
	else: queue_redraw()

func _draw() -> void:
	var progress = age/0.48
	var color = tint
	color.a = (1-progress)*Preferences.flashes()
	var radius = 8+progress*(72 if heavy else 45)
	if blocked:
		draw_arc(Vector2.ZERO,radius,-2.5,0.4,24,color,3*(1-progress),true)
	else:
		for i in range(14 if heavy else 9):
			var angle = i*2.39996
			var vector = Vector2(cos(angle),sin(angle))
			var from = vector*radius+Vector2(0,progress*progress*22)
			draw_line(from,from+vector*(9*(1-progress)+2),color,2,true)
	if heavy: draw_arc(Vector2.ZERO,radius*0.7,0,TAU,40,Color(color,color.a*0.45),1.5,true)
