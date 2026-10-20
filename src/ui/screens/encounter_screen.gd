extends Control
# Event presentation only. Choices are validated, resolved and saved by Game.
signal choice_requested(index: int)
signal continue_requested
const Choice = preload("res://src/ui/components/encounter_choice.gd")
const Preferences = preload("res://src/presentation/preferences.gd")
const Atmosphere = preload("res://assets/shaders/encounter_atmosphere.gdshader")
var event_id = "well"
var choice_id = ""
var unavailable_reason = "No se cumplen los requisitos de esta opción."
var narration: Label
var bubble: Control
var choices: Control
var entry_motion: Tween
var outcome_visible = false
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
	node.add_theme_color_override("font_color", Color("252431"))
	node.add_theme_constant_override("outline_size", 0)
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
	effect.set_shader_parameter("effect_strength", 0.0 if Preferences.low_quality() else Preferences.flashes())
	effect.set_shader_parameter("encounter_kind", ["well", "altar", "library"].find(event_id) if event_id in ["well","altar","library"] else 1)
	# Anchors follow today's artwork, keeping water/terminal movement local.
	var anchors = {
		"well": [0, Vector2(.50,.67), Vector2(.065,.025), Vector3(.15,.85,.7)],
		"altar": [2, Vector2(.31,.31), Vector2(.075,.19), Vector3(.5,.3,1.0)],
		"library": [2, Vector2(.22,.51), Vector2(.18,.07), Vector3(.8,.7,.5)],
		"forest_spring": [0, Vector2(.275,.13), Vector2(.022,.055), Vector3(.3,.65,1.0)],
		"forest_hunter": [2, Vector2(.44,.69), Vector2(.10,.045), Vector3(.65,.6,.5)],
		"forest_spirit": [2, Vector2(.23,.33), Vector2(.13,.15), Vector3(.15,.8,.85)],
		"forge_altar": [2, Vector2(.34,.65), Vector2(.05,.075), Vector3(.1,.6,.85)],
		"ash_archive": [2, Vector2(.28,.58), Vector2(.12,.08), Vector3(.75,.6,.4)],
		"lava_bridge": [2, Vector2(.48,.24), Vector2(.045,.055), Vector3(1.0,.5,.1)]
	}
	if anchors.has(event_id):
		var parameters: Array = anchors[event_id]
		for i in range(4): effect.set_shader_parameter(["encounter_kind","focus","radius","effect_color"][i],parameters[i])
	var scenery_tint = preload("res://src/ui/components/battle_background.gd").SCENERY_TINT
	effect.set_shader_parameter("scenery_tint", Vector3(scenery_tint.r, scenery_tint.g, scenery_tint.b))
	background.material = effect
	place(background, Rect2(0, 0, 1280, 720))
	build_story()
	build_choices()
	if not Preferences.low_quality():
		entry_motion = create_tween().set_parallel(true).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
		for node in [bubble, choices]:
			var destination: Vector2 = node.position
			node.position.y += 12
			node.modulate.a = 0.0
			entry_motion.tween_property(node, "position", destination, .3)
			entry_motion.tween_property(node, "modulate:a", 1.0, .25)

func build_story() -> void:
	# The tail points into the illustration; no full-screen dark panel covers its art.
	bubble = Control.new()
	bubble.name = "StoryBubble"
	place(bubble, Rect2(700, 80, 540, 410))
	var art = TextureRect.new()
	art.texture = preload("res://assets/ui/polished/encounters/bubble.svg")
	art.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	art.mouse_filter = Control.MOUSE_FILTER_IGNORE
	place(art, Rect2(0,0,540,410), bubble)
	var caption = label("ENCUENTRO", Rect2(64,24,422,26), 15, bubble)
	caption.name = "StoryCaption"
	caption.add_theme_color_override("font_color", Color("67716f"))
	var title = label(event.name, Rect2(60,55,426,62), 27, bubble)
	title.name = "EncounterTitle"
	title.add_theme_font_override("font", preload("res://src/ui/components/polish_theme.gd").HEADING)
	narration = label(event.text, Rect2(62,126,424,216), 21, bubble)
	narration.name = "Narration"

func build_choices() -> void:
	choices = Control.new()
	choices.name = "EncounterDialog"
	place(choices, Rect2(36, 544, 1208, 148))
	var count = event.choices.size()
	var width = (1208.0 - 20.0 * (count - 1)) / count
	if count == 1: width = 680
	for i in range(count):
		var button = Choice.new()
		button.name = "EventChoice%d" % i
		choices.add_child(button)
		var data = Choice.describe(choice_id if choice_id != "" else event_id, i, event.choices[i])
		button.configure(data, Rect2((1208-width)/2 if count == 1 else i*(width+20),0,width,148), unavailable_reason if i == 0 and not can_offer else "")
		button.pressed.connect(func():
			if submitted: return
			submitted = true
			for sibling in choices.get_children(): sibling.disabled = true
			choice_requested.emit(i))

func show_outcome(message: String, destination: String) -> void:
	outcome_visible = true
	if entry_motion: entry_motion.kill()
	bubble.position = Vector2(700,80)
	bubble.modulate.a = 1.0
	narration.position = Vector2(62,112)
	narration.size = Vector2(424,226)
	narration.add_theme_font_size_override("font_size", 20)
	narration.text = message
	bubble.get_node("EncounterTitle").text = "Decisión tomada"
	bubble.get_node("StoryCaption").text = "RESULTADO"
	var seal = TextureRect.new()
	seal.name = "ConfirmedSeal"
	seal.texture = preload("res://assets/ui/polished/encounters/accept.svg")
	seal.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	seal.mouse_filter = Control.MOUSE_FILTER_IGNORE
	place(seal,Rect2(62,25,36,36),bubble)
	choices.hide()
	var next = Choice.new()
	next.name = "ContinueEncounter"
	add_child(next)
	next.configure({"icon":"continue", "title":"Elegir carta" if destination in ["reward", "event_cards"] else "Seguir el camino", "detail":"", "tone":Color("32686b")}, Rect2(710,558,530,130))
	next.pressed.connect(func():
		next.disabled = true
		continue_requested.emit())
	next.grab_focus()
	if not Preferences.low_quality():
		next.modulate.a = 0
		create_tween().tween_property(next, "modulate:a", 1.0, .2)

func reject_submission(message: String) -> void:
	submitted = false
	for i in range(choices.get_child_count()): choices.get_child(i).disabled = i == 0 and not can_offer
	narration.text = message
