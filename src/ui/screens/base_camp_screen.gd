extends RefCounted

# Dusk camp presentation; construction and navigation remain controller callbacks.
const ART = "res://assets/base_camp/dusk/"
static var textures: Dictionary = {}
const LOTS = [
	{"id":"market", "node":"MarketBuilding", "title":"Mercado", "area":Rect2(88,157,342,205), "plot":Rect2(140,300,220,70)},
	{"id":"expeditions", "node":"ExpeditionsBuilding", "title":"Expediciones", "area":Rect2(476,478,328,200), "plot":Rect2(530,580,220,80)},
	{"id":"forge", "node":"ForgeBuilding", "title":"Taller", "area":Rect2(56,376,350,224), "plot":Rect2(115,515,220,80)},
	{"id":"church", "node":"ChurchBuilding", "title":"Laboratorio", "area":Rect2(780,176,320,215), "plot":Rect2(840,315,220,75)}
]

static func build(ui: Control, profile: Dictionary, actions: Dictionary) -> void:
	var fire = preload("res://src/campfire.gd").new()
	fire.sheet = load(ART + "fire.png")
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
		var picture = artwork(ui, lot.node if built else "EmptyPlot%d" % i, lot.id if built else "plot", area)
		area = picture.get_rect()
		var hotspot = ui.camp_hotspot("Plot%d" % i, area, lot.title if built else "Solar %d · %s" % [i + 1, lot.title], actions[lot.id])
		if built:
			hotspot.set_script(preload("res://src/ui/components/building_hotspot.gd"))
			hotspot.configure(picture.texture, area.size)
	var refuge = artwork(ui, "RefugeBuilding", "refuge", Rect2(352,220,282,175))
	var tent = ui.camp_hotspot("CampTent", refuge.get_rect(), "Refugio de personajes", actions.refuge)
	tent.set_script(preload("res://src/ui/components/building_hotspot.gd"))
	tent.configure(refuge.texture, refuge.size)
	var projects = artwork(ui, "ProjectsBuilding", "projects", Rect2(866,416,282,183))
	var entrance = ui.camp_hotspot("ProjectsEntrance", projects.get_rect(), "Proyectos", func(): ui.screen = "projects"; ui.render())
	entrance.set_script(preload("res://src/ui/components/building_hotspot.gd"))
	entrance.configure(projects.texture, projects.size)
	protect_captions(ui)
	var training = ui.button("", 40, 630, 76, 76, func(): ui.screen = "training_setup"; ui.render())
	training.name = "TrainingEntrance"
	training.tooltip_text = "Entrenamiento contra el muñeco"
	training.icon = load(ART + "training.png")
	training.expand_icon = true
	training.add_theme_constant_override("icon_max_width", 62)

static func building_texture(asset: String) -> Texture2D:
	if textures.has(asset): return textures[asset]
	var original: Texture2D = load(ART + asset + ".png")
	if asset == "plot": return original
	var crop = AtlasTexture.new()
	crop.atlas = original
	crop.region = Rect2(original.get_image().get_used_rect())
	textures[asset] = crop
	return crop

static func artwork(ui: Control, node_name: String, asset: String, area: Rect2) -> TextureRect:
	var building = TextureRect.new()
	building.name = node_name
	building.texture = building_texture(asset)
	building.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	building.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	building.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
	building.mouse_filter = Control.MOUSE_FILTER_IGNORE
	if asset != "plot":
		var ratio = minf(area.size.x / building.texture.get_width(), area.size.y / building.texture.get_height())
		var drawn = building.texture.get_size() * ratio
		area = Rect2(Vector2(area.get_center().x - drawn.x / 2, area.end.y - drawn.y), drawn)
	ui.rect(building, area.position.x, area.position.y, area.size.x, area.size.y)
	return building

static func protect_captions(ui: Control) -> void:
	var entrances = ["Plot0", "Plot1", "Plot2", "Plot3", "CampTent", "CampExit", "ProjectsEntrance"]
	for id in entrances:
		var button = ui.layer.get_node(id)
		if not button.has_method("configure"): continue
		for other in entrances:
			if id == other: continue
			var caption: Rect2 = ui.layer.get_node(other).get_meta("caption_rect")
			button.passthrough_areas.append(Rect2(caption.position - button.position, caption.size))
