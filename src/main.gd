extends Control

const Game = preload("res://src/game.gd")
const Art = preload("res://src/pixel_art.gd")
const EnemySprite = preload("res://src/enemy_sprite.gd")
const Warrior = preload("res://src/warrior_sprite.gd")
const Guardian = preload("res://src/guardian_sprite.gd")
const Rogue = preload("res://src/rogue_sprite.gd")
const Mage = preload("res://src/mage_sprite.gd")
const Cleric = preload("res://src/cleric_sprite.gd")
const Ranger = preload("res://src/ranger_sprite.gd")
const ANIMATED_HEROES = {"warrior": Warrior, "guardian": Guardian, "rogue": Rogue, "mage": Mage, "cleric": Cleric, "ranger": Ranger}
const Campfire = preload("res://src/campfire.gd")
const CAMP_FRONT = preload("res://assets/camp/front-64.png")
const CAMP_POSITIONS = [Vector2(450, 375), Vector2(830, 375), Vector2(245, 485), Vector2(1035, 485), Vector2(430, 585), Vector2(850, 585)]
const Dungeon = preload("res://src/dungeon.gd")
const GOLD = Color("d8b779")
const INK = Color("10141f")
const TEXT = Color("ebe2d0")
const MUTED = Color("9299ab")
var game = Game.new()
var equipped: Dictionary = {}
var equipment_hero = 0
var selected_item = ""
var screen = "home"
var selected_party: Array = []
var selected_card = -1
var hand_scroll = 0
var layer: Control
var overlay: Control
var upgrade_mode = false
var return_screen = "home"
var combat_busy = false
var hero_art: Dictionary = {}
var enemy_art: Dictionary = {}

func _ready() -> void:
	get_tree().auto_accept_quit = false
	var ui_theme = Theme.new()
	ui_theme.default_font_size = 20
	ui_theme.set_color("font_color", "Label", TEXT)
	ui_theme.set_color("font_color", "Button", TEXT)
	ui_theme.set_color("font_disabled_color", "Button", Color("666b79"))
	ui_theme.set_color("font_hover_color", "Button", Color("fff0c4"))
	ui_theme.set_stylebox("normal", "Button", box(Color("202532"), Color("495062")))
	ui_theme.set_stylebox("hover", "Button", box(Color("303544"), GOLD))
	ui_theme.set_stylebox("pressed", "Button", box(Color("393748"), GOLD))
	ui_theme.set_stylebox("focus", "Button", box(Color(0, 0, 0, 0), GOLD, 2))
	ui_theme.set_stylebox("disabled", "Button", box(Color("151a25"), Color("2c3240")))
	theme = ui_theme
	apply_options()
	render()

func box(fill: Color, border: Color = Color("343b4d"), width: int = 1) -> StyleBoxFlat:
	var style = StyleBoxFlat.new()
	style.bg_color = fill
	style.border_color = border
	style.set_border_width_all(width)
	style.content_margin_left = 12
	style.content_margin_right = 12
	style.content_margin_top = 8
	style.content_margin_bottom = 8
	return style

func rect(node: Control, x: float, y: float, w: float, h: float, parent: Control = null) -> Control:
	node.position = Vector2(x, y)
	node.size = Vector2(w, h)
	(parent if parent != null else layer).add_child(node)
	return node

func label_at(text: String, x: float, y: float, w: float, h: float, font_size: int = 20, color: Color = TEXT, parent: Control = null) -> Label:
	var label = Label.new()
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", color)
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	rect(label, x, y, w, h, parent)
	label.text = text
	return label

func button(text: String, x: float, y: float, w: float, h: float, callback: Callable, enabled: bool = true, parent: Control = null) -> Button:
	var b = Button.new()
	b.text = text
	b.disabled = not enabled
	b.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	b.pressed.connect(func():
		if not combat_busy:
			callback.call())
	rect(b, x, y, w, h, parent)
	return b

func panel(x: float, y: float, w: float, h: float, border: Color = Color("343b4d"), parent: Control = null) -> Panel:
	var p = Panel.new()
	p.add_theme_stylebox_override("panel", box(Color("141a27"), border))
	p.mouse_filter = Control.MOUSE_FILTER_IGNORE
	rect(p, x, y, w, h, parent)
	return p

func art(kind: String, color: Color, x: float, y: float, w: float, h: float, parent: Control = null) -> Control:
	if kind in ANIMATED_HEROES:
		var visual = ANIMATED_HEROES[kind].new()
		rect(visual, x - w * 0.18, y, w * 1.36, h, parent)
		return visual
	var a = Art.new()
	a.kind = kind
	a.tint = color
	rect(a, x, y, w, h, parent)
	return a

func background() -> void:
	if screen == "combat":
		var room = TextureRect.new()
		room.texture = load("res://assets/dungeon/combat.png")
		room.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		room.mouse_filter = Control.MOUSE_FILTER_IGNORE
		rect(room, 0, 64, 1280, 656)
		return
	if screen in ["home", "options"]:
		var title = TextureRect.new()
		title.texture = preload("res://assets/title/background.png")
		title.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		title.mouse_filter = Control.MOUSE_FILTER_IGNORE
		rect(title, 0, 0, 1280, 720)
		return
	if screen == "base_camp":
		var camp = TextureRect.new()
		camp.texture = preload("res://assets/base_camp/background.png")
		camp.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		camp.mouse_filter = Control.MOUSE_FILTER_IGNORE
		rect(camp, 0, 0, 1280, 720)
		return
	if screen == "select":
		var camp = TextureRect.new()
		camp.texture = preload("res://assets/camp/background.png")
		camp.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		camp.mouse_filter = Control.MOUSE_FILTER_IGNORE
		rect(camp, 0, 0, 1280, 720)
		return
	var bg = Art.new()
	bg.scene_art = true
	rect(bg, 0, 0, 1280, 720)
	var shade = ColorRect.new()
	shade.color = Color(0.025, 0.035, 0.06, 0.44)
	shade.mouse_filter = Control.MOUSE_FILTER_IGNORE
	rect(shade, 0, 0, 1280, 720)

func render() -> void:
	hero_art.clear()
	enemy_art.clear()
	if is_instance_valid(layer):
		remove_child(layer)
		layer.queue_free()
	layer = Control.new()
	add_child(layer)
	layer.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	background()
	match screen:
		"home": home()
		"options": options_view()
		"base_camp": base_camp_view()
		"select": selection()
		"equipment": equipment_view()
		"items": items_view()
		"collection": collection()
		"deck": deck_view()
		"map": map_view()
		"combat": combat_view()
		"room": room_view()
		"reward": reward_view()
		"victory", "defeat": result_view()
	if game.message != "":
		label_at(game.message, 36, 682, 960, 32, 17, Color("f3a58d"))
	layer.modulate.a = 0.65
	create_tween().tween_property(layer, "modulate:a", 1.0, 0.12)

func header(title: String, subtitle: String = "") -> void:
	label_at("ETERNO RETORNO", 36, 14, 600, 26, 18, GOLD)
	label_at(title, 36, 43, 950, 44, 30)
	if subtitle != "":
		label_at(subtitle, 36, 87, 1110, 34, 18, MUTED)
	button("Menú", 1134, 30, 110, 48, pause_menu)

func active_run() -> bool:
	return not game.run.is_empty() and game.run.phase not in ["victory", "defeat"]

func title_button(caption: String, y: float, primary: bool, action: Callable) -> Button:
	var b = button(caption, 440, y, 400, 58, action)
	b.add_theme_font_size_override("font_size", 23)
	for state in ["normal", "hover", "pressed"]:
		var style = StyleBoxTexture.new()
		style.texture = load("res://assets/title/" + ("start.png" if primary else "options.png"))
		style.texture_margin_left = 28
		style.texture_margin_right = 28
		style.texture_margin_top = 12
		style.texture_margin_bottom = 12
		style.modulate_color = Color("c8b6e4") if state == "hover" else (Color("857293") if state == "pressed" else Color.WHITE)
		b.add_theme_stylebox_override(state, style)
	return b

func home() -> void:
	title_button("Continuar aventura" if active_run() else "Iniciar juego", 538, true, continue_run if active_run() else open_base_camp).name = "StartGame"
	title_button("Opciones", 606, false, func(): screen = "options"; render()).name = "Options"
	button("Colección", 62, 620, 170, 48, open_collection)
	if active_run():
		button("Campamento", 1048, 620, 170, 48, open_base_camp)

func apply_options() -> void:
	var settings: Dictionary = game.profile.get("settings", {})
	var volume = float(settings.get("volume", 1.0))
	AudioServer.set_bus_volume_db(0, linear_to_db(maxf(0.0001, volume)))
	AudioServer.set_bus_mute(0, volume == 0)
	if not OS.has_feature("mobile") and DisplayServer.get_name() != "headless":
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN if settings.get("fullscreen", false) else DisplayServer.WINDOW_MODE_WINDOWED)

func set_option(key: String, value: Variant) -> void:
	if not game.profile.has("settings"):
		game.profile.settings = {}
	game.profile.settings[key] = value
	apply_options()
	game.checkpoint()

func options_view() -> void:
	var shade = ColorRect.new()
	shade.color = Color(0, 0, 0, 0.75)
	shade.mouse_filter = Control.MOUSE_FILTER_IGNORE
	rect(shade, 0, 0, 1280, 720)
	panel(350, 190, 580, 350, Color("8a799b"))
	label_at("Opciones", 390, 211, 500, 46, 32).horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label_at("Volumen general", 390, 281, 280, 38)
	var volume = HSlider.new()
	volume.name = "Volume"
	volume.min_value = 0
	volume.max_value = 100
	volume.step = 1
	volume.value = float(game.profile.get("settings", {}).get("volume", 1.0)) * 100
	rect(volume, 390, 328, 500, 40)
	volume.value_changed.connect(func(value): set_option("volume", value / 100.0))
	var fullscreen = CheckButton.new()
	fullscreen.name = "Fullscreen"
	fullscreen.text = "Pantalla completa"
	fullscreen.button_pressed = game.profile.get("settings", {}).get("fullscreen", false)
	fullscreen.disabled = OS.has_feature("mobile")
	rect(fullscreen, 390, 386, 500, 48)
	fullscreen.toggled.connect(func(value): set_option("fullscreen", value))
	if OS.has_feature("mobile"):
		label_at("Android utiliza pantalla completa.", 390, 437, 500, 26, 16, MUTED)
	title_button("Volver", 470, false, func(): screen = "home"; render())

func open_base_camp() -> void:
	screen = "base_camp"
	game.message = ""
	render()

func camp_hotspot(id: String, area: Rect2, caption: String, action: Callable) -> void:
	var b = button("", area.position.x, area.position.y, area.size.x, area.size.y + 34, action)
	b.name = id
	b.tooltip_text = caption
	b.add_theme_stylebox_override("normal", box(Color(0, 0, 0, 0), Color(0, 0, 0, 0)))
	for state in ["hover", "pressed", "focus"]:
		b.add_theme_stylebox_override(state, box(Color(0.9, 0.75, 0.35, 0.12), GOLD, 2))
	var plaque = panel(area.position.x + (area.size.x - 208) / 2, area.end.y, 208, 34)
	var title = label_at(caption, 5, 0, 198, 34, 16, GOLD, plaque)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER

func base_camp_view() -> void:
	panel(24, 20, 570, 92)
	label_at("ETERNO RETORNO · EL CAMPAMENTO", 42, 28, 530, 26, 17, GOLD)
	label_at("Un lugar al que volver", 42, 56, 530, 40, 28, TEXT)
	button("Menú", 1134, 30, 110, 48, func(): screen = "home"; render())
	camp_hotspot("CampExit", Rect2(960, 115, 155, 135), "Preparar aventura →", func():
		if active_run():
			confirm_new()
		else:
			open_selection())
	var plots = [Rect2(110, 279, 276, 47), Rect2(836, 299, 256, 40), Rect2(75, 414, 319, 59), Rect2(933, 476, 284, 56)]
	for i in range(plots.size()):
		camp_hotspot("Plot%d" % i, plots[i], "Solar %d · Sin construir" % (i + 1), func():
			show_modal("Solar disponible", "Aquí podrás construir un edificio para tu campamento.\nLas construcciones y sus ventajas todavía no están disponibles.", "Entendido", close_modal))
	camp_hotspot("CampTent", Rect2(427, 240, 180, 107), "Refugio de personajes", func():
		show_modal("Refugio de personajes", "Este será el lugar para mejorar a tus personajes entre aventuras.\nLas mejoras todavía no están disponibles.", "Entendido", close_modal))
	panel(24, 647, 1232, 65)
	label_at("Tocá el arco de piedra para preparar una nueva aventura.", 42, 657, 775, 42, 20, TEXT)
	if active_run():
		button("Continuar aventura →", 916, 657, 320, 44, continue_run)
	else:
		label_at("%d aventuras · %d victorias" % [game.profile.attempts, game.profile.victories], 926, 657, 308, 42, 17, GOLD)

func open_selection() -> void:
	var draft = game.profile.get("preparation", {})
	selected_party = draft.get("party", []).duplicate()
	equipped = draft.get("relics", {}).duplicate()
	if selected_party.size() != 2 or not game.valid_equipment(selected_party, equipped):
		selected_party = []
		equipped = {}
	screen = "select"
	render()

func confirm_new() -> void:
	show_modal("Empezar otro retorno", "La aventura actual terminará. Tus desbloqueos se conservan.", "Empezar de nuevo", func():
		close_modal()
		open_selection())

func selection() -> void:
	panel(24, 18, 1016, 100)
	label_at("ETERNO RETORNO · EL FUEGO NOS REÚNE", 42, 27, 960, 25, 17, GOLD)
	label_at("Elegí dos almas", 42, 54, 900, 35, 28, TEXT)
	label_at("Tocá a los personajes para formar tu pareja de aventura.", 42, 90, 960, 24, 17, MUTED)
	button("Menú", 1134, 30, 110, 48, func(): screen = "home"; render())
	var fire = Campfire.new()
	fire.name = "Campfire"
	rect(fire, 640, 471, 1, 1)
	var ids = game.content.heroes.keys()
	for i in range(ids.size()):
		var id = ids[i]
		var h = game.content.heroes[id]
		var pos = CAMP_POSITIONS[i]
		var chosen = id in selected_party
		var b = button("", pos.x - 90, pos.y - 140, 180, 198, func(): toggle_hero(id))
		b.name = "CampHero_" + id
		b.tooltip_text = h.name + " · " + h.role + "\n" + h.lore
		for state in ["normal", "hover", "pressed", "focus"]:
			b.add_theme_stylebox_override(state, box(Color(0.1, 0.08, 0.04, 0.22) if chosen else Color(0, 0, 0, 0), GOLD if chosen or state == "focus" else Color(0, 0, 0, 0), 2))
		var sprite = TextureRect.new()
		var texture = AtlasTexture.new()
		texture.atlas = CAMP_FRONT
		texture.region = Rect2(i * 64, 0, 64, 64)
		sprite.texture = texture
		sprite.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		sprite.mouse_filter = Control.MOUSE_FILTER_IGNORE
		rect(sprite, -6, -40, 192, 192, b)
		panel(0, 141, 180, 57, Color("343b4d"), b)
		var name_label = label_at(("✓ " if chosen else "") + h.name, 4, 143, 172, 27, 21, GOLD if chosen else TEXT, b)
		name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		var detail = label_at("%s · %d PV" % [h.role, h.hp], 2, 172, 176, 22, 14, Color(h.color), b)
		detail.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	panel(24, 653, 1232, 59)
	button("Campamento", 36, 659, 145, 46, open_base_camp)
	label_at("%d / 2 elegidos" % selected_party.size(), 185, 669, 210, 30, 20, GOLD)
	var names: Array[String] = []
	for id in selected_party:
		names.append(game.content.heroes[id].name)
	label_at(" + ".join(names), 405, 669, 440, 30, 20, TEXT)
	button("Preparar reliquias  →", 894, 659, 350, 46, open_equipment, selected_party.size() == 2)

func toggle_hero(id: String) -> void:
	if id in selected_party:
		selected_party.erase(id)
		equipped.erase(id)
	elif selected_party.size() < 2:
		selected_party.append(id)
	save_preparation()
	render()

func begin() -> void:
	if not game.valid_equipment(selected_party, equipped) or (screen == "equipment" and equipped.size() != 2):
		return
	# Abandon only after a valid replacement party has been chosen.
	if active_run():
		game._finish(false)
	if game.new_run(selected_party, -1, equipped):
		continue_run()

func continue_run() -> void:
	screen = game.run.phase
	selected_card = -1
	upgrade_mode = false
	render()

func act(callback: Callable) -> void:
	callback.call()
	continue_run()

func map_view() -> void:
	header("La cripta de los ecos", "PISO I   ·   Seguí las conexiones iluminadas hasta la escalera central.")
	panel(36, 140, 720, 524)
	var offset = Vector2(66, 151)
	var available = game.available_nodes()
	for node in game.run.nodes:
		for next in node.next:
			var line = Line2D.new()
			line.width = 3
			line.default_color = GOLD.darkened(0.3) if next in available and node.id == game.run.current else Color("353c4d")
			line.add_point(Dungeon.POSITIONS[node.id] + offset)
			line.add_point(Dungeon.POSITIONS[next] + offset)
			layer.add_child(line)
	for node in game.run.nodes:
		var pos = Dungeon.POSITIONS[node.id] + offset
		var reachable = node.id in available
		var visited = node.id in game.run.visited
		var symbol = {"combat": "×", "event": "?", "treasure": "◇", "elite": "!", "rest": "+", "boss": "Ω"}[node.kind]
		var b = button(symbol, pos.x - 27, pos.y - 27, 54, 54, func(): act(func(): game.enter_node(node.id)), reachable)
		b.add_theme_font_size_override("font_size", 27)
		var border = GOLD if reachable else (Color("6c978d") if visited else Color("3b4354"))
		b.add_theme_stylebox_override("disabled" if not reachable else "normal", box(Color("252c3a") if visited or reachable else INK, border, 2))
		b.add_theme_color_override("font_disabled_color", Color("8ba49e") if visited else MUTED)
		var l = label_at("%02d · %s" % [node.id + 1, Dungeon.LABELS[node.kind]], pos.x - 62, pos.y + 28, 124, 26, 14, GOLD if reachable else MUTED)
		l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label_at("EL GRUPO", 792, 140, 440, 30, 18, GOLD)
	for i in range(2):
		map_hero(i, 792, 184 + i * 102)
	label_at("RELIQUIAS", 792, 400, 420, 28, 17, GOLD)
	var relic_text = "Todavía no encontraste reliquias."
	if not game.run.relics.is_empty():
		relic_text = "\n".join(game.run.relics.map(func(id): return game.content.relics[id].name + " · " + game.content.relics[id].description))
	label_at(relic_text, 792, 435, 442, 128, 17, MUTED)
	button("Ver mazo · %d cartas" % game.run.deck.size(), 792, 587, 440, 54, open_deck)
	if game.run.boss_defeated:
		button("Bajar por la escalera  →", 217, 582, 358, 60, func(): act(game.descend))
	label_at("Salas recorridas: %d  /  Semilla: %s" % [game.run.visited.size(), str(game.run.seed)], 36, 676, 1030, 25, 15, MUTED)

func map_hero(i: int, x: float, y: float) -> void:
	var h = game.run.heroes[i]
	var def = game.content.heroes[h.id]
	panel(x, y, 440, 94)
	art(h.id, Color(def.color), x + 8, y + 5, 68, 80)
	label_at(def.name, x + 90, y + 6, 320, 32, 23)
	health_bar(h, x + 90, y + 50, 326)

func health_bar(unit: Dictionary, x: float, y: float, width: float, parent: Control = null) -> void:
	var back = ColorRect.new()
	back.color = Color("35252f")
	back.mouse_filter = Control.MOUSE_FILTER_IGNORE
	rect(back, x, y, width, 25, parent)
	var fill = ColorRect.new()
	fill.color = Color("98605f") if unit.hp > 0 else Color("35252f")
	fill.mouse_filter = Control.MOUSE_FILTER_IGNORE
	rect(fill, x, y, width * float(unit.hp) / unit.max_hp, 25, parent)
	var text = "%d / %d" % [unit.hp, unit.max_hp]
	if unit.hp <= 0:
		text = "CAÍDO"
	var l = label_at(text, x, y, width, 25, 17, TEXT, parent)
	l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER

func combat_target_style(target: Button, valid: bool) -> void:
	for state in ["normal", "disabled", "hover", "pressed", "focus"]:
		target.add_theme_stylebox_override(state, StyleBoxEmpty.new())
	if valid:
		var marker = label_at("▼", 70, -4, 70, 30, 24, GOLD, target)
		marker.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER

func combat_view() -> void:
	var b = game.run.combat
	var node = game.run.nodes[game.run.current]
	panel(0, 0, 1280, 64)
	label_at("Sala %02d" % (node.id + 1), 24, 12, 180, 40, 20, GOLD)
	button("Ver mazo", 690, 8, 150, 48, open_deck)
	var bag = button("     Bolsa", 850, 8, 150, 48, func(): selected_item = ""; screen = "items"; render())
	var icon = TextureRect.new()
	icon.texture = load("res://assets/dungeon/bag.png")
	icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
	rect(icon, 8, 4, 40, 40, bag)
	button("Menú", 1010, 8, 110, 48, pause_menu)
	label_at("TURNO %d" % b.turn, 1134, 12, 140, 40, 19, GOLD)
	var targets: Array = []
	var c: Dictionary = {}
	if selected_card >= 0 and selected_card < b.hand.size():
		c = game.content.card(b.hand[selected_card])
		targets = game.valid_targets(selected_card)
	for i in range(2):
		var h = game.run.heroes[i]
		var def = game.content.heroes[h.id]
		var x = 80 + i * 234
		var valid = not c.is_empty() and c.target != "enemy" and i in targets
		var target = button("", x, 280, 204, 218, func(): target_clicked(i), valid)
		combat_target_style(target, valid)
		var visual = art(h.id, Color(def.color) if h.hp > 0 else Color("4f505d"), 30 if h.id in ANIMATED_HEROES else 48, -7 if h.id in ANIMATED_HEROES else 5, 144 if h.id in ANIMATED_HEROES else 108, 136 if h.id in ANIMATED_HEROES else 132, target)
		hero_art[i] = visual
		if h.id in ANIMATED_HEROES:
			visual.set_fallen(h.hp <= 0)
		label_at(def.name, 10, 139, 184, 29, 22, TEXT, target).horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		health_bar(h, 16, 173, 172, target)
		label_at("Bloqueo %d" % h.block if h.hp > 0 else "Vuelve si ganás", 10, 199, 184, 24, 16, Color("9cbacb"), target).horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	for i in range(2):
		var h = game.run.heroes[i]
		var relic_id = h.get("equipped_relic", "")
		if game.content.equipment.has(relic_id):
			var relic = game.content.equipment[relic_id]
			var relic_button = button("", 80 + i * 234, 245, 32, 32, func(): show_modal(relic.name, relic.description + ("\nFénix ya utilizado." if h.get("phoenix_used", false) else ""), "Cerrar", close_modal))
			object_icon(relic.icon, 0, 0, 32, relic_button)
	for i in range(b.enemies.size()):
		var e = b.enemies[i]
		var def = game.content.enemies[e.id]
		var x = 768 + i * 234 if b.enemies.size() > 1 else 884
		var valid = not c.is_empty() and c.target == "enemy" and i in targets
		var target = button("", x, 280, 214, 218, func(): target_clicked(i), valid)
		combat_target_style(target, valid)
		var enemy_visual = EnemySprite.new()
		enemy_visual.visual_id = def.visual
		enemy_visual.fallen = e.hp <= 0
		rect(enemy_visual, 43, 0, 128, 132, target)
		enemy_art[i] = enemy_visual
		label_at(def.name, 7, 135, 200, 36, 18, TEXT, target).horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		health_bar(e, 16, 173, 182, target)
		label_at("Bloq. %d  ·  Veneno %d" % [e.block, e.poison], 9, 199, 196, 24, 15, Color("b9b5a1"), target).horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		var intent_text = "Derrotado"
		if e.hp > 0:
			var dest = "ambos" if e.intent.get("all", false) else game.content.heroes[game.run.party[e.intent.target]].name
			intent_text = "Ataca %d → %s%s" % [e.intent.damage, dest, "  · +%d bloq." % e.intent.block if e.intent.get("block", 0) > 0 else ""]
		label_at(intent_text, x - 12, 240, 240, 34, 15, Color("e59a87")).horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	panel(16, 582, 142, 112, GOLD)
	label_at("ENERGÍA", 24, 593, 126, 30, 18, GOLD).horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label_at("%d / %d" % [b.energy, game.turn_energy()], 24, 630, 126, 48, 32, GOLD).horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label_at("Mazo %d · Descarte %d · Inactivas %d" % [b.draw.size(), b.discard.size(), b.inactive.size()], 24, 76, 500, 28, 16, MUTED)
	var count = b.hand.size()
	var scroll = ScrollContainer.new()
	scroll.name = "CombatHand"
	rect(scroll, 170, 406, 1086, 314)
	scroll.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_AUTO
	var contents = Control.new()
	contents.custom_minimum_size = Vector2(maxi(1086, count * 178 - 4), 300)
	scroll.add_child(contents)
	scroll.set_deferred("scroll_horizontal", hand_scroll)
	var start = maxf(0, (1086 - (count * 178 - 4)) / 2.0)
	for i in range(count):
		var card = card_panel(b.hand[i], minf(start + i * 178, contents.custom_minimum_size.x - 218) if i == selected_card else start + i * 178, 8 if i == selected_card else 164, 218 if i == selected_card else 174, 290, func(): select_card(i), i == selected_card, not game.valid_targets(i).is_empty(), contents)
		if i == selected_card:
			card.z_index = 10
	if count == 0:
		label_at("Terminá el turno para robar cartas.", 380, 590, 640, 70, 24, MUTED)
	button("Terminar turno →", 1038, 508, 218, 48, func(): animate_combat_action())

func card_panel(instance: Dictionary, x: float, y: float, w: float, h: float, callback: Callable, chosen: bool = false, enabled: bool = true, parent: Control = null) -> Button:
	var c = game.content.card(instance)
	var def = game.content.heroes[c.owner]
	var colors = {"warrior": Color("98483f"), "guardian": Color("438b89"), "rogue": Color("72864a"), "mage": Color("8f65b4"), "cleric": Color("c09a55"), "ranger": Color("507ba6")}
	var accent: Color = colors[c.owner]
	var b = button("", x, y, w, h, callback, enabled, parent)
	b.set_meta("card_id", instance.id)
	b.tooltip_text = c.name + " · " + def.name + "\n" + game.content.describe(instance, game.effective_card(instance))
	for state in ["normal", "disabled", "hover", "pressed", "focus"]:
		b.add_theme_stylebox_override(state, box(Color("101117"), GOLD if chosen or state == "focus" else accent, 3 if chosen else 1))
	var frame = NinePatchRect.new()
	frame.texture = load("res://assets/cards/" + c.owner + ".png")
	frame.patch_margin_left = 9
	frame.patch_margin_right = 9
	frame.patch_margin_top = 9
	frame.patch_margin_bottom = 9
	frame.mouse_filter = Control.MOUSE_FILTER_IGNORE
	frame.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	rect(frame, 3, 3, w - 6, h - 6, b)
	if not enabled:
		frame.modulate = Color(0.65, 0.65, 0.65)
	var banner = panel(11, 12, w - 62, 42, accent, b)
	banner.add_theme_stylebox_override("panel", box(Color("b9aa8c"), Color("564a39"), 2))
	var title = label_at(c.name, 16, 12, w - 72, 42, 14 if w < 190 else 16, Color("211b19"), b)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	var medallion = panel(w - 45, 10, 35, 35, accent, b)
	var round_style = box(accent.darkened(0.55), GOLD if chosen else accent.lightened(0.25), 3)
	round_style.set_corner_radius_all(18)
	medallion.add_theme_stylebox_override("panel", round_style)
	label_at(str(int(c.cost)), w - 45, 10, 35, 35, 23, Color("fff0cf"), b).horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label_at(def.name.to_upper(), 12, 53, w - 24, 19, 12, accent.lightened(0.6), b).horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	var picture_area = panel(18, 80, w - 36, maxf(22, h - 186), accent, b)
	picture_area.name = "IllustrationSpace"
	picture_area.add_theme_stylebox_override("panel", box(Color("14151c"), accent.darkened(0.3), 1))
	var parchment = panel(18, h - 92, w - 36, 74, accent, b)
	parchment.add_theme_stylebox_override("panel", box(Color("b9aa8c") if enabled else Color("8b8375"), Color("564a39"), 2))
	var description = label_at(game.content.describe(instance, game.effective_card(instance)), 24, h - 87, w - 48, 64, 12 if w < 190 else 14, Color("211b19"), b)
	description.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	return b

func select_card(index: int) -> void:
	var hand = layer.get_node_or_null("CombatHand")
	if hand != null:
		hand_scroll = hand.scroll_horizontal
	selected_card = -1 if selected_card == index else index
	render()

func target_clicked(index: int) -> void:
	if selected_card >= 0:
		animate_combat_action(selected_card, index)

func animate_combat_action(hand_index: int = -1, target_index: int = -1) -> void:
	if combat_busy or game.run.phase != "combat":
		return
	var before = game.run.heroes.duplicate(true)
	var old_enemies = game.run.combat.enemies.duplicate(true)
	var owner = -1
	var motion = "attack"
	if hand_index >= 0:
		var instance = game.run.combat.hand[hand_index]
		var card = game.content.card(instance)
		owner = game.owner_index(instance)
		motion = "heavy" if card.cost >= 2 else "attack"
		if card.owner == "mage":
			motion = "heavy" if card.target == "all_enemies" else "attack"
		if instance.id == "guardian_bash":
			motion = "bash"
		if card.damage == 0:
			motion = "guard"
		if card.owner == "cleric":
			motion = "attack" if card.damage > 0 else ("heal" if card.heal > 0 else "guard")
		if instance.id == "rogue_venom":
			motion = "poison"
	# Resolve and persist first. Closing Android during the animation never replays it.
	var accepted = game.play_card(hand_index, target_index) if hand_index >= 0 else game.end_turn()
	if not accepted:
		return
	combat_busy = true
	if owner >= 0 and game.run.party[owner] in ANIMATED_HEROES:
		await hero_art[owner].play_once(motion)
	# The committed result can already be reward/defeat; show the old arena until
	# reactions finish, so a lethal strike and a falling hero remain visible.
	var current_enemies = game.run.combat.get("enemies", [])
	for i in range(old_enemies.size()):
		if i < current_enemies.size() and old_enemies[i].hp > 0:
			if current_enemies[i].hp <= 0:
				await enemy_art[i].play_once("death")
			elif current_enemies[i].hp < old_enemies[i].hp:
				await enemy_art[i].play_once("hurt")
			if hand_index < 0 and current_enemies[i].hp > 0:
				await enemy_art[i].play_once("attack")
	for i in range(before.size()):
		var after = game.run.heroes[i]
		if game.run.party[i] not in ANIMATED_HEROES:
			if after.hp < before[i].hp:
				flash_hit(hero_art[i])
			continue
		if before[i].hp > 0 and after.hp <= 0:
			await hero_art[i].play_once("death")
		elif before[i].hp <= 0 and after.hp > 0:
			await hero_art[i].play_once("revive")
		elif after.hp < before[i].hp:
			await hero_art[i].play_once("hurt")
		elif hand_index < 0 and after.block < before[i].block:
			await hero_art[i].play_once("guard")
	await get_tree().create_timer(0.18).timeout
	combat_busy = false
	continue_run()

func flash_hit(visual: Control) -> void:
	var tween = create_tween()
	tween.tween_property(visual, "modulate", Color(1.7, 0.65, 1.3), 0.06)
	tween.tween_property(visual, "modulate", Color.WHITE, 0.12)

func reward_view() -> void:
	header("Un eco para tu mazo", "Elegí una carta. También podés seguir con un mazo más pequeño.")
	for i in range(game.run.reward.size()):
		var instance = game.run.reward[i]
		var c = game.content.card(instance)
		var x = 250 + i * 268
		art(c.owner, Color(game.content.heroes[c.owner].color), x + 75, 136, 92, 112)
		card_panel(instance, x, 268, 244, 272, func(): act(func(): game.choose_reward(i)))
	button("Saltar recompensa  →", 461, 590, 358, 60, func(): act(func(): game.choose_reward(-1)))
	if not game.run.new_unlocks.is_empty():
		label_at("Nuevo eco: " + ", ".join(game.run.new_unlocks), 80, 656, 1110, 34, 17, GOLD)

func room_view() -> void:
	var node = game.run.nodes[game.run.current]
	header("%s  /  Sala %02d" % [Dungeon.LABELS[node.kind], node.id + 1])
	panel(212, 154, 856, 458, Color("62533e"))
	match node.kind:
		"rest":
			label_at("Una brasa en la oscuridad", 264, 195, 760, 62, 36, GOLD)
			label_at("Por un momento, el tiempo deja de perseguirlos.\nDescansá o templá una carta antes de continuar.", 264, 280, 742, 92, 24)
			button("Recuperar 30 % de vida", 264, 422, 355, 64, func(): act(func(): game.rest(true)))
			button("Mejorar una carta", 645, 422, 355, 64, func(): upgrade_mode = true; return_screen = "room"; screen = "deck"; render())
			label_at("Guerreros vivos: " + "  ·  ".join(game.run.heroes.map(func(h): return "%s %d/%d" % [game.content.heroes[h.id].name, h.hp, h.max_hp])), 264, 520, 730, 43, 18, MUTED)
		"treasure":
			var id = game.run.treasure
			label_at("Lo que el tiempo dejó atrás", 264, 195, 760, 62, 36, GOLD)
			label_at(game.content.relics[id].name if id != "" else "Un cofre vacío", 264, 280, 742, 46, 28)
			label_at(game.content.relics[id].description if id != "" else "Ya poseés todas las reliquias disponibles.", 264, 337, 730, 80, 24, MUTED)
			button("Tomar y continuar  →" if id != "" else "Continuar", 430, 482, 420, 66, func(): act(game.take_treasure))
		"event":
			var event = game.content.events[node.event]
			label_at(event.name, 264, 195, 760, 62, 36, GOLD)
			label_at(event.text, 264, 273, 742, 100, 24)
			var can_offer = true
			if node.event == "altar":
				can_offer = game.run.heroes.all(func(h): return h.hp > 5) and game.run.deck.any(func(c): return not c.upgraded)
			for i in range(2):
				button(event.choices[i], 264, 414 + i * 80, 742, 64, func(): act(func(): game.choose_event(i)), can_offer or i == 1)

func open_deck() -> void:
	return_screen = screen
	upgrade_mode = false
	screen = "deck"
	render()

func scroll_area() -> Control:
	var scroll = ScrollContainer.new()
	rect(scroll, 36, 140, 1208, 485)
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	var contents = Control.new()
	contents.custom_minimum_size = Vector2(1180, 600)
	scroll.add_child(contents)
	return contents

func deck_view() -> void:
	header("Templar una carta" if upgrade_mode else "El mazo compartido", "Elegí una carta sin mejorar. Esta será la acción de descanso." if upgrade_mode else "Cada carta pertenece a uno de tus compañeros.")
	var contents = scroll_area()
	for i in range(game.run.deck.size()):
		var instance = game.run.deck[i]
		var callback = func(): act(func(): game.rest(false, i))
		var b = card_panel(instance, (i % 5) * 238, (i / 5) * 260, 224, 244, callback if upgrade_mode else func(): pass, false, not instance.upgraded if upgrade_mode else true, contents)
		if not upgrade_mode:
			b.mouse_filter = Control.MOUSE_FILTER_IGNORE
	contents.custom_minimum_size.y = ceil(game.run.deck.size() / 5.0) * 260
	button("← Volver", 36, 646, 230, 54, func(): screen = return_screen; upgrade_mode = false; render())

func open_collection() -> void:
	screen = "collection"
	render()

func collection() -> void:
	header("La colección de ecos", "Los desbloqueos amplían las recompensas de próximas aventuras.")
	var contents = scroll_area()
	var index = 0
	for id in game.content.cards:
		var c = game.content.cards[id]
		if not c.locked:
			continue
		var unlocked = id in game.profile.unlocked_cards
		var x = (index % 3) * 394
		var y = (index / 3) * 136
		panel(x, y, 380, 120, GOLD.darkened(0.4) if unlocked else Color("343b4d"), contents)
		label_at(c.name, x + 16, y + 8, 350, 37, 23, GOLD if unlocked else MUTED, contents)
		label_at("DESBLOQUEADO" if unlocked else "Ganá con " + game.content.heroes[c.owner].name, x + 16, y + 51, 350, 47, 18, TEXT, contents)
		index += 1
	panel(0, 286, 1168, 97, Color("343b4d"), contents)
	label_at("Reloj sin arena", 16, 295, 1090, 35, 23, GOLD, contents)
	label_at("DESBLOQUEADO · Primer turno: +1 de energía." if "hourglass" in game.profile.unlocked_relics else "Derrotá al Caballero sin tiempo para desbloquear esta reliquia.", 16, 339, 1090, 33, 18, MUTED, contents)
	label_at("ÚLTIMOS RETORNOS", 0, 408, 1120, 36, 18, GOLD, contents)
	for i in range(game.profile.history.size()):
		var h = game.profile.history[i]
		label_at("%s  ·  %s + %s  ·  %d salas" % ["VICTORIA" if h.won else "DERROTA", game.content.heroes[h.party[0]].name, game.content.heroes[h.party[1]].name, h.rooms], 0, 452 + i * 42, 1168, 38, 20, MUTED, contents)
	contents.custom_minimum_size.y = maxf(500, 460 + game.profile.history.size() * 42)
	button("← Inicio", 36, 646, 230, 54, func(): screen = "home"; render())

func result_view() -> void:
	var won = screen == "victory"
	label_at("EL CICLO CONTINÚA" if won else "EL CICLO RECOMIENZA", 170, 99, 940, 50, 20, GOLD).horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label_at("La escalera espera" if won else "La cripta los recuerda", 100, 166, 1080, 100, 55).horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label_at("Completaste el primer piso de Eterno Retorno.\nEl siguiente descenso llegará en una próxima versión." if won else "Ambos compañeros han caído.\nOtra pareja. Otro mazo. Una nueva oportunidad.", 180, 282, 920, 105, 25, MUTED).horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label_at("%d salas recorridas  ·  %d cartas al final" % [game.run.visited.size(), game.run.summary_cards], 180, 408, 920, 40, 21, TEXT).horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label_at("Ecos desbloqueados: " + ", ".join(game.run.new_unlocks) if not game.run.new_unlocks.is_empty() else "Tus desbloqueos anteriores se conservan.", 170, 470, 940, 65, 22, GOLD).horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	button("Volver al campamento", 322, 581, 310, 64, open_base_camp)
	button("Colección de ecos", 650, 581, 310, 64, open_collection)

func show_modal(title: String, text: String, action_text: String, callback: Callable) -> void:
	close_modal()
	overlay = Control.new()
	add_child(overlay)
	overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var dim = ColorRect.new()
	dim.color = Color(0.02, 0.025, 0.04, 0.9)
	rect(dim, 0, 0, 1280, 720, overlay)
	panel(290, 173, 700, 375, GOLD.darkened(0.4), overlay)
	label_at(title, 330, 203, 620, 60, 34, GOLD, overlay)
	label_at(text, 330, 282, 620, 102, 23, TEXT, overlay)
	button(action_text, 330, 412, 620, 55, callback, true, overlay)
	button("Volver", 330, 478, 620, 48, close_modal, true, overlay)

func close_modal() -> void:
	if is_instance_valid(overlay):
		remove_child(overlay)
		overlay.queue_free()
	overlay = null

func pause_menu() -> void:
	game.checkpoint()
	show_modal("Un respiro", "Tu avance queda guardado automáticamente.\nPodés volver a la aventura desde el inicio.", "Ir al inicio", func(): close_modal(); screen = "home"; render())

func _notification(what: int) -> void:
	if what == NOTIFICATION_APPLICATION_PAUSED:
		game.checkpoint()
	if what == NOTIFICATION_WM_GO_BACK_REQUEST or what == NOTIFICATION_WM_CLOSE_REQUEST:
		back()

func _unhandled_key_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		back()
		get_viewport().set_input_as_handled()

func back() -> void:
	if combat_busy:
		return
	if is_instance_valid(overlay):
		close_modal()
	elif screen == "home":
		show_modal("Cerrar el libro", "Tu progreso está guardado.", "Salir del juego", func(): game.checkpoint(); get_tree().quit())
	elif screen == "items":
		continue_run()
	elif screen == "equipment":
		screen = "select"
		render()
	elif screen == "select":
		open_base_camp()
	elif screen in ["base_camp", "collection", "options"]:
		screen = "home"
		render()
	elif screen == "deck":
		screen = return_screen
		upgrade_mode = false
		render()
	elif screen == "combat" and selected_card >= 0:
		selected_card = -1
		render()
	else:
		pause_menu()

func object_icon(index: int, x: float, y: float, side: float, parent: Control = null) -> void:
	var icon = TextureRect.new()
	var texture = AtlasTexture.new()
	texture.atlas = preload("res://assets/objects/icons.png")
	texture.region = Rect2((index % 4) * 64, (index / 4) * 64, 64, 64)
	icon.texture = texture
	icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	icon.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
	rect(icon, x, y, side, side, parent)

func open_equipment() -> void:
	if selected_party.size() != 2:
		return
	equipment_hero = 0
	screen = "equipment"
	save_preparation()
	render()

func save_preparation() -> void:
	game.profile.preparation = {"party": selected_party.duplicate(), "relics": equipped.duplicate()}
	game.checkpoint()

func equip_relic(id: String) -> void:
	var hero = selected_party[equipment_hero]
	var other = selected_party[1 - equipment_hero]
	if equipped.get(other, "") == id or not game.content.equipment.has(id):
		return
	equipped[hero] = id
	save_preparation()
	render()

func equipment_view() -> void:
	header("Reliquias para el descenso", "Una distinta por héroe. Sus efectos duran esta aventura. Bolsa inicial: una unidad de cada consumible.")
	for i in range(2):
		var hero = selected_party[i]
		var id = equipped.get(hero, "")
		var title = game.content.heroes[hero].name + " · " + (game.content.equipment[id].name if id != "" else "Sin reliquia")
		var tab = button(title, 36 + i * 614, 136, 594, 66, func(): equipment_hero = i; render())
		if equipment_hero == i:
			tab.add_theme_stylebox_override("normal", box(Color("343044"), GOLD, 2))
	var ids = game.content.equipment.keys()
	for i in range(ids.size()):
		var id = ids[i]
		var relic = game.content.equipment[id]
		var other = equipped.get(selected_party[1 - equipment_hero], "") == id
		var chosen = equipped.get(selected_party[equipment_hero], "") == id
		var b = button("", 36 + (i % 4) * 306, 221 + (i / 4) * 191, 290, 178, func(): equip_relic(id), not other)
		b.name = "Equip_" + id
		object_icon(relic.icon, 8, 8, 48, b)
		label_at(relic.name, 62, 8, 220, 48, 19, GOLD if chosen else TEXT, b)
		label_at(relic.description, 12, 61, 266, 88, 16, TEXT, b)
		label_at("Equipado" if chosen else ("Lo lleva tu compañero" if other else "Tocar para equipar"), 12, 150, 266, 23, 14, GOLD if chosen else MUTED, b)
	button("← Personajes", 36, 647, 250, 54, func(): screen = "select"; render())
	button("Iniciar aventura →", 904, 647, 340, 54, begin, equipped.size() == 2 and game.valid_equipment(selected_party, equipped))

func items_view() -> void:
	header("Bolsa compartida", "Consumibles: no cuestan energía. Se gastan al usarlos y no se reponen al cambiar de sala.")
	var ids = game.content.items.keys()
	for i in range(ids.size()):
		var id = ids[i]
		var item = game.content.items[id]
		var amount = game.run.get("inventory", {}).get(id, 0)
		var b = button("", 36 + (i % 4) * 306, 139 + (i / 4) * 210, 290, 196, func(): selected_item = id; render(), not game.item_targets(id).is_empty())
		b.name = "Item_" + id
		object_icon(item.icon, 8, 8, 48, b)
		label_at(item.name, 63, 8, 215, 48, 19, GOLD if selected_item == id else TEXT, b)
		label_at(item.description, 12, 62, 266, 100, 17, TEXT if amount > 0 else MUTED, b)
		label_at("Quedan %d%s" % [amount, " · Sin objetivo válido" if amount > 0 and game.item_targets(id).is_empty() else ""], 12, 166, 266, 25, 15, MUTED, b)
	if selected_item != "":
		var item = game.content.items[selected_item]
		label_at("Usar " + item.name + " en:", 36, 565, 1000, 32, 21, GOLD)
		var targets = game.item_targets(selected_item)
		for i in range(targets.size()):
			var target = targets[i]
			var title = "Equipo" if item.target == "team" else (game.content.enemies[game.run.combat.enemies[target].id].name if item.target == "enemy" else game.content.heroes[game.run.heroes[target].id].name)
			button(title, 340 + i * 300, 624, 280, 62, func():
				if game.use_item(selected_item, target):
					selected_item = ""
					continue_run())
	button("← Combate", 36, 638, 250, 54, continue_run)
