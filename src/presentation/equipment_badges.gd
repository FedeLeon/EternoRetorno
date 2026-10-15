extends RefCounted
# Describes only the equipment snapshot applied to this adventure.
static func entries(heroes: Array, catalog: Dictionary) -> Array:
	var result: Array = []
	for hero in heroes:
		var equipment = hero.get("forge", {})
		for track in ["weapon", "armor"]:
			var level = clampi(int(equipment.get(track, 0)), 0, 3)
			if level == 0: continue
			var weapon = track == "weapon"
			var bonus = int(equipment.get("strength" if weapon else "block", 0))
			result.append({
				"name": "%s · Nivel %d" % ["Arma" if weapon else "Armadura", level],
				"owner": catalog[hero.id].name,
				"description": ("+%d de fuerza por golpe de sus cartas de ataque." if weapon else "+%d de bloqueo en sus cartas defensivas.") % bonus,
				"texture": load("res://assets/forge/badges/%s_%s_%d.png" % [hero.id, track, level]),
				"level": level,
			})
	return result
