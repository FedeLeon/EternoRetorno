extends Control
# Presentation-only sliding party panel; map owns the snapshot and callbacks.
const HealthBar = preload("res://src/ui/components/health_bar.gd")
var host: Control
var opened = false
var motion: Tween
var tab: Button
var popover: PanelContainer
var selected_relic: Button

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
	for i in range(host.heroes.size()): show_hero(host.heroes[i], i)
	label("COMPONENTES", Rect2(28, 437, 320, 28), 18)
	show_relics()
	# Fixed rail stays at the viewport edge while the group panel slides beneath it.
	var rail = Panel.new()
	rail.name = "SideRail"
	rail.z_index = 41
	var rail_style = StyleBoxFlat.new()
	rail_style.bg_color = Color("101016")
	rail_style.border_color = Color("eee8da")
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
	picture(preload("res://assets/map/sidebar/group.png"), Rect2(6, 4, 64, 64), tab)
	var caption = host.label("Grupo", Rect2(0, 70, 76, 24), 16, Color("ead3a0"), tab)
	caption.name = "Caption"
	caption.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	var deck = host.action("", Rect2(4, 246, 76, 94), func(): host.deck_requested.emit(), rail)
	deck.name = "Deck"
	deck.tooltip_text = "Ver mazo · %d cartas" % host.deck_count
	for state in ["normal", "hover", "pressed", "focus"]:
		deck.add_theme_stylebox_override(state, StyleBoxEmpty.new())
	picture(preload("res://assets/map/sidebar/deck.png"), Rect2(6, 4, 64, 64), deck)
	var deck_caption = host.label("Mazo", Rect2(0, 70, 76, 24), 16, Color("ead3a0"), deck)
	deck_caption.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER


	if host.paths_available:
		var map_button = host.action("", Rect2(4, 364, 76, 94), func(): host.map_requested.emit(), rail)
		map_button.name = "Map"
		map_button.tooltip_text = "Volver a los caminos" if host.map_open else "Ver mapa"
		for state in ["normal", "hover", "pressed", "focus"]:
			map_button.add_theme_stylebox_override(state, StyleBoxEmpty.new())
		picture(preload("res://assets/map/sidebar/paths.png"), Rect2(6, 4, 64, 64), map_button)
		var map_caption = host.label("Caminos" if host.map_open else "Mapa", Rect2(0, 70, 76, 24), 16, Color("ead3a0"), map_button)
		map_caption.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER

func toggle() -> void:
	close_relic()
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
	var grid = GridContainer.new()
	grid.columns = 5
	grid.add_theme_constant_override("h_separation", 18)
	grid.add_theme_constant_override("v_separation", 14)
	scroll.add_child(grid)
	scroll.get_v_scroll_bar().value_changed.connect(func(_value): close_relic())
	if host.relics.is_empty():
		var empty = Label.new()
		empty.text = "Sin componentes."
		grid.add_child(empty)
	for relic in host.relics:
		var button = Button.new()
		button.name = "Relic%d" % grid.get_child_count()
		button.custom_minimum_size = Vector2(64, 64)
		button.tooltip_text = relic.name
		button.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
		for state in ["normal", "hover", "pressed", "focus"]:
			button.add_theme_stylebox_override(state, StyleBoxEmpty.new())
		grid.add_child(button)
		if relic.get("icon", -1) >= 0 or relic.has("icon_path"):
			var texture = preload("res://src/presentation/relic_art.gd").texture(relic)
			picture(texture, Rect2(0, 0, 64, 64), button)
		else:
			# Older found relics have no artwork in the catalog: keep them visible.
			var caption = host.label(relic.name, Rect2(0, 0, 64, 64), 13, Color("ead3a0"), button)
			caption.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
			caption.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		button.pressed.connect(func(): show_relic(relic, button))

func show_relic(relic: Dictionary, button: Button) -> void:
	var same = selected_relic == button
	close_relic()
	if same: return
	selected_relic = button
	var anchor = Rect2(button.global_position - global_position, button.size)
	popover = preload("res://src/ui/components/relic_popover.gd").new()
	popover.setup(relic, anchor)
	add_child(popover)
	popover.reset_size()
	popover.position = Vector2(clampf(anchor.position.x, 16, size.x - popover.size.x - 16), anchor.position.y - popover.size.y - 10)
	# Point down toward the selected icon; keep the detail inside the drawer.
	var tip = anchor.get_center().x - popover.position.x
	for child in popover.get_children():
		if child is Polygon2D:
			child.polygon = PackedVector2Array([Vector2(tip - 10, popover.size.y), Vector2(tip, popover.size.y + 9), Vector2(tip + 10, popover.size.y)])

func close_relic() -> void:
	if is_instance_valid(popover):
		remove_child(popover)
		popover.queue_free()
	popover = null
	selected_relic = null

func _input(event: InputEvent) -> void:
	if not is_instance_valid(popover): return
	if event is InputEventMouseButton and event.pressed:
		var point = get_canvas_transform().affine_inverse() * event.position
		if not popover.get_global_rect().has_point(point) and not selected_relic.get_global_rect().has_point(point):
			close_relic()
	elif event.is_action_pressed("ui_cancel"):
		close_relic()
		get_viewport().set_input_as_handled()
