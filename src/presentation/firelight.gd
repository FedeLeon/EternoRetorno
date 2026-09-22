extends RefCounted
# Shared warm light for seated hero artwork, with no geometry deformation.
static func attach(actor: TextureRect, phase: float = 0.0) -> void:
	var light = ShaderMaterial.new()
	light.shader = preload("res://assets/shaders/firelight.gdshader")
	light.set_shader_parameter("phase", phase)
	actor.material = light
