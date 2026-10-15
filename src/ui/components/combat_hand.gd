extends RefCounted
## Hand composition stays separate from the battle actors and HUD.
static func build(ui: Control) -> void:
	var b: Dictionary = ui.game.run.combat
	var layout = preload("res://src/ui/components/combat_layout.gd")
	var reserve = preload("res://src/ui/card_reserve_navigation.gd")
	var reserved: Array = b.get("reserved", [])
	var slot = clampi(int(b.get("reserved_index", 0)), 0, b.hand.size()) if not reserved.is_empty() else -1
	var count: int = b.hand.size() + reserved.size()
	var scroll = ScrollContainer.new()
	scroll.name = "CombatHand"
	ui.rect(scroll, 160, layout.HAND_TOP, 954, 720 - layout.HAND_TOP)
	scroll.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_AUTO
	var contents = Control.new()
	contents.custom_minimum_size = Vector2(ui.HandLayout.content_width(count), 720 - layout.HAND_TOP)
	scroll.add_child(contents)
	scroll.set_deferred("scroll_horizontal", ui.hand_scroll)
	var drag = preload("res://src/ui/components/card_drag.gd").install(ui)
	var selected: Control
	for position in range(count):
		var face_down = position == slot
		var i = position - (1 if slot >= 0 and position > slot else 0)
		var instance: Dictionary = reserved[0] if face_down else b.hand[i]
		var chosen = not face_down and i == ui.selected_card
		var card = ui.card_panel(instance, 0, 0, layout.SELECTED_SIZE.x if chosen else 174, layout.SELECTED_SIZE.y if chosen else 278, func():
			if face_down: reserve.unreserve(ui, ui.layer.find_child("ReservedCard", true, false))
			else: ui.select_card(i), chosen, face_down or not ui.game.valid_targets(i).is_empty(), contents)
		card.disabled = false
		ui.HandLayout.arrange(card, position, count, chosen)
		if face_down:
			reserve.cover(ui, card, instance)
		else:
			card.set_meta("hand_index", i)
			drag.bind(card, i)
			if chosen: selected = card
	preload("res://src/ui/components/synergy_readiness.gd").mark(ui, contents)
	reserve.decorate(ui, selected, ui.selected_card)
	if count == 0:
		ui.label_at("Terminá el turno para robar cartas.", 380, 590, 640, 70, 24, ui.MUTED)
