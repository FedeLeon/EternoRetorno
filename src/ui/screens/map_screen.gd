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
	# Older spiral saves receive the clearer arrangement in a private UI snapshot.
	# Their paths, encounters and persisted positions remain untouched.
	nodes = nodes.duplicate(true)
	var visual_rng = RandomNumberGenerator.new()
	visual_rng.seed = run_seed
	for stage in range(13):
		var layer_nodes = nodes.filter(func(node): return node.get("layout","") == "spiral" and node.get("stage",-1) == stage)
		for lane in range(layer_nodes.size()):
			var node: Dictionary = layer_nodes[lane]
			if int(node.get("layout_version",1)) >= 2: continue
			var point = preload("res://src/map_geometry.gd").position(stage,lane,layer_nodes.size(),visual_rng)
			node.position = [point.x,point.y]
			node.layout_version = 2
	var background = picture(preload("res://assets/map/minimal/parchment.png"), Rect2(0, 0, 1280, 720))
	background.stretch_mode = TextureRect.STRETCH_SCALE
	var title_frame = Panel.new()
	title_frame.name = "DungeonTitleFrame"
	title_frame.mouse_filter = Control.MOUSE_FILTER_IGNORE
	title_frame.add_theme_stylebox_override("panel", preload("res://src/ui/components/button_skin.gd").style("header_frame"))
	place(title_frame, Rect2(360, 16, 560, 64))
	var title = label(dungeon_name, Rect2(380, 24, 520, 48), 30, GOLD)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_override("font",preload("res://src/ui/components/polish_theme.gd").HEADING)
	action("Menú", Rect2(1068, 26, 108, 48), func(): menu_requested.emit()).name = "Menu"
	draw_route()
	var drawer = preload("res://src/ui/components/map_group_drawer.gd").new()
	drawer.host = self
	add_child(drawer)
	var footer = Panel.new()
	footer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	footer.add_theme_stylebox_override("panel",preload("res://src/ui/components/button_skin.gd").style("header_frame"))
	place(footer,Rect2(44,665,494 if current < 0 else 232,36))
	label("Elegí la sala iluminada para comenzar" if current < 0 else "Salas recorridas: %d" % visited.size(), Rect2(56,670,472 if current < 0 else 214,25),15,GOLD)
	tooltip_text = "Semilla: %s" % run_seed
	if boss_defeated:
		action(exit_caption, Rect2(461, 626, 358, 44), func(): descend_requested.emit()).name = "Descend"

func draw_route() -> void:
	for node in nodes:
		for next in node.next:
			var line = Line2D.new()
			var active_path = next in available and node.id == current
			var travelled = node.id in visited and (next in visited or next == current)
			line.width = 3 if active_path else 2.5 if travelled else 1.5
			line.default_color = Color("a14e20") if active_path else Color("674322") if travelled else Color(0.43,0.32,0.20,0.45)
			if node.get("layout", "") == "spiral":
				for point in preload("res://src/map_geometry.gd").connection(node,nodes[next]):
					line.add_point(display_point(point))
			else:
				line.add_point(route_position(node))
				line.add_point(route_position(nodes[next]))
			add_child(line)
			if active_path:
				var flow = preload("res://src/presentation/map_route_flow.gd").new()
				flow.name = "AvailableRouteFlow%d_%d" % [node.id,next]
				flow.points = line.points
				add_child(flow)
	for node in nodes:
		var center = route_position(node)
		var reachable = node.id in available
		var done = node.id in visited
		var highlighted = node.id == current or (reachable and not done)
		if highlighted:
			add_room_glow(center, node.id, node.id == current)
		var target = action("", Rect2(center - Vector2(28, 28), Vector2(56, 56)), func(): room_requested.emit(node.id))
		target.name = "Room%d" % node.id
		target.disabled = not reachable
		if node.kind == "elite" and node.has("elite_modifier"):
			var elite_data = preload("res://src/rules/combat_depth.gd").ELITES[node.elite_modifier]
			target.set_meta("elite_description", elite_data.name + ": " + elite_data.description)
		target.tooltip_text = "Sala actual" if node.id == current else ("Sala disponible" if reachable else ("Sala visitada" if done else "Sin acceso"))
		if node.has("risk"): target.tooltip_text += "\n"+node.risk.name+": "+node.risk.warning
		if node.get("scouted",false): target.tooltip_text += "\nReconocimiento: "+ {"combat":"Combate","elite":"Élite","treasure":"Tesoro","rest":"Descanso","event":"Encuentro","boss":"Guardián"}[node.kind]
		if target.has_meta("elite_description"): target.tooltip_text += "\n" + target.get_meta("elite_description")
		for state in ["normal", "disabled", "hover", "pressed", "focus"]:
			var style = StyleBoxTexture.new()
			style.texture = preload("res://assets/map/minimal/room_papyrus.png")
			style.modulate_color = Color("bda079") if reachable else Color("cfb58e")
			if highlighted:
				style.modulate_color = Color("ffe6a1") if node.id == current else Color("d8efb2")
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

func add_room_glow(center: Vector2, room_id: int, is_current: bool) -> void:
	# Draw before the room button, below the parchment and without intercepting clicks.
	var glow = Panel.new()
	glow.name = "RoomGlow%d" % room_id
	glow.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var style = StyleBoxFlat.new()
	style.bg_color = Color(1.0, 0.82, 0.30, 0.8) if is_current else Color(0.44, 0.88, 0.69, 0.8)
	style.shadow_color = Color(1.0, 0.73, 0.16, 0.85) if is_current else Color(0.16, 0.66, 0.44, 0.85)
	style.shadow_size = 20 if is_current else 18
	style.set_corner_radius_all(4)
	glow.add_theme_stylebox_override("panel", style)
	place(glow, Rect2(center - Vector2(30, 30), Vector2(60, 60)))
	var pulse = create_tween().set_loops().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	pulse.tween_property(glow, "modulate:a", 0.72 if is_current else 0.45, 1.1)
	pulse.tween_property(glow, "modulate:a", 1.0, 1.1)

func route_position(node: Dictionary) -> Vector2:
	return display_point(Dungeon.map_position(node))

func display_point(point: Vector2) -> Vector2:
	# Reserve room for the permanent rail without altering saved map coordinates.
	point.x = 54 + (point.x - 54) * 0.93
	return point
