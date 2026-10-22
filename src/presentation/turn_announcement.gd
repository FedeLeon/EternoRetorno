extends Control
## Cosmetic interlude. Turn resolution and saving happen before this is created.
signal finished
var enemy_turn = false
var turn_number = 1

static func play(parent: Control, enemy: bool, number: int) -> void:
	var banner = load("res://src/presentation/turn_announcement.gd").new()
	banner.name = "TurnAnnouncement"
	banner.enemy_turn = enemy
	banner.turn_number = number
	parent.add_child(banner)
	await banner.finished
	banner.queue_free()
	await parent.get_tree().process_frame

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_STOP
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	z_as_relative = false
	z_index = 180
	var shade = ColorRect.new()
	shade.color = Color(0.025, 0.02, 0.04, 0.38)
	shade.mouse_filter = Control.MOUSE_FILTER_IGNORE
	shade.position = Vector2(0, 234)
	shade.size = Vector2(size.x, 112)
	add_child(shade)
	var caption = TextureRect.new()
	caption.name = "Caption"
	caption.texture = load("res://assets/battle_turns/enemy_turn.png" if enemy_turn else "res://assets/battle_turns/player_turn.png")
	caption.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	caption.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	caption.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
	caption.mouse_filter = Control.MOUSE_FILTER_IGNORE
	caption.size = Vector2(900 if enemy_turn else 450, 112)
	caption.position = Vector2((size.x-caption.size.x)*.5,234)
	add_child(caption)
	if not enemy_turn:
		var number = preload("res://src/ui/components/number_view.gd").new()
		number.name = "TurnNumber"
		number.value = turn_number
		number.glyph_directory = "res://assets/battle_turns/digits"
		number.glyph_aspect = 160.0/144.0
		number.mouse_filter = Control.MOUSE_FILTER_IGNORE
		number.position = Vector2(0,334)
		number.size = Vector2(size.x,68)
		add_child(number)
	modulate.a = 0
	var fade = create_tween()
	fade.tween_property(self, "modulate:a", 1.0, 0.16).set_trans(Tween.TRANS_SINE)
	fade.tween_interval(0.65)
	fade.tween_property(self, "modulate:a", 0.0, 0.2).set_trans(Tween.TRANS_SINE)
	fade.finished.connect(func(): finished.emit())
