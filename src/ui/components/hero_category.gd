extends RefCounted
# Shared class-colored hero category for camp shops.
static func build(ui: Control, hero: Dictionary, id: String, portrait_index: int, origin: Vector2, selected: bool, action: Callable) -> Button:
	var b = ui.button("", origin.x, origin.y, 122, 82, action)
	var frame = TextureRect.new()
	frame.texture = load("res://assets/cards/%s.png" % id)
	frame.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	frame.mouse_filter = Control.MOUSE_FILTER_IGNORE
	ui.rect(frame, 0, 0, 122, 82, b)
	var portrait = TextureRect.new()
	portrait.name = "HeroPortrait"
	portrait.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	portrait.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	portrait.mouse_filter = Control.MOUSE_FILTER_IGNORE
	portrait.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	var crop = AtlasTexture.new()
	crop.atlas = ui.CAMP_FRONT
	crop.region = Rect2(portrait_index * 128, 0, 128, 128)
	portrait.texture = crop
	ui.rect(portrait, 19, -3, 84, 66, b)
	var caption = ui.label_at(hero.name, 5, 55, 112, 24, 16, ui.GOLD if selected else ui.TEXT, b)
	caption.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	return b
