extends Node
## Authored drawings only: no body transforms, deformation or rule-state changes.
var actor: Control
var config: Dictionary = {}
var clip: Dictionary = {}
var action = ""
var elapsed = 0.0
var frame = -1
var textures: Dictionary = {}

func select(next_action: String) -> void:
	if not config.clips.has(next_action):
		set_process(false)
		action = ""
		clip = {}
		frame = -1
		return
	if next_action == action and action == "idle":
		show_frame(frame)
		return
	action = next_action
	clip = config.clips[action]
	elapsed = 0.0
	frame = -1
	if not textures.has(action):
		var atlas = load(clip.path)
		var frames: Array[AtlasTexture] = []
		for i in range(clip.frames.size()):
			var texture = AtlasTexture.new()
			texture.atlas = atlas
			var extent = Vector2(config.frame_size[0],config.frame_size[1])
			texture.region = Rect2(Vector2(i % int(config.columns), i / int(config.columns)) * extent, extent)
			texture.filter_clip = true
			frames.append(texture)
		textures[action] = frames
	show_frame(0)
	set_process(true)

func _process(delta: float) -> void:
	elapsed += delta
	var progress = elapsed / float(clip.duration)
	var completed = not clip.get("loop", false) and progress >= 1.0
	if clip.get("loop", false): progress = fmod(progress, 1.0)
	else: progress = minf(progress, 1.0)
	var next = mini(int(progress * clip.frames.size()), clip.frames.size() - 1)
	# Half-cycle drawings run out and back, slowing naturally at each endpoint.
	if clip.get("ping_pong", false):
		progress = (1.0-cos(progress*TAU))*.5
		next = roundi(progress * (clip.frames.size()-1))
	if next != frame: show_frame(next)
	if completed: set_process(false)

func show_frame(index: int) -> void:
	frame = index
	actor.sprite.texture = textures[action][index]
	actor._place()
	# The existing equipment shader samples only the current atlas cell.
	if actor.sprite.material is ShaderMaterial:
		preload("res://src/presentation/comic_outline.gd").configure(actor.sprite.material, actor.sprite.texture)

func bounds() -> Rect2:
	var b: Array = clip.frames[maxi(frame, 0)].bounds
	return Rect2(b[0], b[1], b[2], b[3])
