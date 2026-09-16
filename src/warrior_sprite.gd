class_name ERWarriorSprite
extends Control

const SHEET = preload("res://assets/warrior/warrior-64.png")
const ROWS = {"idle": 0, "attack": 1, "heavy": 2, "hurt": 3, "death": 4}
const SPEEDS = {"idle": 6.0, "attack": 12.0, "heavy": 9.0, "hurt": 15.0, "death": 8.0}
static var frames_cache: SpriteFrames
var sprite: AnimatedSprite2D
var fallen = false

static func frames() -> SpriteFrames:
	if frames_cache != null:
		return frames_cache
	frames_cache = SpriteFrames.new()
	frames_cache.remove_animation("default")
	for animation in ROWS:
		frames_cache.add_animation(animation)
		frames_cache.set_animation_speed(animation, SPEEDS[animation])
		frames_cache.set_animation_loop(animation, animation == "idle")
		for index in range(6):
			var texture = AtlasTexture.new()
			texture.atlas = SHEET
			texture.region = Rect2(index * 64, ROWS[animation] * 64, 64, 64)
			frames_cache.add_frame(animation, texture)
	frames_cache.add_animation("revive")
	frames_cache.set_animation_speed("revive", 9.0)
	frames_cache.set_animation_loop("revive", false)
	for index in range(5, -1, -1):
		frames_cache.add_frame("revive", frames_cache.get_frame_texture("death", index))
	return frames_cache

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	sprite = AnimatedSprite2D.new()
	sprite.sprite_frames = frames()
	sprite.centered = false
	add_child(sprite)
	resized.connect(_place)
	_place()
	if fallen:
		set_fallen(true)
	else:
		sprite.play("idle")
		sprite.frame = int(Time.get_ticks_msec() / 167) % 6

func _place() -> void:
	# All frames share a fixed baseline. Integer scaling keeps pixels sharp.
	var factor = maxf(1.0, floor(minf(size.x / 64.0, size.y / 48.0)))
	sprite.scale = Vector2.ONE * factor
	sprite.position = Vector2(round((size.x - 64 * factor) / 2), round(size.y - 60 * factor))

func set_fallen(value: bool) -> void:
	fallen = value
	if sprite == null:
		return
	if fallen:
		sprite.play("death")
		sprite.pause()
		sprite.frame = 5
	else:
		sprite.play("idle")

func play_once(animation: String) -> void:
	if animation == "guard":
		var tween = create_tween()
		tween.tween_property(sprite, "modulate", Color(1.4, 1.05, 1.5), 0.14)
		tween.tween_property(sprite, "modulate", Color.WHITE, 0.22)
		await tween.finished
		return
	if not sprite.sprite_frames.has_animation(animation):
		return
	sprite.play(animation)
	sprite.frame = 0
	await sprite.animation_finished
	if animation == "death":
		set_fallen(true)
	else:
		fallen = false
		sprite.play("idle")
