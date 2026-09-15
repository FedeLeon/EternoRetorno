extends Control

const Game = preload("res://src/game.gd")
const Art = preload("res://src/pixel_art.gd")
const Dungeon = preload("res://src/dungeon.gd")
const GOLD = Color("d8b779")
const INK = Color("10141f")
const TEXT = Color("ebe2d0")
const MUTED = Color("9299ab")
var game = Game.new()
var screen = "home"
var selected_party: Array = []
var selected_card = -1
var layer: Control
var overlay: Control
var upgrade_mode = false
var return_screen = "home"

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
	b.pressed.connect(callback)
	rect(b, x, y, w, h, parent)
	return b

func panel(x: float, y: float, w: float, h: float, border: Color = Color("343b4d"), parent: Control = null) -> Panel:
	var p = Panel.new()
	p.add_theme_stylebox_override("panel", box(Color("141a27"), border))
	p.mouse_filter = Control.MOUSE_FILTER_IGNORE
	rect(p, x, y, w, h, parent)
	return p

func art(kind: String, color: Color, x: float, y: float, w: float, h: float, parent: Control = null) -> Control:
	var a = Art.new()
	a.kind = kind
	a.tint = color
	rect(a, x, y, w, h, parent)
	return a

func background() -> void:
	var bg = Art.new()
	bg.scene_art = true
	rect(bg, 0, 0, 1280, 720)
	var shade = ColorRect.new()
	shade.color = Color(0.025, 0.035, 0.06, 0.44)
	shade.mouse_filter = Control.MOUSE_FILTER_IGNORE
	rect(shade, 0, 0, 1280, 720)

func render() -> void:
	if is_instance_valid(layer):
		remove_child(layer)
		layer.queue_free()
	layer = Control.new()
	add_child(layer)
	layer.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	background()
	match screen:
		"home": home()
		"select": selection()
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

func home() -> void:
	label_at("UN DESCENSO. DOS ALMAS. OTRO COMIENZO.", 64, 74, 790, 36, 17, GOLD)
	label_at("ETERNO\nRETORNO", 58, 126, 730, 208, 82)
	label_at("La piedra recuerda a quienes caen.\nElegí a tus compañeros. Desafiá al ciclo.", 64, 340, 650, 76, 23, MUTED)
	button("Continuar aventura" if active_run() else "Iniciar aventura", 64, 456, 352, 64, continue_run if active_run() else open_selection)
	button("Nueva aventura" if active_run() else "Colección de ecos", 64, 534, 352, 56, confirm_new if active_run() else open_collection)
	if active_run():
		button("Colección", 430, 534, 170, 56, open_collection)
	label_at("PISO I  /  LA CRIPTA DE LOS ECOS", 64, 644, 700, 30, 17, GOLD)
	label_at("%d aventuras  ·  %d victorias" % [game.profile.attempts, game.profile.victories], 866, 647, 360, 30, 17, MUTED)
	art("boss", Color("91776d"), 825, 140, 300, 400)
	art("warrior", Color("c66d58"), 752, 432, 130, 156)
	art("mage", Color("b095d4"), 1080, 432, 130, 156)
	label_at("I", 964, 552, 90, 60, 40, GOLD).horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER

func open_selection() -> void:
	selected_party = []
	screen = "select"
	render()

func confirm_new() -> void:
	show_modal("Empezar otro retorno", "La aventura actual terminará. Tus desbloqueos se conservan.", "Empezar de nuevo", func():
		close_modal()
		open_selection())

func selection() -> void:
	header("Elegí dos almas", "Cada pareja crea un mazo distinto. Ambos comparten energía, pero conservan su propia vida.")
	var ids = game.content.heroes.keys()
	for i in range(ids.size()):
		var id = ids[i]
		var h = game.content.heroes[id]
		var x = 36 + i * 204
		var chosen = id in selected_party
		var b = button("", x, 152, 188, 410, func(): toggle_hero(id))
		b.add_theme_stylebox_override("normal", box(Color("242938") if chosen else Color("141a27"), GOLD if chosen else Color("384052"), 2 if chosen else 1))
		label_at("0%d  %s" % [i + 1, "ELEGIDO" if chosen else ""], 12, 8, 165, 26, 16, GOLD, b)
		art(id, Color(h.color), 20, 46, 148, 178, b)
		label_at(h.name, 12, 230, 168, 34, 23, TEXT, b)
		label_at(h.role, 12, 268, 168, 28, 17, Color(h.color), b)
		label_at(h.lore, 12, 307, 164, 56, 16, MUTED, b)
		label_at("VIDA  %d" % h.hp, 12, 369, 168, 28, 17, TEXT, b)
	label_at("%d / 2 personajes seleccionados" % selected_party.size(), 36, 592, 630, 50, 21, GOLD)
	button("Volver", 36, 648, 150, 48, func(): screen = "home"; render())
	button("Entrar en la cripta  →", 894, 607, 350, 64, begin, selected_party.size() == 2)

func toggle_hero(id: String) -> void:
	if id in selected_party:
		selected_party.erase(id)
	elif selected_party.size() < 2:
		selected_party.append(id)
	render()

func begin() -> void:
	# Abandon only after a valid replacement party has been chosen.
	if active_run():
		game._finish(false)
	if game.new_run(selected_party):
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

func combat_view() -> void:
	var b = game.run.combat
	var node = game.run.nodes[game.run.current]
	header("%s  /  Sala %02d" % [Dungeon.LABELS[node.kind], node.id + 1])
	label_at("TURNO %d" % b.turn, 970, 42, 150, 35, 19, GOLD)
	var hint = "Tocá una carta para jugarla. Las intenciones enemigas indican a quién atacarán."
	var targets: Array = []
	var c: Dictionary = {}
	if selected_card >= 0 and selected_card < b.hand.size():
		c = game.content.card(b.hand[selected_card])
		targets = game.valid_targets(selected_card)
		hint = "Tocá un enemigo iluminado." if c.target == "enemy" else "Tocá un aliado iluminado para confirmar."
	label_at(hint, 36, 91, 1200, 30, 18, GOLD if not c.is_empty() else MUTED)
	for i in range(2):
		var h = game.run.heroes[i]
		var def = game.content.heroes[h.id]
		var x = 80 + i * 234
		var valid = not c.is_empty() and c.target != "enemy" and i in targets
		var target = button("", x, 154, 204, 241, func(): target_clicked(i), valid)
		target.add_theme_stylebox_override("normal", box(Color(0.09, 0.12, 0.17, 0.55), GOLD, 2))
		target.add_theme_stylebox_override("disabled", box(Color(0.04, 0.06, 0.09, 0.35), Color("343b4d")))
		art(h.id, Color(def.color) if h.hp > 0 else Color("4f505d"), 48, 5, 108, 132, target)
		label_at(def.name, 10, 140, 184, 29, 22, TEXT, target).horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		health_bar(h, 16, 177, 172, target)
		label_at("Bloqueo %d" % h.block if h.hp > 0 else "Vuelve si ganás", 10, 207, 184, 27, 16, Color("9cbacb"), target).horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label_at("VS", 598, 258, 75, 56, 25, Color("625c5b"))
	for i in range(b.enemies.size()):
		var e = b.enemies[i]
		var def = game.content.enemies[e.id]
		var x = 768 + i * 234 if b.enemies.size() > 1 else 884
		var valid = not c.is_empty() and c.target == "enemy" and i in targets
		var target = button("", x, 154, 214, 241, func(): target_clicked(i), valid)
		target.add_theme_stylebox_override("normal", box(Color(0.16, 0.10, 0.13, 0.65), GOLD, 2))
		target.add_theme_stylebox_override("disabled", box(Color(0.04, 0.06, 0.09, 0.35), Color("343b4d")))
		art(e.id, Color(def.color) if e.hp > 0 else Color("424451"), 50, 5, 114, 132, target)
		label_at(def.name, 7, 134, 200, 43, 18, TEXT, target).horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		health_bar(e, 16, 177, 182, target)
		label_at("Bloq. %d  ·  Veneno %d" % [e.block, e.poison], 9, 207, 196, 27, 15, Color("b9b5a1"), target).horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		var intent_text = "Derrotado"
		if e.hp > 0:
			var dest = "ambos" if e.intent.get("all", false) else game.content.heroes[game.run.party[e.intent.target]].name
			intent_text = "Ataca %d → %s%s" % [e.intent.damage, dest, "  · +%d bloq." % e.intent.block if e.intent.get("block", 0) > 0 else ""]
		label_at(intent_text, x - 12, 120, 240, 34, 15, Color("e59a87")).horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label_at("ENERGÍA  %d / %d" % [b.energy, 4 if b.turn == 1 and "hourglass" in game.run.relics else 3], 36, 402, 300, 32, 21, GOLD)
	label_at("Mazo %d   ·   Descarte %d   ·   Inactivas %d" % [b.draw.size(), b.discard.size(), b.inactive.size()], 689, 403, 556, 30, 17, MUTED).horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	var count = b.hand.size()
	var width = 218
	var start = (1280 - (count * (width + 14) - 14)) / 2.0
	for i in range(count):
		card_panel(b.hand[i], start + i * (width + 14), 444, width, 204, func(): select_card(i), i == selected_card, not game.valid_targets(i).is_empty())
	if count == 0:
		label_at("No quedan cartas en la mano. Terminá el turno para robar.", 280, 498, 760, 70, 24, MUTED)
	label_at(game.run.log.back() if not game.run.log.is_empty() else "", 36, 663, 680, 30, 16, MUTED)
	button("Ver mazo", 772, 659, 175, 48, open_deck)
	button("Terminar turno  →", 963, 659, 281, 48, func(): act(game.end_turn))

func card_panel(instance: Dictionary, x: float, y: float, w: float, h: float, callback: Callable, chosen: bool = false, enabled: bool = true, parent: Control = null) -> Button:
	var c = game.content.card(instance)
	var def = game.content.heroes[c.owner]
	var b = button("", x, y, w, h, callback, enabled, parent)
	b.add_theme_stylebox_override("normal", box(Color("282b38") if chosen else Color("1c2230"), GOLD if chosen else Color(def.color).darkened(0.3), 3 if chosen else 1))
	panel(9, 9, 35, 35, Color(def.color), b)
	label_at(str(int(c.cost)), 9, 9, 35, 35, 23, GOLD, b).horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label_at(def.name.to_upper(), 54, 9, w - 64, 32, 13, Color(def.color), b)
	label_at(c.name, 14, 51, w - 28, 50, 21, TEXT if enabled else MUTED, b)
	label_at(game.content.describe(instance), 14, 108, w - 28, h - 112, 17, TEXT if enabled else MUTED, b)
	return b

func select_card(index: int) -> void:
	selected_card = -1 if selected_card == index else index
	render()

func target_clicked(index: int) -> void:
	if selected_card >= 0:
		act(func(): game.play_card(selected_card, index))

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
	button("Volver a empezar", 322, 581, 310, 64, open_selection)
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
	if is_instance_valid(overlay):
		close_modal()
	elif screen == "home":
		show_modal("Cerrar el libro", "Tu progreso está guardado.", "Salir del juego", func(): game.checkpoint(); get_tree().quit())
	elif screen in ["select", "collection"]:
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
