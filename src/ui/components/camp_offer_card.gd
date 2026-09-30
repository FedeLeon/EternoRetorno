extends RefCounted
# Shared illustrated offer shell. Rules and callbacks are supplied by the screen.
static func build(ui: Control, parent: Control, area: Rect2, art: String, title: String, description: String, portrait: bool = false) -> Control:
	var card = Control.new()
	ui.rect(card, area.position.x, area.position.y, area.size.x, area.size.y, parent)
	var panel = ui.panel(0, 0, area.size.x, area.size.y, Color("b49a67"), card)
	panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	if not portrait:
		panel.add_theme_stylebox_override("panel", preload("res://src/ui/components/dark_skin.gd").dialog())
	var picture = TextureRect.new()
	picture.texture = load(art)
	picture.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	picture.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED if portrait else TextureRect.STRETCH_KEEP_ASPECT_COVERED
	picture.mouse_filter = Control.MOUSE_FILTER_IGNORE
	ui.rect(picture, 12, 12, area.size.x - 24, 210 if portrait else 144, card)
	ui.label_at(title, 14, 226 if portrait else 166, area.size.x - 28, 46 if portrait else 66, 22 if portrait else 20, ui.GOLD, card).horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	ui.label_at(description, 20, 274 if portrait else 238, area.size.x - 40, 84 if portrait else 112, 18, ui.TEXT, card).horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	return card
