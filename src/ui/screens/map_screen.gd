extends "res://src/ui/components/adventure_scene.gd"
# Tactical map; the path scene reuses its snapshot and party rail.

var layout = preload("res://src/ui/components/vertical_map_layout.gd").new()
var scroll: ScrollContainer
var route: Control

func _ready() -> void:
	layout.build(nodes)
	var background = picture(preload("res://assets/map/minimal/parchment.png"), Rect2(0, 0, 1280, 720))
	background.stretch_mode = TextureRect.STRETCH_SCALE
	var title_frame = Panel.new()
	title_frame.name = "DungeonTitleFrame"
	title_frame.mouse_filter = Control.MOUSE_FILTER_IGNORE
	title_frame.add_theme_stylebox_override("panel", preload("res://src/ui/components/button_skin.gd").style("header_frame"))
	place(title_frame, Rect2(360, 16, 560, 64))
	var title = label(dungeon_name, Rect2(380, 24, 520, 48), 30, Color("e7dded"))
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_override("font",preload("res://src/ui/components/polish_theme.gd").HEADING)
	action("Menú", Rect2(1068, 26, 108, 48), func(): menu_requested.emit()).name = "Menu"
	scroll = ScrollContainer.new()
	scroll.name = "MapScroll"
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	scroll.scroll_deadzone = 10
	place(scroll, Rect2(44, 100, 1136, 548))
	route = Control.new()
	route.name = "Route"
	route.mouse_filter = Control.MOUSE_FILTER_IGNORE
	route.custom_minimum_size = Vector2(layout.WIDTH, layout.height)
	scroll.add_child(route)
	draw_route()
	focus_party.call_deferred()
	var drawer = preload("res://src/ui/components/map_group_drawer.gd").new()
	drawer.host = self
	add_child(drawer)
	var footer = Panel.new()
	footer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	footer.add_theme_stylebox_override("panel",preload("res://src/ui/components/button_skin.gd").style("header_frame"))
	place(footer,Rect2(44,665,650,36))
	label("Elegí la sala iluminada · Deslizá para ver el recorrido" if current < 0 else "Avanzá hacia arriba · %d salas recorridas · Deslizá para explorar" % visited.size(), Rect2(56,670,626,25),15,GOLD)
	tooltip_text = "Semilla: %s" % run_seed
	if boss_defeated:
		action(exit_caption, Rect2(461, 626, 358, 44), func(): descend_requested.emit()).name = "Descend"

func draw_route() -> void:
	for node in nodes:
		for next in node.next:
			var line = Line2D.new()
			var active_path = next in available and node.id == current
			var travelled = node.id in visited and (next in visited or next == current)
			line.width = 4.5 if active_path else 3.5 if travelled else 2.5
			line.default_color = Color("75ded4") if active_path else Color("a8bdc4") if travelled else Color(0.58,0.64,0.70,0.70)
			line.points = layout.connection(node.id, next)
			route.add_child(line)
			if active_path:
				var flow = preload("res://src/presentation/map_route_flow.gd").new()
				flow.name = "AvailableRouteFlow%d_%d" % [node.id,next]
				flow.points = line.points
				route.add_child(flow)
	for node in nodes:
		var center = route_position(node)
		var reachable = node.id in available
		var done = node.id in visited
		var highlighted = node.id == current or (reachable and not done)
		if highlighted:
			add_room_glow(center, node.id, node.id == current)
		var room_size = 88.0 if node.kind == "boss" else 72.0
		var target = action("", Rect2(center - Vector2.ONE*room_size/2, Vector2.ONE*room_size), func(): room_requested.emit(node.id), route)
		target.name = "Room%d" % node.id
		target.disabled = not reachable
		if node.kind == "elite" and node.has("elite_modifier"):
			var elite_data = preload("res://src/rules/combat_depth.gd").ELITES[node.elite_modifier]
			target.set_meta("elite_description", elite_data.name + ": " + elite_data.description)
		target.tooltip_text = "Sala actual" if node.id == current else ("Sala disponible" if reachable else ("Sala visitada" if done else "Sin acceso"))
		if node.has("risk"): target.tooltip_text += "\n"+node.risk.name+": "+node.risk.warning
		if target.has_meta("elite_description"): target.tooltip_text += "\n" + target.get_meta("elite_description")
		for state in ["normal", "disabled", "hover", "pressed", "focus"]:
			var style = StyleBoxTexture.new()
			style.texture = preload("res://assets/map/minimal/room_papyrus.png")
			style.modulate_color = Color("d8cbe0") if reachable else Color("a297ac")
			if highlighted:
				style.modulate_color = Color("eddefa") if node.id == current else Color("d8e0ee")
			if state in ["hover", "focus"]:
				style.modulate_color = Color("efe2f7")
			if state == "pressed":
				style.modulate_color = Color("baa7c9")
			target.add_theme_stylebox_override(state, style)
		var texture = load("res://assets/map/minimal/" + node.kind + ".png")
		var icon = picture(texture, Rect2(6, 6, room_size-12, room_size-12), target)
		icon.modulate = Color.WHITE if reachable or node.id == current else Color(1, 1, 1, 0.65)
		icon.name = "RoomIcon"
		if node.kind == "boss":
			var caption = label("JEFE FINAL", Rect2(center+Vector2(-120,-83),Vector2(240,30)),22,GOLD,route)
			caption.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		if node.id == current:
			for i in range(heroes.size()):
				var portrait = preload("res://src/ui/components/refuge_portrait.gd")
				picture(portrait.face_texture(heroes[i].id),Rect2(room_size/2-38+i*40,-68,36,38),target).name = "PartyHero%d"%i
			var marker = picture(preload("res://assets/map/minimal/current_room.svg"), Rect2(room_size/2-12, -25, 24, 20), target)
			marker.name = "CurrentRoomMarker"

func add_room_glow(center: Vector2, room_id: int, is_current: bool) -> void:
	# Draw before the room button, below the parchment and without intercepting clicks.
	var glow = Panel.new()
	glow.name = "RoomGlow%d" % room_id
	glow.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var style = StyleBoxFlat.new()
	style.bg_color = Color(0.76, 0.55, 0.95, 0.8) if is_current else Color(0.55, 0.66, 0.91, 0.8)
	style.shadow_color = Color(0.59, 0.35, 0.8, 0.85) if is_current else Color(0.36, 0.44, 0.74, 0.85)
	style.shadow_size = 20 if is_current else 18
	style.set_corner_radius_all(4)
	glow.add_theme_stylebox_override("panel", style)
	place(glow, Rect2(center - Vector2(38, 38), Vector2(76, 76)), route)
	var pulse = create_tween().set_loops().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	pulse.tween_property(glow, "modulate:a", 0.72 if is_current else 0.45, 1.1)
	pulse.tween_property(glow, "modulate:a", 1.0, 1.1)

func route_position(node: Dictionary) -> Vector2:
	return layout.positions[node.id]

func focus_party() -> void:
	if nodes.is_empty(): return
	var focus: Vector2 = layout.positions.get(current, layout.positions[nodes[0].id])
	scroll.scroll_vertical = maxi(0, roundi(focus.y-scroll.size.y*.72))
