extends RefCounted
## Camp entry keeps the existing continue/new adventure callback.
static func build(ui: Control, action: Callable) -> Button:
	var button = ui.button("", 1100, 116, 164, 164, action)
	button.name = "CampExit"
	button.tooltip_text = "Aventuras"
	button.set_meta("caption_rect", Rect2(button.position + Vector2(10, 126), Vector2(144, 30)))
	var play = TextureRect.new()
	play.name = "AdventurePlay"
	play.texture = preload("res://assets/ui/play.svg")
	play.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	play.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	play.mouse_filter = Control.MOUSE_FILTER_IGNORE
	ui.rect(play, 18, 4, 128, 128, button)
	var caption = ui.label_at("Aventuras", 10, 126, 144, 30, 20, ui.GOLD, button)
	caption.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	var electricity = preload("res://src/presentation/end_turn_electricity.gd").new()
	electricity.name = "Electricity"
	electricity.rectangular = true
	button.add_child(electricity)
	electricity.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	return button
