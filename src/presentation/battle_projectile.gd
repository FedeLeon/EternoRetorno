extends Control
# Traveling effects accompany a committed hit. They never apply damage.
signal landed
var start: Vector2
var destination: Vector2
var tint: Color
var kind = "arrow"
var progress = 0.0

static func play(parent: Control, source: Control, target: Control, hero: String) -> Control:
	var effect = new()
	effect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	effect.z_index = 80
	var inverse = parent.get_global_transform().affine_inverse()
	effect.start = inverse * source.get_global_rect().get_center() + Vector2(34,-12)
	effect.destination = inverse * target.get_global_rect().get_center() + Vector2(0,-18)
	effect.tint = preload("res://src/presentation/hero_cut_in.gd").COLORS.get(hero,Color("e9cfa4"))
	effect.kind = "orb" if hero == "mage" else "slash"
	parent.add_child(effect)
	var tween = effect.create_tween()
	tween.tween_property(effect,"progress",1.0,0.23 if effect.kind != "slash" else 0.12)
	tween.tween_callback(func(): effect.landed.emit();effect.queue_free())
	return effect

func _process(_delta: float) -> void: queue_redraw()

func _draw() -> void:
	var point = start.lerp(destination,progress)
	var direction = (destination-start).normalized()
	var normal = direction.orthogonal()
	var trail = point - direction * (66 if kind == "arrow" else 38)
	for i in range(3): draw_line(trail,point,Color(tint,0.15 + i*0.12),9-i*3,true)
	if kind == "arrow":
		draw_line(point-direction*30,point,Color("e9e0d1"),2,true)
		draw_colored_polygon(PackedVector2Array([point+direction*12,point-direction*3+normal*6,point-direction*3-normal*6]),tint)
	elif kind == "orb":
		draw_circle(point,9,Color(tint,0.35));draw_circle(point,4,Color("f8f0e3"))
	else:
		draw_line(point-normal*22,point+normal*22,tint,3,true)
