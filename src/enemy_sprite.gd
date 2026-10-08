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

static func entries() -> Dictionary:
	if catalog.is_empty():
		catalog = JSON.parse_string(FileAccess.get_file_as_string(CATALOG_PATH))
	return catalog

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	# Different silhouettes no longer flap or idle in perfect synchrony.
	clock = float(absi(visual_id.hash())%1000)/137.0
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	sprite = Sprite2D.new()
	var motion_path = "res://assets/enemies/animations/" + visual_id + ".png"
	has_motion_frames = ResourceLoader.exists(motion_path)
	sprite.texture = load(motion_path if has_motion_frames else "res://assets/enemies/hd/" + visual_id + ".png")
	sprite.hframes = 8 if has_motion_frames else 1
	sprite.offset = Vector2(0, -64)
	sprite.frame_changed.connect(_size_pose)
	add_child(sprite)
	resized.connect(_place)
	_place()
	set_fallen(fallen)

func _place() -> void:
	base_scale = maxf(1, floor(minf(size.x / 64, size.y / 52))) / 2.0
	sprite.position = Vector2(round(size.x / 2), size.y)
	sprite.scale = Vector2.ONE * base_scale
	_size_pose()

func _size_pose() -> void:
	if not has_motion_frames or sprite == null: return
	if pose_sizes.is_empty():
		pose_sizes = JSON.parse_string(FileAccess.get_file_as_string("res://data/enemy_pose_sizes.json"))
	var metrics: Dictionary = pose_sizes.get(visual_id, {})
	# Correction belongs to the drawn frame, not to the current action flag.
	# Reactions and ash playback can freeze the last rendered attack frame.
	var factor = float(metrics.get("scale", [1,1,1,1,1,1,1,1])[sprite.frame])
	var bottom = float(metrics.get("bottom", [120,120,120,120,120,120,120,120])[sprite.frame])
	sprite.scale = Vector2.ONE * base_scale * factor
	# Keep the original opaque foot baseline while correcting the drawn pose size.
	sprite.offset.y = 64-bottom + (bottom-128)/factor

func _process(delta: float) -> void:
	if acting or fallen or sprite == null:
		return
	clock += delta
	if has_motion_frames:
		sprite.frame = int(clock * (9.0 if entries()[visual_id].motion == "fly" else 6.0)) % int(entries()[visual_id].get("idle_frames", 8))
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
			sprite.modulate = Color(1.6, 0.5, 0.5)
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
	# Family-specific anticipation and impact, layered over the drawn motion poses.
	var origin = sprite.position
	var drawn_attack = has_motion_frames and int(entries()[visual_id].get("attack_frames", 0)) == 4
	if drawn_attack: sprite.frame = 4
	var reach = 16.0
	if visual_id == "crypt_lancer":
		reach = 24.0
	elif visual_id == "crypt_automaton":
		reach = 20.0
	tween.tween_property(sprite, "position:x", origin.x + 5, 0.10)
	if drawn_attack: tween.parallel().tween_property(sprite, "frame", 5, 0.10)
	match visual_id:
		"crypt_slime":
			if not drawn_attack: tween.parallel().tween_property(sprite, "scale", Vector2(1.12, 0.82) * base_scale, 0.10)
		"crypt_bat":
			tween.parallel().tween_property(sprite, "position:y", origin.y - 9, 0.10)
		"crypt_shaman":
			tween.parallel().tween_property(sprite, "modulate", Color(1.35, 1.1, 0.8), 0.10)
		"crypt_automaton", "skeleton_6":
			tween.parallel().tween_property(sprite, "rotation", 0.08, 0.10)
	tween.tween_property(sprite, "position:x", origin.x - reach, 0.12)
	if drawn_attack: tween.parallel().tween_property(sprite, "frame", 6, 0.12)
	match visual_id:
		"crypt_slime":
			if not drawn_attack: tween.parallel().tween_property(sprite, "scale", Vector2(0.9, 1.08) * base_scale, 0.12)
			tween.parallel().tween_property(sprite, "position:y", origin.y - 5, 0.12)
		"crypt_bat":
			tween.parallel().tween_property(sprite, "position:y", origin.y + 4, 0.12)
		"crypt_automaton", "skeleton_6":
			tween.parallel().tween_property(sprite, "rotation", -0.1, 0.12)
	tween.tween_callback(func():preload("res://src/presentation/actor_attack_trail.gd").echo(sprite))
	tween.tween_property(sprite, "position", origin, 0.16).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	if drawn_attack: tween.parallel().tween_property(sprite, "frame", 7, 0.16)
	if not drawn_attack: tween.parallel().tween_property(sprite, "scale", Vector2.ONE * base_scale, 0.16)
	tween.parallel().tween_property(sprite, "rotation", 0.0, 0.16)
	tween.parallel().tween_property(sprite, "modulate", Color.WHITE, 0.16)
