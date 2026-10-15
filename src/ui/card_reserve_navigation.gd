extends RefCounted
const Rule = preload("res://src/rules/card_reserve.gd")
const Flip = preload("res://src/presentation/card_flip.gd")

static func back_for(ui: Control, instance: Dictionary) -> Texture2D:
	return load("res://assets/cards/backs/%s.png" % ui.game.content.cards[instance.id].owner)

static func decorate(ui: Control, card: Control, index: int) -> void:
	var active = Rule.can_unreserve(ui.game)
	var button = ui.button("Recuperar carta" if active else "Guardar carta", 1120, 510, 136, 42, func():
		if active: unreserve(ui, ui.layer.find_child("ReservedCard", true, false))
		else: reserve(ui, card, index), active or Rule.can_reserve(ui.game, index))
	button.name = "ReserveCard"
	button.tooltip_text = "Una carta boca abajo se conserva para el próximo turno. Tocala para recuperarla y poder guardar otra."
	button.add_theme_font_size_override("font_size", 14)
	button.mouse_filter = Control.MOUSE_FILTER_STOP
	button.z_index = 20

static func cover(ui: Control, card: Control, instance: Dictionary) -> void:
	card.name = "ReservedCard"
	card.tooltip_text = ui.game.content.card(instance).name + " · Guardada\nTocá para volver a ponerla de frente."
	for child in card.get_children():
		if child is CanvasItem: child.hide()
	var back = TextureRect.new()
	back.name = "CardBackCover"
	back.texture = back_for(ui, instance)
	back.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	back.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	back.mouse_filter = Control.MOUSE_FILTER_IGNORE
	back.size = card.size
	card.add_child(back)

static func unreserve(ui: Control, card: Control) -> void:
	if ui.combat_busy or is_instance_valid(ui.overlay) or not is_instance_valid(card) or not Rule.can_unreserve(ui.game): return
	var index = clampi(int(ui.game.run.combat.get("reserved_index", 0)), 0, ui.game.run.combat.hand.size())
	var texture = back_for(ui, ui.game.run.combat.reserved[0])
	if not ui.game.unreserve_card(): return
	ui.combat_busy = true
	ui.selected_card = index
	ui.selected_synergy = ""
	card.get_node("CardBackCover").free()
	await Flip.play(card, texture, false)
	ui.combat_busy = false
	ui.render()

static func reserve(ui: Control, card: Control, index: int) -> void:
	if ui.combat_busy or ui.overlay != null or not Rule.can_reserve(ui.game, index): return
	var texture = back_for(ui, ui.game.run.combat.hand[index])
	if not ui.game.reserve_card(index): return
	ui.combat_busy = true
	ui.selected_card = -1
	ui.selected_synergy = ""
	await Flip.play(card, texture, true)
	ui.combat_busy = false
	ui.render()

static func reveal(ui: Control) -> void:
	var hand = ui.layer.find_child("CombatHand", true, false)
	if hand == null or hand.get_child(0).get_child_count() == 0: return
	ui.combat_busy = true
	var card = hand.get_child(0).get_child(0)
	await Flip.play(card, back_for(ui, ui.game.run.combat.hand[0]), false)
	ui.combat_busy = false
