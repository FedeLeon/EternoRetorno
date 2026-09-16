extends Control
signal open_requested
signal continue_requested
signal menu_requested

var result: Dictionary = {}
var busy = false
var picture: TextureRect
var chest: Button
var hint: Label

func place(node: Control, area: Rect2, parent: Node = self) -> void:
	node.position = area.position
	node.size = area.size
	parent.add_child(node)

func label(text: String, area: Rect2, font_size: int = 22, parent: Node = self) -> Label:
	var node = Label.new()
	node.text = text
	node.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	node.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	node.add_theme_font_size_override("font_size", font_size)
	node.mouse_filter = Control.MOUSE_FILTER_IGNORE
	place(node, area, parent)
	return node

func _ready() -> void:
	var background = TextureRect.new()
	background.texture = load("res://assets/dungeon/combat_columns.png")
	background.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	background.mouse_filter = Control.MOUSE_FILTER_IGNORE
	place(background, Rect2(0, 0, 1280, 720))
	var shade = ColorRect.new()
	shade.color = Color(0.02, 0.03, 0.06, 0.35)
	shade.mouse_filter = Control.MOUSE_FILTER_IGNORE
	place(shade, Rect2(0, 0, 1280, 720))
	label("Lo que el tiempo dejó atrás", Rect2(220, 42, 840, 55), 34)
	hint = label("Tocá el cofre para abrirlo", Rect2(330, 635, 620, 40))
	var menu = Button.new()
	menu.text = "Menú"
	menu.pressed.connect(func(): if not busy: menu_requested.emit())
	place(menu, Rect2(1100, 24, 140, 50))
	chest = Button.new()
	chest.name = "Chest"
	for state in ["normal", "hover", "pressed", "focus", "disabled"]:
		chest.add_theme_stylebox_override(state, StyleBoxEmpty.new())
	chest.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	chest.pressed.connect(func():
		if not busy and not result.opened:
			open_requested.emit())
	place(chest, Rect2(380, 150, 520, 460))
	picture = TextureRect.new()
	picture.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	picture.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	picture.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	picture.mouse_filter = Control.MOUSE_FILTER_IGNORE
	place(picture, Rect2(0, 0, 520, 460), chest)
	set_frame(5 if result.opened else 0)
	if result.opened:
		show_reward()

func set_frame(index: int) -> void:
	var texture = AtlasTexture.new()
	texture.atlas = load("res://assets/treasure/chest.png")
	texture.region = Rect2(index * 256, 0, 256, 256)
	picture.texture = texture

func reveal(committed_result: Dictionary) -> void:
	result = committed_result
	busy = true
	chest.disabled = true
	hint.text = "El cierre cede…"
	for frame in range(6):
		set_frame(frame)
		await get_tree().create_timer(0.13).timeout
	if result.trapped:
		modulate = Color(1.0, 0.35, 0.35)
		var flash = create_tween()
		flash.tween_property(self, "modulate", Color.WHITE, 0.3)
		await flash.finished
	busy = false
	show_reward()

func show_reward() -> void:
	chest.disabled = true
	hint.text = "Cofre abierto"
	var shade = ColorRect.new()
	shade.name = "RewardModal"
	shade.color = Color(0, 0, 0, 0.6)
	place(shade, Rect2(0, 0, 1280, 720))
	var panel = Panel.new()
	var style = StyleBoxFlat.new()
	style.bg_color = Color("19212e")
	style.border_color = Color("b59660")
	style.set_border_width_all(2)
	style.set_corner_radius_all(8)
	panel.add_theme_stylebox_override("panel", style)
	place(panel, Rect2(340, 135, 600, 480), shade)
	label(result.title, Rect2(25, 22, 550, 48), 28, panel)
	if result.icon >= 0:
		var icon = TextureRect.new()
		var texture = AtlasTexture.new()
		texture.atlas = load("res://assets/objects/icons.png")
		texture.region = Rect2((int(result.icon) % 4) * 64, (int(result.icon) / 4) * 64, 64, 64)
		icon.texture = texture
		icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		icon.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		place(icon, Rect2(244, 73, 112, 112), panel)
	label(result.description, Rect2(35, 192, 530, 190), 21, panel)
	var accept = Button.new()
	accept.name = "Continue"
	accept.text = "Continuar"
	accept.pressed.connect(func(): continue_requested.emit())
	place(accept, Rect2(170, 400, 260, 55), panel)
