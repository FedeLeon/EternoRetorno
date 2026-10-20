extends RefCounted
# Presentation only; controller owns the current, non-persistent preparation.
static func build(ui: Control, actions: Dictionary) -> void:
	preload("res://src/ui/components/preparation_header.gd").build(ui, "Elegí tus personajes · El fuego nos reúne", actions.menu)
	var selection_frame = ui.panel(280, 104, 720, 104)
	selection_frame.name = "PartySelectionFrame"
	selection_frame.add_theme_stylebox_override("panel", preload("res://src/ui/components/button_skin.gd").style("party_panel"))
	var instruction = ui.label_at("Tocá a dos personajes para formar tu pareja de aventura.", 20, 12, 680, 42, 23, ui.TEXT, selection_frame)
	instruction.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	var count = ui.label_at("%d / 2 elegidos" % ui.selected_party.size(), 20, 58, 680, 32, 22, ui.GOLD, selection_frame)
	count.name = "PartySelectionCount"
	count.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	var fire = ui.Campfire.new()
	fire.name = "Campfire"
	fire.embers_only = true
	ui.rect(fire, 640, 471, 1, 1)
	var ids = preload("res://src/rules/hero_roster.gd").ids(ui.game.content.heroes)
	for i in range(ids.size()):
		var id = ids[i]
		var h = ui.game.content.heroes[id]
		var pos = ui.CAMP_POSITIONS[i]
		var chosen = id in ui.selected_party
		var b = ui.button("", pos.x - 98, pos.y - 250, 196, 308, func(): actions.toggle.call(id))
		b.name = "CampHero_" + id
		b.tooltip_text = h.name + " · " + h.role + "\n" + h.lore
		for state in ["normal", "hover", "pressed", "focus"]:
			b.add_theme_stylebox_override(state, StyleBoxEmpty.new())
		preload("res://src/ui/components/target_glow.gd").attach(b, chosen)
		if chosen:
			var glow = b.get_node("TargetGlow")
			glow.position = Vector2(-6, -6)
			glow.size = Vector2(208, 262)
		var sprite = TextureRect.new()
		sprite.name = "SeatedHero"
		sprite.texture = preload("res://src/presentation/seated_hero_art.gd").texture(id)
		sprite.flip_h = pos.x > 640
		sprite.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		preload("res://src/presentation/firelight.gd").attach(sprite, i * 0.6)
		sprite.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		sprite.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
		sprite.mouse_filter = Control.MOUSE_FILTER_IGNORE
		b.add_child(sprite)
		preload("res://src/presentation/seated_hero_art.gd").fit(sprite, id, Rect2(0, 0, 196, 250))
		ui.panel(8, 251, 180, 57, Color("343b4d"), b)
		var name_label = ui.label_at(("✓ " if chosen else "") + h.name, 12, 253, 172, 32, 20, ui.GOLD if chosen else ui.TEXT, b)
		name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		var detail = ui.label_at("%s · %d PV" % [h.role, h.hp], 10, 282, 176, 22, 14, Color(h.color), b)
		detail.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	var footer = ui.panel(24, 647, 1232, 70)
	footer.name = "PartyFooter"
	footer.add_theme_stylebox_override("panel", preload("res://src/ui/components/button_skin.gd").style("party_panel"))
	var choose = ui.button("Elegir componente", 894, 659, 350, 46, actions.equipment, ui.selected_party.size() == 2)

	choose.name = "ChooseRelic"
	preload("res://src/ui/components/button_skin.gd").decorate(choose, "wood_button")
