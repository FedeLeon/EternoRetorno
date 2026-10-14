extends RefCounted
# Four civilian heroes: face portraits and full-body sketchbook crops.
const COLORS = {"warrior":"74637f", "guardian":"898191", "rogue":"635a70", "mage":"9679b3"}
const SKETCH_CROPS = {"warrior":Rect2(0.045,0.04,0.205,0.54), "guardian":Rect2(0.29,0.06,0.21,0.54), "rogue":Rect2(0.54,0.05,0.205,0.54), "mage":Rect2(0.79,0.06,0.205,0.54)}
static func build(ui: Control, parent: Control, hero: String, title: String, position: Vector2, action: Callable, compact: bool = false, life: Dictionary = {}, card_size: Vector2 = Vector2.ZERO) -> Button:
	var dimensions = card_size if card_size != Vector2.ZERO else (Vector2(244, 166) if compact else Vector2(190, 338))
	var large_compact = compact and dimensions.y > 200
	var plaque_height = 50 if large_compact else (38 if compact else 53)
	var plaque_y = dimensions.y - plaque_height - (6 if compact else 7)
	var b = ui.button("", position.x, position.y, dimensions.x, dimensions.y, action, true, parent)
	b.name = "RefugeHero_" + hero
	var accent = Color(COLORS[hero])
	for state in ["normal", "hover", "pressed", "focus"]:
		b.add_theme_stylebox_override(state, ui.box(Color("141119"), accent.lightened(0.35) if state in ["hover", "focus"] else accent, 2))
	var crop = portrait(hero, compact)
	var picture = TextureRect.new()
	picture.name = "ComicPortrait"
	picture.texture = crop
	picture.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	picture.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED if compact and not large_compact and SKETCH_CROPS.has(hero) else TextureRect.STRETCH_KEEP_ASPECT_COVERED
	picture.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
	picture.mouse_filter = Control.MOUSE_FILTER_IGNORE
	ui.rect(picture, 6, 6, dimensions.x - 12, plaque_y - 10, b)
	var plaque = ui.panel(5, plaque_y, dimensions.x - 10, plaque_height, accent, b)
	plaque.add_theme_stylebox_override("panel", preload("res://src/ui/components/button_skin.gd").style("wood_button"))
	if life.is_empty():
		ui.label_at(title, 0, 0, dimensions.x - 10, 38 if compact else 53, 20 if compact else 22, ui.TEXT, plaque).horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	else:
		b.tooltip_text = life.hook + "\n" + life.voice
		ui.label_at(life.name, 0, 3 if large_compact else 0, dimensions.x-10, 24 if large_compact else (22 if compact else 28), 20 if large_compact else (18 if compact else 22), ui.TEXT, plaque).horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		ui.label_at((title if life.occupation == title else life.occupation + " · " + title), 0, 28 if large_compact else (21 if compact else 28), dimensions.x-10, 18 if large_compact else (16 if compact else 22), 12 if large_compact else (11 if compact else 12), ui.GOLD, plaque).horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	return b

static func portrait(hero: String, compact: bool) -> AtlasTexture:
	var crop = AtlasTexture.new()
	if compact and SKETCH_CROPS.has(hero):
		crop.atlas = load("res://assets/heroes/identity/portraits/%s.png" % hero)
		crop.region = Rect2(Vector2.ZERO, crop.atlas.get_size())
		return crop
	crop.atlas = load("res://assets/heroes/identity/rogue_unmasked.png") if hero == "rogue" else load("res://assets/heroes/identity/sketchbook.png")
	var region: Rect2 = Rect2(0.22, 0.035, 0.56, 0.52) if hero == "rogue" else SKETCH_CROPS[hero]
	crop.region = Rect2(region.position * crop.atlas.get_size(), region.size * crop.atlas.get_size())
	return crop
