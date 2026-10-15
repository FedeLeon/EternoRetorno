extends RefCounted

# Shared UI factory + explicit view data and actions; no rule or save mutations.
static func build(ui: Control, relics: Dictionary, equipped: Dictionary, can_start: bool, actions: Dictionary) -> void:
	var background = TextureRect.new()
	background.name = "ValhallaBackground"
	background.texture = preload("res://assets/equipment/valhalla.png")
	background.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	background.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	background.mouse_filter = Control.MOUSE_FILTER_IGNORE
	ui.rect(background, 0, 0, 1280, 720)
	preload("res://src/ui/components/preparation_header.gd").build(ui, "Elegí tu componente · Prepará el descenso", actions.menu)
	var ids = relics.keys()
	for i in range(ids.size()):
		var id = ids[i]
		var relic = relics[id]
		var angle = -PI / 2.0 + TAU * i / ids.size()
		var center = Vector2(640, 378) + Vector2(cos(angle), sin(angle)) * 190.0
		var b = ui.button("", center.x - 66, center.y - 66, 132, 132, func(): actions.equip.call(id))
		b.name = "Equip_" + id
		if equipped.get("team", "") == id:
			preload("res://src/ui/components/equipment_description.gd").attach(ui, relic, center)
		for state in ["normal", "hover", "pressed", "disabled"]:
			b.add_theme_stylebox_override(state, StyleBoxEmpty.new())
		var icon = TextureRect.new()
		icon.name = "ComponentArt"
		icon.texture = preload("res://src/presentation/relic_art.gd").texture(relic)
		icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		icon.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
		icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
		ui.rect(icon, 0, 0, 132, 132, b)
		b.mouse_entered.connect(func(): b.modulate = Color(1.2, 1.2, 1.2))
		b.mouse_exited.connect(func(): b.modulate = Color.WHITE)
	var back = ui.button("Volver a personajes", 36, 647, 320, 54, actions.back)
	back.name = "BackToCharacters"
	var start = ui.button("Iniciar aventura", 904, 647, 340, 54, actions.start, can_start)
	start.name = "StartAdventure"
	start.icon = preload("res://assets/ui/play.svg")
	start.expand_icon = true
	start.alignment = HORIZONTAL_ALIGNMENT_LEFT
	start.add_theme_constant_override("icon_max_width", 38)
	start.add_theme_constant_override("h_separation", 12)
	preload("res://src/ui/components/button_skin.gd").decorate(back, "wood_button")
	preload("res://src/ui/components/button_skin.gd").decorate(start, "wood_button")
