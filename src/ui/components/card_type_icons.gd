extends RefCounted

static func attach(card: Control, data: Dictionary) -> void:
	var attack = data.damage > 0 or data.poison > 0
	var icons: Array[Texture2D] = []
	if attack:
		icons.append(preload("res://assets/ui/sword.svg"))
	if data.block > 0:
		var shield = AtlasTexture.new()
		shield.atlas = preload("res://assets/objects/icons.png")
		var cell = Rect2i(128, 64, 64, 64)
		var bounds = shield.atlas.get_image().get_region(cell).get_used_rect()
		shield.region = Rect2(cell.position + bounds.position, bounds.size)
		icons.append(shield)
	for i in range(icons.size()):
		var icon = TextureRect.new()
		icon.name = "CardType%d" % i
		icon.texture = icons[i]
		icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
		icon.position = Vector2(52 + i * 32, 14)
		icon.size = Vector2(27, 27)
		card.add_child(icon)

