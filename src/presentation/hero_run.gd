extends RefCounted
# Dedicated eight-frame gait. Separate atlas prevents changing combat actions.
const FRAMES = 8
const FPS = 10.0
const HEIGHTS = preload("res://src/ui/components/combat_actor_scale.gd").IDLE_HEIGHT

static func add_animation(frames: SpriteFrames, hero: String) -> void:
	var atlas = load("res://assets/heroes/running/%s.png" % hero)
	frames.add_animation("run")
	frames.set_animation_speed("run", FPS)
	frames.set_animation_loop("run", true)
	for i in range(FRAMES):
		var texture = AtlasTexture.new()
		texture.atlas = atlas
		texture.region = Rect2(i * 128, 0, 128, 128)
		frames.add_frame("run", texture)

static func start(actor: Control) -> void:
	if actor.sprite.animation == "run": return
	actor.set_fallen(false)
	var hero: String = actor.get_meta("hero_id")
	actor.set_meta("before_run_scale", actor.sprite.scale)
	actor.set_meta("before_run_position", actor.sprite.position)
	# Match the current equipment silhouette height while sharing each hero's gait.
	var ratio = float(actor.get_meta("idle_height", HEIGHTS[hero])) / float(HEIGHTS[hero])
	var old_scale: Vector2 = actor.sprite.scale
	actor.sprite.scale *= ratio
	actor.sprite.position.y += 120 * (old_scale.y - actor.sprite.scale.y)
	actor.sprite.position.x += 64 * (old_scale.x - actor.sprite.scale.x)
	actor.sprite.speed_scale = 1.0
	actor.sprite.play("run")
	actor.sprite.frame = 0

static func stop(actor: Control) -> void:
	if actor.has_meta("before_run_scale"):
		actor.sprite.scale = actor.get_meta("before_run_scale")
		actor.sprite.position = actor.get_meta("before_run_position")
		actor.remove_meta("before_run_scale")
		actor.remove_meta("before_run_position")
	actor.sprite.play("idle")
