extends RefCounted
static func build(ui: Control) -> void:
	var bg = TextureRect.new();bg.texture = preload("res://assets/reward/background.png");bg.expand_mode = TextureRect.EXPAND_IGNORE_SIZE;bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	ui.rect(bg,0,0,1280,720)
	ui.panel(20,12,1240,92)
	ui.label_at("El legado del guardián",60,24,1010,58,32,ui.GOLD)
	ui.button("Menú",1124,32,110,44,ui.pause_menu)
	ui.label_at("Elegí una reliquia exclusiva. Su efecto permanece durante esta aventura.",100,122,1080,44,21,ui.TEXT).horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	var offers: Array = ui.game.run.get("boss_offers",[])
	for i in range(offers.size()):
		var id: String = offers[i];var relic: Dictionary = ui.game.content.relics[id]
		var tile = ui.panel(70+i*388,198,364,434)
		var icon = TextureRect.new();icon.texture = load(relic.asset);icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE;icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED;icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
		ui.rect(icon,94,22,176,176,tile)
		ui.label_at(relic.name,24,210,316,58,24,ui.GOLD,tile).horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		ui.label_at(relic.description,24,276,316,76,20,ui.TEXT,tile).horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		ui.button("Elegir reliquia",24,364,316,48,func(): ui.act(func(): ui.game.polish_action("boss_relic",{"id":id})),true,tile).name = "BossRelic_"+id
