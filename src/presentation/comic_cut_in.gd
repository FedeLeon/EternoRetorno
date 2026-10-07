extends Control
## Shared foreground comic animation; presentation only.
signal finished
const DURATION = 0.72
var texture_path: String
var from_right = false
var framing_scale = 1.0
var framing_offset = Vector2.ZERO # Relative to the viewport; adapter-owned framing.
var elapsed = 0.0
var accent: Color
var picture: TextureRect
var frame_grid = Vector2i.ONE
var frame_index = 0
var frame_texture: AtlasTexture
var enhanced_lights = false
var defensive_effect = false
var hero_fx: Control

func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	z_as_relative = false
	z_index = 150 # Above cards; below modal overlays (200).
	picture = TextureRect.new()
	picture.texture = load(texture_path)
	if frame_grid != Vector2i.ONE:
		frame_texture = AtlasTexture.new()
		frame_texture.atlas = picture.texture
		frame_texture.filter_clip = true
		picture.texture = frame_texture
		_update_frame()
	picture.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	picture.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	picture.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
	picture.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(picture)
	if enhanced_lights:
		hero_fx = preload("res://src/presentation/hero_comic_fx.gd").new()
		hero_fx.name = "HeroLights"
		add_child(hero_fx)
	_layout()
	resized.connect(_layout)
	modulate.a = 0.0

func _layout() -> void:
	if picture == null:
		return
	var height = minf(size.y * 0.72, size.x * 0.62 / 1.5) * framing_scale
	picture.size = Vector2(height * 1.5, height)
	picture.position = Vector2(_rest_x(), size.y - height + size.y * framing_offset.y)

func _process(delta: float) -> void:
	# First-use texture uploads or a slow frame must not skip the new hero poses.
	# Fade and lifetime follow this same visual clock, including on slow devices.
	elapsed += minf(delta, DURATION / (frame_grid.x * frame_grid.y) * preload("res://src/presentation/preferences.gd").speed()) if enhanced_lights else delta
	modulate.a = minf(clampf(elapsed / 0.10, 0.0, 1.0), clampf((DURATION - elapsed) / 0.16, 0.0, 1.0))
	# Frame animation and framing share the same clock.
	_update_frame()
	var entry = 1.0 - pow(1.0 - clampf(elapsed / 0.14, 0.0, 1.0), 3.0)
	picture.position.x = _rest_x() + (1.0 if from_right else -1.0) * (1.0 - entry) * picture.size.x * 0.7
	picture.pivot_offset = Vector2(picture.size.x if from_right else 0.0, picture.size.y)
	picture.scale = Vector2.ONE * (1.0 + minf(elapsed, DURATION) * 0.035)
	if enhanced_lights:
		# Brief highlights on the artwork itself; transparent pixels remain transparent.
		var flash = pow(maxf(0.0, sin(elapsed / DURATION * PI)), 6.0)
		picture.self_modulate = Color(1.0 + flash * 0.32, 1.0 + flash * 0.32, 1.0 + flash * 0.32)
		hero_fx.present(Rect2(picture.position, picture.size * picture.scale), elapsed, accent, defensive_effect)
	queue_redraw()
	if elapsed >= DURATION:
		finished.emit()
		queue_free()

func _draw() -> void:
	# Only streaks: no dimmer, opaque panel or frame over the dungeon.
	var area = Rect2(picture.position, picture.size)
	for i in range(5 if preload("res://src/presentation/preferences.gd").low_quality() else (14 if enhanced_lights else 22)):
		var y = area.position.y + fmod(i * 37.0, area.size.y)
		var travel = fmod(i * 173.0 + elapsed * 1200.0, area.size.x)
		var x = area.end.x - travel if from_right else area.position.x + travel
		var length = minf(60 + (i % 5) * 20, x - area.position.x if from_right else area.end.x - x)
		draw_line(Vector2(x, y), Vector2(x - length if from_right else x + length, y - 12), Color(accent, 0.65), 1 + i % 3)

func _rest_x() -> float:
	return (size.x * 0.985 - picture.size.x if from_right else size.x * 0.015) + size.x * framing_offset.x

func _update_frame() -> void:
	if frame_texture == null: return
	var count = frame_grid.x * frame_grid.y
	# Avoid rounding 12 * 0.045 down to frame 11, then jumping to 13.
	frame_index = mini(count - 1, int(elapsed / DURATION * count + 0.00001))
	var cell = frame_texture.atlas.get_size() / Vector2(frame_grid)
	frame_texture.region = Rect2(Vector2(frame_index % frame_grid.x, frame_index / frame_grid.x) * cell, cell)
