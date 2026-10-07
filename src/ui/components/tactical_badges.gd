extends RefCounted
static func enemy(ui: Control, parent: Control, unit: Dictionary) -> void:
	if int(unit.get("root_hp", 0)) > 0:
		var roots = TextureRect.new()
		roots.texture = preload("res://assets/combat_depth/roots.png")
		roots.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		roots.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		roots.mouse_filter = Control.MOUSE_FILTER_IGNORE
		ui.rect(roots, 24, 186, 168, 76, parent)
	var parts: Array[String] = []
	if unit.get("rear", false): parts.append("Retaguardia cubierta")
	if int(unit.get("root_hp", 0)) > 0: parts.append("Raíces · %d PV" % unit.root_hp)
	var special = unit.intent.get("special", "")
	if special == "resurrect": parts.append("Prepara resurrección")
	if special == "embers": parts.append("Brasas · 4 daño a ambos")
	if unit.has("modifier"): parts.append(preload("res://src/rules/combat_depth.gd").ELITES[unit.modifier].name)
	if parts.is_empty() or unit.hp <= 0: return
	var badge = ui.button(" · ".join(parts), 0, 272, 214, 44, func():
		var descriptions: Array[String] = []
		if unit.get("rear", false): descriptions.append("El protector cubre esta criatura. Ataques de maga, explorador, penetrantes y de área alcanzan la retaguardia.")
		if int(unit.get("root_hp", 0)) > 0: descriptions.append("Las raíces absorben golpes directos: quedan %d PV. El veneno las ignora." % unit.root_hp)
		if special == "resurrect": descriptions.append("Al actuar revivirá una criatura caída con un tercio de su vida. Cada criatura puede regresar una sola vez.")
		if special == "embers": descriptions.append("Al actuar las brasas causarán 4 de daño a ambos héroes. El bloqueo puede absorberlo.")
		if unit.has("modifier"): descriptions.append(preload("res://src/rules/combat_depth.gd").ELITES[unit.modifier].description)
		descriptions.append("Una carta de interrupción cancela la intención especial y el contraataque del objetivo.")
		preload("res://src/ui/components/reading_dialog.gd").open(ui, "Situación táctica", "\n\n".join(descriptions)), true, parent)
	badge.add_theme_font_size_override("font_size", 13)
	badge.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART

static func hero(ui: Control, parent: Control, index: int) -> void:
	var attacks: Array = ui.game.run.combat.get("prepared", []).filter(func(attack): return attack.owner == index)
	if attacks.is_empty(): return
	ui.panel(0, 278, 204, 38, ui.GOLD, parent)
	ui.label_at("Ataque preparado · próximo turno", 5, 278, 194, 38, 13, ui.GOLD, parent).horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER

static func toolbar(ui: Control) -> void:
	ui.button("Registro", 36, 70, 130, 34, func():
		if ui.combat_busy: return
		ui.close_modal()
		var entries: Array = ui.game.run.combat.get("journal", [])
		preload("res://src/ui/components/reading_dialog.gd").open(ui, "Registro del combate", "Todavía no hubo acciones." if entries.is_empty() else "\n".join(entries)))
	var sets = preload("res://src/rules/relic_sets.gd").active(ui.game.run)
	if not sets.is_empty():
		ui.button("Sinergias de reliquias · %d" % sets.size(), 180, 70, 260, 34, func():
			if ui.combat_busy: return
			ui.close_modal()
			var lines: Array[String] = []
			for set_data in sets: lines.append(set_data.name + ": " + set_data.effect)
			ui.overlay = preload("res://src/ui/components/dialog_view.gd").build(ui, "Reliquias enlazadas", "\n".join(lines), [{"text":"Volver", "callback":ui.close_modal}]))
