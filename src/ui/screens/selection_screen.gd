extends RefCounted
# Presentation only; controller owns party changes and preparation saves.
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
			b.add_theme_stylebox_override(state, ui.box(Color(0.1, 0.08, 0.04, 0.22) if chosen else Color(0, 0, 0, 0), ui.GOLD if chosen or state == "focus" else Color(0, 0, 0, 0), 2))
		var sprite = TextureRect.new()
		var texture = AtlasTexture.new()
		texture.atlas = ui.CAMP_FRONT
		texture.region = Rect2(i * 128, 0, 128, 128)
		sprite.texture = texture
		sprite.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		sprite.mouse_filter = Control.MOUSE_FILTER_IGNORE
		ui.rect(sprite, -6, -40, 192, 192, b)
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
	var names: Array[String] = []
	for id in ui.selected_party:
		names.append(ui.game.content.heroes[id].name)
	ui.label_at(" + ".join(names), 405, 669, 440, 30, 20, ui.TEXT)
	var choose = ui.button("Elegir reliquia  →", 894, 659, 350, 46, actions.equipment, ui.selected_party.size() == 2)

	choose.name = "ChooseRelic"
	preload("res://src/ui/components/button_skin.gd").decorate(choose, "relic_button")
