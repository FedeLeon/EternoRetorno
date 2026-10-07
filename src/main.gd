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
const CAMP_POSITIONS = [Vector2(450, 345), Vector2(830, 345), Vector2(245, 485), Vector2(1035, 485), Vector2(430, 585), Vector2(850, 585)]
const Dungeon = preload("res://src/dungeon.gd")
const GOLD = preload("res://src/ui/components/dark_skin.gd").ACCENT
const INK = Color("10141f")
const TEXT = Color("ebe2d0")
const MUTED = Color("9299ab")
var training_original: RefCounted

var game = Game.new()
var audio = preload("res://src/audio/audio_manager.gd").new()
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
	ui_theme.set_color("font_hover_color", "Button", Color("eee5fa"))
	preload("res://src/ui/components/button_skin.gd").install(ui_theme)
	ui_theme.set_stylebox("focus", "Button", preload("res://src/ui/components/dark_skin.gd").focus())
	theme = ui_theme
	add_child(audio)
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
	label.add_theme_font_size_override("font_size", roundi(font_size * (preload("res://src/presentation/preferences.gd").text_scale() if font_size >= 16 else 1.0)))
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
	if text in ["Inicio", "Elegir reliquia", "Saltar recompensa"]:
		preload("res://src/ui/components/button_skin.gd").arrow(b, text == "Inicio")
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
	p.add_theme_stylebox_override("panel", preload("res://src/ui/components/dark_skin.gd").frame(h < 90) if w >= 250 and h >= 50 else box(Color("101016"), border))
	p.mouse_filter = Control.MOUSE_FILTER_IGNORE
	rect(p, x, y, w, h, parent)
	return p

func art(kind: String, x: float, y: float, w: float, h: float, parent: Control = null, gear: Dictionary = {}) -> Control:
	var visual = ANIMATED_HEROES[kind].new()
	rect(visual, x - w * 0.18, y, w * 1.36, h, parent)
	preload("res://src/presentation/hero_equipment.gd").apply(visual, kind, gear)
	return visual

func background() -> void:
	preload("res://src/ui/screen_backgrounds.gd").build(self)

func render() -> void:
	audio.select_screen(screen, game.run, return_screen)
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
		"merchant": preload("res://src/ui/screens/merchant_screen.gd").build(self)
		"bestiary": preload("res://src/ui/screens/bestiary_screen.gd").build(self)
		"training_setup": preload("res://src/ui/screens/training_screen.gd").build(self)
		"options": options_view()
		"base_camp": base_camp_view()
		"market": market_view()
		"expeditions": preload("res://src/ui/camp_expansion_navigation.gd").expeditions(self)
		"church": preload("res://src/ui/camp_expansion_navigation.gd").church(self)
		"bonds": preload("res://src/ui/screens/bonds_screen.gd").build(self, func(): screen = "refuge"; render())
		"refuge": preload("res://src/ui/refuge_navigation.gd").build(self)
		"forge": preload("res://src/ui/forge_navigation.gd").build(self)
		"select": selection()
		"equipment": equipment_view()
		"items": items_view()
		"collection": collection()
		"deck": deck_view()
		"map": map_view()
		"combat": combat_view()
		"room": room_view()
		"event_cards": preload("res://src/ui/screens/event_cards_screen.gd").build(self)
		"reward": reward_view()
		"victory", "defeat": result_view()
	if screen == "combat" and game.run.combat.turn == 1:
		preload("res://src/ui/tutorial_navigation.gd").maybe.call_deferred(self)
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
	preload("res://src/presentation/preferences.gd").settings = settings
	theme.default_font_size = roundi(20 * preload("res://src/presentation/preferences.gd").text_scale())
	audio.apply_settings(settings)
	if not OS.has_feature("mobile") and DisplayServer.get_name() != "headless":
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN if settings.get("fullscreen", false) else DisplayServer.WINDOW_MODE_WINDOWED)

func set_option(key: String, value: Variant) -> void:
	if not game.profile.has("settings"):
		game.profile.settings = {}
	game.profile.settings[key] = value
	apply_options()
	game.checkpoint()

func options_view() -> void:
	preload("res://src/ui/screens/options_screen.gd").build(self)

var market_hero = ""
var forge_hero = ""
var church_hero = ""

func open_market() -> void:
	market_hero = ""
	screen = "market"
	render()

func market_view() -> void:
	preload("res://src/ui/screens/market_screen.gd").build(self, game.content, game.profile.duplicate(true), market_hero, {
		"back": open_base_camp,
		"category": func(id): market_hero = id; render(),
		"buy": func(id):
			var scroll_position = layer.get_node("MarketCards").scroll_vertical
			if game.buy_market_card(id): audio.play_sfx("coins")
			render()
			layer.get_node("MarketCards").set_deferred("scroll_vertical", scroll_position)})

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

func camp_hotspot(id: String, area: Rect2, caption: String, action: Callable, caption_above: bool = false, caption_offset: Vector2 = Vector2.ZERO) -> Button:
	var b = button("", area.position.x, area.position.y - (34 if caption_above else 0), area.size.x, area.size.y + 34, action)
	b.name = id
	b.tooltip_text = caption
	for state in ["normal", "hover", "pressed", "focus", "disabled"]:
		b.add_theme_stylebox_override(state, StyleBoxEmpty.new())
	var plaque = panel(area.position.x + (area.size.x - 208) / 2, area.position.y - 34 if caption_above else area.end.y, 208, 34)
	plaque.position += caption_offset
	if caption_offset != Vector2.ZERO:
		var clickable = b.get_rect().merge(plaque.get_rect())
		b.position = clickable.position
		b.size = clickable.size
	plaque.add_theme_stylebox_override("panel", preload("res://src/ui/components/button_skin.gd").style("wood_button"))
	var title = label_at(caption, 5, 0, 198, 34, 16, GOLD, plaque)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	if id == "CampExit": preload("res://src/ui/components/button_skin.gd").plaque_arrow(title)
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
		"refuge": func(): screen = "refuge"; render(),
		"expeditions": func(): preload("res://src/ui/camp_expansion_navigation.gd").plot(self, "expeditions"),
		"church": func(): preload("res://src/ui/camp_expansion_navigation.gd").plot(self, "church"),
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
	preload("res://src/ui/development_start.gd").open(self, func(floor): preload("res://src/ui/screens/run_setup_screen.gd").open(self, floor, begin_on_floor))

func begin_on_floor(starting_floor: int) -> void:
	close_modal()
	# Abandon only after a valid replacement party has been chosen.
	if active_run():
		game._finish(false)
	if game.new_run(selected_party, -1, equipped, starting_floor):
		continue_run()

func continue_run() -> void:
	screen = game.run.phase
	selected_card = -1
	selected_synergy = ""
	upgrade_mode = false
	render()

func act(callback: Callable) -> void:
	var previous_room = game.run.get("current", -1)
	callback.call()
	if game.run.get("current", -1) != previous_room: audio.play_sfx("step", -7)
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
	view.dungeon_name = Dungeon.definition(int(game.run.get("floor", 1))).name
	view.exit_caption = ("Entrar al bosque" if int(game.run.get("floor", 1)) == 1 else "Entrar a la fortaleza") if int(game.run.get("floor", 1)) < int(game.run.get("floor_count", 1)) else "Completar aventura"
	view.deck_count = game.run.deck.size()
	view.relics = equipped_relics()
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
	for id in game.run.get("relics", []):
		var relic = game.content.relics[id].duplicate()
		relic.owner = "Hallada"
		result.append(relic)
	return result

func combat_view() -> void:
	preload("res://src/ui/screens/combat_screen.gd").build(self)

func card_panel(instance: Dictionary, x: float, y: float, w: float, h: float, callback: Callable, chosen: bool = false, enabled: bool = true, parent: Control = null, base_values: bool = false) -> Button:
	return preload("res://src/ui/components/card_view.gd").build(self, instance, x, y, w, h, callback, chosen, enabled, parent, base_values)

func select_card(index: int) -> void:
	var drag = layer.get_node_or_null("CardDrag")
	if drag != null and drag.dragging: return
	audio.play_sfx("card_select", -5)
	selected_synergy = ""
	var hand = layer.get_node_or_null("CombatHand")
	if hand != null:
		hand_scroll = hand.scroll_horizontal
	selected_card = -1 if selected_card == index else index
	render()

func _exit_tree() -> void:
	Engine.time_scale = 1.0

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
		if int(game.run.get("floor", 1)) >= 2: view.background_path = BattleBackground.path_for(game.run.seed, game.run.current, game.run.floor)
		view.name = "TreasureScreen"
		view.result = treasure_display()
		view.open_requested.connect(func():
			if game.take_treasure():
				audio.play_sfx("treasure")
				view.reveal(treasure_display()))
		view.continue_requested.connect(func(): act(game.leave_treasure))
		view.menu_requested.connect(pause_menu)
		rect(view, 0, 0, 1280, 720)
		return
	if node.kind == "rest":
		var view = preload("res://src/ui/screens/rest_screen.gd").new()
		if int(game.run.get("floor", 1)) >= 2: view.background_path = "res://assets/forest/rest.png" if game.run.floor == 2 else "res://assets/volcano/rest.png"
		view.heroes = game.run.heroes.duplicate(true)
		view.can_upgrade = game.run.deck.any(func(card): return not card.upgraded)
		view.heal_requested.connect(func(): audio.play_sfx("heal"); act(func(): game.rest(true)))
		view.upgrade_requested.connect(func(): upgrade_mode = true; return_screen = "room"; screen = "deck"; render())
		view.menu_requested.connect(pause_menu)
		rect(view, 0, 0, 1280, 720)
		return
	if node.kind == "event":
		var view = preload("res://src/ui/screens/encounter_screen.gd").new()
		view.event_id = node.event
		view.event = game.content.events[node.event].duplicate(true)
		var chains = {"forest_hunter":"Además, las provisiones esconden una contraseña de descuento para el mercader errante.", "forest_spirit":"Además, el siguiente descanso restaurará 5 PV extra.", "library":"Además, el siguiente cofre ocultará otra poción de curación."}
		if chains.has(node.event): view.event.text += " " + chains[node.event]
		if node.event == "lava_bridge": view.can_offer = game.run.heroes.all(func(h): return h.hp > 8)
		if node.event == "altar":
			view.can_offer = game.run.heroes.all(func(h): return h.hp > 5) and game.run.deck.any(func(c): return not c.upgraded)
		view.choice_requested.connect(func(index): act(func(): game.choose_event(index)))
		view.menu_requested.connect(pause_menu)
		rect(view, 0, 0, 1280, 720)

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
	preload("res://src/ui/screens/deck_screen.gd").build(self, func(): screen = return_screen; upgrade_mode = false; render())

func open_collection() -> void:
	screen = "collection"
	render()

func collection() -> void:
	preload("res://src/ui/collection_navigation.gd").build(self)

func result_view() -> void:
	preload("res://src/ui/screens/run_result_screen.gd").build(self)

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
	var drag = layer.get_node_or_null("CardDrag")
	if drag != null: drag.cancel()
	preload("res://src/ui/pause_navigation.gd").open(self)

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
	elif screen == "bonds":
		screen = "refuge"; render()
	elif screen == "refuge":
		layer.get_node("RefugeScreen").go_back()
	elif screen == "items":
		continue_run()
	elif screen == "equipment":
		screen = "select"
		render()
	elif screen == "market" and market_hero != "":
		market_hero = ""
		render()
	elif screen == "forge" and forge_hero != "":
		forge_hero = ""
		render()
	elif screen == "church" and church_hero != "":
		church_hero = ""
		render()
	elif screen in ["select", "market", "forge", "church", "expeditions"]:
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
