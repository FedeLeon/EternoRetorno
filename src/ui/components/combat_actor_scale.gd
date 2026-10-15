extends RefCounted
# Opaque idle silhouette heights in the 128px atlases (six frames, alpha > 0.5).
# A fixed per-class factor prevents size changes between animation frames.
const IDLE_HEIGHT = {"warrior": 78.0, "guardian": 91.0, "rogue": 87.0, "mage": 90.0}
const PREVIOUS_SCALE = 1.25
const GROWTH = 1.95
const HERO_HEIGHT = 91.0 * PREVIOUS_SCALE * GROWTH
static var enemy_heights: Dictionary = {}

static func hero(actor: Control, id: String) -> void:
	actor.pivot_offset = Vector2(actor.size.x / 2, actor.size.y)
	var metrics = preload("res://src/data/json_catalog.gd").dictionary("res://data/forge_visuals.json")
	actor.scale = Vector2.ONE * HERO_HEIGHT / float(actor.get_meta("idle_height", metrics.get(id+"_w0_a0",IDLE_HEIGHT[id])))

static func enemy(actor: Control) -> void:
	actor.pivot_offset = Vector2(actor.size.x / 2, actor.size.y - 8)
	actor.scale = Vector2.ONE * PREVIOUS_SCALE * GROWTH

static func fit_enemy(actor: Control, max_height: float) -> void:
	var texture: Texture2D = actor.sprite.texture
	var key = texture.resource_path
	if not enemy_heights.has(key):
		var image = texture.get_image()
		if image.is_compressed(): image.decompress()
		var bounds = image.get_region(Rect2i(0, 0, image.get_height(), image.get_height())).get_used_rect()
		enemy_heights[key] = bounds.size.y
	actor.scale *= minf(1.0, max_height / maxf(1, enemy_heights[key] * actor.sprite.scale.y * actor.scale.y))
