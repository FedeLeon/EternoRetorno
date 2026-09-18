extends Control
## Shared foreground comic animation; presentation only.
signal finished
const DURATION = 0.72
var texture_path: String
var from_right = false
var elapsed = 0.0
var accent: Color
var picture: TextureRect

func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	z_as_relative = false
	z_index = 150 # Above cards; below modal overlays (200).
	picture = TextureRect.new()
	picture.texture = load(texture_path)
	picture.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	picture.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	picture.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
	picture.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(picture)
	_layout()
	resized.connect(_layout)
	modulate.a = 0.0
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 1.0, 0.10)
	tween.tween_interval(0.46)
	tween.tween_property(self, "modulate:a", 0.0, 0.16)
	tween.tween_callback(func():
		finished.emit()
		queue_free())

func _layout() -> void:
	if picture == null:
		return
	var height = minf(size.y * 0.72, size.x * 0.62 / 1.5)
	picture.size = Vector2(height * 1.5, height)
	picture.position = Vector2(_rest_x(), size.y - height)

func _process(delta: float) -> void:
	elapsed += delta
	# Static illustration, dynamic framing: fast entry and restrained push-in.
	var entry = 1.0 - pow(1.0 - clampf(elapsed / 0.14, 0.0, 1.0), 3.0)
	picture.position.x = _rest_x() + (1.0 if from_right else -1.0) * (1.0 - entry) * picture.size.x * 0.7
	picture.pivot_offset = Vector2(picture.size.x if from_right else 0.0, picture.size.y)
	picture.scale = Vector2.ONE * (1.0 + minf(elapsed, DURATION) * 0.035)
	queue_redraw()

func _draw() -> void:
	# Only streaks: no dimmer, opaque panel or frame over the dungeon.
	var area = Rect2(picture.position, picture.size)
	for i in range(22):
		var y = area.position.y + fmod(i * 37.0, area.size.y)
		var travel = fmod(i * 173.0 + elapsed * 1200.0, area.size.x)
		var x = area.end.x - travel if from_right else area.position.x + travel
		var length = minf(60 + (i % 5) * 20, x - area.position.x if from_right else area.end.x - x)
		draw_line(Vector2(x, y), Vector2(x - length if from_right else x + length, y - 12), Color(accent, 0.65), 1 + i % 3)

func _rest_x() -> float:
	return size.x * 0.985 - picture.size.x if from_right else size.x * 0.015
