extends RefCounted

# Camp presentation; construction and navigation are controller callbacks.
static func build(ui: Control, profile: Dictionary, actions: Dictionary) -> void:
	var fire = preload("res://src/campfire.gd").new()
	fire.name = "DayCampfire"
	ui.rect(fire, 643, 396, 1, 1)
	fire.scale = Vector2(0.62, 0.62)
	preload("res://src/ui/components/preparation_header.gd").build(ui, "El Campamento, un lugar al que volver...", actions.home, profile.souls)
	ui.camp_hotspot("CampExit", Rect2(960, 115, 155, 135), "Aventuras", actions.prepare)
	if profile.buildings.get("market", false):
		var building = TextureRect.new()
		building.name = "MarketBuilding"
		building.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		building.texture = preload("res://assets/base_camp/market_building.png")
		building.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		building.mouse_filter = Control.MOUSE_FILTER_IGNORE
		ui.rect(building, 91, 111, 310, 235)
	var plots = [Rect2(110, 279, 276, 47), Rect2(836, 299, 256, 40), Rect2(75, 414, 319, 59), Rect2(933, 476, 284, 56)]
	if profile.buildings.get("forge", false):
		var forge = TextureRect.new()
		forge.name = "ForgeBuilding"
		forge.texture = preload("res://assets/forge/building.png")
		forge.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		forge.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		forge.mouse_filter = Control.MOUSE_FILTER_IGNORE
		ui.rect(forge, 50, 289, 370, 224)
	for i in range(plots.size()):
		if i == 2:
			var hotspot = ui.camp_hotspot("Plot2", Rect2(50, 289, 370, 224) if profile.buildings.get("forge", false) else plots[2], "Herrería" if profile.buildings.get("forge", false) else "Solar 3 · Herrería", actions.forge)
			if profile.buildings.get("forge", false):
				hotspot.set_script(preload("res://src/ui/components/building_hotspot.gd"))
				hotspot.configure(preload("res://assets/forge/building.png"), Vector2(370, 224))
				var market_caption: Rect2 = ui.layer.get_node("Plot0").get_meta("caption_rect")
				market_caption.position -= hotspot.position
				hotspot.passthrough_areas.append(market_caption)
			continue
		if i == 0:
			ui.camp_hotspot("Plot0", Rect2(91, 111, 310, 235) if profile.buildings.get("market", false) else plots[0], "Mercado" if profile.buildings.get("market", false) else "Solar 1 · Mercado", actions.market, profile.buildings.get("market", false))
			continue
		var id = "church" if i == 1 else "expeditions"
		var built = profile.buildings.get(id, false)
		var area = Rect2(742, 212, 296, 176) if i == 1 else Rect2(888, 350, 342, 216)
		var title = "Iglesia" if i == 1 else "Expediciones"
		if built:
			var building = TextureRect.new()
			building.name = "ChurchBuilding" if i == 1 else "ExpeditionsBuilding"
			building.texture = load("res://assets/%s/building.png" % id)
			building.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
			building.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
			building.mouse_filter = Control.MOUSE_FILTER_IGNORE
			ui.rect(building, area.position.x, area.position.y, area.size.x, area.size.y)
		var hotspot = ui.camp_hotspot("Plot%d" % i, area if built else plots[i], title if built else "Solar %d · %s" % [i + 1, title], actions[id])
		if built:
			hotspot.set_script(preload("res://src/ui/components/building_hotspot.gd"))
			hotspot.configure(load("res://assets/%s/building.png" % id), area.size)
			var other = ui.layer.get_node("CampExit" if i == 1 else "Plot1")
			var caption: Rect2 = other.get_meta("caption_rect")
			caption.position -= hotspot.position
			hotspot.passthrough_areas.append(caption)
	ui.camp_hotspot("CampTent", Rect2(427, 240, 180, 107), "Refugio de personajes", actions.refuge)
