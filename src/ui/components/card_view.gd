extends RefCounted
# Shared presentation for combat, rewards, collection and market.
# Normalized centers measured on each illustrated frame (not identical layouts).
const COST_CENTERS = {
	"warrior": Vector2(0.87, 0.18), "guardian": Vector2(0.884, 0.173),
	"rogue": Vector2(0.872, 0.158), "mage": Vector2(0.880, 0.158),
	"cleric": Vector2(0.884, 0.192), "ranger": Vector2(0.872, 0.171)
}
static func build(ui: Control, instance: Dictionary, x: float, y: float, w: float, h: float, callback: Callable, _chosen: bool, enabled: bool, parent: Control, base_values: bool) -> Button:
	var c = ui.game.content.card(instance)
	var linked = ui.game.content.synergies.any(func(recipe): return instance.id in recipe.cards)
	var card_description = ui.game.content.describe(instance, c if base_values else ui.game.effective_card(instance))
	var def = ui.game.content.heroes[c.owner]
	var colors = {"warrior": Color("98483f"), "guardian": Color("438b89"), "rogue": Color("72864a"), "mage": Color("8f65b4"), "cleric": Color("c09a55"), "ranger": Color("507ba6")}
	var accent: Color = colors[c.owner]
	var b = ui.button("", x, y, w, h, callback, enabled, parent)
	b.set_meta("card_id", instance.id)
	b.tooltip_text = c.name + " · " + def.name + "\n" + card_description
	for state in ["normal", "disabled", "hover", "pressed", "focus"]:
		b.add_theme_stylebox_override(state, StyleBoxEmpty.new())
	var frame = TextureRect.new()
	frame.texture = load("res://assets/cards/frames/" + c.owner + ".png")
	frame.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	frame.mouse_filter = Control.MOUSE_FILTER_IGNORE
	frame.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
	ui.rect(frame, 0, 0, w, h, b)
	if not enabled:
		frame.modulate = Color(0.65, 0.65, 0.65)
	var title = ui.label_at(c.name, w * 0.12, h * 0.145, w * 0.62, h * 0.085, 12 if w < 190 else 14, Color("211b19"), b)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	var cost = preload("res://src/ui/components/number_view.gd").new()
	cost.name = "CostNumber"
	cost.z_index = 1 # Keep the energy digits above the small overlap between neighbours.
	cost.value = int(c.cost)
	var cost_center: Vector2 = COST_CENTERS[c.owner]
	ui.rect(cost, w * (cost_center.x - 0.08), h * (cost_center.y - 0.05), w * 0.16, h * 0.10, b)
	preload("res://src/ui/components/card_type_icons.gd").attach(b, c, linked)
	var picture_area = ui.panel(18, h * 0.27, w - 36, h * 0.34, accent, b)
	picture_area.name = "IllustrationSpace"
	picture_area.add_theme_stylebox_override("panel", ui.box(Color("14151c"), accent.darkened(0.3), 1))
	preload("res://src/ui/components/card_art.gd").attach(picture_area, instance.id, Rect2(3, 3, picture_area.size.x - 6, picture_area.size.y - 6))
	var description = ui.label_at(card_description, w * 0.13, h * 0.655, w * 0.74, h * 0.245, 12 if w < 190 else 14, Color("211b19"), b)
	description.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	preload("res://src/ui/components/synergy_view.gd").mark(ui, b, instance.id, ui.game.content.synergies, ui.game.content.cards)
	preload("res://src/presentation/card_finish.gd").attach(b, frame, linked)
	preload("res://src/ui/components/card_typography.gd").apply(b)
	return b
