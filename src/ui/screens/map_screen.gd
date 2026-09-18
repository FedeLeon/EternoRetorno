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
	var title = label("La cripta de los ecos", Rect2(380, 24, 520, 48), 30, GOLD)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	action("Menú", Rect2(1068, 26, 108, 48), func(): menu_requested.emit()).name = "Menu"
	draw_route()
	var drawer = preload("res://src/ui/components/map_group_drawer.gd").new()
	drawer.host = self
	add_child(drawer)
	label("Salas recorridas: %d" % visited.size(), Rect2(54, 671, 560, 25), 15, Color("614932"))
	tooltip_text = "Semilla: %s" % run_seed
	if boss_defeated:
		action("Bajar por la escalera →", Rect2(461, 596, 358, 54), func(): descend_requested.emit()).name = "Descend"

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
		var target = action("", Rect2(center - Vector2(28, 28), Vector2(56, 56)), func(): room_requested.emit(node.id))
		target.name = "Room%d" % node.id
		target.disabled = not reachable
		target.tooltip_text = Dungeon.LABELS[node.kind] + (" · disponible" if reachable else (" · visitada" if done else " · sin acceso"))
		for state in ["normal", "disabled", "hover", "pressed", "focus"]:
			var style = StyleBoxFlat.new()
			style.bg_color = Color(0, 0, 0, 0)
			style.set_corner_radius_all(28)
			style.set_border_width_all(2 if reachable or node.id == current else 0)
			style.border_color = Color("a14e20") if reachable else Color("49705a")
			if state in ["hover", "focus"]:
				style.bg_color = Color(0.6, 0.35, 0.12, 0.18)
			target.add_theme_stylebox_override(state, style)
		var texture = load("res://assets/map/minimal/" + node.kind + ".png")
		var icon = picture(texture, Rect2(4, 4, 48, 48), target)
		icon.modulate = Color.WHITE if reachable or node.id == current else Color(1, 1, 1, 0.65)
		var caption = label("%02d · %s" % [node.id + 1, Dungeon.LABELS[node.kind]], Rect2(center + Vector2(-62, 28), Vector2(124, 23)), 12, Color("733813") if reachable else Color("59452f"))
		caption.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		if node.id == current:
			label("▼", Rect2(center + Vector2(-12, -49), Vector2(24, 24)), 20, Color("733813"))

func route_position(node: Dictionary) -> Vector2:
	var point = Dungeon.map_position(node)
	# Reserve room for the permanent rail without altering saved map coordinates.
	point.x = 54 + (point.x - 54) * 0.93
	return point
