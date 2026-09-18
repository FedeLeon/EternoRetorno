class_name ERBlockIndicator
extends Control
const NumberView = preload("res://src/ui/components/number_view.gd")
var amount = 0
var number_height = 24.0
var gaining_block = false
var icon_texture: Texture2D
var explanation = ""
func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_STOP if explanation != "" else Control.MOUSE_FILTER_IGNORE
	if explanation != "":
		size = Vector2(70, 30)
		mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
		gui_input.connect(func(event):
			if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
				preload("res://src/ui/components/combat_tip.gd").show_for(self, explanation)
				accept_event())
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
	number.position = Vector2(35, (28 - number_height) / 2)
	number.size = Vector2(minf(35 if number_height < 24 else 41, str(maxi(0, amount)).length() * number_height * 0.65), number_height)
	add_child(number)

	if gaining_block:
		var arrow = TextureRect.new()
		arrow.name = "BlockUp"
		arrow.texture = preload("res://assets/ui/block_up.svg")
		arrow.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		arrow.mouse_filter = Control.MOUSE_FILTER_IGNORE
		arrow.position = Vector2(20, -5)
		arrow.size = Vector2(14, 22)
		add_child(arrow)

func update_active_block(value: int) -> void:
	amount = value
	visible = amount > 0
	get_child(1).value = amount
	explanation = "Bloqueo activo: absorberá hasta %d de daño de los próximos golpes, salvo ataques penetrantes. El sobrante se pierde al comenzar el siguiente turno de esta unidad." % amount
