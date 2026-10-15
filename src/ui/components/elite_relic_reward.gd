extends RefCounted
# The relic has already been granted and saved before this panel is shown.
static func build(ui: Control, relic: Dictionary) -> void:
	var panel = ui.panel(28, 160, 358, 414)
	panel.name = "EliteRelicReward"
	ui.label_at("Componente obtenida", 16, 14, 326, 36, 25, ui.GOLD, panel).horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	var icon = TextureRect.new()
	icon.name = "RelicArtwork"
	icon.texture = preload("res://src/presentation/relic_art.gd").texture(relic)
	icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
	ui.rect(icon, 101, 58, 156, 156, panel)
	ui.label_at(relic.name, 18, 218, 322, 52, 23, ui.GOLD, panel).horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	ui.label_at(relic.description, 22, 276, 314, 90, 18, ui.TEXT, panel).horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	ui.label_at("Ya añadida al grupo", 18, 376, 322, 26, 17, ui.MUTED, panel).horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
