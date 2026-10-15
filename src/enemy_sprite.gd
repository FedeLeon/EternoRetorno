class_name EREnemySprite
extends Control

const CATALOG_PATH = "res://data/enemy_visuals.json"
static var catalog: Dictionary = {}
static var pose_sizes: Dictionary = {}
var visual_id = "crypt_bat"
var sprite: Sprite2D
var fallen = false
var acting = false
var clock = 0.0
var base_scale = 1.0
var tween: Tween
var has_motion_frames = false
var frame_size = 128.0

static func entries() -> Dictionary:
	if catalog.is_empty():
		catalog = preload("res://src/data/json_catalog.gd").dictionary(CATALOG_PATH)
	return catalog

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	# Different silhouettes no longer flap or idle in perfect synchrony.
	clock = float(absi(visual_id.hash())%1000)/137.0
	texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
	sprite = Sprite2D.new()
	var motion_path = "res://assets/enemies/animations/" + visual_id + ".png"
	has_motion_frames = ResourceLoader.exists(motion_path)
	sprite.texture = load(motion_path if has_motion_frames else "res://assets/enemies/hd/" + visual_id + ".png")
	sprite.hframes = 8 if has_motion_frames else 1
	frame_size = sprite.texture.get_height()
	sprite.offset = Vector2(0, -frame_size/2)
	sprite.frame_changed.connect(_size_pose)
	add_child(sprite)
	resized.connect(_place)
	_place()
	set_fallen(fallen)

func _place() -> void:
	base_scale = maxf(1, floor(minf(size.x / 64, size.y / 52))) / 2.0 * 128.0/frame_size
	sprite.position = Vector2(round(size.x / 2), size.y)
	sprite.scale = Vector2.ONE * base_scale
	_size_pose()

func _size_pose() -> void:
	if not has_motion_frames or sprite == null: return
	if pose_sizes.is_empty():
		pose_sizes = preload("res://src/data/json_catalog.gd").dictionary("res://data/enemy_pose_sizes.json")
	var metrics: Dictionary = pose_sizes.get(visual_id, {})
	# Correction belongs to the drawn frame, not to the current action flag.
	# Reactions and ash playback can freeze the last rendered attack frame.
	var factor = float(metrics.get("scale", [1,1,1,1,1,1,1,1])[sprite.frame])
	var bottom = float(metrics.get("bottom", [120,120,120,120,120,120,120,120])[sprite.frame]) * frame_size / float(metrics.get("frame_size",128))
	sprite.scale = Vector2.ONE * base_scale * factor
	# Keep the original opaque foot baseline while correcting the drawn pose size.
	sprite.offset.y = frame_size/2-bottom + (bottom-frame_size)/factor

func _process(delta: float) -> void:
	if acting or fallen or sprite == null:
		return
	clock += delta
	if has_motion_frames:
		var idle_frames = int(entries()[visual_id].get("idle_frames", 8))
		var step = int(clock * (7.0 if entries()[visual_id].motion == "fly" else 5.0))
		# Ping-pong avoids a sudden jump from the fourth pose back to the first.
		sprite.frame = [0,1,2,3,2,1][step % 6] if idle_frames == 4 else step % idle_frames
	var kind = entries()[visual_id].motion
	var wave = sin(clock * (4.5 if kind == "fly" else 2.6))
	# Bottom pivot keeps grounded feet fixed throughout breathing.
	if not has_motion_frames:
		sprite.scale = Vector2(base_scale * (1.0 + (0.025 * wave if kind == "ooze" else 0.0)), base_scale * (1.0 + wave * (0.04 if kind == "ooze" else 0.015)))
	sprite.position.y = size.y + (round(wave * 3) - 5 if kind == "fly" else 0)

func set_fallen(value: bool) -> void:
	fallen = value
	if sprite == null:
		return
	sprite.visible = not fallen
	sprite.modulate = Color.WHITE
	sprite.rotation = -PI / 2 if fallen else 0.0
	if not fallen:
		sprite.rotation = 0.0
		if has_motion_frames: sprite.frame = 0
		_place()

func play_once(animation: String) -> void:
	if fallen:
		return
	acting = true
	# Freeze the visible pose for damage/death instead of recalculating its size.
	if animation == "attack": _place()
	_size_pose()
	if animation == "death":
		await preload("res://src/presentation/enemy_ash.gd").play(self)
		acting = false
		set_fallen(true)
		return
	tween = create_tween()
	match animation:
		"attack":
			attack_motion()
		_:
			sprite.modulate = Color(0.5, 1.6, 0.5) if animation == "poison" else Color(1.6, 0.5, 0.5)
			tween.tween_property(sprite, "position:x", size.x / 2 + 7, 0.08)
			tween.tween_property(sprite, "position:x", size.x / 2, 0.12)
			tween.parallel().tween_property(sprite, "modulate", Color.WHITE, 0.12)
	await tween.finished
	# Return frame and scale together, before a following reaction can start.
	if animation == "attack" and has_motion_frames:
		sprite.frame = 0
	acting = false
	_size_pose()


func attack_motion() -> void:
	preload("res://src/presentation/enemy_motion.gd").play(self)
