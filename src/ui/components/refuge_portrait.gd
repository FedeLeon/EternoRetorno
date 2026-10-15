extends RefCounted
# Shared civilian portraits, full-body cards and individual face framing.
const COLORS = {"warrior":"bd6be1", "guardian":"f0a657", "rogue":"69caa5", "mage":"75d8e6"}
const FACE_REGIONS = {
	"warrior": Rect2(310, 0, 240, 280),
	"guardian": Rect2(350, 0, 240, 280),
	"rogue": Rect2(362, 0, 276, 322),
	"mage": Rect2(280, 0, 240, 280)
}

static func face_texture(hero: String) -> AtlasTexture:
	var texture = portrait(hero, true).atlas
	var scale = texture.get_size() / Vector2(928, 464)
	var area: Rect2 = FACE_REGIONS[hero]
	var crop = AtlasTexture.new()
	crop.atlas = texture
	crop.region = Rect2(area.position * scale, area.size * scale)
	crop.filter_clip = true
	return crop

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
	picture.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED if compact and not large_compact and COLORS.has(hero) else TextureRect.STRETCH_KEEP_ASPECT_COVERED
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
	if compact and COLORS.has(hero):
		crop.atlas = load("res://assets/heroes/identity/portraits/%s.png" % hero)
		crop.region = Rect2(Vector2.ZERO, crop.atlas.get_size())
		return crop
	crop.atlas = load("res://assets/heroes/identity/postapocalyptic/%s.png" % hero)
	crop.region = Rect2(Vector2.ZERO,crop.atlas.get_size())
	return crop
