extends Control
## Transparent foreground attack illustration. Receives only a hero ID and action; never changes gameplay or saves.
signal finished
const COLORS = {
	"warrior": Color("ab47ed"), "guardian": Color("efc46e"),
	"rogue": Color("94d23d"), "mage": Color("688bff"),
	"cleric": Color("ffdb83"), "ranger": Color("64bdff")
}
const DURATION = 0.72
var hero_id: String
var action = "attack"
var elapsed = 0.0
var accent: Color
var picture: TextureRect

static func play(parent: Control, hero: String, kind: String = "attack") -> Control:
	if not COLORS.has(hero) or kind not in ["attack", "defense"]:
		return null
	var effect = new()
	effect.hero_id = hero
	effect.action = kind
	effect.name = "HeroCutIn"
	parent.add_child(effect)
	return effect

func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	z_as_relative = false
	z_index = 150 # Above cards; below modal overlays (200).
	accent = COLORS[hero_id]
	picture = TextureRect.new()
	var path = "res://assets/comic/defense/%s.png" if action == "defense" else "res://assets/comic/%s.png"
	picture.texture = load(path % hero_id)
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
	picture.position = Vector2(size.x * 0.015, size.y - height)

func _process(delta: float) -> void:
	elapsed += delta
	# Static illustration, dynamic framing: fast entry and restrained push-in.
	var entry = 1.0 - pow(1.0 - clampf(elapsed / 0.14, 0.0, 1.0), 3.0)
	picture.position.x = size.x * 0.015 - (1.0 - entry) * picture.size.x * 0.7
	picture.pivot_offset = Vector2(0, picture.size.y)
	picture.scale = Vector2.ONE * (1.0 + minf(elapsed, DURATION) * 0.035)
	queue_redraw()

func _draw() -> void:
	# Only streaks: no dimmer, opaque panel or frame over the dungeon.
	var area = Rect2(picture.position, picture.size)
	for i in range(22):
		var y = area.position.y + fmod(i * 37.0, area.size.y)
		var travel = fmod(i * 173.0 + elapsed * 1200.0, area.size.x)
		var x = area.position.x + travel
		var length = minf(60 + (i % 5) * 20, area.end.x - x)
		draw_line(Vector2(x, y), Vector2(x + length, y - 12), Color(accent, 0.65), 1 + i % 3)
