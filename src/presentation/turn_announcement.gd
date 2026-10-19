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
	var caption = Label.new()
	caption.name = "Caption"
	caption.text = "Turno del enemigo" if enemy_turn else "Tu turno · %d" % turn_number
	caption.add_theme_font_override("font", preload("res://assets/fonts/heading.tres"))
	caption.add_theme_font_size_override("font_size", 54)
	caption.add_theme_color_override("font_color", Color("f0cc73") if enemy_turn else Color("b9f1ef"))
	caption.add_theme_color_override("font_outline_color", Color("121019"))
	caption.add_theme_constant_override("outline_size", 7)
	caption.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	caption.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	caption.mouse_filter = Control.MOUSE_FILTER_IGNORE
	caption.position = Vector2(0, 234)
	caption.size = Vector2(size.x, 112)
	add_child(caption)
	modulate.a = 0
	var fade = create_tween()
	fade.tween_property(self, "modulate:a", 1.0, 0.16).set_trans(Tween.TRANS_SINE)
	fade.tween_interval(0.65)
	fade.tween_property(self, "modulate:a", 0.0, 0.2).set_trans(Tween.TRANS_SINE)
	fade.finished.connect(func(): finished.emit())
