extends Control
# Ambient presentation only; local RNG never touches run generation or saves.
const BUBBLE = preload("res://assets/ui/polished/speech_bubble.svg")
const AREAS = {
	"market": Rect2(380, 94, 336, 160),
	"forge": Rect2(378, 94, 338, 164),
	"church": Rect2(374, 94, 342, 166),
	"expeditions": Rect2(302, 94, 200, 160)
}
var phrases: Array = []
var phrase_index = -1
var speaking = false
var elapsed = 0.0
var duration = 1.0
var rng = RandomNumberGenerator.new()
var text_label: Label

static func attach(ui: Control, attendant: String) -> Control:
	var bubble = new()
	bubble.name = "AttendantDialogue"
	bubble.phrases = preload("res://src/data/json_catalog.gd").dictionary("res://data/camp_dialogue.json").get(attendant, [])
	var area: Rect2 = AREAS[attendant]
	if attendant == "forge" and ui.forge_hero != "": area.size.x = 242
	if attendant == "church" and ui.church_hero != "": area.size = Vector2(146, 186)
	ui.rect(bubble, area.position.x, area.position.y, area.size.x, area.size.y)
	return bubble

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	rng.randomize()
	var artwork = TextureRect.new()
	artwork.name = "SpeechBubbleArt"
	artwork.texture = BUBBLE
	artwork.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	artwork.stretch_mode = TextureRect.STRETCH_SCALE
	artwork.size = size
	artwork.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(artwork)
	text_label = Label.new()
	text_label.position = size * Vector2(.10, .10)
	text_label.size = size * Vector2(.80, .62)
	text_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	text_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	text_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	text_label.add_theme_font_size_override("font_size", 18 if size.x >= 260 else 17)
	text_label.add_theme_color_override("font_color", Color("171723"))
	text_label.add_theme_constant_override("outline_size", 0)
	text_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(text_label)
	modulate.a = 0.0
	set_process(not phrases.is_empty())

func _process(delta: float) -> void:
	elapsed += delta
	if elapsed >= duration:
		elapsed = 0.0
		speaking = not speaking
		duration = rng.randf_range(5.5, 7.0) if speaking else rng.randf_range(7.0, 11.0)
		if speaking:
			phrase_index = rng.randi_range(0, phrases.size() - 1) if phrase_index < 0 else (phrase_index + rng.randi_range(1, maxi(1, phrases.size() - 1))) % phrases.size()
			text_label.text = phrases[phrase_index]
	modulate.a = minf(clampf(elapsed / 0.3, 0.0, 1.0), clampf((duration - elapsed) / 0.4, 0.0, 1.0)) if speaking else 0.0
