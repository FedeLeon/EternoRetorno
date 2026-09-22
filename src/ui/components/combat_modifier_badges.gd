extends RefCounted
# Small snapshot badges; rules and expiry belong to combat_modifiers.gd.
static func attach(parent: Control, unit: Dictionary, area: Rect2) -> void:
	if unit.hp <= 0: return
	var definitions = [
		["strength_pct", "strength", "Daño de cartas +%d%% durante este turno. No se acumula; se conserva el porcentaje mayor. Redondeo hacia abajo."],
		["weak_pct", "weak", "En su próxima acción, el enemigo inflige %d%% menos daño de ataque. No cambia su contraataque. Expira después de actuar y no se acumula."],
		["fracture_pct", "fracture", "Bloqueo reducido un %d%%: afecta al bloqueo actual y al que obtendrá en su próxima acción. No se acumula. El bloqueo perdido no se recupera."]
	]
	var x = area.position.x
	for entry in definitions:
		var value = int(unit.get(entry[0], 0))
		if value <= 0: continue
		var badge = Button.new()
		badge.name = "Modifier_" + entry[0]
		badge.position = Vector2(x, area.position.y)
		badge.size = Vector2(84, 28)
		badge.text = "%d%%" % value
		badge.icon = load("res://assets/ui/" + entry[1] + ".svg")
		badge.expand_icon = true
		badge.add_theme_constant_override("icon_max_width", 24)
		badge.add_theme_font_size_override("font_size", 15)
		var style = StyleBoxFlat.new()
		style.bg_color = Color(0.035, 0.045, 0.06, 0.85)
		style.set_corner_radius_all(4)
		for state in ["normal", "hover", "pressed", "focus"]: badge.add_theme_stylebox_override(state, style)
		badge.pressed.connect(func(): preload("res://src/ui/components/combat_tip.gd").show_for(badge, entry[2] % value))
		parent.add_child(badge)
		x += 88
