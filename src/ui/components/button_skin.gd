extends RefCounted
# Shared raster skin. Text remains native, readable and localizable.
const REGIONS = {
	"wood_button": Rect2(0, 119, 2172, 457),
	"wood_menu": Rect2(3, 4, 1896, 797),
	"header_frame": Rect2(12, 219, 2147, 272),
	"back_party": Rect2(4, 98, 2164, 493),
	"start_adventure": Rect2(3, 118, 2072, 465),
	"button": Rect2(18, 275, 1738, 334),
	"relic_button": Rect2(4, 128, 2164, 434),
	"party_panel": Rect2(0, 222, 2172, 263),
}
static func style(kind: String = "wood_button", tint: Color = Color.WHITE) -> StyleBoxTexture:
	var result = StyleBoxTexture.new()
	result.texture = load("res://assets/ui/buttons/" + kind + ".png")
	var source_width = 1774.0 if kind == "button" else 2172.0
	if kind == "start_adventure": source_width = 2078.0
	if kind == "wood_menu": source_width = 1902.0
	if kind == "header_frame": source_width = 2170.0
	var scale_factor = result.texture.get_width() / source_width
	var region: Rect2 = REGIONS[kind]
	result.region_rect = Rect2(region.position * scale_factor, region.size * scale_factor)
	if kind in ["button", "wood_button"]:
		result.texture_margin_left = 22
		result.texture_margin_right = 22
		result.texture_margin_top = 12
		result.texture_margin_bottom = 12
	result.modulate_color = tint
	result.content_margin_left = 16
	result.content_margin_right = 16
	result.content_margin_top = 8
	result.content_margin_bottom = 8
	if kind == "wood_menu":
		result.content_margin_top = 16
		result.content_margin_bottom = 4
	return result

static func install(ui_theme: Theme) -> void:
	for state in ["normal", "hover", "pressed", "disabled"]:
		ui_theme.set_stylebox(state, "Button", state_style("wood_button", state))

static func state_style(kind: String, state: String) -> StyleBoxTexture:
	var tint = Color.WHITE
	if state == "hover": tint = Color(1.25, 1.18, 1.05)
	if state == "pressed": tint = Color(0.75, 0.82, 0.9)
	if state == "disabled": tint = Color(0.45, 0.47, 0.5)
	return style(kind, tint)

static func decorate(button: Button, kind: String) -> void:
	if kind in ["button", "back_party", "start_adventure", "relic_button"]:
		kind = "wood_button"
	for state in ["normal", "hover", "pressed", "disabled"]:
		button.add_theme_stylebox_override(state, state_style(kind, state))
