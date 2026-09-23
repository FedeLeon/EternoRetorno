extends RefCounted
static func decorate(panel: Panel) -> void:
	panel.add_theme_stylebox_override("panel", preload("res://src/ui/components/dark_skin.gd").dialog())
