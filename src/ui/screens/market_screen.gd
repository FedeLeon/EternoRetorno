extends RefCounted

# Snapshot-only presentation; transactions belong to Game/Progression.
static func build(ui: Control, content: RefCounted, profile: Dictionary, selected: String, actions: Dictionary) -> void:
	var background = TextureRect.new()
	background.texture = preload("res://assets/market/interior.png")
	background.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	background.mouse_filter = Control.MOUSE_FILTER_IGNORE
	ui.rect(background, 0, 0, 1280, 720)
	ui.panel(24, 18, 1232, 66)
	ui.label_at("EL MERCADO DE LOS ECOS", 42, 28, 550, 42, 26, ui.GOLD)
	preload("res://src/ui/components/soul_counter.gd").attach(ui, profile.souls, Vector2(810, 25))
	ui.button("Campamento", 1070, 28, 166, 44, actions.back)
	ui.label_at("Elegí un héroe", 576, 100, 210, 30, 21, ui.GOLD)
	var ids = content.heroes.keys()
	for i in range(ids.size()):
		var id = ids[i]
		var hero = content.heroes[id]
		var b = ui.button("", 582, 142 + i * 90, 122, 82, func(): actions.category.call(id))
		b.name = "Category_" + id
		var frame = TextureRect.new()
		frame.texture = load("res://assets/cards/%s.png" % id)
		frame.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		frame.mouse_filter = Control.MOUSE_FILTER_IGNORE
		ui.rect(frame, 0, 0, 122, 82, b)
		var portrait = TextureRect.new()
		portrait.name = "HeroPortrait"
		portrait.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		portrait.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		portrait.mouse_filter = Control.MOUSE_FILTER_IGNORE
		portrait.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		var crop = AtlasTexture.new()
		crop.atlas = ui.CAMP_FRONT
		crop.region = Rect2(i * 128, 0, 128, 128)
		portrait.texture = crop
		ui.rect(portrait, 19, -3, 84, 66, b)
		var caption = ui.label_at(hero.name, 5, 55, 112, 24, 16, ui.GOLD if selected == id else ui.TEXT, b)
		caption.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	ui.panel(728, 104, 528, 570)
	ui.label_at(content.heroes[selected].name + " · Nuevas cartas", 744, 112, 488, 32, 23, ui.GOLD)
	ui.label_at("Comprar habilita su aparición tras ganar batallas.", 744, 148, 488, 32, 16, ui.TEXT)
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
		body.custom_minimum_size = Vector2(228, 364)
		list.add_child(body)
		var preview = ui.card_panel({"id": id, "upgraded": false}, 4, 0, 220, 300, func(): pass, false, true, body, true)
		preview.name = "MarketCard_" + id
		preview.mouse_filter = Control.MOUSE_FILTER_IGNORE
		preview.focus_mode = Control.FOCUS_NONE
		var owned = id in profile.market_cards
		var buy = Button.new()
		buy.name = "Buy_" + id
		buy.text = "Habilitada" if owned else "Comprar · %d almas" % card.market_price
		buy.disabled = owned or profile.souls < card.market_price
		buy.tooltip_text = "Ya disponible en recompensas" if owned else "Se conserva entre aventuras"
		buy.pressed.connect(func(): actions.buy.call(id))
		buy.add_theme_font_size_override("font_size", 16)
		ui.rect(buy, 0, 312, 228, 48, body)
