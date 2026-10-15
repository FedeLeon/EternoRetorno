extends RefCounted
# Shared presentation for combat, rewards, collection and market.
# Shared normalized centers authored in the native comic card skins.
const COST_CENTERS = {
	"warrior": Vector2(0.89, 0.17), "guardian": Vector2(0.89, 0.17),
	"rogue": Vector2(0.89, 0.17), "mage": Vector2(0.89, 0.17)
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
	frame.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
	ui.rect(frame, 0, 0, w, h, b)
	if not enabled:
		frame.modulate = Color(0.65, 0.65, 0.65)
	var title = ui.label_at(c.name, w * 0.12, h * 0.145, w * 0.62, h * 0.085, 12 if w < 190 else 14, Color("211b19"), b)
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
	var owner_name = def.get("civilian", {}).get("name", def.name)
	var owner_caption = owner_name + " · " + def.name
	if instance.get("upgraded", false): owner_caption += " · MEJORADA"
	var owner = ui.label_at(owner_caption, w * 0.12, h * 0.228, w * 0.76, maxf(16, h * 0.055), 10 if h < 300 else 12, Color("e4ebee"), b)
	owner.name = "CardOwner"
	owner.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	owner.autowrap_mode = TextServer.AUTOWRAP_OFF
	owner.add_theme_font_override("font", preload("res://src/ui/components/card_typography.gd").owner_font())
	var owner_font_size = owner.get_theme_font_size("font_size")
	while owner_font_size > 9 and owner.get_theme_font("font").get_string_size(owner_caption, HORIZONTAL_ALIGNMENT_LEFT, -1, owner_font_size).x > w * 0.76:
		owner_font_size -= 1
	owner.add_theme_font_size_override("font_size", owner_font_size)
	preload("res://src/ui/components/card_type_icons.gd").attach(b, c, linked)
	var picture_area = ui.panel(18, h * 0.30, w - 36, h * 0.30, accent, b)
	picture_area.name = "IllustrationSpace"
	picture_area.add_theme_stylebox_override("panel", ui.box(Color("14151c"), accent.darkened(0.3), 1))
	preload("res://src/ui/components/card_art.gd").attach(picture_area, instance.id, Rect2(3, 3, picture_area.size.x - 6, picture_area.size.y - 6))
	var description_top = h * (0.63 if support else 0.655)
	var description_height = minf(h * 0.245, h - 35 - description_top)
	var description_font = preload("res://src/ui/components/card_typography.gd").font()
	var description_size = (10 if h < 260 else 11) if support else (12 if w < 190 else 14)
	while description_size > 9 and description_font.get_multiline_string_size(card_description, HORIZONTAL_ALIGNMENT_CENTER, w * 0.74, description_size).y > description_height:
		description_size -= 1
	var description = ui.label_at(card_description, w * 0.13, description_top, w * 0.74, description_height, description_size, Color("211b19"), b)
	description.name = "CardDescription"
	description.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	preload("res://src/ui/components/synergy_view.gd").mark(ui, b, instance.id, ui.game.content.synergies, ui.game.content.cards)
	preload("res://src/presentation/card_finish.gd").attach(b, frame, linked)
	preload("res://src/ui/components/card_typography.gd").apply(b)
	return b
