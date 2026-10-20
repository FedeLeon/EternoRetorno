extends Button
# Illustrated choice; no gameplay or persistence dependencies.
const ART = "res://assets/ui/polished/encounters/"
const Preferences = preload("res://src/presentation/preferences.gd")
var artwork: TextureRect
var hover_motion: Tween

static func describe(id: String, index: int, text: String) -> Dictionary:
	var icon = "continue"
	if id.begins_with("pair_"): icon = "link" if index == 0 else "heal"
	elif id.begins_with("pact_"): icon = "risk" if index == 0 else "leave"
	elif index == 1: icon = "leave"
	else: icon = {"well":"heal", "altar":"upgrade", "library":"read", "forest_spring":"heal", "forest_hunter":"remove", "forest_spirit":"heal", "forge_altar":"transform", "ash_archive":"exchange", "lava_bridge":"risk"}.get(id, "continue")
	var separator = " · " if text.contains(" · ") else ": "
	var parts = text.split(separator, true, 1)
	if index == 0 and id == "forest_spring": parts = ["Recuperar fuerzas", "Descansar junto al colector de lluvia."]
	if index == 0 and id == "forest_spirit": parts = ["Revisar el depósito", "Recoger los suministros señalados."]
	return {"icon":icon, "title":parts[0], "detail":parts[1] if parts.size() > 1 else "", "tone":Color("a95b49") if icon == "risk" or id == "altar" and index == 0 else Color("32686b")}

func configure(data: Dictionary, area: Rect2, unavailable: String = "") -> void:
	position = area.position
	size = area.size
	text = "" # Labels below give long consequences a separate, readable line.
	tooltip_text = data.title + (". " + data.detail if data.detail != "" else "")
	accessibility_name = tooltip_text
	mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	for state in ["normal", "hover", "pressed", "disabled"]:
		var frame = StyleBoxTexture.new()
		frame.texture = load(ART + "choice.svg")
		for side in [SIDE_LEFT, SIDE_TOP, SIDE_RIGHT, SIDE_BOTTOM]: frame.set_texture_margin(side, 22)
		frame.modulate_color = Color("bdb8b0") if state == "disabled" else (Color("d5f3ed") if state == "hover" else (Color("bacccc") if state == "pressed" else Color.WHITE))
		add_theme_stylebox_override(state, frame)
	var focus = StyleBoxFlat.new()
	focus.bg_color = Color.TRANSPARENT
	focus.border_color = Color("60b5b5")
	focus.set_border_width_all(3)
	focus.set_corner_radius_all(10)
	add_theme_stylebox_override("focus", focus)
	artwork = TextureRect.new()
	artwork.name = "ChoiceIcon"
	artwork.texture = load(ART + data.icon + ".svg")
	artwork.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	artwork.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	artwork.mouse_filter = Control.MOUSE_FILTER_IGNORE
	artwork.position = Vector2(20, (size.y - 72) / 2)
	artwork.size = Vector2(72, 72)
	add_child(artwork)
	var title = add_text(data.title, Rect2(110, 15, size.x-142, 46), 22)
	title.add_theme_font_override("font", preload("res://src/ui/components/polish_theme.gd").HEADING)
	title.add_theme_color_override("font_color", data.tone)
	var detail: String = unavailable if unavailable != "" else data.detail
	if detail == "":
		title.position.y = 20
		title.size.y = size.y - 40
	else:
		add_text(detail, Rect2(110, 61, size.x-142, size.y-75), 19)
	disabled = unavailable != ""
	if disabled:
		artwork.modulate = Color(.6,.6,.6)
		tooltip_text = unavailable
	mouse_entered.connect(func(): highlight(true))
	mouse_exited.connect(func(): highlight(false))
	focus_entered.connect(func(): highlight(true))
	focus_exited.connect(func(): highlight(false))

func add_text(value: String, area: Rect2, font_size: int) -> Label:
	var line = Label.new()
	line.text = value
	line.position = area.position
	line.size = area.size
	line.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	line.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	line.mouse_filter = Control.MOUSE_FILTER_IGNORE
	line.add_theme_font_size_override("font_size", font_size)
	line.add_theme_color_override("font_color", Color("252431"))
	line.add_theme_constant_override("outline_size", 0)
	add_child(line)
	return line

func highlight(active: bool) -> void:
	if disabled or Preferences.low_quality(): return
	if hover_motion: hover_motion.kill()
	hover_motion = create_tween().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	hover_motion.tween_property(artwork, "position:x", 24.0 if active else 20.0, .15)
