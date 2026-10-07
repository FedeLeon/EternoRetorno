extends RefCounted
static func build(ui: Control) -> void:
	var bg = TextureRect.new()
	bg.texture = preload("res://assets/combat_depth/merchant.png")
	bg.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	ui.rect(bg, 0, 0, 1280, 720)
	ui.panel(20, 12, 1240, 116)
	ui.header("El mercader errante", ("Contraseña aceptada · %d almas" if ui.game.run.get("merchant_discount", false) else "Provisiones para el camino · %d almas") % ui.game.profile.souls)
	for child in ui.layer.get_children():
		if child is Button and child.text == "Menú": child.hide()
	ui.button("Continuar", 1020, 22, 220, 42, func(): ui.act(func(): ui.game.merchant_action("leave")))
	var offers: Array = ui.game.run.get("merchant_offers", [])
	for i in range(offers.size()):
		var offer: Dictionary = offers[i]
		var item: Dictionary = ui.game.content.items[offer.item]
		var tile = ui.panel(550, 145 + i * 126, 650, 110)
		ui.label_at(item.name + " · %d almas" % offer.price, 20, 8, 610, 32, 22, ui.GOLD, tile)
		ui.label_at(item.description, 20, 40, 440, 58, 17, ui.TEXT, tile)
		ui.button("Vendido" if offer.sold else "Comprar", 466, 51, 165, 42, func(): ui.game.merchant_action("buy", i); ui.render(), not offer.sold and ui.game.profile.souls >= offer.price, tile)
	var relic_id: String = ui.game.run.get("merchant_relic", "")
	if not relic_id.is_empty():
		ui.panel(550, 533, 650, 145)
		ui.label_at("Intercambiar por " + ui.game.content.relics[relic_id].name, 570, 539, 610, 34, 22, ui.GOLD)
		ui.label_at(ui.game.content.relics[relic_id].description, 570, 575, 610, 46, 17, ui.TEXT)
		var selector = OptionButton.new()
		for i in range(ui.game.run.relics.size()):
			var relic: Dictionary = ui.game.content.relics[ui.game.run.relics[i]]
			if relic.get("condition", "") != "max_hp": selector.add_item(relic.name, i)
		selector.tooltip_text = "Las reliquias que aumentan la vida máxima no se intercambian."
		if selector.item_count == 0: selector.text = "Sin reliquias intercambiables"
		ui.rect(selector, 570, 628, 370, 38)
		ui.button("Intercambiar", 950, 626, 230, 42, func():
			ui.game.merchant_action("trade", selector.get_selected_id()); ui.render(), not ui.game.run.get("merchant_traded", false) and selector.item_count > 0, ui.layer)
