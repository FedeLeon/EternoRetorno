extends RefCounted
# Small snapshot badges; rules and expiry belong to combat_modifiers.gd.
static func entries(unit: Dictionary) -> Array:
	if unit.hp <= 0: return []
	var definitions = [
		["strength_pct", "strength", "Daño de cartas +%d%% durante este turno. No se acumula; se conserva el porcentaje mayor. Redondeo hacia abajo."],
		["weak_pct", "weak", "En su próxima acción, el enemigo inflige %d%% menos daño de ataque. No cambia su contraataque. Expira después de actuar y no se acumula."],
		["fracture_pct", "fracture", "Bloqueo reducido un %d%%: afecta al bloqueo actual y al que obtendrá en su próxima acción. No se acumula. El bloqueo perdido no se recupera."]
	]
	var result: Array = []
	for entry in definitions:
		var value = int(unit.get(entry[0], 0))
		if value <= 0: continue
		var id: String = {"strength":"strength", "weak":"weakness", "fracture":"fracture"}[entry[1]]
		var badge: Dictionary = {"id":id, "title":{"strength":"Fuerza", "weakness":"Debilidad", "fracture":"Defensa quebrada"}[id], "asset":"res://assets/battle_effects/%s.png" % id, "value":value, "percent":true, "description":entry[2] % value}
		result.append(badge)
	return result
