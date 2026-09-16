extends Control

signal animation_finished
signal value_changed(value: int)
var displayed_hp = 0
var maximum_hp = 1
var target_hp = 0
var animating = false
var elapsed = 0.0
var fill: ColorRect
var caption: Label

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	var back = ColorRect.new()
	back.color = Color("35252f")
	back.mouse_filter = Control.MOUSE_FILTER_IGNORE
	back.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(back)
	fill = ColorRect.new()
	fill.color = Color("98605f")
	fill.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(fill)
	caption = Label.new()
	caption.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	caption.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	caption.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	caption.add_theme_font_size_override("font_size", 17)
	caption.add_theme_color_override("font_color", Color("e0dbcf"))
	caption.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(caption)
	resized.connect(refresh)
	refresh()

func set_health(hp: int, max_hp: int) -> void:
	maximum_hp = maxi(1, max_hp)
	displayed_hp = clampi(hp, 0, maximum_hp)
	target_hp = displayed_hp
	if is_node_ready():
		refresh()

func animate_to(hp: int) -> void:
	target_hp = clampi(hp, 0, maximum_hp)
	elapsed = 0.0
	animating = displayed_hp != target_hp

func _process(delta: float) -> void:
	if not animating:
		return
	elapsed += delta
	if elapsed < 0.025:
		return
	# At most one point per rendered frame, so intermediate integers remain visible.
	elapsed = 0.0
	displayed_hp += 1 if target_hp > displayed_hp else -1
	refresh()
	value_changed.emit(displayed_hp)
	if displayed_hp == target_hp:
		animating = false
		animation_finished.emit()

func refresh() -> void:
	fill.size = Vector2(size.x * displayed_hp / float(maximum_hp), size.y)
	caption.text = "%d / %d" % [displayed_hp, maximum_hp] if displayed_hp > 0 else "CAÍDO"
