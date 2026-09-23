extends RefCounted
# Align action silhouettes with the idle ground line without altering source art.
static var bottoms: Dictionary = {}

static func attach(sprite: AnimatedSprite2D) -> void:
	var refresh = func(): update(sprite)
	sprite.frame_changed.connect(refresh)
	sprite.animation_changed.connect(refresh)
	sprite.sprite_frames_changed.connect(refresh)
	update(sprite)

static func update(sprite: AnimatedSprite2D) -> void:
	sprite.offset.y = 0
	if sprite.animation in ["idle", "run", "death", "revive"]:
		return
	var frames = sprite.sprite_frames
	if not frames.has_animation(sprite.animation) or not frames.has_animation("idle"):
		return
	if sprite.frame >= frames.get_frame_count(sprite.animation):
		return
	var idle = frames.get_frame_texture("idle", 0)
	var current = frames.get_frame_texture(sprite.animation, sprite.frame)
	sprite.offset.y = bottom(idle) - bottom(current)

static func bottom(texture: Texture2D) -> int:
	var key = texture.resource_path
	if texture is AtlasTexture:
		key = texture.atlas.resource_path + str(texture.region)
	if bottoms.has(key):
		return bottoms[key]
	var image = texture.get_image()
	if image.is_compressed(): image.decompress()
	for y in range(image.get_height() - 1, -1, -1):
		for x in range(image.get_width()):
			if image.get_pixel(x, y).a > 0.5:
				bottoms[key] = y + 1
				return y + 1
	bottoms[key] = 0
	return 0
