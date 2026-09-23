extends RefCounted
# Shared skin. Small controls keep a clean interior; large frames retain artwork.
# Legacy kind IDs retained so all callers share the replacement skin.
static func style(kind: String = "wood_button", tint: Color = Color.WHITE) -> StyleBox:
	if kind in ["header_frame", "party_panel"]:
		return preload("res://src/ui/components/dark_skin.gd").frame(true, tint)
	return preload("res://src/ui/components/dark_skin.gd").button(tint)

static func install(ui_theme: Theme) -> void:
	for state in ["normal", "hover", "pressed", "disabled"]:
		ui_theme.set_stylebox(state, "Button", state_style("wood_button", state))

static func state_style(kind: String, state: String) -> StyleBox:
	var tint = Color.WHITE
	if state == "hover": tint = Color(1.22, 1.16, 1.30)
	if state == "pressed": tint = Color(0.72, 0.70, 0.80)
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
