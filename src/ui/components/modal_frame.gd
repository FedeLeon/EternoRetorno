extends RefCounted
static func decorate(panel: Panel) -> void:
	var style = StyleBoxTexture.new()
	style.texture = preload("res://assets/ui/modal_frame.png")
	panel.add_theme_stylebox_override("panel", style)
