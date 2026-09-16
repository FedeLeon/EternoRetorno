extends Control
# Receives a presentation snapshot. Navigation and saves belong to the controller.
signal room_requested(id: int)
signal deck_requested
signal menu_requested
signal descend_requested

const Dungeon = preload("res://src/dungeon.gd")
const HealthBar = preload("res://src/ui/components/health_bar.gd")
const GOLD = Color("d8b779")
const ICONS = {"combat": 0, "event": 1, "treasure": 2, "elite": 3, "rest": 4, "boss": 5}
var nodes: Array = []
var available: Array = []
var visited: Array = []
var current = -1
var heroes: Array = []
var relics: Array = []
var boss_defeated = false
var deck_count = 0
var run_seed = 0
var souls = 0

func place(node: Control, area: Rect2, parent: Node = self) -> void:
	node.position = area.position
	node.size = area.size
	parent.add_child(node)

func label(text: String, area: Rect2, font_size: int = 20, color: Color = Color("e6ddd0"), parent: Node = self) -> Label:
	var node = Label.new()
	node.text = text
	node.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	node.add_theme_font_size_override("font_size", font_size)
	node.add_theme_color_override("font_color", color)
	node.mouse_filter = Control.MOUSE_FILTER_IGNORE
	place(node, area, parent)
	return node

func picture(texture: Texture2D, area: Rect2, parent: Node = self) -> TextureRect:
	var node = TextureRect.new()
	node.texture = texture
	node.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	node.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	node.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	node.mouse_filter = Control.MOUSE_FILTER_IGNORE
	place(node, area, parent)
	return node

func action(text: String, area: Rect2, callback: Callable) -> Button:
	var node = Button.new()
	node.text = text
	node.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	node.pressed.connect(callback)
	place(node, area)
	return node

func _ready() -> void:
	# Fit the painted divider to the route/sidebar boundary without shifting controls.
	var source = load("res://assets/map/background.png")
	var split = round(source.get_width() * 0.69)
	for part in [Rect2(0, 0, split, source.get_height()), Rect2(split, 0, source.get_width() - split, source.get_height())]:
		var texture = AtlasTexture.new()
		texture.atlas = source
		texture.region = part
		var area = Rect2(0, 0, 770, 720) if part.position.x == 0 else Rect2(770, 0, 510, 720)
		var background = picture(texture, area)
		background.stretch_mode = TextureRect.STRETCH_SCALE
	label("La cripta de los ecos", Rect2(54, 30, 700, 48), 30, GOLD)
	action("Menú", Rect2(1130, 26, 108, 48), func(): menu_requested.emit()).name = "Menu"
	draw_route()
	label("Almas: %d" % souls, Rect2(810, 32, 300, 40), 24, GOLD)
	label("EL GRUPO", Rect2(798, 91, 420, 30), 18, GOLD)
	for i in range(heroes.size()):
		show_hero(heroes[i], i)
	label("RELIQUIAS", Rect2(798, 437, 320, 28), 18, GOLD)
	show_relics()
	var deck = action("", Rect2(800, 641, 64, 58), func(): deck_requested.emit())
	deck.name = "Deck"
	deck.tooltip_text = "Ver mazo · %d cartas" % deck_count
	for state in ["normal", "hover", "pressed", "focus"]:
		deck.add_theme_stylebox_override(state, StyleBoxEmpty.new())
	picture(preload("res://assets/ui/deck.svg"), Rect2(0, 0, 64, 58), deck)
	label("%d cartas" % deck_count, Rect2(882, 657, 160, 30), 18)
	label("Salas recorridas: %d" % visited.size(), Rect2(54, 671, 560, 25), 15, Color("b6afa3"))
	tooltip_text = "Semilla: %s" % run_seed
	if boss_defeated:
		action("Bajar por la escalera →", Rect2(217, 596, 358, 54), func(): descend_requested.emit()).name = "Descend"

func draw_route() -> void:
	var offset = Vector2(66, 145)
	for node in nodes:
		for next in node.next:
			var line = Line2D.new()
			line.width = 4
			line.default_color = GOLD if next in available and node.id == current else Color("535462")
			line.add_point(Dungeon.POSITIONS[node.id] + offset)
			line.add_point(Dungeon.POSITIONS[next] + offset)
			add_child(line)
	for node in nodes:
		var center = Dungeon.POSITIONS[node.id] + offset
		var reachable = node.id in available
		var done = node.id in visited
		var target = action("", Rect2(center - Vector2(38, 38), Vector2(76, 76)), func(): room_requested.emit(node.id))
		target.name = "Room%d" % node.id
		target.disabled = not reachable
		target.tooltip_text = Dungeon.LABELS[node.kind] + (" · disponible" if reachable else (" · visitada" if done else " · sin acceso"))
		for state in ["normal", "disabled", "hover", "pressed", "focus"]:
			var style = StyleBoxFlat.new()
			style.bg_color = Color(0.06, 0.07, 0.1, 0.45)
			style.set_corner_radius_all(38)
			style.set_border_width_all(2 if reachable or node.id == current else 0)
			style.border_color = GOLD if reachable else Color("8dcbb7")
			if state in ["hover", "focus"]:
				style.bg_color = Color(0.45, 0.32, 0.12, 0.5)
			target.add_theme_stylebox_override(state, style)
		var texture = AtlasTexture.new()
		texture.atlas = load("res://assets/map/nodes.png")
		var index = ICONS[node.kind]
		var cell = texture.atlas.get_size() / Vector2(3, 2)
		texture.region = Rect2(Vector2(index % 3, index / 3) * cell, cell)
		var icon = picture(texture, Rect2(0, 0, 76, 76), target)
		icon.modulate = Color.WHITE if reachable or node.id == current else (Color("9db9ad") if done else Color("777789"))
		var caption = label("%02d · %s" % [node.id + 1, Dungeon.LABELS[node.kind]], Rect2(center + Vector2(-66, 39), Vector2(132, 25)), 14, GOLD if reachable else Color("b1a99d"))
		caption.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		if node.id == current:
			label("▼", Rect2(center + Vector2(-12, -62), Vector2(24, 24)), 20, GOLD)

func show_hero(hero: Dictionary, index: int) -> void:
	var top = 124 + index * 152
	var actor = hero.visual.new()
	actor.name = "Hero%d" % index
	place(actor, Rect2(788, top, 152, 128))
	actor.set_fallen(hero.hp <= 0)
	label(hero.title, Rect2(955, top + 25, 274, 40), 24)
	var health = HealthBar.new()
	health.name = "Health%d" % index
	health.set_health(hero.hp, hero.max_hp)
	place(health, Rect2(955, top + 77, 270, 28))

func show_relics() -> void:
	var scroll = ScrollContainer.new()
	scroll.name = "Relics"
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	place(scroll, Rect2(796, 473, 434, 161))
	var column = VBoxContainer.new()
	column.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.add_child(column)
	if relics.is_empty():
		var empty = Label.new()
		empty.text = "Sin reliquias."
		column.add_child(empty)
	for relic in relics:
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
