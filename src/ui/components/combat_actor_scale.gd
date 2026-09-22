extends RefCounted
# Opaque idle silhouette heights in the 128px atlases (six frames, alpha > 0.5).
# A fixed per-class factor prevents size changes between animation frames.
const IDLE_HEIGHT = {"warrior": 78.0, "guardian": 91.0, "rogue": 87.0, "mage": 90.0, "cleric": 85.0, "ranger": 81.0}
const PREVIOUS_SCALE = 1.25
const GROWTH = 1.45
const HERO_HEIGHT = 91.0 * PREVIOUS_SCALE * GROWTH

static func hero(actor: Control, id: String) -> void:
	actor.pivot_offset = Vector2(actor.size.x / 2, actor.size.y)
	actor.scale = Vector2.ONE * HERO_HEIGHT / float(actor.get_meta("idle_height", IDLE_HEIGHT[id]))

static func enemy(actor: Control) -> void:
	actor.pivot_offset = Vector2(actor.size.x / 2, actor.size.y - 8)
	actor.scale = Vector2.ONE * PREVIOUS_SCALE * GROWTH
