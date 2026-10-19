extends RefCounted
## Shared paper outline. Frame bounds are updated from resources, never image pixels.
const SHADER = preload("res://assets/shaders/comic_outline.gdshader")
static var cache: Dictionary = {}

static func is_baked(texture: Texture2D) -> bool:
	if texture == null: return false
	var source = texture.atlas if texture is AtlasTexture else texture
	return preload("res://src/data/json_catalog.gd").dictionary("res://data/comic_art.json").get("baked",{}).has(source.resource_path.trim_prefix("res://"))

static func region(texture: Texture2D) -> Vector4:
	if texture is AtlasTexture:
		var area: Rect2 = texture.region
		var dimensions: Vector2 = texture.atlas.get_size()
		return Vector4(area.position.x/dimensions.x,area.position.y/dimensions.y,area.size.x/dimensions.x,area.size.y/dimensions.y)
	return Vector4(0,0,1,1)

static func material_for(texture: Texture2D) -> ShaderMaterial:
	if texture == null: return null
	if is_baked(texture): return null
	var area = region(texture)
	var key = str(texture.get_rid()) + str(area)
	if cache.has(key): return cache[key]
	var material = ShaderMaterial.new()
	material.shader = SHADER
	configure(material,texture)
	material.set_shader_parameter("cutout_width",1.0)
	if cache.size() >= 128: cache.erase(cache.keys()[0])
	cache[key] = material
	return material

static func configure(material: ShaderMaterial, texture: Texture2D) -> void:
	if texture == null: return
	var source = texture.atlas if texture is AtlasTexture else texture
	material.set_shader_parameter("cutout_source",source)
	material.set_shader_parameter("cutout_texel",Vector2.ONE/source.get_size())
	material.set_shader_parameter("cutout_region",region(texture))
	material.set_shader_parameter("cutout_enabled",not is_baked(texture))

static func attach_sprite(sprite: Node2D) -> void:
	var texture: Texture2D
	if sprite is AnimatedSprite2D:
		if sprite.sprite_frames.has_animation(sprite.animation) and sprite.frame < sprite.sprite_frames.get_frame_count(sprite.animation):
			texture = sprite.sprite_frames.get_frame_texture(sprite.animation,sprite.frame)
	else: texture = sprite.texture
	if texture == null: return
	if is_baked(texture) and sprite.material == null: return
	if sprite.material == null:
		var material = ShaderMaterial.new(); material.shader = SHADER
		sprite.material = material
	if not sprite.has_meta("comic_frame_binding"):
		sprite.set_meta("comic_frame_binding",true)
		sprite.frame_changed.connect(func(): update_frame(sprite))
		if sprite is AnimatedSprite2D:
			sprite.animation_changed.connect(func(): update_frame(sprite))
			sprite.sprite_frames_changed.connect(func(): update_frame(sprite))
		else: sprite.texture_changed.connect(func(): update_frame(sprite))
	update_frame(sprite)

static func update_frame(sprite: Node2D) -> void:
	if not sprite.material is ShaderMaterial: return
	var material: ShaderMaterial = sprite.material
	var path = material.shader.resource_path
	if path not in [SHADER.resource_path,"res://assets/shaders/detailed_equipment.gdshader"]: return
	var area = Vector4(0,0,1,1)
	if sprite is AnimatedSprite2D:
		if not sprite.sprite_frames.has_animation(sprite.animation): return
		if sprite.frame >= sprite.sprite_frames.get_frame_count(sprite.animation): return
		var texture = sprite.sprite_frames.get_frame_texture(sprite.animation,sprite.frame)
		bind_source(sprite,material,texture)
		area = region(texture)
	elif sprite is Sprite2D:
		bind_source(sprite,material,sprite.texture)
		area = Vector4(float(sprite.frame_coords.x)/sprite.hframes,float(sprite.frame_coords.y)/sprite.vframes,1.0/sprite.hframes,1.0/sprite.vframes)
	material.set_shader_parameter("cutout_region",area)

static func bind_source(sprite: Node2D, material: ShaderMaterial, texture: Texture2D) -> void:
	if texture == null: return
	var source = texture.atlas if texture is AtlasTexture else texture
	var key = str(material.get_rid()) + str(source.get_rid())
	if sprite.get_meta("comic_source_binding", "") == key: return
	sprite.set_meta("comic_source_binding",key)
	configure(material,texture)
