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
	# Normalize against the living silhouette, including when rebuilding a corpse.
	var idle: Array = actor.poses.idle.bounds
	var bounds = Rect2(idle[0],idle[1],idle[2],idle[3])
	var factor = minf(max_height / maxf(1.0, bounds.size.y * float(actor.poses.idle.scale)), max_width / maxf(1.0, bounds.size.x * float(actor.poses.idle.scale)))
	actor.scale = Vector2.ONE * factor
	# Keep wide silhouettes inside the enemy arena; their bars stay in their columns.
	var half_width = bounds.size.x * float(actor.poses.idle.scale) * factor * 0.5
	var center = (actor.get_global_transform() * Vector2(actor.size.x*.5,actor.size.y)).x
	actor.position.x += clampf(center, 536.0 + half_width, 1264.0 - half_width) - center
