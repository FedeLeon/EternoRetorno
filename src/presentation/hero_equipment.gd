extends RefCounted
# Visual-only atlas substitution. Reuses exact animation names, timing and reverse revive.
static var cache: Dictionary = {}
static var metrics: Dictionary = {}
const MAX_CACHED_VARIANTS = 8

static func apply(actor: Control, hero: String, gear: Dictionary) -> void:
	if gear.is_empty() or not actor.get("sprite"):
		return # Legacy runs retain their original appearance.
	var key = "%s_w%d_a%d" % [hero, int(gear.get("weapon", 0)), int(gear.get("armor", 0))]
	var path = "res://assets/forge/heroes/%s.png" % key
	if not ResourceLoader.exists(path):
		return
	if metrics.is_empty() and FileAccess.file_exists("res://data/forge_visuals.json"):
		metrics = JSON.parse_string(FileAccess.get_file_as_string("res://data/forge_visuals.json"))
	if metrics.has(key):
		actor.set_meta("idle_height", float(metrics[key]))
	if not cache.has(key):
		if cache.size() >= MAX_CACHED_VARIANTS:
			cache.erase(cache.keys()[0])
		var frames = actor.frames().duplicate(true)
		var atlas = load(path)
		for animation in frames.get_animation_names():
			if animation == "run": continue # Running has its own atlas, not a forge action row.
			for i in range(frames.get_frame_count(animation)):
				var old = frames.get_frame_texture(animation, i)
				var texture = AtlasTexture.new()
				texture.atlas = atlas
				texture.region = old.region
				frames.set_frame(animation, i, texture, frames.get_frame_duration(animation, i))
		cache[key] = frames
	var sprite = actor.sprite
	var animation = sprite.animation
	var frame = sprite.frame
	var progress = sprite.frame_progress
	var playing = sprite.is_playing()
	sprite.sprite_frames = cache[key]
	sprite.animation = animation
	if playing:
		sprite.play(animation)
	else:
		sprite.pause()
	sprite.set_frame_and_progress(frame, progress)
