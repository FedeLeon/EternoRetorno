extends Control
# Icon layout and inspection only. Snapshot owns descriptions, Game owns actions.
const CELL = 40
const GAP = 1
const COLUMNS = 5
var entries: Array = []
var ui: Control
var compact = false

static func height_for(count: int, small: bool = false) -> int:
	return ceili(count / float(6 if small else COLUMNS)) * ((32 if small else CELL) + GAP)

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	if entries.is_empty(): return
	var columns = 6 if compact else COLUMNS
	var cell = 32 if compact else CELL
	var holder: Control = self
	var left = (size.x - mini(entries.size(), columns) * (cell + GAP) + GAP) / 2.0
	for i in range(entries.size()):
		var data: Dictionary = entries[i]
		var button = Button.new()
		button.name = "Effect_" + data.id
		button.set_meta("battle_effect", data)
		button.tooltip_text = data.title
		button.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
		button.position = Vector2(left + (i % columns) * (cell + GAP), (i / columns) * (cell + GAP))
		button.size = Vector2(cell, cell)
		for state in ["normal", "hover", "pressed"]:
			var style = StyleBoxFlat.new()
			style.bg_color = Color(0.025, 0.022, 0.035, 0.85 if state == "normal" else 0.98)
			style.set_corner_radius_all(5)
			if state != "normal":
				style.set_border_width_all(1); style.border_color = Color("bba06e")
			button.add_theme_stylebox_override(state, style)
		button.add_theme_stylebox_override("focus", preload("res://src/ui/components/dark_skin.gd").focus())
		button.pressed.connect(func():
			if ui.combat_busy: return
			ui.close_modal()
			var actions: Array = []
			if data.get("objective_action", false): actions = preload("res://src/ui/components/boss_objective.gd").actions(ui)
			actions.append({"text":"Volver", "callback":ui.close_modal})
			var font_size = roundi(21 * preload("res://src/presentation/preferences.gd").text_scale())
			var body_height = preload("res://src/ui/components/polish_theme.gd").BODY.get_multiline_string_size(data.description, HORIZONTAL_ALIGNMENT_CENTER, 648, font_size).y + 10
			ui.overlay = preload("res://src/ui/components/dialog_view.gd").build(ui, data.title, data.description, actions, body_height))
		holder.add_child(button)
		var picture = TextureRect.new()
		picture.texture = load(data.asset)
		picture.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		picture.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		picture.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
		picture.position = Vector2(2, 2); picture.size = Vector2(cell - 4, cell - 4)
		picture.mouse_filter = Control.MOUSE_FILTER_IGNORE
		button.add_child(picture)
		if int(data.get("value", 0)) > 0:
			var amount = Label.new()
			amount.text = str(data.value) + ("%" if data.get("percent", false) else "")
			amount.add_theme_font_size_override("font_size", 15)
			amount.add_theme_color_override("font_color", Color("fff0c8"))
			amount.add_theme_color_override("font_outline_color", Color("08070b"))
			amount.add_theme_constant_override("outline_size", 5)
			amount.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
			amount.position = Vector2(2, cell - 17); amount.size = Vector2(cell - 4, 17)
			amount.mouse_filter = Control.MOUSE_FILTER_IGNORE
			button.add_child(amount)
