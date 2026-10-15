extends Control
## Brief pair-colored link and emblem. Committed gameplay is never changed here.
var clock = 0.0
var points: Array[Vector2] = []
var colors: Array[Color] = []
static func play(ui: Control, pair: String) -> void:
	var effect = load("res://src/presentation/pair_link_fx.gd").new()
	effect.name = "PairLinkFX"
	effect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	effect.z_index = 65
	ui.layer.add_child(effect)
	var palette = {"warrior":Color("bd6be1"), "guardian":Color("f0a657"), "rogue":Color("69caa5"), "mage":Color("75d8e6")}
	for i in range(2):
		var actor: Control = ui.hero_art[i]
		effect.points.append(effect.get_global_transform().affine_inverse() * actor.get_global_transform() * Vector2(actor.size.x * 0.5, actor.size.y * 0.5))
		effect.colors.append(palette[actor.hero_id])
	var icon = TextureRect.new()
	icon.texture = load("res://assets/synergies/%s.svg" % pair)
	icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	icon.size = Vector2(64, 64)
	icon.position = (effect.points[0] + effect.points[1]) * 0.5 - icon.size * 0.5
	effect.add_child(icon)
	var tween = effect.create_tween()
	tween.tween_interval(0.35)
	tween.tween_property(effect, "modulate:a", 0.0, 0.25)
	tween.tween_callback(effect.queue_free)

func _process(delta: float) -> void:
	clock += delta
	queue_redraw()

func _draw() -> void:
	if points.size() != 2: return
	var midpoint = (points[0] + points[1]) * 0.5
	for i in range(2):
		var end = points[i].lerp(midpoint, minf(1.0, clock * 7.0))
		draw_line(points[i], end, Color(colors[i], 0.2), 12, true)
		draw_line(points[i], end, colors[i], 3, true)
		for p in range(5):
			var at = points[i].lerp(end, fmod(clock * 2.0 + p * 0.2, 1.0))
			draw_circle(at, 2.5, colors[i])
