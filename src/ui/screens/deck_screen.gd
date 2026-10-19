extends RefCounted
# Read-only deck gallery. Upgrade selection remains in card_upgrade_screen.gd.
static func build(ui: Control) -> void:
	preload("res://src/ui/components/inventory_background.gd").build(ui)
	ui.panel(0, 0, 1280, 84)
	ui.label_at("El mazo compartido", 100, 18, 920, 48, 30, ui.TEXT)
	var battle = ui.game.run.combat
	var detail = "Total: %d cartas" % ui.game.run.deck.size()
	if ui.game.run.phase == "combat":
		var face_down = battle.get("reserved", []).size()
		detail += " · Mazo: %d · Mano: %d (%d boca abajo) · Descarte: %d · Inactivas: %d" % [battle.draw.size(), battle.hand.size() + face_down, face_down, battle.discard.size(), battle.inactive.size()]
	var frame = Panel.new()
	frame.name = "DeckSummaryFrame"
	frame.mouse_filter = Control.MOUSE_FILTER_IGNORE
	frame.add_theme_stylebox_override("panel", preload("res://src/ui/components/dark_skin.gd").dialog())
	ui.rect(frame, 36, 96, 1208, 44)
	ui.label_at(detail, 52, 103, 1176, 30, 17, ui.GOLD).name = "DeckSummary"
	var scroll = ScrollContainer.new()
	scroll.name = "DeckCards"
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	ui.rect(scroll, 36, 152, 1208, 548)
	var contents = Control.new()
	contents.custom_minimum_size = Vector2(1180, ceil(ui.game.run.deck.size() / 5.0) * 384)
	scroll.add_child(contents)
	for i in range(ui.game.run.deck.size()):
		var card = ui.card_panel(ui.game.run.deck[i], (i % 5) * 238, (i / 5) * 384, 224, 368, func(): pass, false, true, contents)
		card.mouse_filter = Control.MOUSE_FILTER_IGNORE
