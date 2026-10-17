extends RefCounted
# Dedicated eight-frame gait. Separate atlas prevents changing combat actions.
const FRAMES = 8
const FPS = 10.0
static var height_ratios: Dictionary = {}
const Ground = preload("res://src/presentation/hero_grounding.gd")
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

# One uniform scale for the whole gait: preserve natural limb motion without
# changing body size on each frame. Measure the active art, not old class data.
static func height_ratio(frames: SpriteFrames) -> float:
	var key = frames.get_instance_id()
	if height_ratios.has(key): return height_ratios[key]
	var heights: Array[int] = []
	for i in range(frames.get_frame_count("run")):
		heights.append(pose_height(frames.get_frame_texture("run",i)))
	heights.sort()
	var idle = pose_height(frames.get_frame_texture("idle",0))
	var middle = heights.size()/2
	var median = (heights[middle-1]+heights[middle])*0.5 if heights.size()%2==0 else float(heights[middle])
	var ratio = float(idle) / maxf(1,median)
	if height_ratios.size() >= 16: height_ratios.clear()
	height_ratios[key] = ratio
	return ratio

static func pose_height(texture: Texture2D) -> int:
	var image = texture.get_image()
	if image.is_compressed(): image.decompress()
	for y in range(image.get_height()):
		for x in range(image.get_width()):
			if image.get_pixel(x,y).a > 0.5: return Ground.bottom(texture)-y
	return 0

static func start(actor: Control) -> void:
	if actor.sprite.animation == "run": return
	actor.set_fallen(false)
	if actor.has_meta("detailed"):
		# Let the HD controller place its 256px frames and cancel older actions.
		actor.play_once("run")
		return
	actor.set_meta("before_run_scale", actor.sprite.scale)
	actor.set_meta("before_run_position", actor.sprite.position)
	var frames: SpriteFrames = actor.sprite.sprite_frames
	var idle = frames.get_frame_texture("idle",0)
	var running = frames.get_frame_texture("run",0)
	var old_scale: Vector2 = actor.sprite.scale
	actor.sprite.scale *= height_ratio(frames)
	actor.sprite.position.y += Ground.bottom(idle)*old_scale.y-Ground.bottom(running)*actor.sprite.scale.y
	actor.sprite.position.x += (idle.get_width()*old_scale.x-running.get_width()*actor.sprite.scale.x)/2
	actor.sprite.speed_scale = 1.0
	actor.sprite.play("run")
	actor.sprite.frame = 0

static func stop(actor: Control) -> void:
	if actor.has_meta("detailed"):
		actor.play_once("idle")
		return
	if actor.has_meta("before_run_scale"):
		actor.sprite.scale = actor.get_meta("before_run_scale")
		actor.sprite.position = actor.get_meta("before_run_position")
		actor.remove_meta("before_run_scale")
		actor.remove_meta("before_run_position")
	actor.sprite.play("idle")
