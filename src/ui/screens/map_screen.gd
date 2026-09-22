extends Control
# Receives a presentation snapshot. Navigation and saves belong to the controller.
signal room_requested(id: int)
signal deck_requested
signal menu_requested
signal descend_requested

const Dungeon = preload("res://src/dungeon.gd")
const GOLD = Color("d8b779")
var nodes: Array = []
var available: Array = []
var visited: Array = []
var current = -1
var heroes: Array = []
var relics: Array = []
var boss_defeated = false
var deck_count = 0
var run_seed = 0
var dungeon_name = "La cripta de los ecos"
var exit_caption = "Bajar por la escalera"

func place(node: Control, area: Rect2, parent: Node = self) -> void:
	node.position = area.position
	node.size = area.size
	parent.add_child(node)

func label(text: String, area: Rect2, font_size: int = 20, color: Color = Color("e6ddd0"), parent: Node = self) -> Label:
	var node = Label.new()
	node.text = text
	node.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	node.add_theme_font_size_override("font_size", font_size)
	node.add_theme_color_override("font_color", color)
	node.mouse_filter = Control.MOUSE_FILTER_IGNORE
	place(node, area, parent)
	return node

func picture(texture: Texture2D, area: Rect2, parent: Node = self) -> TextureRect:
	var node = TextureRect.new()
	node.texture = texture
	node.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	node.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	node.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	node.mouse_filter = Control.MOUSE_FILTER_IGNORE
	place(node, area, parent)
	return node

func action(text: String, area: Rect2, callback: Callable, parent: Node = self) -> Button:
	var node = Button.new()
	node.text = text
	if text in ["Bajar por la escalera", "Entrar al bosque", "Completar aventura"]:
		preload("res://src/ui/components/button_skin.gd").arrow(node)
	if text == "Menú":
		preload("res://src/ui/components/button_skin.gd").decorate(node, "wood_menu")
	node.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	node.pressed.connect(callback)
	place(node, area, parent)
	return node

func _ready() -> void:
	var background = picture(preload("res://assets/map/minimal/parchment.png"), Rect2(0, 0, 1280, 720))
	background.stretch_mode = TextureRect.STRETCH_SCALE
	var title_frame = Panel.new()
	title_frame.name = "DungeonTitleFrame"
	title_frame.mouse_filter = Control.MOUSE_FILTER_IGNORE
	title_frame.add_theme_stylebox_override("panel", preload("res://src/ui/components/button_skin.gd").style("header_frame"))
	place(title_frame, Rect2(360, 16, 560, 64))
	var title = label(dungeon_name, Rect2(380, 24, 520, 48), 30, GOLD)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	action("Menú", Rect2(1068, 26, 108, 48), func(): menu_requested.emit()).name = "Menu"
	draw_route()
	var drawer = preload("res://src/ui/components/map_group_drawer.gd").new()
	drawer.host = self
	add_child(drawer)
	label("Salas recorridas: %d" % visited.size(), Rect2(54, 671, 560, 25), 15, Color("614932"))
	tooltip_text = "Semilla: %s" % run_seed
	if boss_defeated:
		action(exit_caption, Rect2(461, 626, 358, 44), func(): descend_requested.emit()).name = "Descend"

func draw_route() -> void:
	for node in nodes:
		for next in node.next:
			var line = Line2D.new()
			line.width = 2
			line.default_color = Color("a14e20") if next in available and node.id == current else Color("917858")
			line.add_point(route_position(node))
			line.add_point(route_position(nodes[next]))
			add_child(line)
	for node in nodes:
		var center = route_position(node)
		var reachable = node.id in available
		var done = node.id in visited
		var highlighted = node.id == current or (current < 0 and reachable and not done)
		if highlighted:
			add_room_glow(center, node.id)
		var target = action("", Rect2(center - Vector2(28, 28), Vector2(56, 56)), func(): room_requested.emit(node.id))
		target.name = "Room%d" % node.id
		target.disabled = not reachable
		target.tooltip_text = "Sala actual" if node.id == current else ("Sala disponible" if reachable else ("Sala visitada" if done else "Sin acceso"))
		for state in ["normal", "disabled", "hover", "pressed", "focus"]:
			var style = StyleBoxTexture.new()
			style.texture = preload("res://assets/map/minimal/room_papyrus.png")
			style.modulate_color = Color("bda079") if reachable else Color("cfb58e")
			if highlighted:
				style.modulate_color = Color("ffe6a1")
			if state in ["hover", "focus"]:
				style.modulate_color = Color("edc285")
			if state == "pressed":
				style.modulate_color = Color("b18b62")
			target.add_theme_stylebox_override(state, style)
		var texture = load("res://assets/map/minimal/" + node.kind + ".png")
		var icon = picture(texture, Rect2(4, 4, 48, 48), target)
		icon.modulate = Color.WHITE if reachable or node.id == current else Color(1, 1, 1, 0.65)
		icon.name = "RoomIcon"
		if node.id == current:
			var marker = picture(preload("res://assets/map/minimal/current_room.svg"), Rect2(16, -23, 24, 20), target)
			marker.name = "CurrentRoomMarker"

func add_room_glow(center: Vector2, room_id: int) -> void:
	# Draw before the room button, below the parchment and without intercepting clicks.
	var glow = Panel.new()
	glow.name = "RoomGlow%d" % room_id
	glow.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var style = StyleBoxFlat.new()
	style.bg_color = Color(1.0, 0.82, 0.30, 0.8)
	style.shadow_color = Color(1.0, 0.73, 0.16, 0.85)
	style.shadow_size = 20
	style.set_corner_radius_all(4)
	glow.add_theme_stylebox_override("panel", style)
	place(glow, Rect2(center - Vector2(30, 30), Vector2(60, 60)))
	var pulse = create_tween().set_loops().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	pulse.tween_property(glow, "modulate:a", 0.72, 1.1)
	pulse.tween_property(glow, "modulate:a", 1.0, 1.1)

func route_position(node: Dictionary) -> Vector2:
	var point = Dungeon.map_position(node)
	# Reserve room for the permanent rail without altering saved map coordinates.
	point.x = 54 + (point.x - 54) * 0.93
	return point
