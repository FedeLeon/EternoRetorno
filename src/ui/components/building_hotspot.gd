extends Button
# Transparent pixels do not cover the neighbouring building's clickable area.
var alpha_mask: BitMap
var artwork_size: Vector2
var artwork_rect: Rect2
var pixel_scale = 1.0
var passthrough_areas: Array[Rect2] = []
var artwork_flipped = false
func configure(texture: Texture2D, area: Vector2, artwork_offset: Vector2 = Vector2.ZERO, flipped: bool = false) -> void:
	artwork_flipped = flipped
	artwork_size = area
	pixel_scale = minf(area.x / texture.get_width(), area.y / texture.get_height())
	var drawn_size = texture.get_size() * pixel_scale
	artwork_rect = Rect2((area - drawn_size) / 2.0 + artwork_offset, drawn_size)
	alpha_mask = BitMap.new()
	alpha_mask.create_from_image_alpha(texture.get_image(), 0.3)
func _has_point(point: Vector2) -> bool:
	for area in passthrough_areas:
		if area.has_point(point): return false
	var caption: Rect2 = get_meta("caption_rect", Rect2(position + Vector2((artwork_size.x - 208) / 2, artwork_size.y), Vector2(208, 34)))
	if Rect2(caption.position - position, caption.size).has_point(point):
		return true
	if alpha_mask == null or not artwork_rect.has_point(point):
		return false
	var pixel = Vector2i((point - artwork_rect.position) / pixel_scale)
	if artwork_flipped: pixel.x = alpha_mask.get_size().x - 1 - pixel.x
	return alpha_mask.get_bitv(pixel)
