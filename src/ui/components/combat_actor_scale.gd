extends RefCounted
# Legacy logical reference heights; actual still-image bounds come from the catalogue.
# Layout uses uniform scaling and never animates a body transform.
const IDLE_HEIGHT = {"warrior": 78.0, "guardian": 91.0, "rogue": 87.0, "mage": 90.0}
const PREVIOUS_SCALE = 1.25
const GROWTH = 1.95
const HERO_HEIGHT = 91.0 * PREVIOUS_SCALE * GROWTH

static func hero(actor: Control, id: String) -> void:
	actor.pivot_offset = Vector2(actor.size.x / 2, actor.size.y)
	actor.scale = Vector2.ONE * HERO_HEIGHT / float(actor.get_meta("idle_height", IDLE_HEIGHT[id]))

static func enemy(actor: Control) -> void:
	actor.pivot_offset = Vector2(actor.size.x / 2, actor.size.y)
	actor.scale = Vector2.ONE * PREVIOUS_SCALE * GROWTH

static func silhouette(actor: Control) -> Rect2:
	var b: Array = actor.poses[actor.current_action].bounds
	return Rect2(b[0],b[1],b[2],b[3])

static func fit_enemy(actor: Control, max_height: float, max_width: float = 220.0) -> void:
	# Normalize the actual drawing, rather than preserving accidental source sizes.
	# Wide machines get their presence from width; tall machines from height.
	var bounds = silhouette(actor)
	var factor = minf(max_height / maxf(1.0, bounds.size.y * actor.sprite.scale.y), max_width / maxf(1.0, bounds.size.x * actor.sprite.scale.x))
	actor.scale = Vector2.ONE * factor
	# Keep wide silhouettes inside the enemy arena; their bars stay in their columns.
	var half_width = bounds.size.x * actor.sprite.scale.x * factor * 0.5
	var center = (actor.get_global_transform() * actor.body_rect().get_center()).x
	actor.position.x += clampf(center, 536.0 + half_width, 1264.0 - half_width) - center
