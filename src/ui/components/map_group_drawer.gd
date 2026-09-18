extends Control
# Presentation-only sliding party panel; map owns the snapshot and callbacks.
const HealthBar = preload("res://src/ui/components/health_bar.gd")
var host: Control
var opened = false
var motion: Tween
var tab: Button

func place(node: Control, area: Rect2, parent: Node = self) -> void:
	host.place(node, area, parent)
func label(text: String, area: Rect2, font_size: int = 20) -> Label:
	return host.label(text, area, font_size, Color("e6ddd0"), self)
func picture(texture: Texture2D, area: Rect2, parent: Node = self) -> TextureRect:
	return host.picture(texture, area, parent)

func _ready() -> void:
	name = "GroupDrawer"
	position = Vector2(1280, 0)
	size = Vector2(510, 720)
	z_index = 40
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	var panel = Panel.new()
	preload("res://src/ui/components/modal_frame.gd").decorate(panel)
	place(panel, Rect2(0, 48, 510, 672))
	label("EL GRUPO", Rect2(28, 104, 420, 30), 18)
	for i in range(host.heroes.size()): show_hero(host.heroes[i], i)
	label("RELIQUIAS", Rect2(28, 437, 320, 28), 18)
	show_relics()
	var deck = host.action("", Rect2(30, 641, 64, 58), func(): host.deck_requested.emit(), self)
	deck.name = "Deck"
	deck.tooltip_text = "Ver mazo · %d cartas" % host.deck_count
	for state in ["normal", "hover", "pressed", "focus"]:
		deck.add_theme_stylebox_override(state, StyleBoxEmpty.new())
	picture(preload("res://assets/ui/deck.svg"), Rect2(0, 0, 64, 58), deck)
	label("%d cartas" % host.deck_count, Rect2(112, 657, 160, 30), 18)
	# Fixed rail stays at the viewport edge while the group panel slides beneath it.
	var rail = Panel.new()
	rail.name = "SideRail"
	rail.z_index = 41
	var rail_style = StyleBoxFlat.new()
	rail_style.bg_color = Color("111923")
	rail_style.border_color = Color("ba995f")
	rail_style.border_width_left = 2
	rail.add_theme_stylebox_override("panel", rail_style)
	host.place(rail, Rect2(1196, 0, 84, 720))
	var ornament = Panel.new()
	ornament.mouse_filter = Control.MOUSE_FILTER_IGNORE
	ornament.add_theme_stylebox_override("panel", preload("res://src/ui/components/button_skin.gd").style("header_frame"))
	place(ornament, Rect2(84, 0, 720, 84), rail)
	ornament.rotation = PI / 2
	tab = host.action("", Rect2(4, 106, 76, 116), toggle, rail)
	tab.name = "GroupTab"
	tab.tooltip_text = "Abrir grupo"
	for state in ["normal", "hover", "pressed", "focus"]:
		tab.add_theme_stylebox_override(state, StyleBoxEmpty.new())
	picture(preload("res://assets/map/group_tab.png"), Rect2(0, 0, 76, 94), tab)
	var caption = host.label("Grupo", Rect2(0, 91, 76, 24), 16, Color("ead3a0"), tab)
	caption.name = "Caption"
	caption.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER

func toggle() -> void:
	opened = not opened
	tab.tooltip_text = "Cerrar grupo" if opened else "Abrir grupo"
	tab.get_node("Caption").modulate = Color("fff1c6") if opened else Color.WHITE
	if motion != null: motion.kill()
	motion = create_tween().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	motion.tween_property(self, "position:x", 686.0 if opened else 1280.0, 0.28)

func show_hero(hero: Dictionary, index: int) -> void:
	var top = 124 + index * 152
	var actor = hero.visual.new()
	actor.name = "Hero%d" % index
	place(actor, Rect2(18, top, 152, 128))
	preload("res://src/presentation/hero_equipment.gd").apply(actor, hero.id, hero.get("forge", {}))
	actor.set_fallen(hero.hp <= 0)
	label(hero.title, Rect2(185, top + 25, 274, 40), 24)
	var health = HealthBar.new()
	health.name = "Health%d" % index
	health.set_health(hero.hp, hero.max_hp)
	place(health, Rect2(185, top + 77, 270, 28))

func show_relics() -> void:
	var scroll = ScrollContainer.new()
	scroll.name = "Relics"
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	place(scroll, Rect2(26, 473, 434, 161))
	var column = VBoxContainer.new()
	column.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.add_child(column)
	if host.relics.is_empty():
		var empty = Label.new()
		empty.text = "Sin reliquias."
		column.add_child(empty)
	for relic in host.relics:
		var row = HBoxContainer.new()
		row.add_theme_constant_override("separation", 10)
		column.add_child(row)
		if relic.get("icon", -1) >= 0:
			var texture = AtlasTexture.new()
			texture.atlas = load("res://assets/objects/icons.png")
			texture.region = Rect2((int(relic.icon) % 4) * 64, (int(relic.icon) / 4) * 64, 64, 64)
			var icon = picture(texture, Rect2(0, 0, 56, 56), row)
			icon.custom_minimum_size = Vector2(56, 56)
		var text = Label.new()
		text.text = relic.name + " · " + relic.owner + "\n" + relic.description
		text.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		text.add_theme_font_size_override("font_size", 16)
		text.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		row.add_child(text)
