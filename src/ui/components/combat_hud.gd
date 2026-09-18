class_name ERCombatHUD
extends Control

const NumberView = preload("res://src/ui/components/number_view.gd")
const RelicPopover = preload("res://src/ui/components/relic_popover.gd")
var popover: PanelContainer
var open_relic = -1

signal bag_requested
signal deck_requested
signal menu_requested
signal relic_requested(index: int)

# Presentation snapshot supplied by the controller; no game or save dependency.
var relics: Array = []
var turn = 1
var energy = 3

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	var bar = ColorRect.new()
	bar.color = Color("10141f")
	place(bar, Rect2(0, 0, 1280, 64))
	bar.mouse_filter = Control.MOUSE_FILTER_IGNORE
	for i in range(relics.size()):
		var relic = relics[i]
		var texture = AtlasTexture.new()
		texture.atlas = load("res://assets/objects/icons.png")
		texture.region = Rect2((int(relic.icon) % 4) * 64, (int(relic.icon) / 4) * 64, 64, 64)
		var target = icon_button(texture, Rect2(20 + i * 68, 4, 56, 56), relic.owner + " · " + relic.name, func(): relic_requested.emit(i))
		target.name = "Relic%d" % i
	var bag = icon_button(load("res://assets/dungeon/bag.png"), Rect2(897, 4, 56, 56), "Bolsa de objetos", func(): bag_requested.emit())
	bag.name = "Bag"
	var deck = icon_button(preload("res://assets/ui/deck.svg"), Rect2(829, 4, 56, 56), "Ver mazo", func(): deck_requested.emit())
	deck.name = "Deck"
	text_button("Menú", Rect2(1010, 8, 110, 48), func(): menu_requested.emit())
	var title = Label.new()
	title.text = "TURNO"
	title.add_theme_font_size_override("font_size", 16)
	title.add_theme_color_override("font_color", Color("d8b779"))
	title.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	place(title, Rect2(1134, 12, 65, 40))
	title.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_number(turn, Rect2(1200, 16, 68, 32), "TurnNumber")
	var orb = TextureRect.new()
	orb.name = "EnergyOrb"
	var flow = ShaderMaterial.new()
	flow.shader = preload("res://assets/ui/shaders/energy_flow.gdshader")
	orb.material = flow
	orb.texture = load("res://assets/ui/energy.png")
	orb.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	orb.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	orb.mouse_filter = Control.MOUSE_FILTER_IGNORE
	place(orb, Rect2(16, 572, 140, 140))
	add_number(energy, Rect2(49, 615, 74, 52), "EnergyNumber")

func place(node: Control, area: Rect2) -> void:
	node.position = area.position
	node.size = area.size
	add_child(node)

func add_number(amount: int, area: Rect2, id: String) -> void:
	var display = NumberView.new()
	display.value = amount
	display.name = id
	place(display, area)

func text_button(caption: String, area: Rect2, action: Callable) -> void:
	var target = Button.new()
	target.text = caption
	if caption == "Menú":
		preload("res://src/ui/components/button_skin.gd").decorate(target, "wood_menu")
	target.pressed.connect(action)
	place(target, area)

func icon_button(texture: Texture2D, area: Rect2, description: String, action: Callable) -> Button:
	var target = Button.new()
	target.tooltip_text = description
	target.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	for state in ["normal", "hover", "pressed", "focus", "disabled"]:
		target.add_theme_stylebox_override(state, StyleBoxEmpty.new())
	target.pressed.connect(action)
	place(target, area)
	var picture = TextureRect.new()
	picture.texture = texture
	picture.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	picture.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	picture.mouse_filter = Control.MOUSE_FILTER_IGNORE
	picture.position = Vector2(-2, -2)
	picture.size = area.size + Vector2(4, 4)
	target.add_child(picture)
	target.mouse_entered.connect(func(): picture.modulate = Color(1.3, 1.3, 1.3))
	target.mouse_exited.connect(func(): picture.modulate = Color.WHITE)
	target.focus_entered.connect(func(): picture.modulate = Color(1.3, 1.3, 1.6))
	target.focus_exited.connect(func(): picture.modulate = Color.WHITE)
	return target


func show_relic(index: int) -> void:
	var same = open_relic == index
	close_relic()
	if same:
		return
	open_relic = index
	popover = RelicPopover.new()
	popover.setup(relics[index], get_node("Relic%d" % index).get_rect())
	add_child(popover)

func close_relic() -> bool:
	if not is_instance_valid(popover):
		return false
	remove_child(popover)
	popover.queue_free()
	popover = null
	open_relic = -1
	return true

func _input(event: InputEvent) -> void:
	if not is_instance_valid(popover):
		return
	if event is InputEventMouseButton and event.pressed:
		var point = get_global_transform_with_canvas().affine_inverse() * event.position
		if popover.get_rect().has_point(point):
			return
		# Let relic buttons toggle or switch the description.
		for i in range(relics.size()):
			if get_node("Relic%d" % i).get_rect().has_point(point):
				return
		close_relic()
		get_viewport().set_input_as_handled()
