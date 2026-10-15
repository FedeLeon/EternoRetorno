extends RefCounted
## Reusable visual construction. No navigation, game state or persistence.
const TEXT = Color("ded9e5")

static func create_theme() -> Theme:
	var ui_theme = Theme.new()
	ui_theme.default_font_size = 20
	ui_theme.set_color("font_color", "Label", TEXT)
	ui_theme.set_color("font_color", "Button", TEXT)
	ui_theme.set_color("font_disabled_color", "Button", Color("666b79"))
	ui_theme.set_color("font_hover_color", "Button", Color("eee5fa"))
	preload("res://src/ui/components/button_skin.gd").install(ui_theme)
	ui_theme.set_stylebox("focus", "Button", preload("res://src/ui/components/dark_skin.gd").focus())
	preload("res://src/ui/components/polish_theme.gd").install(ui_theme)
	return ui_theme

static func box(fill: Color, border: Color = Color("343b4d"), width: int = 1) -> StyleBoxFlat:
	var style = StyleBoxFlat.new()
	style.bg_color = fill
	style.border_color = border
	style.set_border_width_all(width)
	style.content_margin_left = 12
	style.content_margin_right = 12
	style.content_margin_top = 8
	style.content_margin_bottom = 8
	return style


static func rect(node: Control, x: float, y: float, w: float, h: float, parent: Control) -> Control:
	node.set_meta("intended_size",Vector2(w,h))
	node.position = Vector2(x, y)
	node.size = Vector2(w, h)
	parent.add_child(node)
	return node


static func label_at(text: String, x: float, y: float, w: float, h: float, font_size: int = 20, color: Color = TEXT, parent: Control = null) -> Label:
	var label = Label.new()
	label.add_theme_font_size_override("font_size", roundi(font_size * (preload("res://src/presentation/preferences.gd").text_scale() if font_size >= 16 else 1.0)))
	label.add_theme_color_override("font_color", color)
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	rect(label, x, y, w, h, parent)
	if font_size >= 25: label.add_theme_font_override("font", preload("res://src/ui/components/polish_theme.gd").HEADING)
	label.text = text
	return label


static func button(text: String, x: float, y: float, w: float, h: float, callback: Callable, enabled: bool = true, parent: Control = null) -> Button:
	var b = Button.new()
	b.text = text
	if text in ["Inicio", "Elegir componente", "Saltar recompensa"]:
		preload("res://src/ui/components/button_skin.gd").arrow(b, text == "Inicio")
	if text == "Menú":
		preload("res://src/ui/components/button_skin.gd").decorate(b, "wood_menu")
	b.disabled = not enabled
	b.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	b.pressed.connect(callback)
	rect(b, x, y, w, h, parent)
	return b


static func panel(x: float, y: float, w: float, h: float, border: Color = Color("343b4d"), parent: Control = null) -> Panel:
	var p = Panel.new()
	p.add_theme_stylebox_override("panel", preload("res://src/ui/components/dark_skin.gd").frame(h < 90) if w >= 250 and h >= 50 else box(Color("101016"), border))
	p.mouse_filter = Control.MOUSE_FILTER_IGNORE
	rect(p, x, y, w, h, parent)
	return p


