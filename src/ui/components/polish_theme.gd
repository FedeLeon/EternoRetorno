extends RefCounted
const BODY = preload("res://assets/fonts/body.tres")
const HEADING = preload("res://assets/fonts/heading.tres")

static func install(theme: Theme) -> void:
	theme.default_font = BODY
	theme.set_color("font_disabled_color", "Button", Color("8d8793"))
	theme.set_color("font_focus_color", "Button", Color("f4dfac"))
	theme.set_color("font_hover_color", "Button", Color("f6ead9"))
	theme.set_constant("outline_size", "Label", 1)
	theme.set_color("font_outline_color", "Label", Color(0.03,0.025,0.04,0.45))
	var skin = preload("res://src/ui/components/dark_skin.gd")
	for type in ["OptionButton", "MenuButton"]:
		for state in ["normal","hover","pressed","disabled"]:
			theme.set_stylebox(state, type, preload("res://src/ui/components/button_skin.gd").state_style("wood_button", state))
		theme.set_stylebox("focus", type, skin.focus())
		theme.set_constant("arrow_margin", type, 14)
	theme.set_stylebox("panel", "PopupMenu", skin.dialog())
	theme.set_stylebox("panel", "TooltipPanel", skin.dialog())
	theme.set_font_size("font_size", "TooltipLabel", 17)
	theme.set_color("font_color", "TooltipLabel", Color("eee5d8"))
	for type in ["HScrollBar","VScrollBar"]:
		var track = StyleBoxFlat.new(); track.bg_color = Color("17151e"); track.set_corner_radius_all(4)
		track.content_margin_left = 5; track.content_margin_top = 5
		theme.set_stylebox("scroll", type, track)
		for state in ["grabber","grabber_highlight","grabber_pressed"]:
			var grip = StyleBoxFlat.new(); grip.bg_color = Color("897b89") if state == "grabber" else Color("c5ad83")
			grip.set_corner_radius_all(4); grip.content_margin_left = 5; grip.content_margin_top = 5
			theme.set_stylebox(state, type, grip)
	for type in ["HSlider","VSlider"]:
		var track = StyleBoxFlat.new();track.bg_color = Color("302b39");track.set_corner_radius_all(3)
		track.content_margin_top = 3;track.content_margin_bottom = 3
		theme.set_stylebox("slider", type, track)
		var fill = track.duplicate(); fill.bg_color = Color("baa071")
		theme.set_stylebox("grabber_area", type, fill); theme.set_stylebox("grabber_area_highlight", type, fill)
