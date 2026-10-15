extends RefCounted
# Shared bold type: raster oversampling also stays smooth when cards rotate.
static var card_font: FontVariation

static func font() -> FontVariation:
	if card_font == null:
		var source = preload("res://assets/fonts/SourceSans3.ttf").duplicate() as FontFile
		# Source Sans 3's overlapping bold contours leave holes in MSDF glyphs (e).
		# Rasterize at double resolution instead; preserve the same font and weight.
		source.multichannel_signed_distance_field = false
		source.oversampling = 2.0
		card_font = FontVariation.new()
		card_font.base_font = source
		card_font.variation_opentype = {2003265652: 700.0} # OpenType tag: wght.
	return card_font

static func apply(node: Node) -> void:
	if node is Label:
		node.add_theme_font_override("font", font())
		node.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
	for child in node.get_children():
		apply(child)
