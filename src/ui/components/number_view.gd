class_name ERNumberView
extends Control

var value: int = 0:
	set(next):
		value = maxi(0, next)
		if is_inside_tree():
			refresh()

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	resized.connect(refresh)
	refresh()

func refresh() -> void:
	for child in get_children():
		remove_child(child)
		child.queue_free()
	var digits = str(value)
	var height = minf(size.y, size.x / (digits.length() * 0.65))
	var width = height * 0.65
	var left = (size.x - width * digits.length()) / 2.0
	for i in range(digits.length()):
		var glyph = TextureRect.new()
		glyph.texture = load("res://assets/ui/numbers/%s.png" % digits[i])
		glyph.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		glyph.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		glyph.mouse_filter = Control.MOUSE_FILTER_IGNORE
		glyph.position = Vector2(left + i * width, (size.y - height) / 2)
		glyph.size = Vector2(width, height)
		add_child(glyph)
