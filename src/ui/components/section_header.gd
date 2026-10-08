extends RefCounted
# Consistent framed titles for secondary sections; no duplicated game logo.
static func build(ui: Control, title: String, subtitle: String, action: Callable = Callable(), caption: String = "Menú", action_width: float = 102) -> void:
	var frame = ui.panel(0,0,1280,125)
	frame.name = "SectionHeader"
	frame.add_theme_stylebox_override("panel",preload("res://src/ui/components/button_skin.gd").style("header_frame"))
	ui.label_at(title,64,16,1152-action_width-24,48,28,ui.GOLD)
	if subtitle != "": ui.label_at(subtitle,64,69,1152,42,18,ui.MUTED)
	ui.button(caption,1240-action_width,22,action_width,40,action if action.is_valid() else ui.pause_menu)
