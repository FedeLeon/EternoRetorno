extends Control

const TargetGlow = preload("res://src/ui/components/target_glow.gd")
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
const BATTLE_HEROES = {"warrior": true, "guardian": true, "rogue": true, "mage": true}
const Campfire = preload("res://src/campfire.gd")
const CAMP_POSITIONS = [Vector2(180, 558), Vector2(1100, 558), Vector2(380, 558), Vector2(900, 558)]
const Dungeon = preload("res://src/dungeon.gd")
const GOLD = preload("res://src/ui/components/dark_skin.gd").ACCENT
const INK = Color("10141f")
const TEXT = Color("ded9e5")
const MUTED = Color("9299ab")
var training_original: RefCounted
var training_config: Dictionary = {}
var keyboard_target = -1

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
var navigation = preload("res://src/ui/back_navigation.gd").new()
var combat_busy = false
var hero_health: Dictionary = {}
var enemy_health: Dictionary = {}
var hero_art: Dictionary = {}
var enemy_art: Dictionary = {}

func _ready() -> void:
	get_tree().auto_accept_quit = false
	theme = preload("res://src/ui/components/ui_factory.gd").create_theme()
	add_child(audio)
	apply_options()
	var comic = preload("res://src/presentation/comic_presentation.gd").new()
	add_child(comic); comic.watch(self)
	render()

func box(fill: Color, border: Color = Color("343b4d"), width: int = 1) -> StyleBoxFlat:
	return preload("res://src/ui/components/ui_factory.gd").box(fill, border, width)

func rect(node: Control, x: float, y: float, w: float, h: float, parent: Control = null) -> Control:
	return preload("res://src/ui/components/ui_factory.gd").rect(node, x, y, w, h, parent if parent != null else layer)

func label_at(text: String, x: float, y: float, w: float, h: float, font_size: int = 20, color: Color = TEXT, parent: Control = null) -> Label:
	return preload("res://src/ui/components/ui_factory.gd").label_at(text, x, y, w, h, font_size, color, parent if parent != null else layer)

func button(text: String, x: float, y: float, w: float, h: float, callback: Callable, enabled: bool = true, parent: Control = null) -> Button:
	var guarded = func():
		if not combat_busy: callback.call()
	return preload("res://src/ui/components/ui_factory.gd").button(text, x, y, w, h, guarded, enabled, parent if parent != null else layer)

func panel(x: float, y: float, w: float, h: float, border: Color = Color("343b4d"), parent: Control = null) -> Panel:
	return preload("res://src/ui/components/ui_factory.gd").panel(x, y, w, h, border, parent if parent != null else layer)

func art(kind: String, x: float, y: float, w: float, h: float, parent: Control = null, gear: Dictionary = {}) -> Control:
	var visual = preload("res://src/presentation/detailed_hero.gd").new()
	visual.hero_id = kind
	rect(visual, x - w * 0.18, y, w * 1.36, h, parent)
	visual.apply_gear(gear)
	return visual

func background() -> void:
	preload("res://src/ui/screen_backgrounds.gd").build(self)

func render() -> void:
	navigation.observe(self)
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
		"cinematics": preload("res://src/ui/screens/cinematics_screen.gd").build(self)
		"boss_reward": preload("res://src/ui/screens/boss_reward_screen.gd").build(self)
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
		"paths": preload("res://src/ui/adventure_navigation.gd").build(self, true)
		"combat": combat_view()
		"room": room_view()
		"event_cards": preload("res://src/ui/screens/event_cards_screen.gd").build(self)
		"reward": reward_view()
		"victory", "defeat": result_view()
	preload("res://src/ui/components/header_back_button.gd").build(self)
	preload("res://src/presentation/comic_presentation.gd").frame_screen(self)
	if screen == "combat" and game.run.combat.turn == 1:
		preload("res://src/ui/tutorial_navigation.gd").maybe.call_deferred(self)
	if game.message != "":
		preload("res://src/ui/components/message_toast.gd").show(self,game.message)
	layer.modulate.a = 0.65
	create_tween().tween_property(layer, "modulate:a", 1.0, 0.12)

func header(title: String, subtitle: String = "") -> void:
	preload("res://src/ui/components/section_header.gd").build(self,title,subtitle)

func active_run() -> bool:
	return not game.run.is_empty() and game.run.phase not in ["victory", "defeat"]

func title_button(caption: String, y: float, primary: bool, action: Callable) -> Button:
	var b = button(caption, 440, y, 400, 58, action)
	b.add_theme_font_size_override("font_size", 23)
	preload("res://src/ui/components/button_skin.gd").decorate(b, "wood_button")
	return b

func home() -> void:
	title_button("Continuar aventura" if active_run() else "Iniciar juego", 510 if active_run() else 538, true, continue_run if active_run() else func():preload("res://src/ui/cinematic_navigation.gd").enter(self)).name = "StartGame"
	button("Historias",62,500,170,48,func():screen="cinematics";render()).name = "HomeCinematics"
	preload("res://src/ui/components/title_actions.gd").build(self, 638 if active_run() else 606)
	button("Bestiario", 62, 560, 170, 48, func():
		return_screen = "home"; screen = "bestiary"; render()).name = "HomeBestiary"
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
		show_modal("Mercado", "Necesitás %d celdas. Ganá batallas para reunirlas." % cost, "Entendido", close_modal)
		return
	show_modal("Construir mercado", "Construir en el solar 1 cuesta %d celdas. Permite comprar cartas para futuras recompensas." % cost, "Construir", func():
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
	plaque.z_index = 4 # Camp captions stay above neighbouring roofs.
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
		# Commit the first encounter before any presentation; resume starts in combat.
		game.enter_node(0)
		await preload("res://src/ui/cinematic_navigation.gd").party(self)
		continue_run()

func continue_run() -> void:
	screen = preload("res://src/ui/adventure_navigation.gd").screen_for(game)
	selected_card = -1
	selected_synergy = ""
	upgrade_mode = false
	render()
	preload("res://src/ui/cinematic_navigation.gd").boss(self)

func act(callback: Callable) -> void:
	var previous_room = game.run.get("current", -1)
	callback.call()
	if game.run.get("current", -1) != previous_room: audio.play_sfx("step", -7)
	continue_run()

func map_view() -> void:
	preload("res://src/ui/adventure_navigation.gd").build(self, false)

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
	if visual.has_method("play_once"): visual.play_once("hurt")

func reward_view() -> void:
	preload("res://src/ui/screens/reward_screen.gd").build(self)

func room_view() -> void:
	preload("res://src/ui/room_navigation.gd").build(self)

func open_deck() -> void:
	return_screen = screen
	upgrade_mode = false
	screen = "deck"
	render()

func deck_view() -> void:
	if upgrade_mode:
		var view = preload("res://src/ui/screens/card_upgrade_screen.gd").new()
		view.ui = self
		view.name = "CardUpgradeScreen"
		rect(view, 0, 0, 1280, 720)
		return
	preload("res://src/ui/screens/deck_screen.gd").build(self)

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

func _input(event: InputEvent) -> void:
	if preload("res://src/ui/combat_input.gd").handle(self, event): get_viewport().set_input_as_handled()

func _unhandled_key_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		back()
		get_viewport().set_input_as_handled()

func back() -> void:
	navigation.back(self)

func object_icon(index: int, x: float, y: float, side: float, parent: Control = null) -> void:
	var icon = TextureRect.new()
	var texture = AtlasTexture.new()
	texture.atlas = preload("res://assets/objects/icons.png")
	texture.region = Rect2((index % 4) * 64, (index / 4) * 64, 64, 64)
	icon.texture = texture
	icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	icon.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
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
