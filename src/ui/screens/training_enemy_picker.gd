extends RefCounted
## Read-only discovered-enemy gallery; the configuration dialog owns the draft.
static func open(ui: Control, ids: Array, selected: String, choose: Callable, cancel: Callable) -> void:
	ui.close_modal()
	var overlay = Control.new()
	overlay.name = "TrainingEnemyPicker"
	overlay.z_as_relative = false
	overlay.z_index = 200
	ui.rect(overlay, 0, 0, 1280, 720, ui)
	ui.overlay = overlay
	var shade = ColorRect.new()
	shade.color = Color(0, 0, 0, .9)
	ui.rect(shade, 0, 0, 1280, 720, overlay)
	ui.panel(100, 36, 1080, 648, ui.GOLD, overlay)
	ui.label_at("Elegir rival · Enemigos descubiertos", 124, 48, 780, 48, 27, ui.GOLD, overlay)
	ui.button("Volver", 1000, 52, 150, 40, cancel, true, overlay)
	ui.button("Dejar este espacio vacío", 124, 108, 420, 42, func(): choose.call(""), true, overlay).name = "ClearRival"
	ui.label_at("Sin rivales elegidos, practicarás contra el maniquí.", 564, 108, 584, 42, 17, ui.MUTED, overlay)
	var scroll = ScrollContainer.new()
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	ui.rect(scroll, 124, 166, 1032, 492, overlay)
	var grid = Control.new()
	grid.custom_minimum_size = Vector2(1008, ceili(ids.size() / 4.0) * 244)
	scroll.add_child(grid)
	if ids.is_empty():
		ui.label_at("Todavía no descubriste enemigos. Podés entrenar contra el maniquí.", 12, 40, 972, 80, 23, ui.TEXT, grid)
	for i in range(ids.size()):
		var id: String = ids[i]
		var enemy: Dictionary = ui.game.content.enemies[id]
		var card = ui.button("", (i % 4) * 252, (i / 4) * 244, 238, 232, func(): choose.call(id), true, grid)
		card.name = "Rival_" + id
		card.tooltip_text = enemy.name
		if id == selected: card.modulate = Color(1.2, 1.35, 1.25)
		var picture = TextureRect.new()
		picture.texture = load("res://assets/combat_static/enemies/%s/idle.png" % enemy.visual)
		picture.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		picture.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		picture.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
		picture.mouse_filter = Control.MOUSE_FILTER_IGNORE
		ui.rect(picture, 14, 12, 210, 162, card)
		var label = ui.label_at(enemy.name, 12, 176, 214, 46, 19, ui.TEXT, card)
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
