extends RefCounted
# Illustration lookup belongs to presentation; gameplay card IDs stay unchanged.
const MANIFEST = "res://data/card_art.json"
static var entries: Dictionary = {}
static var textures: Dictionary = {}

static func texture_for(id: String) -> Texture2D:
	if entries.is_empty():
		entries = preload("res://src/data/json_catalog.gd").dictionary(MANIFEST)
	if textures.has(id): return textures[id]
	if not entries.has(id): return null
	var entry = entries[id]
	if not ResourceLoader.exists(entry.source): return null
	var source = load(entry.source) as Texture2D
	if entry.has("region"):
		var atlas = AtlasTexture.new()
		atlas.atlas = source
		var r = entry.region
		atlas.region = Rect2(r[0], r[1], r[2], r[3])
		atlas.filter_clip = true
		textures[id] = atlas
	else:
		textures[id] = source
	return textures[id]

static func attach(parent: Control, id: String, area: Rect2) -> TextureRect:
	var picture = TextureRect.new()
	picture.name = "CardIllustration"
	picture.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	picture.texture = texture_for(id)
	picture.position = area.position
	picture.size = area.size
	picture.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	picture.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
	picture.mouse_filter = Control.MOUSE_FILTER_IGNORE
	parent.add_child(picture)
	return picture
