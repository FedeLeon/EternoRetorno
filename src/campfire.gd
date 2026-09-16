extends Control

const SHEET = preload("res://assets/camp/fire-64.png")
var flame: AnimatedSprite2D
var elapsed = 0.0

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	flame = AnimatedSprite2D.new()
	var frames = SpriteFrames.new()
	frames.set_animation_speed("default", 9.0)
	for i in range(6):
		var texture = AtlasTexture.new()
		texture.atlas = SHEET
		texture.region = Rect2(i * 64, 0, 64, 64)
		frames.add_frame("default", texture)
	flame.sprite_frames = frames
	flame.centered = false
	flame.scale = Vector2(3, 3)
	flame.position = Vector2(-96, -180)
	add_child(flame)
	flame.play()

func _process(delta: float) -> void:
	elapsed += delta
	queue_redraw()

func _draw() -> void:
	var pulse = 0.85 + 0.15 * sin(elapsed * 7.0)
	for radius in [105, 80, 55]:
		draw_set_transform(Vector2.ZERO, 0, Vector2(1, 0.3))
		draw_circle(Vector2.ZERO, radius, Color(1, 0.36, 0.06, 0.05 * pulse))
	draw_set_transform(Vector2.ZERO)
	for i in range(16):
		var age = fmod(elapsed * (0.31 + i * 0.006) + i * 0.173, 1.0)
		var x = sin(i * 7.1 + age * 5.0) * (10 + age * 27)
		var y = -32 - age * 164
		var side = 2 if i % 3 else 3
		draw_rect(Rect2(round(x), round(y), side, side), Color(1, 0.65, 0.19, (1 - age) * 0.85))
