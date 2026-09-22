extends RefCounted
# Presentation only; controller owns the current, non-persistent preparation.
static func build(ui: Control, actions: Dictionary) -> void:
	preload("res://src/ui/components/preparation_header.gd").build(ui, "Elegí tus personajes · El fuego nos reúne", actions.menu)
	ui.label_at("Tocá a dos personajes para formar tu pareja de aventura.", 28, 88, 1100, 30, 18, ui.TEXT)
	var fire = ui.Campfire.new()
	fire.name = "Campfire"
	ui.rect(fire, 640, 471, 1, 1)
	var ids = ui.game.content.heroes.keys()
	for i in range(ids.size()):
		var id = ids[i]
		var h = ui.game.content.heroes[id]
		var pos = ui.CAMP_POSITIONS[i]
		var chosen = id in ui.selected_party
		var b = ui.button("", pos.x - 90, pos.y - 140, 180, 198, func(): actions.toggle.call(id))
		b.name = "CampHero_" + id
		b.tooltip_text = h.name + " · " + h.role + "\n" + h.lore
		for state in ["normal", "hover", "pressed", "focus"]:
			b.add_theme_stylebox_override(state, StyleBoxEmpty.new())
		preload("res://src/ui/components/target_glow.gd").attach(b, chosen)
		if chosen:
			var glow = b.get_node("TargetGlow")
			glow.position = Vector2(-6, -40)
			glow.size = Vector2(192, 192)
		var sprite = TextureRect.new()
		sprite.name = "SeatedHero"
		sprite.texture = load("res://assets/rest/%s.png" % id)
		sprite.flip_h = pos.x > 640
		sprite.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		preload("res://src/presentation/firelight.gd").attach(sprite, i * 0.6)
		sprite.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		sprite.mouse_filter = Control.MOUSE_FILTER_IGNORE
		ui.rect(sprite, -24, -42, 228, 182, b)
		ui.panel(0, 141, 180, 57, Color("343b4d"), b)
		var name_label = ui.label_at(("✓ " if chosen else "") + h.name, 4, 143, 172, 27, 21, ui.GOLD if chosen else ui.TEXT, b)
		name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		var detail = ui.label_at("%s · %d PV" % [h.role, h.hp], 2, 172, 176, 22, 14, Color(h.color), b)
		detail.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	var footer = ui.panel(24, 647, 1232, 70)
	footer.name = "PartyFooter"
	footer.add_theme_stylebox_override("panel", preload("res://src/ui/components/button_skin.gd").style("party_panel"))
	ui.button("Volver", 36, 659, 145, 46, actions.back)
	ui.label_at("%d / 2 elegidos" % ui.selected_party.size(), 185, 669, 210, 30, 20, ui.GOLD)
	var choose = ui.button("Elegir reliquia", 894, 659, 350, 46, actions.equipment, ui.selected_party.size() == 2)

	choose.name = "ChooseRelic"
	preload("res://src/ui/components/button_skin.gd").decorate(choose, "wood_button")
