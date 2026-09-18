extends Control

const TargetGlow = preload("res://src/ui/components/target_glow.gd")
const CombatEffects = preload("res://src/presentation/combat_effects.gd")
const EnemyIntent = preload("res://src/ui/components/enemy_intent.gd")
const BattleBackground = preload("res://src/ui/components/battle_background.gd")
const TreasureScreen = preload("res://src/ui/screens/treasure_screen.gd")
const HealthBar = preload("res://src/ui/components/health_bar.gd")
const StatusEffects = preload("res://src/ui/components/status_effects.gd")
const EquipmentScreen = preload("res://src/ui/screens/equipment_screen.gd")
const CombatHUD = preload("res://src/ui/components/combat_hud.gd")
const HandLayout = preload("res://src/ui/components/hand_layout.gd")
const NumberView = preload("res://src/ui/components/number_view.gd")
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
const CAMP_FRONT = preload("res://assets/camp/front-128.png")
const CAMP_POSITIONS = [Vector2(450, 375), Vector2(830, 375), Vector2(245, 485), Vector2(1035, 485), Vector2(430, 585), Vector2(850, 585)]
const Dungeon = preload("res://src/dungeon.gd")
const GOLD = Color("d8b779")
const INK = Color("10141f")
const TEXT = Color("ebe2d0")
const MUTED = Color("9299ab")
var game = Game.new()
var equipped: Dictionary = {}
var selected_item = ""
var screen = "home"
var selected_party: Array = []
const SynergyView = preload("res://src/ui/components/synergy_view.gd")
var selected_synergy = ""
var selected_card = -1
var hand_scroll = 0
var layer: Control
var overlay: Control
var upgrade_mode = false
var return_screen = "home"
var combat_busy = false
var hero_health: Dictionary = {}
var enemy_health: Dictionary = {}
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
	preload("res://src/ui/components/button_skin.gd").install(ui_theme)
	ui_theme.set_stylebox("focus", "Button", box(Color(0, 0, 0, 0), GOLD, 2))
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
	if text == "Menú":
		preload("res://src/ui/components/button_skin.gd").decorate(b, "wood_menu")
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

func art(kind: String, x: float, y: float, w: float, h: float, parent: Control = null, gear: Dictionary = {}) -> Control:
	var visual = ANIMATED_HEROES[kind].new()
	rect(visual, x - w * 0.18, y, w * 1.36, h, parent)
	preload("res://src/presentation/hero_equipment.gd").apply(visual, kind, gear)
	return visual

func background() -> void:
	if screen in ["map", "equipment"]:
		return # These screens own their backgrounds.
	if screen == "combat":
		var room = TextureRect.new()
		room.texture = load(BattleBackground.path_for(game.run.seed, game.run.current))
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
		camp.name = "DayCampBackground"
		var ambience = ShaderMaterial.new()
		ambience.shader = preload("res://assets/shaders/camp_day.gdshader")
		camp.material = ambience
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
	rect(bg, 0, 0, 1280, 720)
	var shade = ColorRect.new()
	shade.color = Color(0.025, 0.035, 0.06, 0.44)
	shade.mouse_filter = Control.MOUSE_FILTER_IGNORE
	rect(shade, 0, 0, 1280, 720)

func render() -> void:
	hero_health.clear()
	enemy_health.clear()
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
		"market": market_view()
		"forge": preload("res://src/ui/forge_navigation.gd").build(self)
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
	preload("res://src/ui/components/button_skin.gd").decorate(b, "wood_button")
	return b

func home() -> void:
	title_button("Continuar aventura" if active_run() else "Iniciar juego", 510 if active_run() else 538, true, continue_run if active_run() else open_base_camp).name = "StartGame"
	preload("res://src/ui/components/title_actions.gd").build(self, 638 if active_run() else 606)
	button("Colección", 62, 620, 170, 48, open_collection)
	if active_run():
		title_button("Campamento", 574, true, open_base_camp).name = "Camp"

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

var market_hero = "warrior"
var forge_hero = "warrior"

func open_market() -> void:
	screen = "market"
	render()

func market_view() -> void:
	preload("res://src/ui/screens/market_screen.gd").build(self, game.content, game.profile.duplicate(true), market_hero, {
		"back": open_base_camp,
		"category": func(id): market_hero = id; render(),
		"buy": func(id): game.buy_market_card(id); render()})

func market_plot() -> void:
	if game.profile.buildings.get("market", false):
		open_market()
		return
	var cost = int(game.Progression.config().market_cost)
	if game.profile.souls < cost:
		show_modal("Mercado", "Necesitás %d almas. Ganá batallas para reunirlas." % cost, "Entendido", close_modal)
		return
	show_modal("Construir mercado", "Construir en el solar 1 cuesta %d almas. Permite comprar cartas para futuras recompensas." % cost, "Construir", func():
		if game.build_market():
			close_modal()
			open_market())

func open_base_camp() -> void:
	screen = "base_camp"
	game.message = ""
	render()

func camp_hotspot(id: String, area: Rect2, caption: String, action: Callable, caption_above: bool = false) -> Button:
	var b = button("", area.position.x, area.position.y - (34 if caption_above else 0), area.size.x, area.size.y + 34, action)
	b.name = id
	b.tooltip_text = caption
	for state in ["normal", "hover", "pressed", "focus", "disabled"]:
		b.add_theme_stylebox_override(state, StyleBoxEmpty.new())
	var plaque = panel(area.position.x + (area.size.x - 208) / 2, area.position.y - 34 if caption_above else area.end.y, 208, 34)
	plaque.add_theme_stylebox_override("panel", preload("res://src/ui/components/button_skin.gd").style("wood_button"))
	var title = label_at(caption, 5, 0, 198, 34, 16, GOLD, plaque)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	b.set_meta("caption_rect", plaque.get_rect())
	return b

func camp_adventures() -> void:
	close_modal()
	overlay = preload("res://src/ui/components/dialog_view.gd").build(self, "Más allá del campamento", "Elegí cómo querés seguir tu viaje.", [
		{"id": "ContinueAdventure", "text": "Continuar aventura", "enabled": active_run(), "callback": func(): close_modal(); continue_run()},
		{"id": "NewAdventure", "text": "Nueva aventura", "callback": func():
			close_modal()
			if active_run(): confirm_new()
			else: open_selection()},
		{"id": "BackToCamp", "text": "Volver", "callback": close_modal}])

func base_camp_view() -> void:
	preload("res://src/ui/screens/base_camp_screen.gd").build(self, game.profile.duplicate(true), {
		"home": func(): screen = "home"; render(),
		"prepare": camp_adventures,
		"market": market_plot, "forge": func(): preload("res://src/ui/forge_navigation.gd").plot(self), "close_modal": close_modal})

func open_selection() -> void:
	selected_party = []
	equipped = {}
	if game.profile.erase("preparation"):
		game.checkpoint()
	screen = "select"
	render()

func confirm_new() -> void:
	show_modal("Empezar otro retorno", "La aventura actual terminará. Tus desbloqueos se conservan.", "Empezar de nuevo", func():
		close_modal()
		open_selection())

func selection() -> void:
	preload("res://src/ui/screens/selection_screen.gd").build(self, {
		"toggle": toggle_hero, "back": open_base_camp, "equipment": open_equipment,
		"menu": func(): screen = "home"; render(),
	})

func toggle_hero(id: String) -> void:
	if id in selected_party:
		selected_party.erase(id)
		equipped.erase(id)
	elif selected_party.size() < 2:
		selected_party.append(id)
	render()

func begin() -> void:
	if not game.valid_equipment(selected_party, equipped) or (screen == "equipment" and equipped.size() != 1):
		return
	# Abandon only after a valid replacement party has been chosen.
	if active_run():
		game._finish(false)
	if game.new_run(selected_party, -1, equipped):
		continue_run()

func continue_run() -> void:
	screen = game.run.phase
	selected_card = -1
	selected_synergy = ""
	upgrade_mode = false
	render()

func act(callback: Callable) -> void:
	callback.call()
	continue_run()

func map_view() -> void:
	var view = preload("res://src/ui/screens/map_screen.gd").new()
	view.name = "MapScreen"
	view.nodes = game.run.nodes.duplicate(true)
	view.available = game.available_nodes()
	view.visited = game.run.visited.duplicate()
	view.current = game.run.current
	view.run_seed = game.run.seed
	view.boss_defeated = game.run.boss_defeated
	view.deck_count = game.run.deck.size()
	view.relics = equipped_relics()
	for id in game.run.relics:
		var relic = game.content.relics[id].duplicate()
		relic.owner = "Hallada"
		view.relics.append(relic)
	for hero in game.run.heroes:
		var snapshot = hero.duplicate()
		snapshot.title = game.content.heroes[hero.id].name
		snapshot.visual = ANIMATED_HEROES[hero.id]
		view.heroes.append(snapshot)
	view.room_requested.connect(func(id): act(func(): game.enter_node(id)))
	view.deck_requested.connect(open_deck)
	view.menu_requested.connect(pause_menu)
	view.descend_requested.connect(func(): act(game.descend))
	rect(view, 0, 0, 1280, 720)

func health_bar(unit: Dictionary, x: float, y: float, width: float, parent: Control = null) -> Control:
	var bar = HealthBar.new()
	bar.set_health(int(unit.hp), int(unit.max_hp))
	rect(bar, x, y, width, 25, parent)
	return bar

func combat_target_style(target: Button) -> void:
	for state in ["normal", "disabled", "hover", "pressed", "focus"]:
		target.add_theme_stylebox_override(state, StyleBoxEmpty.new())

func equipped_relics() -> Array:
	var result: Array = []
	var team_relic = game.run.get("team_relic", "")
	if game.content.equipment.has(team_relic):
		var relic = game.content.equipment[team_relic].duplicate()
		relic.owner = "Equipo"
		if team_relic == "phoenix_idol":
			for hero in game.run.heroes:
				relic.description += "\n" + game.content.heroes[hero.id].name + (": utilizado." if hero.get("phoenix_used", false) else ": disponible.")
		result.append(relic)
	else:
		# Preserve personal equipment in adventures saved before team relics.
		for hero in game.run.heroes:
			var relic_id = hero.get("equipped_relic", "")
			if game.content.equipment.has(relic_id):
				var relic = game.content.equipment[relic_id].duplicate()
				relic.owner = game.content.heroes[hero.id].name
				relic.description += "\nPartida anterior: efecto personal."
				relic.description += "\nFénix ya utilizado." if hero.get("phoenix_used", false) else ""
				result.append(relic)
	return result

func combat_view() -> void:
	preload("res://src/ui/screens/combat_screen.gd").build(self)

func card_panel(instance: Dictionary, x: float, y: float, w: float, h: float, callback: Callable, chosen: bool = false, enabled: bool = true, parent: Control = null, base_values: bool = false) -> Button:
	return preload("res://src/ui/components/card_view.gd").build(self, instance, x, y, w, h, callback, chosen, enabled, parent, base_values)

func select_card(index: int) -> void:
	selected_synergy = ""
	var hand = layer.get_node_or_null("CombatHand")
	if hand != null:
		hand_scroll = hand.scroll_horizontal
	selected_card = -1 if selected_card == index else index
	render()

func target_clicked(index: int) -> void:
	if selected_synergy != "":
		animate_combat_action(-1, index, selected_synergy)
	elif selected_card >= 0:
		animate_combat_action(selected_card, index)

func animate_combat_action(hand_index: int = -1, target_index: int = -1, synergy_id: String = "") -> void:
	await preload("res://src/ui/combat_flow.gd").run(self, hand_index, target_index, synergy_id)

func flash_hit(visual: Control) -> void:
	var original = visual.modulate
	visual.modulate = Color(1.6, 0.5, 0.5)
	var tween = visual.create_tween()
	tween.tween_interval(0.10)
	tween.tween_property(visual, "modulate", original, 0.20)

func reward_view() -> void:
	preload("res://src/ui/screens/reward_screen.gd").build(self)

func room_view() -> void:
	var node = game.run.nodes[game.run.current]
	if node.kind == "treasure":
		var view = TreasureScreen.new()
		view.name = "TreasureScreen"
		view.result = treasure_display()
		view.open_requested.connect(func():
			if game.take_treasure():
				view.reveal(treasure_display()))
		view.continue_requested.connect(func(): act(game.leave_treasure))
		view.menu_requested.connect(pause_menu)
		rect(view, 0, 0, 1280, 720)
		return
	header("%s  /  Sala %02d" % [Dungeon.LABELS[node.kind], node.id + 1])
	panel(212, 154, 856, 458, Color("62533e"))
	match node.kind:
		"rest":
			label_at("Una brasa en la oscuridad", 264, 195, 760, 62, 36, GOLD)
			label_at("Por un momento, el tiempo deja de perseguirlos.\nDescansá o templá una carta antes de continuar.", 264, 280, 742, 92, 24)
			button("Recuperar 30 % de vida", 264, 422, 355, 64, func(): act(func(): game.rest(true)))
			button("Mejorar una carta", 645, 422, 355, 64, func(): upgrade_mode = true; return_screen = "room"; screen = "deck"; render())
			label_at("Guerreros vivos: " + "  ·  ".join(game.run.heroes.map(func(h): return "%s %d/%d" % [game.content.heroes[h.id].name, h.hp, h.max_hp])), 264, 520, 730, 43, 18, MUTED)
		"event":
			var event = game.content.events[node.event]
			label_at(event.name, 264, 195, 760, 62, 36, GOLD)
			label_at(event.text, 264, 273, 742, 100, 24)
			var can_offer = true
			if node.event == "altar":
				can_offer = game.run.heroes.all(func(h): return h.hp > 5) and game.run.deck.any(func(c): return not c.upgraded)
			for i in range(2):
				button(event.choices[i], 264, 414 + i * 80, 742, 64, func(): act(func(): game.choose_event(i)), can_offer or i == 1)

func treasure_display() -> Dictionary:
	var state = game.Treasure.state(game.run.treasure)
	var data = game.content.items.get(state.get("item", ""), {})
	if state.has("legacy_relic"):
		data = game.content.relics.get(state.legacy_relic, {})
	var text = data.get("description", "")
	if state.get("opened", false):
		if state.has("legacy_relic"):
			text += "\nReliquia conservada de tu partida anterior."
		else:
			text += "\nAñadido a la bolsa: 1."
		if state.trapped:
			text += "\n¡Era una trampa!"
			for i in range(state.losses.size()):
				text += "\n%s: −%d de vida." % [game.content.heroes[game.run.heroes[i].id].name, state.losses[i]]
	return {"opened": state.opened, "trapped": state.trapped, "title": data.get("name", "Cofre vacío"), "description": text, "icon": data.get("icon", -1)}

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
	if upgrade_mode:
		var view = preload("res://src/ui/screens/card_upgrade_screen.gd").new()
		view.ui = self
		view.name = "CardUpgradeScreen"
		rect(view, 0, 0, 1280, 720)
		return
	header("El mazo compartido", "")
	var battle = game.run.combat
	var detail = "Total: %d cartas" % game.run.deck.size()
	if game.run.phase == "combat":
		detail += " · Mazo: %d · Mano: %d · Descarte: %d · Inactivas: %d" % [battle.draw.size(), battle.hand.size(), battle.discard.size(), battle.inactive.size()]
	var summary = label_at(detail, 36, 108, 1208, 28, 17, GOLD)
	summary.name = "DeckSummary"
	var contents = scroll_area()
	for i in range(game.run.deck.size()):
		var instance = game.run.deck[i]
		var b = card_panel(instance, (i % 5) * 238, (i / 5) * 260, 224, 244, func(): pass, false, true, contents)
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
	overlay = preload("res://src/ui/components/dialog_view.gd").build(self, title, text, [
		{"text": action_text, "callback": callback},
		{"text": "Volver", "callback": close_modal}])

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
	var hud = layer.get_node_or_null("CombatHUD")
	if is_instance_valid(hud) and hud.close_relic():
		return
	if combat_busy:
		return
	var treasure = layer.get_node_or_null("TreasureScreen")
	if is_instance_valid(treasure) and treasure.busy:
		return
	if is_instance_valid(treasure) and treasure.result.get("opened", false) and not is_instance_valid(overlay):
		treasure.continue_requested.emit()
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
	elif screen in ["select", "market", "forge"]:
		open_base_camp()
	elif screen in ["base_camp", "collection", "options"]:
		screen = "home"
		render()
	elif screen == "deck":
		screen = return_screen
		upgrade_mode = false
		render()
	elif screen == "combat" and (selected_card >= 0 or selected_synergy != ""):
		selected_card = -1
		selected_synergy = ""
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
	screen = "equipment"
	render()

func equip_relic(id: String) -> void:
	if not game.content.equipment.has(id):
		return
	equipped = {"team": id}
	render()

func equipment_view() -> void:
	EquipmentScreen.build(self, game.content.equipment, equipped, equipped.size() == 1 and game.valid_equipment(selected_party, equipped), {
		"equip": equip_relic,
		"menu": pause_menu,
		"back": func(): screen = "select"; render(),
		"start": begin,
	})

func items_view() -> void:
	preload("res://src/ui/items_navigation.gd").build(self)
