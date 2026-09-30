extends Control
# Event presentation only. Choices are validated, resolved and saved by Game.
signal choice_requested(index: int)
signal menu_requested
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
	effect.set_shader_parameter("encounter_kind", ["well", "altar", "library"].find(event_id))
	# Calibrated against the actual generated water, fissure and book positions.
	var focus = {"well": Vector2(0.5, 0.312), "altar": Vector2(0.503, 0.335), "library": Vector2(0.5, 0.289)}
	effect.set_shader_parameter("focus", focus[event_id])
	effect.set_shader_parameter("radius", Vector2(0.108, 0.025) if event_id == "well" else Vector2(0.12, 0.10))
	background.material = effect
	place(background, Rect2(0, 0, 1280, 720))
	var menu = Button.new()
	menu.name = "Menu"
	menu.text = "Menú"
	Buttons.decorate(menu, "wood_menu")
	menu.pressed.connect(func(): menu_requested.emit())
	place(menu, Rect2(1138, 22, 106, 42))
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
