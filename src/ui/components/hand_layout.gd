extends RefCounted
# Soft fan with enough exposed width for touch input; extra cards can scroll.
const CARD_WIDTH = 174.0
const STEP = 160.0
static func content_width(count: int) -> float:
	return maxf(1086, maxf(0, count - 1) * STEP + CARD_WIDTH + 100)

static func arrange(card: Control, index: int, count: int, selected: bool) -> void:
	var spread = maxf(0, count - 1) * STEP + CARD_WIDTH
	var left = (content_width(count) - spread) / 2.0
	var t = (index * 2.0 / (count - 1) - 1.0) if count > 1 else 0.0
	card.pivot_offset = Vector2(card.size.x / 2, card.size.y)
	card.position = Vector2(left + index * STEP, 70 + 8 * t * t)
	card.rotation_degrees = 3 * t
	# Child order and draw order stay consistent for overlapping hit targets.
	card.z_index = 0
	if selected:
		card.position = Vector2(clampf(left + index * STEP - 22, 0, content_width(count) - card.size.x), 8)
		card.rotation = 0
		card.z_index = 10
