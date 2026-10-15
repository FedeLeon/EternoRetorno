extends RefCounted
# Shared comic UI type stays smooth when cards rotate.
static var card_font: FontFile
static var metadata_font: FontVariation

static func font() -> FontFile:
	if card_font == null:
		card_font = preload("res://assets/fonts/SourceSans3.ttf").duplicate() as FontFile
		card_font.multichannel_signed_distance_field = true
	return card_font

static func owner_font() -> FontVariation:
	if metadata_font == null:
		metadata_font = FontVariation.new()
		metadata_font.base_font = font()
		metadata_font.variation_embolden = 0.5
	return metadata_font

static func apply(node: Node) -> void:
	if node is Label:
		node.add_theme_font_override("font", owner_font() if node.name == "CardOwner" else font())
		node.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
	for child in node.get_children():
		apply(child)
