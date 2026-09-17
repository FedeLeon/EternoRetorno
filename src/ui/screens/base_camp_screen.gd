extends RefCounted

# Camp presentation; construction and navigation are controller callbacks.
static func build(ui: Control, profile: Dictionary, actions: Dictionary) -> void:
	preload("res://src/ui/components/preparation_header.gd").build(ui, "El Campamento, un lugar al que volver...", actions.home, profile.souls)
	ui.camp_hotspot("CampExit", Rect2(960, 115, 155, 135), "Aventuras →", actions.prepare)
	if profile.buildings.get("market", false):
		var building = TextureRect.new()
		building.name = "MarketBuilding"
		building.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		building.texture = preload("res://assets/base_camp/market_building.png")
		building.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		building.mouse_filter = Control.MOUSE_FILTER_IGNORE
		ui.rect(building, 91, 111, 310, 235)
	var plots = [Rect2(110, 279, 276, 47), Rect2(836, 299, 256, 40), Rect2(75, 414, 319, 59), Rect2(933, 476, 284, 56)]
	for i in range(plots.size()):
		if i == 0:
			ui.camp_hotspot("Plot0", Rect2(91, 111, 310, 235) if profile.buildings.get("market", false) else plots[0], "Mercado · Entrar" if profile.buildings.get("market", false) else "Solar 1 · Mercado", actions.market)
			continue
		ui.camp_hotspot("Plot%d" % i, plots[i], "Solar %d · Sin construir" % (i + 1), func():
			ui.show_modal("Solar disponible", "Aquí podrás construir un edificio para tu campamento.\nLas construcciones y sus ventajas todavía no están disponibles.", "Entendido", actions.close_modal))
	ui.camp_hotspot("CampTent", Rect2(427, 240, 180, 107), "Refugio de personajes", func():
		ui.show_modal("Refugio de personajes", "Este será el lugar para mejorar a tus personajes entre aventuras.\nLas mejoras todavía no están disponibles.", "Entendido", actions.close_modal))
