extends RefCounted
# Visual effects only: committed gameplay and saves are never changed here.
static func attack_flash(parent: Control) -> void:
	var light = ColorRect.new()
	light.name = "AttackFlash"
	light.color = Color(1, 1, 1, 0.18)
	light.size = Vector2(1280, 720)
	light.mouse_filter = Control.MOUSE_FILTER_IGNORE
	light.z_index = 100
	parent.add_child(light)
	var fade = light.create_tween()
	fade.tween_property(light, "color:a", 0.0, 0.14)
	fade.tween_callback(light.queue_free)

static func leave_room(parent: Control, actors: Array) -> void:
	# Slower departure with a steady pose, forward lean and grounded strides.
	# Both actors exit together; a revived companion joins after recovery.
	var travel = parent.create_tween().set_parallel(true)
	for i in range(actors.size()):
		var actor = actors[i]
		actor.set_fallen(false)
		actor.sprite.speed_scale = 1.0
		actor.z_index = 30
		var start = actor.position
		var end_x = start.x + 1460 - actor.global_position.x
		travel.tween_method(func(t: float):
			actor.position = Vector2(lerpf(start.x, end_x, t), start.y - absf(sin(t * TAU * 7)) * 8)
			actor.rotation = 0.07 + sin(t * TAU * 7) * 0.025,
			0.0, 1.0, 2.5 + i * 0.12)
	await travel.finished
