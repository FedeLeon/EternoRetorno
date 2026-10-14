extends Node
## Keeps a stable pose; only peripheral cloth/weapon pixels sway, never the body.
var actor: Control
var clock = 0.0
var material: ShaderMaterial

static func attach(owner_actor: Control, hero: String) -> void:
	preload("res://src/presentation/hero_grounding.gd").attach(owner_actor.sprite)
	var effect = new()
	effect.name = "SteadyIdle"
	effect.actor = owner_actor
	effect.material = ShaderMaterial.new()
	effect.material.shader = preload("res://assets/shaders/hero_idle.gdshader")
	effect.material.set_shader_parameter("phase", float(["warrior", "guardian", "rogue", "mage"].find(hero)))
	owner_actor.sprite.material = effect.material
	owner_actor.add_child(effect)
	effect._process(0.0)

func _process(delta: float) -> void:
	var sprite: AnimatedSprite2D = actor.sprite
	var active = sprite.animation == "idle" and not actor.fallen
	material.set_shader_parameter("enabled", 1.0 if active else 0.0)
	if not active:
		return
	sprite.pause()
	sprite.frame = 0
	clock += delta
	material.set_shader_parameter("clock", clock)
	var texture = sprite.sprite_frames.get_frame_texture("idle", 0) as AtlasTexture
	if texture != null:
		var atlas_size = texture.atlas.get_size()
		material.set_shader_parameter("frame_rect", Vector4(texture.region.position.x / atlas_size.x, texture.region.position.y / atlas_size.y, texture.region.size.x / atlas_size.x, texture.region.size.y / atlas_size.y))
