extends RefCounted

# Snapshot-only presentation; transactions belong to Game/Progression.
static func build(ui: Control, content: RefCounted, profile: Dictionary, selected: String, actions: Dictionary) -> void:
	var background = TextureRect.new()
	background.texture = preload("res://assets/market/interior.png")
	background.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	background.mouse_filter = Control.MOUSE_FILTER_IGNORE
	ui.rect(background, 0, 0, 1280, 720)
	preload("res://src/ui/components/attendant_dialogue.gd").attach(ui, "market")
	ui.panel(24, 18, 1232, 66)
	ui.label_at("EL MERCADO DE LOS ECOS", 68, 28, 524, 42, 26, ui.GOLD)
	preload("res://src/ui/components/soul_counter.gd").attach(ui, profile.souls, Vector2(810, 25))
	ui.button("Campamento", 1070, 28, 166, 44, actions.back)
	if selected == "":
		preload("res://src/ui/components/building_hero_picker.gd").build(ui, content.heroes, "Elegí un héroe para descubrir nuevas cartas", "Category_", actions.category, true)
		return
	ui.panel(728, 104, 528, 570)
	var back = ui.button("Volver a héroes", 1046, 108, 192, 40, func(): actions.category.call(""))
	back.name = "BackToHeroes"
	back.add_theme_font_size_override("font_size", 16)
	ui.label_at(content.heroes[selected].name + " · Nuevas cartas", 780, 116, 258, 32, 18, ui.GOLD)
	ui.label_at("Comprar habilita su aparición tras ganar batallas.", 766, 158, 466, 26, 15, ui.TEXT)
	var scroll = ScrollContainer.new()
	ui.rect(scroll, 744, 190, 494, 465)
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	scroll.name = "MarketCards"
	var list = GridContainer.new()
	list.columns = 2
	list.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	list.add_theme_constant_override("h_separation", 14)
	list.add_theme_constant_override("v_separation", 18)
	scroll.add_child(list)
	for id in content.cards:
		var card = content.cards[id]
		if card.owner != selected or int(card.get("market_price", 0)) <= 0: continue
		var body = Control.new()
		body.custom_minimum_size = Vector2(228, 412)
		list.add_child(body)
		var preview = ui.card_panel({"id": id, "upgraded": false}, 4, 0, 220, 300, func(): pass, false, true, body, true)
		preview.name = "MarketCard_" + id
		preview.mouse_filter = Control.MOUSE_FILTER_IGNORE
		preview.focus_mode = Control.FOCUS_NONE
		var owned = id in profile.market_cards
		var buy = Button.new()
		buy.name = "Buy_" + id
		var price = preload("res://src/rules/building_projects.gd").price(profile,card)
		buy.text = "Habilitada" if owned else "Comprar · %d celdas" % price
		buy.disabled = owned or profile.souls < price
		buy.tooltip_text = "Ya disponible en recompensas" if owned else "Se conserva entre aventuras"
		buy.pressed.connect(func(): actions.buy.call(id))
		buy.add_theme_font_size_override("font_size", 16)
		ui.rect(buy, 0, 312, 228, 48, body)
		if not owned and preload("res://src/rules/building_projects.gd").owned(profile,"reservation"):
			var reserved=profile.get("reserved_card","")==id
			ui.button("Reservada · -20 celdas" if reserved else "Reservar carta",0,366,228,36,func():
				var position=scroll.scroll_vertical
				if ui.game.polish_action("reserve",{"id":id}): ui.render();ui.layer.get_node("MarketCards").set_deferred("scroll_vertical",position),not reserved,body).add_theme_font_size_override("font_size",15)
