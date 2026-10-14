extends Control

const SHEET = preload("res://assets/camp/fire-natural.png")
const COLUMNS = 6
const FRAME_COUNT = 24
const FPS = 12.0
var flame: AnimatedSprite2D
var elapsed = 0.0
var sheet: Texture2D = SHEET
var baselines: Array = preload("res://src/data/json_catalog.gd").dictionary("res://data/camp_fire_dusk.json").baselines
var fps = FPS
var sketch_style = true

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR if sketch_style else CanvasItem.TEXTURE_FILTER_NEAREST
	flame = AnimatedSprite2D.new()
	var frames = SpriteFrames.new()
	frames.set_animation_speed("default", fps)
	for i in range(FRAME_COUNT):
		var texture = AtlasTexture.new()
		texture.atlas = sheet
		var start = Vector2((i % COLUMNS) * 256, (i / COLUMNS) * 256)
		var end = start + Vector2(256, 256)
		texture.region = Rect2(start, end - start)
		frames.add_frame("default", texture)
	flame.sprite_frames = frames
	flame.centered = false
	flame.scale = Vector2.ONE * 0.75
	flame.position = Vector2(-96, -179.25)
	flame.frame_changed.connect(_align_base)
	add_child(flame)
	flame.play()
	_align_base()

func _align_base() -> void:
	# Ignore tiny detached sparks when measuring the stable base of each flame.
	flame.offset.y = 239 - baselines[flame.frame]

func _process(delta: float) -> void:
	elapsed += delta
	queue_redraw()

func _draw() -> void:
	var pulse = 0.92 + 0.08 * sin(elapsed * 2.4)
	for radius in [105, 80, 55]:
		draw_set_transform(Vector2.ZERO, 0, Vector2(1, 0.3))
		draw_circle(Vector2.ZERO, radius, Color(1, 0.36, 0.06, 0.05 * pulse))
	draw_set_transform(Vector2.ZERO)
	for i in range(8):
		var age = fmod(elapsed * (0.31 + i * 0.006) + i * 0.173, 1.0)
		var x = sin(i * 7.1 + age * 5.0) * (10 + age * 27)
		var y = -32 - age * 164
		var side = 1 if i % 3 else 2
		var tint = Color(1, 0.65, 0.19, (1 - age) * 0.65)
		if sketch_style:
			draw_line(Vector2(x,y), Vector2(x+side,y-3), tint, 1.0, true)
		else:
			draw_rect(Rect2(round(x), round(y), side, side), tint)
