extends TextureRect
## Independent visual RNG. Never reads or advances the run's random state.
const SWEEP_SECONDS = 0.85
var random = RandomNumberGenerator.new()
var remaining = 0.0
var sweeping = false
var progress = 0.0

static func attach(card: Control, frame: TextureRect, linked: bool) -> void:
	if linked:
		var glow = TextureRect.new()
		glow.name = "LinkGlow"
		glow.texture = frame.texture
		glow.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		glow.size = card.size
		glow.mouse_filter = Control.MOUSE_FILTER_IGNORE
		var glow_material = ShaderMaterial.new()
		glow_material.shader = preload("res://assets/shaders/card_link_glow.gdshader")
		glow.material = glow_material
		card.add_child(glow)
		card.move_child(glow, 0)
	var sheen = new()
	sheen.name = "CardSheen"
	sheen.texture = frame.texture
	sheen.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	sheen.size = card.size
	sheen.mouse_filter = Control.MOUSE_FILTER_IGNORE
	card.add_child(sheen)

func _ready() -> void:
	random.randomize()
	remaining = random.randf_range(0.8, 7.0)
	var finish = ShaderMaterial.new()
	finish.shader = preload("res://assets/shaders/card_sheen.gdshader")
	material = finish

func _process(delta: float) -> void:
	if not is_visible_in_tree(): return
	if sweeping:
		progress += delta / SWEEP_SECONDS
		material.set_shader_parameter("sweep", lerpf(-0.2, 1.6, minf(progress, 1.0)))
		if progress >= 1.0:
			sweeping = false
			remaining = random.randf_range(4.0, 11.0)
			material.set_shader_parameter("sweep", -1.0)
	else:
		remaining -= delta
		if remaining <= 0.0:
			sweeping = true
			progress = 0.0
