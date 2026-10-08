extends RefCounted
# Shared visual backdrop for deck and consumables; no state or input handling.
static func build(ui: Control, parent: Node = null) -> void:
	var background = TextureRect.new()
	background.name = "InventoryBackground"
	background.texture = preload("res://assets/inventory/background.png")
	background.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	background.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	background.mouse_filter = Control.MOUSE_FILTER_IGNORE
	ui.rect(background, 0, 0, 1280, 720, parent)
