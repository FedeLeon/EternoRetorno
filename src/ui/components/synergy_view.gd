extends RefCounted
# UI factory only. Eligibility and damage are supplied by the rules layer.
static func description(combo: Dictionary) -> String:
	var text = "%d de daño%s." % [combo.damage, " penetrante" if combo.pierce else ""]
	if combo.poison > 0: text += "\n%d de corrosión." % combo.poison
	if combo.block > 0: text += "\n%d de bloqueo a ambos." % combo.block
	if combo.heal > 0: text += "\nCura %d a ambos." % combo.heal
	var tactic = combo.get("tactic_text", "")
	if not tactic.is_empty(): text += "\n" + tactic
	return text

static func build(ui: Control, combos: Array, selected: String, energy: int, cards: Dictionary, select: Callable) -> void:
	for i in range(combos.size()):
		var combo = combos[i]
		var chosen = selected == combo.id
		var caption = "%s\nCombinar · %d energía" % [combo.name, combo.cost]
		var crowded: bool = ui.game.run.combat.enemies.size() >= 3
		var b = ui.button(caption, 12 if crowded else 530, 424 if crowded else 113 + i * 70, 136 if crowded else 228, 94 if crowded else 64, func(): select.call(combo.id))
		b.name = "Synergy_" + combo.id
		b.icon = load("res://assets/synergies/%s.svg" % combo.id)
		b.add_theme_constant_override("icon_max_width", 36)
		b.expand_icon = true
		b.modulate = Color.WHITE if energy >= combo.cost else Color(0.65, 0.65, 0.7)
		b.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		b.add_theme_font_size_override("font_size", 14 if crowded else 16)
		b.add_theme_color_override("font_color", ui.GOLD if chosen else ui.TEXT)
		b.tooltip_text = "%s + %s\n%s\nDescarta ambas cartas." % [cards[combo.cards[0]].name, cards[combo.cards[1]].name, description(combo)]
		if chosen and not crowded:
			var note = description(combo) + ("\nTocá un enemigo." if energy >= combo.cost else "\nFalta energía.")
			ui.panel(530, 185, 228, 214)
			ui.label_at(note, 534, 189, 220, 206, 16, ui.GOLD)

static func mark(_ui: Control, button: Button, card_id: String, recipes: Array, cards: Dictionary) -> void:
	var partners: Array[String] = []
	for combo in recipes:
		if card_id not in combo.cards: continue
		var other = combo.cards[1] if card_id == combo.cards[0] else combo.cards[0]
		partners.append("%s + %s: %s (%d energía)" % [cards[card_id].name, cards[other].name, combo.name, combo.cost])
	if partners.is_empty(): return
	button.tooltip_text += "\nSinergias (ambas cartas en mano):\n" + "\n".join(partners)

static func hint(ui: Control, card_id: String, recipes: Array, party: Array, cards: Dictionary) -> void:
	for combo in recipes:
		if card_id not in combo.cards or not combo.heroes.all(func(id): return id in party): continue
		var other = combo.cards[1] if card_id == combo.cards[0] else combo.cards[0]
		ui.panel(530, 109, 228, 216)
		ui.label_at("%s\nCombiná con:\n%s\nAmbas deben estar en la mano y ambos héroes vivos." % [combo.name, cards[other].name], 534, 113, 220, 210, 17, ui.GOLD)
