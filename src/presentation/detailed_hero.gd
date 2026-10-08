extends Control
# Shared HD battlefield actor. No combat rules, persistence or body deformation.
var hero_id = "warrior"
var gear: Dictionary = {}
var sprite: AnimatedSprite2D
var fallen = false
static var cache: Dictionary = {}
const ACTIONS = ["idle","attack","skill","guard","hurt","death","run"]
func frames() -> SpriteFrames:
	if cache.has(hero_id): return cache[hero_id]
	if cache.size() >= 2: cache.erase(cache.keys()[0])
	var result = SpriteFrames.new();result.remove_animation("default")
	for action in ACTIONS + ["revive","heal","thrust","sweep","charged"]:
		var path = "res://assets/heroes/detail/%s_%s.png" % [hero_id,"death" if action=="revive" else "skill" if action=="heal" else action]
		if action in ["thrust","sweep","charged"]: path = "res://assets/heroes/actions/%s_%s.png" % [hero_id,action]
		if not ResourceLoader.exists(path): continue
		result.add_animation(action)
		result.set_animation_loop(action,action in ["idle","run"])
		result.set_animation_speed(action,10 if action=="idle" else (13 if action=="run" else 18))
		var sheet = load(path)
		for index in range(12):
			var i = 11-index if action=="revive" else index
			var texture = AtlasTexture.new();texture.atlas = sheet
			var cell: Vector2 = sheet.get_size()/Vector2(4,3)
			texture.region = Rect2(Vector2(i%4,i/4)*cell,cell)
			texture.filter_clip = true
			result.add_frame(action,texture)
	cache[hero_id] = result
	return result
func _ready() -> void:
	set_meta("hero_id",hero_id)
	set_meta("detailed",true)
	var metrics = JSON.parse_string(FileAccess.get_file_as_string("res://data/detailed_heroes.json"))
	set_meta("idle_height",metrics[hero_id].idle_height)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
	sprite = AnimatedSprite2D.new();sprite.centered=false;sprite.sprite_frames=frames()
	add_child(sprite);resized.connect(_place);sprite.animation_changed.connect(_place);_place()
	apply_gear(gear)
	set_fallen(fallen)
func _place() -> void:
	if sprite==null:return
	var texture = sprite.sprite_frames.get_frame_texture(sprite.animation,0)
	var cell: Vector2 = texture.get_size() if texture != null else Vector2(256,256)
	sprite.scale=Vector2(0.5,0.5)
	sprite.position=Vector2((size.x-cell.x*0.5)/2,size.y-(cell.y-16)*0.5)
func apply_gear(levels: Dictionary) -> void:
	gear=levels
	if sprite==null:return
	var material=ShaderMaterial.new();material.shader=preload("res://assets/shaders/detailed_equipment.gdshader")
	material.set_shader_parameter("weapon_rank",float(gear.get("weapon",0)))
	material.set_shader_parameter("armor_rank",float(gear.get("armor",0)))
	sprite.material=material
func set_fallen(value: bool) -> void:
	fallen=value
	if sprite==null:return
	if value:sprite.play("death");sprite.pause();sprite.frame=11
	else:sprite.play("idle")
func play_once(animation: String) -> void:
	var action="skill" if animation in ["heavy","bash","poison"] else animation
	if not sprite.sprite_frames.has_animation(action):return
	_blend_pose()
	sprite.play(action);sprite.frame=0
	if action in ["idle","run"]:return
	if action in ["attack","skill","guard","hurt","thrust","sweep","charged"]:
		preload("res://src/presentation/actor_sparks.gd").play(self,action,hero_id)
	await sprite.animation_finished
	if action=="death":set_fallen(true)
	else:
		fallen=false
		_blend_pose()
		sprite.play("idle")

func _blend_pose() -> void:
	if not sprite.sprite_frames.has_animation(sprite.animation): return
	var ghost = Sprite2D.new()
	ghost.centered = false
	ghost.texture = sprite.sprite_frames.get_frame_texture(sprite.animation, sprite.frame)
	ghost.position = sprite.position
	ghost.scale = sprite.scale
	ghost.material = sprite.material
	add_child(ghost)
	var tween = create_tween()
	tween.tween_property(ghost, "modulate:a", 0.0, 0.08)
	tween.tween_callback(ghost.queue_free)
