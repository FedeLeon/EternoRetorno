extends RefCounted
# Shared raster skin. Text remains native, readable and localizable.
const REGIONS = {
	"wood_button": Rect2(0, 119, 2172, 457),
	"wood_menu": Rect2(3, 4, 1896, 797),
	"header_frame": Rect2(12, 219, 2147, 272),
	"party_panel": Rect2(0, 222, 2172, 263),
}
static func style(kind: String = "wood_button", tint: Color = Color.WHITE) -> StyleBoxTexture:
	var result = StyleBoxTexture.new()
	result.texture = load("res://assets/ui/buttons/" + kind + ".png")
	var source_width = 2172.0
	if kind == "wood_menu": source_width = 1902.0
	if kind == "header_frame": source_width = 2170.0
	var scale_factor = result.texture.get_width() / source_width
	var region: Rect2 = REGIONS[kind]
	result.region_rect = Rect2(region.position * scale_factor, region.size * scale_factor)
	if kind == "wood_button":
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
		result.content_margin_top = 8
		result.content_margin_bottom = 8
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
	for state in ["normal", "hover", "pressed", "disabled"]:
		button.add_theme_stylebox_override(state, state_style(kind, state))

# Native button icons inherit hover/disabled colors and need no font glyph.
static func arrow(button: Button, left: bool = false) -> Button:
	button.icon = load("res://assets/ui/arrow_left.svg" if left else "res://assets/ui/arrow_right.svg")
	button.icon_alignment = HORIZONTAL_ALIGNMENT_LEFT if left else HORIZONTAL_ALIGNMENT_RIGHT
	button.add_theme_constant_override("icon_max_width", 24)
	button.add_theme_constant_override("h_separation", 8)
	return button

static func plaque_arrow(label: Label) -> void:
	var text_width = ceilf(label.get_theme_font("font").get_string_size(label.text, HORIZONTAL_ALIGNMENT_LEFT, -1, label.get_theme_font_size("font_size")).x)
	label.position.x += (label.size.x - text_width - 32) / 2
	label.size.x = text_width
	var icon = TextureRect.new()
	icon.name = "NavigationArrow"
	icon.texture = preload("res://assets/ui/arrow_right.svg")
	icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
	icon.position = Vector2(label.size.x + 8, 5)
	icon.size = Vector2(24, 24)
	label.add_child(icon)
