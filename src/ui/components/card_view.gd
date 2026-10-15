extends RefCounted
# Shared presentation for combat, rewards, collection and market.
# Shared normalized centers measured on the generated pixel-art frames.
const COST_CENTERS = {
	"warrior": Vector2(0.878, 0.088), "guardian": Vector2(0.878, 0.088),
	"rogue": Vector2(0.878, 0.088), "mage": Vector2(0.878, 0.088)
}
static func build(ui: Control, instance: Dictionary, x: float, y: float, w: float, h: float, callback: Callable, _chosen: bool, enabled: bool, parent: Control, base_values: bool) -> Button:
	var c = ui.game.content.card(instance)
	var support = c.get("support", false) or c.get("risk", false) or c.get("charge",false) or c.get("interrupt",false)
	var linked = ui.game.content.synergies.any(func(recipe): return instance.id in recipe.cards)
	var card_description = ui.game.content.describe(instance, c if base_values else ui.game.effective_card(instance))
	var def = ui.game.content.heroes[c.owner]
	var accent = Color(def.color)
	var b = ui.button("", x, y, w, h, callback, enabled, parent)
	b.set_meta("card_id", instance.id)
	b.tooltip_text = c.name + " · " + def.name + "\n" + card_description
	for state in ["normal", "disabled", "hover", "pressed", "focus"]:
		b.add_theme_stylebox_override(state, StyleBoxEmpty.new())
	var frame = TextureRect.new()
	frame.texture = load("res://assets/cards/frames/" + c.owner + ".png")
	frame.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	frame.mouse_filter = Control.MOUSE_FILTER_IGNORE
	frame.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	ui.rect(frame, 0, 0, w, h, b)
	if not enabled:
		frame.modulate = Color(0.65, 0.65, 0.65)
	var title = ui.label_at(c.name, w * 0.14, h * 0.061, w * 0.62, h * 0.085, 12 if w < 190 else 14, Color("211b19"), b)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.name = "CardTitle"
	title.autowrap_mode = TextServer.AUTOWRAP_OFF
	title.add_theme_font_override("font", preload("res://src/ui/components/card_typography.gd").font())
	var font_size = title.get_theme_font_size("font_size")
	while font_size > 9 and title.get_theme_font("font").get_string_size(c.name, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size).x > w * 0.62:
		font_size -= 1
	title.add_theme_font_size_override("font_size", font_size)
	var cost = preload("res://src/ui/components/number_view.gd").new()
	cost.name = "CostNumber"
	cost.z_index = 1 # Keep the energy digits above the small overlap between neighbours.
	cost.value = int(c.cost)
	var cost_center: Vector2 = COST_CENTERS[c.owner]
	ui.rect(cost, w * (cost_center.x - 0.08), h * (cost_center.y - 0.05), w * 0.16, h * 0.10, b)
	preload("res://src/ui/components/card_type_icons.gd").attach(b, c, linked)
	var picture_area = ui.panel(w * 0.095, h * 0.185, w * 0.81, h * 0.32, accent, b)
	picture_area.name = "IllustrationSpace"
	picture_area.add_theme_stylebox_override("panel", ui.box(Color("14151c"), accent.darkened(0.3), 1))
	preload("res://src/ui/components/card_art.gd").attach(picture_area, instance.id, Rect2(3, 3, picture_area.size.x - 6, picture_area.size.y - 6))
	var category = "Ataque" if c.damage > 0 or c.poison > 0 else ("Defensa" if c.block > 0 and not support else "Habilidad")
	var ribbon = ui.label_at(category, w * 0.22, h * 0.52, w * 0.56, h * 0.055, 10 if h < 300 else 12, Color("f1e8d5"), b)
	ribbon.name = "CardCategory"
	ribbon.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	var description_top = h * 0.60
	var description_height = h * 0.275
	var description_size = clampi(roundi(h * 0.058), 14, 24)
	var description = ui.label_at(card_description, w * 0.11, description_top, w * 0.78, description_height, description_size, Color("211b19"), b)
	description.name = "CardDescription"
	description.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	description.add_theme_font_override("font", preload("res://src/ui/components/card_typography.gd").font())
	description.add_theme_constant_override("line_spacing", 2)
	# Fit the actual wrapped label, including explicit lines and line spacing.
	# Short effects use larger type; verbose support cards shrink only as needed.
	description_size = description.get_theme_font_size("font_size")
	while description_size > 9 and description.get_line_count() * description.get_line_height() + maxi(0, description.get_line_count() - 1) * 2 > description_height:
		description_size -= 1
		description.add_theme_font_size_override("font_size", description_size)
	preload("res://src/ui/components/synergy_view.gd").mark(ui, b, instance.id, ui.game.content.synergies, ui.game.content.cards)
	preload("res://src/presentation/card_finish.gd").attach(b, frame, linked)
	preload("res://src/ui/components/card_typography.gd").apply(b)
	return b
