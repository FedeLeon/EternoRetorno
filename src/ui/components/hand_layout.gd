extends RefCounted
## Keep the full hand inside its fixed battlefield area, including rotated corners.
const CARD_WIDTH = 174.0
const CARD_HEIGHT = 278.0
const STEP = 146.0
const WIDTH = 954.0
const MARGIN = 4.0
const Layout = preload("res://src/ui/components/combat_layout.gd")

static func content_width(_count: int) -> float:
	return WIDTH

static func _fan_bounds(count: int) -> Rect2:
	var bounds = Rect2()
	var pivot = Vector2(CARD_WIDTH / 2, CARD_HEIGHT)
	for i in range(count):
		var t = i * 2.0 / (count - 1) - 1.0
		var position = Vector2(i * STEP, 20 + 6 * t * t)
		for corner in [Vector2.ZERO, Vector2(CARD_WIDTH, 0), Vector2(CARD_WIDTH, CARD_HEIGHT), Vector2(0, CARD_HEIGHT)]:
			var point = position + pivot + (corner - pivot).rotated(deg_to_rad(7 * t))
			bounds = Rect2(point, Vector2.ZERO) if i == 0 and corner == Vector2.ZERO else bounds.expand(point)
	return bounds

static func arrange(card: Control, index: int, count: int, selected: bool) -> void:
	var t = (index * 2.0 / (count - 1) - 1.0) if count > 1 else 0.0
	card.pivot_offset = Vector2(card.size.x / 2, card.size.y)
	card.rotation_degrees = 7 * t
	card.z_index = 0
	if count > 6:
		var bounds = _fan_bounds(count)
		var factor = minf(1.0, (WIDTH - MARGIN * 2) / bounds.size.x)
		var origin = Vector2((WIDTH - bounds.size.x * factor) / 2 - bounds.position.x * factor,
			720 - Layout.HAND_TOP - MARGIN - bounds.end.y * factor)
		card.scale = Vector2.ONE * factor
		card.position = origin + Vector2(index * STEP, 20 + 6 * t * t) * factor - card.pivot_offset * (1 - factor)
		if selected:
			# The inspected card stays readable at full size, above the compact fan.
			card.scale = Vector2.ONE
			var center = origin.x + (index * STEP + CARD_WIDTH / 2) * factor
			card.position = Vector2(clampf(center - card.size.x / 2, MARGIN, WIDTH - MARGIN - card.size.x), 0)
	else:
		var spread = maxf(0, count - 1) * STEP + CARD_WIDTH
		var left = (WIDTH - spread) / 2.0
		card.position = Vector2(left + index * STEP, 434 - Layout.HAND_TOP + 6 * t * t)
		if selected:
			card.position = Vector2(clampf(left + index * STEP - 22, 0, WIDTH - card.size.x), 0)
	if selected:
		card.rotation = 0
		card.z_index = 10
