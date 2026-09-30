extends Control
# Ambient presentation only; local RNG never touches run generation or saves.
const Chrome = preload("res://src/ui/components/dark_skin.gd")
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
	bubble.phrases = JSON.parse_string(FileAccess.get_file_as_string("res://data/camp_dialogue.json")).get(attendant, [])
	ui.rect(bubble, 48, 584, 408, 104)
	return bubble

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	rng.randomize()
	var panel = Panel.new()
	panel.size = size
	panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	panel.add_theme_stylebox_override("panel", Chrome.dialog())
	add_child(panel)
	text_label = Label.new()
	text_label.position = Vector2(20, 12)
	text_label.size = size - Vector2(40, 24)
	text_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	text_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	text_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	text_label.add_theme_font_size_override("font_size", 20)
	text_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(text_label)
	modulate.a = 0.0
	set_process(not phrases.is_empty())

func _draw() -> void:
	# Small upward tail points toward the attendant, above the shared dark frame.
	var points = PackedVector2Array([Vector2(170, 1), Vector2(185, -17), Vector2(204, 1)])
	draw_colored_polygon(points, Color("14121c"))
	draw_polyline(points, Chrome.ACCENT, 2.0, true)

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
