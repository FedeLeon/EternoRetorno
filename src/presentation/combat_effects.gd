extends RefCounted
# Visual effects only: committed gameplay and saves are never changed here.
static func attack_flash(parent: Control) -> void:
	var light = ColorRect.new()
	light.name = "AttackFlash"
	light.color = Color(1, 1, 1, 0.18 * preload("res://src/presentation/preferences.gd").flashes())
	light.size = Vector2(1280, 720)
	light.mouse_filter = Control.MOUSE_FILTER_IGNORE
	light.z_index = 100
	parent.add_child(light)
	var fade = light.create_tween()
	fade.tween_property(light, "color:a", 0.0, 0.14)
	fade.tween_callback(light.queue_free)

static func leave_room(parent: Control, actors: Array) -> void:
	# Both actors run out together using actual alternating-limb sprite frames.
	var travel = parent.create_tween().set_parallel(true)
	for i in range(actors.size()):
		var actor = actors[i]
		preload("res://src/presentation/hero_run.gd").start(actor)
		actor.z_index = 30
		var end_x = actor.position.x + 1460 - actor.global_position.x
		travel.tween_property(actor, "position:x", end_x, 2.5 + i * 0.12)
	await travel.finished
