extends RefCounted
# Opaque idle silhouette heights in the 128px atlases (six frames, alpha > 0.5).
# A fixed per-class factor prevents size changes between animation frames.
const IDLE_HEIGHT = {"warrior": 78.0, "guardian": 91.0, "rogue": 87.0, "mage": 90.0}
const PREVIOUS_SCALE = 1.25
const GROWTH = 1.95
const HERO_HEIGHT = 91.0 * PREVIOUS_SCALE * GROWTH
static var enemy_bounds: Dictionary = {}

static func hero(actor: Control, id: String) -> void:
	actor.pivot_offset = Vector2(actor.size.x / 2, actor.size.y)
	var metrics = preload("res://src/data/json_catalog.gd").dictionary("res://data/forge_visuals.json")
	actor.scale = Vector2.ONE * HERO_HEIGHT / float(actor.get_meta("idle_height", metrics.get(id+"_w0_a0",IDLE_HEIGHT[id])))

static func enemy(actor: Control) -> void:
	actor.pivot_offset = Vector2(actor.size.x / 2, actor.size.y - 8)
	actor.scale = Vector2.ONE * PREVIOUS_SCALE * GROWTH

static func silhouette(actor: Control) -> Rect2:
	var texture: Texture2D = actor.sprite.texture
	var key = texture.resource_path
	if not enemy_bounds.has(key):
		var image = texture.get_image()
		if image.is_compressed(): image.decompress()
		var cell = image.get_region(Rect2i(0, 0, image.get_height(), image.get_height()))
		var low = cell.get_size()
		var high = Vector2i(-1, -1)
		for y in range(cell.get_height()):
			for x in range(cell.get_width()):
				if cell.get_pixel(x, y).a >= 0.5:
					low = low.min(Vector2i(x, y)); high = high.max(Vector2i(x, y))
		enemy_bounds[key] = Rect2(Vector2(low), Vector2(high - low + Vector2i.ONE))
	return enemy_bounds[key]

static func fit_enemy(actor: Control, max_height: float, max_width: float = 220.0) -> void:
	# Normalize the actual drawing, rather than preserving accidental source sizes.
	# Wide machines get their presence from width; tall machines from height.
	var bounds = silhouette(actor)
	var factor = minf(max_height / maxf(1.0, bounds.size.y * actor.sprite.scale.y), max_width / maxf(1.0, bounds.size.x * actor.sprite.scale.x))
	actor.scale = Vector2.ONE * factor
	# Keep wide silhouettes inside the enemy arena; their bars stay in their columns.
	var half_width = bounds.size.x * actor.sprite.scale.x * factor * 0.5
	var center = (actor.get_global_transform() * actor.sprite.position).x
	actor.position.x += clampf(center, 536.0 + half_width, 1264.0 - half_width) - center
