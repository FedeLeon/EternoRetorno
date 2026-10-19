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
var combat_style = false
var liquid: ShaderMaterial

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	fill = ColorRect.new()
	fill.mouse_filter = Control.MOUSE_FILTER_IGNORE
	liquid = ShaderMaterial.new()
	liquid.shader = preload("res://assets/shaders/health_liquid.gdshader")
	liquid.set_shader_parameter("phase", float(get_instance_id() % 101) * 0.37)
	fill.material = liquid
	add_child(fill)
	caption = Label.new()
	caption.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	# The font's minimum line height can exceed the thin combat bar. Grow on
	# both sides so that minimum size never pushes the caption below its center.
	caption.grow_vertical = Control.GROW_DIRECTION_BOTH
	caption.grow_horizontal = Control.GROW_DIRECTION_BOTH
	caption.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	caption.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	caption.add_theme_font_size_override("font_size", 17)
	caption.add_theme_color_override("font_color", Color("e0dbcf"))
	caption.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(caption)
	caption.add_theme_color_override("font_outline_color", Color("100b12"))
	caption.add_theme_constant_override("outline_size", 3)
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
	fill.visible = not combat_style
	caption.add_theme_font_size_override("font_size", 16 if combat_style else 17)
	queue_redraw()
	fill.size = size
	liquid.set_shader_parameter("tube_size", size)
	liquid.set_shader_parameter("level", displayed_hp / float(maximum_hp))
	caption.text = "%d / %d" % [displayed_hp, maximum_hp] if displayed_hp > 0 else "CAÍDO"

func _draw() -> void:
	if not combat_style: return
	# Quiet, thin bar: the silhouette and intent remain the main visual signals.
	draw_style_box(_bar_style(Color("161823"), Color("bbb5aa")), Rect2(Vector2.ZERO, size))
	var inside = Rect2(Vector2(2, 2), Vector2(maxf(0, size.x - 4), maxf(0, size.y - 4)))
	inside.size.x *= displayed_hp / float(maximum_hp)
	if inside.size.x > 0:
		draw_rect(inside, Color("bd3349"))
		draw_line(inside.position, inside.position + Vector2(inside.size.x, 0), Color("ed6c74"), 1)

func _bar_style(fill_color: Color, edge: Color) -> StyleBoxFlat:
	var style = StyleBoxFlat.new()
	style.bg_color = fill_color
	style.border_color = edge
	style.set_border_width_all(1)
	style.set_corner_radius_all(3)
	return style
