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
	if icons.is_empty(): return
	var width = 12 + icons.size() * 24
	var pill = Panel.new()
	pill.name = "CardTypePill"
	pill.mouse_filter = Control.MOUSE_FILTER_IGNORE
	pill.position = Vector2(12, card.size.y - 29)
	pill.size = Vector2(width, 24)
	var style = StyleBoxFlat.new()
	style.bg_color = Color("242127")
	style.border_color = Color("a58d64")
	style.set_border_width_all(1)
	style.set_corner_radius_all(8)
	pill.add_theme_stylebox_override("panel", style)
	card.add_child(pill)
	for i in range(icons.size()):
		var icon = TextureRect.new()
		icon.name = "CardType%d" % i
		icon.texture = icons[i]
		icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
		icon.position = pill.position + Vector2(6 + i * 24, 1)
		icon.size = Vector2(22, 22)
		card.add_child(icon)

