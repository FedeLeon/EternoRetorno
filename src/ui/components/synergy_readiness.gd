extends RefCounted
## Highlights only the two actual instances that can combine right now.
static func mark(ui: Control, contents: Control) -> void:
	for combo in ui.game.available_synergies():
		if ui.game.run.combat.energy < combo.cost: continue
		for card in contents.get_children():
			if int(card.get_meta("hand_index", -1)) not in combo.indices: continue
			var icon = TextureRect.new()
			icon.name = "SynergyReady"
			icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
			icon.texture = load("res://assets/synergies/%s.svg" % combo.id)
			icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
			icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
			icon.size = Vector2(32, 32)
			icon.position = Vector2(card.size.x - 36, card.size.y * 0.40)
			card.add_child(icon)
			var pulse = icon.create_tween().set_loops()
			pulse.tween_property(icon, "modulate", Color(1.3, 1.3, 1.3), 0.7)
			pulse.tween_property(icon, "modulate", Color.WHITE, 0.7)
