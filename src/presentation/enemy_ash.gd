extends RefCounted
const DURATION = 1.0
static func play(actor: Control) -> void:
	var sprite: Sprite2D = actor.sprite
	var material = ShaderMaterial.new()
	material.shader = preload("res://assets/shaders/enemy_ash.gdshader")
	material.set_shader_parameter("frame_rect", Vector4(float(sprite.frame) / sprite.hframes, 0, 1.0 / sprite.hframes, 1))
	sprite.material = material
	sprite.modulate = Color.WHITE
	var ashes = CPUParticles2D.new()
	ashes.name = "EnemyAshParticles"
	ashes.position = Vector2(0, -55)
	ashes.emission_shape = CPUParticles2D.EMISSION_SHAPE_RECTANGLE
	ashes.emission_rect_extents = Vector2(28, 42)
	ashes.amount = 55
	ashes.lifetime = 0.65
	ashes.one_shot = true
	ashes.explosiveness = 0.1
	ashes.direction = Vector2(-0.25, -1)
	ashes.spread = 30
	ashes.gravity = Vector2(-12, -30)
	ashes.initial_velocity_min = 15
	ashes.initial_velocity_max = 40
	ashes.scale_amount_min = 0.8
	ashes.scale_amount_max = 1.6
	var gradient = Gradient.new()
	gradient.colors = PackedColorArray([Color("ffb56c"), Color("777177"), Color(0.3, 0.3, 0.3, 0)])
	ashes.color_ramp = gradient
	sprite.add_child(ashes)
	var tween = actor.create_tween()
	tween.tween_method(func(value): material.set_shader_parameter("progress", value), 0.0, 1.0, DURATION)
	tween.tween_interval(0.3)
	await tween.finished
	ashes.queue_free()
	sprite.material = null
	sprite.hide()
