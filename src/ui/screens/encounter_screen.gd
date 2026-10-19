extends Control
# Event presentation only. Choices are validated, resolved and saved by Game.
signal choice_requested(index: int)
const Buttons = preload("res://src/ui/components/button_skin.gd")
const Chrome = preload("res://src/ui/components/dark_skin.gd")
const Atmosphere = preload("res://assets/shaders/encounter_atmosphere.gdshader")
var event_id = "well"
var event: Dictionary = {}
var can_offer = true
var submitted = false

func place(node: Control, area: Rect2, parent: Control = self) -> void:
	node.position = area.position
	node.size = area.size
	parent.add_child(node)

func label(text: String, area: Rect2, font_size: int, parent: Control) -> Label:
	var node = Label.new()
	node.text = text
	node.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	node.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	node.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	node.mouse_filter = Control.MOUSE_FILTER_IGNORE
	node.add_theme_font_size_override("font_size", font_size)
	place(node, area, parent)
	return node

func _ready() -> void:
	name = "EncounterScreen"
	var background = TextureRect.new()
	background.name = "EncounterBackground"
	background.texture = load("res://assets/encounters/%s.png" % event_id)
	background.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	background.stretch_mode = TextureRect.STRETCH_SCALE
	background.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var effect = ShaderMaterial.new()
	effect.shader = Atmosphere
	effect.set_shader_parameter("encounter_kind", ["well", "altar", "library"].find(event_id) if event_id in ["well","altar","library"] else 1)
	# Calibrated against the actual generated water, fissure and book positions.
	var focus = {"well": Vector2(0.5, 0.312), "altar": Vector2(0.503, 0.335), "library": Vector2(0.5, 0.289)}
	effect.set_shader_parameter("focus", focus.get(event_id, Vector2(0.5, 0.33)))
	effect.set_shader_parameter("radius", Vector2(0.108, 0.025) if event_id == "well" else Vector2(0.12, 0.10))
	var expanded = {
		"forest_spring": [0, Vector2(0.5,0.49), Vector2(0.17,0.055), Vector3(0.15,0.65,1.0)],
		"forest_hunter": [2, Vector2(0.546,0.441), Vector2(0.052,0.058), Vector3(1.0,0.45,0.1)],
		"forest_spirit": [2, Vector2(0.5,0.264), Vector2(0.16,0.2), Vector3(1.0,0.8,0.25)],
		"forge_altar": [2, Vector2(0.5,0.204), Vector2(0.07,0.15), Vector3(1.0,0.35,0.08)],
		"ash_archive": [2, Vector2(0.5,0.305), Vector2(0.08,0.10), Vector3(0.9,0.55,0.2)],
		"lava_bridge": [0, Vector2(0.5,0.52), Vector2(0.32,0.055), Vector3(1.0,0.22,0.04)]
	}
	if expanded.has(event_id):
		var parameters: Array = expanded[event_id]
		for i in range(4): effect.set_shader_parameter(["encounter_kind","focus","radius","effect_color"][i],parameters[i])
	var scenery_tint = preload("res://src/ui/components/battle_background.gd").SCENERY_TINT
	effect.set_shader_parameter("scenery_tint", Vector3(scenery_tint.r, scenery_tint.g, scenery_tint.b))
	background.material = effect
	place(background, Rect2(0, 0, 1280, 720))
	var panel = Panel.new()
	panel.name = "EncounterDialog"
	panel.add_theme_stylebox_override("panel", Chrome.dialog())
	place(panel, Rect2(310, 416, 660, 280))
	label(event.name, Rect2(20, 10, 620, 40), 27, panel).add_theme_color_override("font_color", Chrome.ACCENT)
	label(event.text, Rect2(28, 54, 604, 68), 20, panel)
	for i in range(event.choices.size()):
		var button = Button.new()
		button.name = "EventChoice%d" % i
		button.text = event.choices[i]
		button.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		button.add_theme_font_size_override("font_size", 18)
		button.disabled = i == 0 and not can_offer
		button.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
		button.pressed.connect(func():
			if submitted: return
			submitted = true
			choice_requested.emit(i))
		place(button, Rect2(28, 130 + i * 66, 604, 56), panel)
