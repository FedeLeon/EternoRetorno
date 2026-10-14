extends RefCounted

# Dusk camp presentation; construction and navigation remain controller callbacks.
const ART = "res://assets/base_camp/dusk/"
const LOTS = [
	{"id":"market", "node":"MarketBuilding", "title":"Mercado", "area":Rect2(115,190,270,185), "plot":Rect2(140,300,220,70)},
	{"id":"expeditions", "node":"ExpeditionsBuilding", "title":"Expediciones", "area":Rect2(485,505,310,170), "plot":Rect2(530,580,220,80)},
	{"id":"forge", "node":"ForgeBuilding", "title":"Herrería", "area":Rect2(70,400,310,200), "plot":Rect2(115,515,220,80)},
	{"id":"church", "node":"ChurchBuilding", "title":"Iglesia", "area":Rect2(825,205,250,190), "plot":Rect2(840,315,220,75)}
]

static func build(ui: Control, profile: Dictionary, actions: Dictionary) -> void:
	var fire = preload("res://src/campfire.gd").new()
	fire.sheet = load(ART + "fire.png")
	fire.baselines = preload("res://src/data/json_catalog.gd").dictionary("res://data/camp_fire_dusk.json").baselines
	fire.fps = 12.0
	fire.sketch_style = true
	fire.name = "DayCampfire"
	ui.rect(fire, 643, 475, 1, 1)
	fire.scale = Vector2(0.62, 0.62)
	preload("res://src/ui/components/preparation_header.gd").build(ui, "El Campamento, un lugar al que volver...", actions.home, profile.souls)
	ui.camp_hotspot("CampExit", Rect2(1100,145,150,140), "Aventuras", actions.prepare)
	for i in range(LOTS.size()):
		var lot: Dictionary = LOTS[i]
		var built: bool = profile.buildings.get(lot.id, false)
		var area: Rect2 = lot.area if built else lot.plot
		artwork(ui, lot.node if built else "EmptyPlot%d" % i, lot.id if built else "plot", area)
		var hotspot = ui.camp_hotspot("Plot%d" % i, area, lot.title if built else "Solar %d · %s" % [i + 1, lot.title], actions[lot.id])
		if built:
			hotspot.set_script(preload("res://src/ui/components/building_hotspot.gd"))
			hotspot.configure(load(ART + lot.id + ".png"), area.size)
	artwork(ui, "RefugeBuilding", "refuge", Rect2(360,230,265,165))
	ui.camp_hotspot("CampTent", Rect2(360,230,265,165), "Refugio de personajes", actions.refuge)
	artwork(ui, "ProjectsBuilding", "projects", Rect2(875,435,255,170))
	ui.camp_hotspot("ProjectsEntrance", Rect2(875,435,255,170), "Proyectos", func(): ui.screen = "projects"; ui.render())
	var training = ui.button("", 40, 630, 76, 76, func(): ui.screen = "training_setup"; ui.render())
	training.name = "TrainingEntrance"
	training.tooltip_text = "Entrenamiento contra el muñeco"
	training.icon = load(ART + "training.png")
	training.expand_icon = true
	training.add_theme_constant_override("icon_max_width", 62)

static func artwork(ui: Control, node_name: String, asset: String, area: Rect2) -> void:
	var building = TextureRect.new()
	building.name = node_name
	building.texture = load(ART + asset + ".png")
	building.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	building.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	building.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
	building.mouse_filter = Control.MOUSE_FILTER_IGNORE
	ui.rect(building, area.position.x, area.position.y, area.size.x, area.size.y)
