extends Node2D
# Snapshot the full card, including text and icons. Presentation only.
const DURATION = 0.85
var source: Control
var viewport: SubViewport

static func play(parent: Control, card: Control) -> Node2D:
	var effect = new()
	effect.name = "CardAsh"
	effect.source = card
	parent.add_child(effect)
	return effect

func _ready() -> void:
	z_index = 80
	transform = get_parent().get_global_transform().affine_inverse() * source.get_global_transform()
	viewport = SubViewport.new()
	viewport.size = Vector2i(source.size.ceil())
	viewport.transparent_bg = true
	viewport.disable_3d = true
	viewport.gui_disable_input = true
	viewport.render_target_update_mode = SubViewport.UPDATE_ONCE
	add_child(viewport)
	var copy = source.duplicate(0) as Control
	copy.position = Vector2.ZERO
	copy.rotation = 0
	copy.scale = Vector2.ONE
	copy.pivot_offset = Vector2.ZERO
	copy.modulate = Color.WHITE
	viewport.add_child(copy)
	source.hide()
	if DisplayServer.get_name() == "headless":
		await get_tree().create_timer(DURATION).timeout
		queue_free()
		return
	await RenderingServer.frame_post_draw
	if not is_instance_valid(source):
		queue_free()
		return
	var picture = Sprite2D.new()
	picture.texture = viewport.get_texture()
	picture.centered = false
	var material = ShaderMaterial.new()
	material.shader = preload("res://assets/shaders/card_ash.gdshader")
	picture.material = material
	add_child(picture)
	var ashes = CPUParticles2D.new()
	ashes.position = source.size * Vector2(0.5, 0.7)
	ashes.emission_shape = CPUParticles2D.EMISSION_SHAPE_RECTANGLE
	ashes.emission_rect_extents = source.size * Vector2(0.4, 0.23)
	ashes.amount = 55
	ashes.lifetime = 0.65
	ashes.one_shot = true
	ashes.explosiveness = 0.15
	ashes.direction = Vector2(0.3, -1)
	ashes.spread = 30
	ashes.gravity = Vector2(12, -38)
	ashes.initial_velocity_min = 25
	ashes.initial_velocity_max = 65
	ashes.scale_amount_min = 1.5
	ashes.scale_amount_max = 3.0
	var gradient = Gradient.new()
	gradient.colors = PackedColorArray([Color("ffb56c"), Color("7c7775"), Color(0.35, 0.33, 0.32, 0)])
	gradient.offsets = PackedFloat32Array([0, 0.25, 1])
	ashes.color_ramp = gradient
	add_child(ashes)
	var tween = create_tween()
	tween.tween_method(func(t): material.set_shader_parameter("progress", t), 0.0, 1.0, DURATION)
	tween.tween_interval(0.3)
	tween.tween_callback(queue_free)
