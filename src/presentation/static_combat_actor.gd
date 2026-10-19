extends Control
## One TextureRect per action. No frame player, processing, Tween or body VFX.
const Catalog = preload("res://src/data/json_catalog.gd")
const Outline = preload("res://src/presentation/comic_outline.gd")
var sprite: TextureRect
var poses: Dictionary = {}
var current_action = "idle"
var fallen = false
var acting = false
var action_revision = 0
var gear: Dictionary = {}
var hide_when_fallen = false

func pose_catalog() -> Dictionary:
	return {}

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
	poses = pose_catalog()
	var idle: Dictionary = poses.idle
	set_meta("idle_height",float(idle.bounds[3])*float(idle.scale))
	sprite = TextureRect.new()
	sprite.name = "StaticIllustration"
	sprite.mouse_filter = Control.MOUSE_FILTER_IGNORE
	sprite.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	add_child(sprite)
	resized.connect(_place)
	set_process(false)
	set_fallen(fallen)

func canonical(action: String) -> String:
	if action in ["thrust","sweep","charged","heavy","bash"]: return "attack"
	if action in ["defense","block"]: return "guard"
	if action in ["poison","damage"]: return "hurt"
	if action in ["heal","revive"]: return "skill"
	return action if poses.has(action) else "idle"

func show_pose(action: String) -> void:
	current_action = canonical(action)
	sprite.texture = load(poses[current_action].path)
	sprite.visible = true
	sprite.modulate = Color("78e993") if action == "poison" else Color.WHITE
	apply_gear(gear)
	_place()

func _place() -> void:
	if sprite == null or sprite.texture == null: return
	var pose: Dictionary = poses[current_action]
	var factor = float(pose.scale)
	sprite.size = sprite.texture.get_size()
	sprite.scale = Vector2.ONE*factor
	sprite.position = Vector2(size.x*.5,size.y)-Vector2(pose.anchor[0],pose.anchor[1])*factor

func body_rect() -> Rect2:
	var b: Array = poses[current_action].bounds
	return Rect2(sprite.position+Vector2(b[0],b[1])*sprite.scale,Vector2(b[2],b[3])*sprite.scale)

func apply_gear(levels: Dictionary) -> void:
	gear = levels
	if sprite == null or sprite.texture == null: return
	var material = ShaderMaterial.new()
	material.shader = preload("res://assets/shaders/detailed_equipment.gdshader")
	material.set_shader_parameter("weapon_rank",float(gear.get("weapon",0)))
	material.set_shader_parameter("armor_rank",float(gear.get("armor",0)))
	Outline.configure(material,sprite.texture)
	sprite.material = material

func set_fallen(value: bool) -> void:
	action_revision += 1
	acting = false
	fallen = value
	if sprite == null: return
	show_pose("death" if value else "idle")
	sprite.visible = not (value and hide_when_fallen)

func begin_action(action: String) -> int:
	if fallen and action not in ["revive","death"]: return -1
	action_revision += 1
	acting = canonical(action) != "idle"
	if action == "revive": fallen = false
	if action == "death": fallen = true
	show_pose(action)
	return action_revision

func finish_action(revision: int) -> void:
	if revision != action_revision or fallen: return
	acting = false
	show_pose("idle")

func play_once(action: String) -> void:
	var revision = begin_action(action)
	if revision < 0 or current_action == "idle": return
	# A held illustration gives feedback without animating its pixels or transform.
	await get_tree().create_timer(.35 if action == "death" else .28).timeout
	if revision != action_revision: return
	if action == "death":
		acting = false
		sprite.visible = not hide_when_fallen
	else:
		finish_action(revision)

func replace_illustration(texture: Texture2D) -> void:
	var bounds = texture.get_image().get_used_rect()
	var pose = {"path":texture.resource_path,"scale":128.0/texture.get_height(),
		"anchor":[texture.get_width()*.5,bounds.end.y],
		"bounds":[bounds.position.x,bounds.position.y,bounds.size.x,bounds.size.y]}
	for action in poses.keys(): poses[action] = pose.duplicate(true)
	show_pose("idle")
