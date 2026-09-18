extends Button
# Transparent pixels do not cover the neighbouring building's clickable area.
var alpha_mask: BitMap
var artwork_size: Vector2
var artwork_rect: Rect2
var pixel_scale = 1.0
var passthrough_areas: Array[Rect2] = []
func configure(texture: Texture2D, area: Vector2) -> void:
	artwork_size = area
	pixel_scale = minf(area.x / texture.get_width(), area.y / texture.get_height())
	var drawn_size = texture.get_size() * pixel_scale
	artwork_rect = Rect2((area - drawn_size) / 2.0, drawn_size)
	alpha_mask = BitMap.new()
	alpha_mask.create_from_image_alpha(texture.get_image(), 0.3)
func _has_point(point: Vector2) -> bool:
	for area in passthrough_areas:
		if area.has_point(point): return false
	if Rect2(Vector2((artwork_size.x - 208) / 2, artwork_size.y), Vector2(208, 34)).has_point(point):
		return true
	if alpha_mask == null or not artwork_rect.has_point(point):
		return false
	return alpha_mask.get_bitv(Vector2i((point - artwork_rect.position) / pixel_scale))
