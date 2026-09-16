class_name EREnemySprite
extends Control

const CATALOG_PATH = "res://data/enemy_visuals.json"
static var catalog: Dictionary = {}
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
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	sprite = Sprite2D.new()
	var motion_path = "res://assets/enemies/animations/" + visual_id + ".png"
	has_motion_frames = ResourceLoader.exists(motion_path)
	sprite.texture = load(motion_path if has_motion_frames else "res://assets/enemies/hd/" + visual_id + ".png")
	sprite.hframes = 8 if has_motion_frames else 1
	sprite.offset = Vector2(0, -64)
	add_child(sprite)
	resized.connect(_place)
	_place()
	set_fallen(fallen)

func _place() -> void:
	base_scale = maxf(1, floor(minf(size.x / 64, size.y / 52))) / 2.0
	sprite.position = Vector2(round(size.x / 2), size.y)
	sprite.scale = Vector2.ONE * base_scale

func _process(delta: float) -> void:
	if acting or fallen or sprite == null:
		return
	clock += delta
	if has_motion_frames:
		sprite.frame = int(clock * (9.0 if entries()[visual_id].motion == "fly" else 6.0)) % 8
	var kind = entries()[visual_id].motion
	var wave = sin(clock * (4.5 if kind == "fly" else 2.6))
	# Bottom pivot keeps grounded feet fixed throughout breathing.
	sprite.scale = Vector2.ONE * base_scale if has_motion_frames else Vector2(base_scale * (1.0 + (0.025 * wave if kind == "ooze" else 0.0)), base_scale * (1.0 + wave * (0.04 if kind == "ooze" else 0.015)))
	sprite.position.y = size.y + (round(wave * 3) - 5 if kind == "fly" else 0)

func set_fallen(value: bool) -> void:
	fallen = value
	if sprite == null:
		return
	sprite.modulate = Color(0.5, 0.5, 0.5, 0.35) if fallen else Color.WHITE
	sprite.rotation = -PI / 2 if fallen else 0.0
	sprite.scale = Vector2.ONE * base_scale * (0.6 if fallen else 1.0)

func play_once(animation: String) -> void:
	if fallen:
		return
	acting = true
	_place()
	tween = create_tween()
	match animation:
		"attack":
			attack_motion()
		"death":
			tween.set_parallel(true)
			tween.tween_property(sprite, "rotation", -PI / 2, 0.30)
			tween.tween_property(sprite, "scale", Vector2.ONE * base_scale * 0.6, 0.30)
			tween.tween_property(sprite, "modulate", Color(0.5, 0.5, 0.5, 0.35), 0.30)
		_:
			sprite.modulate = Color(1.6, 0.5, 0.5)
			tween.tween_property(sprite, "position:x", size.x / 2 + 7, 0.08)
			tween.tween_property(sprite, "position:x", size.x / 2, 0.12)
			tween.parallel().tween_property(sprite, "modulate", Color.WHITE, 0.12)
	await tween.finished
	acting = false
	if animation == "death":
		set_fallen(true)


func attack_motion() -> void:
	# Family-specific anticipation and impact, layered over the drawn motion poses.
	var origin = sprite.position
	var reach = 16.0
	if visual_id == "crypt_lancer":
		reach = 24.0
	elif visual_id == "crypt_automaton":
		reach = 20.0
	tween.tween_property(sprite, "position:x", origin.x + 5, 0.10)
	match visual_id:
		"crypt_slime":
			tween.parallel().tween_property(sprite, "scale", Vector2(1.12, 0.82) * base_scale, 0.10)
		"crypt_bat":
			tween.parallel().tween_property(sprite, "position:y", origin.y - 9, 0.10)
		"crypt_shaman":
			tween.parallel().tween_property(sprite, "modulate", Color(1.35, 1.1, 0.8), 0.10)
		"crypt_automaton", "skeleton_6":
			tween.parallel().tween_property(sprite, "rotation", 0.08, 0.10)
	tween.tween_property(sprite, "position:x", origin.x - reach, 0.12)
	match visual_id:
		"crypt_slime":
			tween.parallel().tween_property(sprite, "scale", Vector2(0.9, 1.08) * base_scale, 0.12)
			tween.parallel().tween_property(sprite, "position:y", origin.y - 5, 0.12)
		"crypt_bat":
			tween.parallel().tween_property(sprite, "position:y", origin.y + 4, 0.12)
		"crypt_automaton", "skeleton_6":
			tween.parallel().tween_property(sprite, "rotation", -0.1, 0.12)
	tween.tween_property(sprite, "position", origin, 0.16)
	tween.parallel().tween_property(sprite, "scale", Vector2.ONE * base_scale, 0.16)
	tween.parallel().tween_property(sprite, "rotation", 0.0, 0.16)
	tween.parallel().tween_property(sprite, "modulate", Color.WHITE, 0.16)
