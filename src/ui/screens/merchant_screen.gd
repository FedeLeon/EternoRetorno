extends RefCounted
static func build(ui: Control) -> void:
	var bg = TextureRect.new()
	bg.texture = preload("res://assets/combat_depth/merchant.png")
	bg.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	ui.rect(bg, 0, 0, 1280, 720)
	preload("res://src/ui/components/section_header.gd").build(ui,"El mercader errante", ("Contraseña aceptada · %d celdas" if ui.game.run.get("merchant_discount", false) else "Provisiones para el camino · %d celdas") % ui.game.profile.souls,func(): ui.act(func(): ui.game.merchant_action("leave")),"Continuar",220)
	if not ui.game.run.get("curses",[]).is_empty():
		ui.button("Limpiar avería · 35 celdas",46,586,430,48,func(): ui.act(func():ui.game.polish_action("cleanse")),ui.game.profile.souls>=35)
	var offers: Array = ui.game.run.get("merchant_offers", [])
	var scroll = ScrollContainer.new()
	scroll.name = "MerchantOffers"
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	ui.rect(scroll,550,145,650,365)
	var offer_list = Control.new()
	offer_list.custom_minimum_size = Vector2(630,offers.size()*164)
	scroll.add_child(offer_list)
	for i in range(offers.size()):
		var offer: Dictionary = offers[i]
		var item: Dictionary = ui.game.content.items[offer.item]
		var tile = ui.panel(0, i * 164, 630, 150, ui.GOLD, offer_list)
		ui.object_icon(item.icon,20,25,56,tile)
		ui.label_at(item.name + " · %d celdas" % offer.price, 94, 8, 516, 32, 20, ui.GOLD, tile)
		ui.label_at(item.description, 94, 40, 338, 96, 17, ui.TEXT, tile)
		ui.button("Vendido" if offer.sold else "Comprar", 446, 65, 165, 42, func():
			var offset = scroll.scroll_vertical
			ui.game.merchant_action("buy", i); ui.render()
			ui.layer.get_node("MerchantOffers").set_deferred("scroll_vertical",offset), not offer.sold and ui.game.profile.souls >= offer.price, tile)
	var relic_id: String = ui.game.run.get("merchant_relic", "")
	if not relic_id.is_empty():
		ui.panel(550, 524, 650, 178)
		ui.label_at("Intercambiar por " + ui.game.content.relics[relic_id].name, 570, 530, 610, 34, 22, ui.GOLD)
		ui.label_at(ui.game.content.relics[relic_id].description, 570, 565, 610, 65, 17, ui.TEXT)
		var selector = OptionButton.new()
		for i in range(ui.game.run.relics.size()):
			var relic: Dictionary = ui.game.content.relics[ui.game.run.relics[i]]
			if relic.get("condition", "") != "max_hp": selector.add_item(relic.name, i)
		selector.tooltip_text = "Los componentes que aumentan la vida máxima no se intercambian."
		if selector.item_count == 0: selector.text = "Sin componentes intercambiables"
		ui.rect(selector, 570, 644, 370, 42)
		ui.button("Intercambiar", 950, 644, 230, 42, func():
			ui.game.merchant_action("trade", selector.get_selected_id()); ui.render(), not ui.game.run.get("merchant_traded", false) and selector.item_count > 0, ui.layer)
