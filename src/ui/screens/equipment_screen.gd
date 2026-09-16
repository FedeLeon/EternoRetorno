extends RefCounted

# Shared UI factory + explicit view data and actions; no rule or save mutations.
static func build(ui: Control, relics: Dictionary, equipped: Dictionary, can_start: bool, actions: Dictionary) -> void:
	ui.header("Reliquias para el descenso", "Elegí una sola reliquia para ambos héroes. Cambiarla reemplaza la anterior.")
	var ids = relics.keys()
	for i in range(ids.size()):
		var id = ids[i]
		var relic = relics[id]
		var chosen = equipped.get("team", "") == id
		var b = ui.button("", 36 + (i % 4) * 306, 151 + (i / 4) * 211, 290, 178, func(): actions.equip.call(id), true)
		b.name = "Equip_" + id
		ui.object_icon(relic.icon, 8, 8, 48, b)
		ui.label_at(relic.name, 62, 8, 220, 48, 19, ui.GOLD if chosen else ui.TEXT, b)
		ui.label_at(relic.description, 12, 61, 266, 88, 16, ui.TEXT, b)
		ui.label_at("Elegida para ambos" if chosen else "Tocar para elegir", 12, 150, 266, 23, 14, ui.GOLD if chosen else ui.MUTED, b)
	ui.button("← Personajes", 36, 647, 250, 54, actions.back)
	ui.button("Iniciar aventura →", 904, 647, 340, 54, actions.start, can_start)
