extends "res://src/ui/components/adventure_scene.gd"
# First-person route selection. Only exact reachable node IDs emit navigation.
const NAMES = {"combat":"Combate", "elite":"Élite", "treasure":"Cofre", "rest":"Descanso", "event":"Encuentro", "boss":"Guardián"}
const CENTERS = {1:[0.47], 2:[0.26, 0.68], 3:[0.18, 0.47, 0.76]}

static func background_path(floor_id: int, count: int) -> String:
	return "res://assets/paths/floor_%d_%d.png" % [clampi(floor_id, 1, 3), clampi(count, 1, 3)]

func _ready() -> void:
	var background = picture(load(background_path(floor_number, available.size())), Rect2(0, 0, 1280, 720))
	background.name = "PathsBackground"
	background.stretch_mode = TextureRect.STRETCH_SCALE
	var header = Panel.new()
	header.name = "PathsHeader"
	header.mouse_filter = Control.MOUSE_FILTER_IGNORE
	header.add_theme_stylebox_override("panel", preload("res://src/ui/components/button_skin.gd").style("header_frame"))
	place(header, Rect2(18, 16, 1160, 84))
	label(dungeon_name, Rect2(44, 27, 950, 32), 26, GOLD)
	label("La central quedó atrás. Es hora de volver." if boss_defeated else "Elegí por dónde seguir", Rect2(44, 61, 950, 26), 18)
	action("Menú", Rect2(1062, 32, 102, 42), func(): menu_requested.emit()).name = "Menu"
	if boss_defeated:
		var finish = action("Completar aventura", Rect2(416, 492, 370, 72), func(): descend_requested.emit())
		finish.name = "Descend"
	var centers: Array = CENTERS[clampi(available.size(), 1, 3)]
	for i in range(available.size()):
		build_path(nodes[available[i]], centers[i] * 1280)
	var drawer = preload("res://src/ui/components/map_group_drawer.gd").new()
	drawer.host = self
	add_child(drawer)

func build_path(node: Dictionary, center: float) -> void:
	var target = action("", Rect2(center - 142, 138, 284, 480), func(): room_requested.emit(node.id))
	target.name = "Path%d" % node.id
	target.set_meta("room_id", node.id)
	target.set_meta("kind", node.kind)
	target.tooltip_text = NAMES.get(node.kind, node.kind)
	if node.has("risk"): target.tooltip_text += "\n" + node.risk.name + ": " + node.risk.warning
	for state in ["normal", "hover", "pressed", "focus"]:
		var style = StyleBoxFlat.new()
		style.bg_color = Color(0.10, 0.31, 0.33, 0.19) if state in ["hover", "focus", "pressed"] else Color.TRANSPARENT
		style.border_color = Color("8ce6dc") if state in ["hover", "focus"] else Color(0.5, 0.8, 0.85, 0.15)
		style.set_border_width_all(2 if state in ["hover", "focus"] else 0)
		style.set_corner_radius_all(8)
		target.add_theme_stylebox_override(state, style)
	var sign = Panel.new()
	sign.mouse_filter = Control.MOUSE_FILTER_IGNORE
	sign.add_theme_stylebox_override("panel", preload("res://src/ui/components/button_skin.gd").style("header_frame"))
	place(sign, Rect2(24, 24, 236, 126), target)
	picture(load("res://assets/map/minimal/" + node.kind + ".png"), Rect2(92, 34, 100, 62), target)
	var caption = label(NAMES.get(node.kind, node.kind), Rect2(26, 105, 232, 36), 24, Color("e9e1ee"), target)
	caption.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	if node.has("risk"):
		var warning = label("Riesgo: " + node.risk.name, Rect2(14, 156, 256, 54), 17, Color("f0a657"), target)
		warning.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	var footer = Panel.new()
	footer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	footer.add_theme_stylebox_override("panel", preload("res://src/ui/components/button_skin.gd").style("header_frame"))
	place(footer, Rect2(16, 360, 252, 116), target)
	var hint = label("Seguir por aquí", Rect2(24, 365, 236, 30), 20, GOLD, target)
	hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	if node.next.is_empty():
		label("Fin del sector", Rect2(46, 415, 192, 28), 17, Color("d6cbea"), target).horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	else:
		label("Después", Rect2(24, 398, 236, 24), 16, Color("b4bac8"), target).horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		var gap = 44.0
		var left = (284 - node.next.size() * gap) / 2
		for j in range(node.next.size()):
			var kind: String = nodes[node.next[j]].kind
			var icon = picture(load("res://assets/map/minimal/" + kind + ".png"), Rect2(left + j * gap, 428, 36, 36), target)
			icon.name = "Next%d" % node.next[j]
