extends RefCounted
const NumberView = preload("res://src/ui/components/number_view.gd")
static func attach(ui: Control, amount: int, origin: Vector2) -> void:
	var icon = TextureRect.new()
	icon.name = "SoulIcon"
	icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	icon.texture = preload("res://assets/ui/soul.png")
	icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
	ui.rect(icon, origin.x, origin.y, 48, 52)
	var number = NumberView.new()
	number.name = "SoulNumber"
	number.value = amount
	number.tooltip_text = "Almas disponibles"
	ui.rect(number, origin.x + 52, origin.y + 8, 160, 36)
