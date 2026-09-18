extends RefCounted
# Vector-distance text stays smooth when a card rotates; artwork keeps nearest filtering.
static var card_font: FontFile

static func apply(node: Node) -> void:
	if card_font == null:
		card_font = ThemeDB.fallback_font.duplicate() as FontFile
		card_font.multichannel_signed_distance_field = true
	if node is Label:
		node.add_theme_font_override("font", card_font)
		node.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
	for child in node.get_children():
		apply(child)
