extends Control
# Shared fallback uses the same drawn dungeon; keep resource path and UID.
const BACKGROUND = preload("res://assets/dungeon/combat.png")
func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
	resized.connect(queue_redraw)
func _draw() -> void:
	draw_texture_rect(BACKGROUND,Rect2(Vector2.ZERO,size),false)
	draw_rect(Rect2(Vector2.ZERO,size),Color(0.035,0.025,0.045,0.52))
