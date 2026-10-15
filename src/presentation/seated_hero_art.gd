extends RefCounted
# Shared alpha-cropped seated artwork; anchor the visible boots to the allocated floor.
static var textures: Dictionary = {}
static func texture(hero: String) -> Texture2D:
	if textures.has(hero): return textures[hero]
	var original: Texture2D = load("res://assets/rest/%s.png" % hero)
	var image = original.get_image()
	if image.is_compressed(): image.decompress()
	var crop = AtlasTexture.new()
	crop.atlas = original
	crop.region = image.get_used_rect()
	crop.filter_clip = true
	textures[hero] = crop
	return crop

static func fit(view: TextureRect, hero: String, area: Rect2) -> void:
	view.texture = texture(hero)
	view.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	view.stretch_mode = TextureRect.STRETCH_SCALE
	view.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
	var dimensions = view.texture.get_size()
	var ratio = minf(area.size.x / dimensions.x, area.size.y / dimensions.y)
	view.size = dimensions * ratio
	view.position = Vector2(area.get_center().x - view.size.x / 2, area.end.y - view.size.y)
