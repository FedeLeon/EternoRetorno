extends RefCounted
# Runtime crops of existing comic art: no duplicate hero images.
const COLORS = {"warrior":"98483f", "guardian":"438b89", "rogue":"72864a", "mage":"8f65b4", "cleric":"c09a55", "ranger":"507ba6"}
const CROPS = {
	"warrior":Rect2(0.39, 0.12, 0.38, 0.66), "guardian":Rect2(0.39, 0.06, 0.38, 0.66),
	"rogue":Rect2(0.55, 0.09, 0.38, 0.66), "mage":Rect2(0.43, 0.07, 0.38, 0.66),
	"cleric":Rect2(0.40, 0.08, 0.38, 0.66), "ranger":Rect2(0.41, 0.10, 0.38, 0.66)
}
const COMPACT_TOP = {"warrior":0.22, "guardian":0.12, "rogue":0.20, "mage":0.25, "cleric":0.18, "ranger":0.23}
static func build(ui: Control, parent: Control, hero: String, title: String, position: Vector2, action: Callable, compact: bool = false) -> Button:
	var dimensions = Vector2(244, 166) if compact else Vector2(190, 338)
	var b = ui.button("", position.x, position.y, dimensions.x, dimensions.y, action, true, parent)
	b.name = "RefugeHero_" + hero
	var accent = Color(COLORS[hero])
	for state in ["normal", "hover", "pressed", "focus"]:
		b.add_theme_stylebox_override(state, ui.box(Color("131922"), accent.lightened(0.35) if state in ["hover", "focus"] else accent, 3))
	var crop = AtlasTexture.new()
	crop.atlas = load("res://assets/comic/%s.png" % hero)
	var region: Rect2 = CROPS[hero]
	if compact:
		region.position.y = COMPACT_TOP[hero]
		region.size.y = 0.30
	crop.region = Rect2(region.position * crop.atlas.get_size(), region.size * crop.atlas.get_size())
	var picture = TextureRect.new()
	picture.name = "ComicPortrait"
	picture.texture = crop
	picture.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	picture.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	picture.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
	picture.mouse_filter = Control.MOUSE_FILTER_IGNORE
	ui.rect(picture, 6, 6, dimensions.x - 12, 112 if compact else 268, b)
	var plaque = ui.panel(5, 122 if compact else 278, dimensions.x - 10, 38 if compact else 53, accent, b)
	plaque.add_theme_stylebox_override("panel", preload("res://src/ui/components/button_skin.gd").style("wood_button"))
	ui.label_at(title, 0, 0, dimensions.x - 10, 38 if compact else 53, 20 if compact else 22, ui.TEXT, plaque).horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	return b
