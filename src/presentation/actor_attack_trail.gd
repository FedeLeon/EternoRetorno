extends RefCounted
static func echo(source: Sprite2D) -> void:
	if preload("res://src/presentation/preferences.gd").low_quality(): return
	var ghost = Sprite2D.new()
	ghost.name = "AttackEcho"
	ghost.texture = source.texture
	ghost.hframes = source.hframes
	ghost.frame = source.frame
	ghost.offset = source.offset
	ghost.position = source.position
	ghost.scale = source.scale
	ghost.rotation = source.rotation
	ghost.modulate = Color(0.75,0.78,1.0,0.22)
	ghost.z_index = -1
	source.get_parent().add_child(ghost)
	var fade = ghost.create_tween()
	fade.tween_property(ghost,"modulate:a",0.0,0.16)
	fade.tween_callback(ghost.queue_free)
