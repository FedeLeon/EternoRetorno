class_name ERBlockIndicator
extends Control
const NumberView = preload("res://src/ui/components/number_view.gd")
var amount = 0
var icon_texture: Texture2D
func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	visible = amount > 0
	var shield = TextureRect.new()
	var texture = AtlasTexture.new()
	texture.atlas = preload("res://assets/objects/icons.png")
	# Existing pilgrim shield artwork reused as the block symbol.
	# Trim the atlas cell's transparent padding so the visible shield fills its slot.
	var cell = Rect2i(128, 64, 64, 64)
	var bounds = texture.atlas.get_image().get_region(cell).get_used_rect()
	texture.region = Rect2(cell.position + bounds.position, bounds.size)
	shield.texture = icon_texture if icon_texture != null else texture
	shield.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	shield.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	shield.mouse_filter = Control.MOUSE_FILTER_IGNORE
	shield.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	shield.position = Vector2(0, -2)
	shield.size = Vector2(32, 32)
	add_child(shield)
	var number = NumberView.new()
	number.value = amount
	number.position = Vector2(35, 2)
	number.size = Vector2(minf(41, str(maxi(0, amount)).length() * 15.6), 24)
	add_child(number)
