extends Control
# Read-only gallery. Receives snapshots; never awards achievements or saves.
const Chrome = preload("res://src/ui/components/dark_skin.gd")
const Buttons = preload("res://src/ui/components/button_skin.gd")
var ui: Control
var snapshot: Dictionary
var home: Callable
var body: Control
var detail: Control
var tabs: Array[Button] = []
var selected: Button

func _ready() -> void:
	var background = TextureRect.new()
	background.texture = preload("res://assets/collection/background.png")
	background.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	background.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	background.mouse_filter = Control.MOUSE_FILTER_IGNORE
	ui.rect(background, 0, 0, 1280, 720, self)
	var header = ui.panel(0, 0, 1280, 84, ui.GOLD, self)
	header.name = "CollectionHeader"
	ui.label_at("La colección de ecos", 48, 17, 900, 50, 30, ui.GOLD, self)
	var back = ui.button("Inicio", 1060, 22, 184, 40, home, true, self)
	back.name = "CollectionHome"
	for state in ["normal", "hover", "pressed", "disabled"]:
		var style = back.get_theme_stylebox(state).duplicate()
		style.content_margin_left = 40
		style.content_margin_right = 40
		back.add_theme_stylebox_override(state, style)
	var summary = _frame(Rect2(36, 100, 1208, 48), self)
	var earned = snapshot.achievements.filter(func(a): return a.unlocked).size()
	var totals = ui.label_at("%d / %d logros    ·    %d aventuras    ·    %d victorias" % [earned, snapshot.achievements.size(), snapshot.attempts, snapshot.victories], 20, 5, 1168, 38, 20, ui.TEXT, summary)
	totals.name = "AchievementTotals"
	for i in range(3):
		var tab = ui.button(["Logros", "Desbloqueos", "Últimos retornos"][i], 36 + i * 256, 164, 244, 42, func(): show_tab(i), true, self)
		tab.name = ["AchievementsTab", "UnlocksTab", "HistoryTab"][i]
		tabs.append(tab)
	show_tab(0)

func _frame(area: Rect2, parent: Control) -> Panel:
	var panel = Panel.new()
	panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	panel.add_theme_stylebox_override("panel", Chrome.dialog())
	ui.rect(panel, area.position.x, area.position.y, area.size.x, area.size.y, parent)
	return panel

func show_tab(index: int) -> void:
	selected = null
	if is_instance_valid(body):
		remove_child(body)
		body.queue_free()
	body = Control.new()
	body.name = "CollectionBody"
	ui.rect(body, 36, 220, 1208, 478, self)
	for i in range(tabs.size()):
		tabs[i].disabled = i == index
		# The active tab remains legible; disabled prevents redundant rebuilds.
		tabs[i].add_theme_color_override("font_disabled_color", ui.GOLD)
	if index == 0: _achievements()
	elif index == 1: _unlocks()
	else: _history()

func _scroll(width: float, content_height: float) -> Control:
	var scroll = ScrollContainer.new()
	scroll.name = "CollectionScroll"
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	ui.rect(scroll, 0, 0, width, 478, body)
	var contents = Control.new()
	contents.custom_minimum_size = Vector2(width - 20, content_height)
	scroll.add_child(contents)
	return contents

func _icon(path: String, area: Rect2, parent: Control, tint: Color = Color.WHITE) -> void:
	var picture = TextureRect.new()
	picture.texture = load(path)
	picture.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	picture.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	picture.mouse_filter = Control.MOUSE_FILTER_IGNORE
	picture.modulate = tint
	ui.rect(picture, area.position.x, area.position.y, area.size.x, area.size.y, parent)

func _achievement_icon(entry: Dictionary) -> String:
	if entry.secret and not entry.unlocked:
		return "res://assets/collection/secret.svg"
	return "res://assets/collection/icons/%s.png" % entry.id

func _achievements() -> void:
	var contents = _scroll(884, ceil(snapshot.achievements.size() / 3.0) * 156)
	detail = _frame(Rect2(908, 0, 300, 478), body)
	detail.name = "AchievementDetail"
	for i in range(snapshot.achievements.size()):
		var entry: Dictionary = snapshot.achievements[i]
		var tile = ui.button("", (i % 3) * 288, (i / 3) * 156, 276, 144, func(): pass, true, contents)
		tile.name = "Achievement_" + entry.id
		tile.pressed.connect(func(): _select(entry, tile))
		_icon(_achievement_icon(entry), Rect2(12, 20, 76, 76), tile, Color.WHITE if entry.unlocked else Color(0.65, 0.65, 0.72))
		ui.label_at(entry.name, 100, 12, 164, 62, 19, ui.TEXT if entry.unlocked else ui.MUTED, tile)
		ui.label_at("DESBLOQUEADO" if entry.unlocked else ("SECRETO" if entry.secret else "EN PROGRESO"), 100, 79, 164, 24, 13, ui.GOLD if entry.unlocked else ui.MUTED, tile)
		if not entry.secret:
			var progress = ProgressBar.new()
			progress.max_value = entry.target
			progress.value = entry.progress
			progress.show_percentage = false
			for part in ["background", "fill"]:
				var style = StyleBoxFlat.new()
				style.bg_color = Color("342d40") if part == "background" else Color("aa90b8")
				style.set_corner_radius_all(2)
				progress.add_theme_stylebox_override(part, style)
			progress.mouse_filter = Control.MOUSE_FILTER_IGNORE
			ui.rect(progress, 14, 122, 188, 5, tile)
			ui.label_at("%d / %d" % [entry.progress, entry.target], 206, 106, 62, 30, 14, ui.MUTED, tile)
		if i == 0: _select(entry, tile)

func _select(entry: Dictionary, tile: Button) -> void:
	if is_instance_valid(selected): Buttons.decorate(selected, "wood_button")
	selected = tile
	selected.add_theme_stylebox_override("normal", Chrome.button(Color(1.3, 1.2, 1.45)))
	for child in detail.get_children():
		detail.remove_child(child)
		child.queue_free()
	_icon(_achievement_icon(entry), Rect2(82, 28, 136, 136), detail)
	ui.label_at(entry.name, 22, 180, 256, 66, 25, ui.GOLD, detail).horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	ui.label_at(entry.description, 24, 256, 252, 112, 20, ui.TEXT, detail).horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	var status = "Desbloqueado" if entry.unlocked else ("Logro secreto" if entry.secret else "Progreso: %d / %d" % [entry.progress, entry.target])
	ui.label_at(status, 24, 398, 252, 40, 19, ui.GOLD, detail).horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER

func _unlocks() -> void:
	var contents = _scroll(1208, ceil(snapshot.unlocks.size() / 3.0) * 172)
	for i in range(snapshot.unlocks.size()):
		var entry: Dictionary = snapshot.unlocks[i]
		var tile = _frame(Rect2((i % 3) * 396, (i / 3) * 172, 382, 158), contents)
		_icon(entry.icon, Rect2(18, 30, 78, 88), tile, Color.WHITE if entry.unlocked else Color(0.5, 0.5, 0.6))
		ui.label_at(entry.name, 110, 14, 252, 48, 22, ui.GOLD, tile)
		ui.label_at(entry.get("detail","DESBLOQUEADO") if entry.unlocked else entry.requirement, 110, 70, 252, 72, 18, ui.TEXT, tile)

func _history() -> void:
	var contents = _scroll(1208, maxf(478, snapshot.history.size() * 88))
	if snapshot.history.is_empty():
		var empty = _frame(Rect2(150, 110, 880, 170), contents)
		ui.label_at("Tu historia todavía está por escribirse.\nLos retornos de tus aventuras aparecerán aquí.", 30, 26, 820, 118, 24, ui.TEXT, empty).horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	for i in range(snapshot.history.size()):
		var entry: Dictionary = snapshot.history[i]
		var row = _frame(Rect2(0, i * 88, 1188, 76), contents)
		ui.button("Ver", 885, 18, 80, 38, func(): history_detail(entry), true, row)
		ui.label_at("VICTORIA" if entry.won else "RETORNO", 20, 14, 160, 48, 20, ui.GOLD if entry.won else ui.MUTED, row)
		ui.label_at(entry.party_names, 190, 14, 690, 48, 22, ui.TEXT, row)
		ui.label_at("%d salas" % entry.rooms, 980, 14, 180, 48, 20, ui.MUTED, row)

func history_detail(entry: Dictionary) -> void:
	var lines: Array[String] = [entry.party_names, "Semilla: %s · %d salas · piso %d" % [entry.get("seed", "?"), entry.rooms, entry.get("floor", 1)]]
	if not entry.get("killer", "").is_empty(): lines.append("Último golpe fatal: " + entry.killer)
	if entry.get("abandoned", false): lines.append("Aventura terminada voluntariamente.")

	var metrics: Dictionary = entry.get("telemetry", {})
	if not metrics.is_empty():
		lines.append("\nRegistro de combate:")
		for battle in metrics.battles:
			lines.append("Piso %d · sala %d · %d turnos · %d s · PV finales %s" % [battle.floor,battle.room+1,battle.turns,battle.seconds,str(battle.hp)])
		for kind in ["cards","picked","unused"]:
			lines.append({"cards":"Cartas jugadas", "picked":"Recompensas elegidas", "unused":"Cartas descartadas sin usar"}[kind]+":")
			for id in metrics.get(kind,{}): lines.append("  %s × %d" % [ui.game.content.cards.get(id,{"name":id}).name,metrics[kind][id]])
	lines.append("\nComponentes:")
	for id in entry.get("relics", []): lines.append(ui.game.content.relics.get(id, {"name":id}).name)
	lines.append("\nMazo final:")
	for card in entry.get("deck", []):
		if ui.game.content.cards.has(card.id):
			var variants = {"power":"Potencia", "efficient":"Eficiencia", "shared":"Amparo compartido"}
			var suffix = " · " + variants.get(card.get("upgrade_variant", "power"), "Mejora") if card.get("upgraded", false) else ""
			lines.append(ui.game.content.card(card).name + suffix)
	if not entry.has("deck"): lines.append("Esta aventura antigua solo conserva su resumen.")
	var labels = {"battles":"Combates", "elites":"Élites", "bosses":"Guardianes", "souls":"Celdas ganadas", "damage_taken":"Daño recibido", "fallen":"Caídas", "cards_removed":"Cartas retiradas"}
	for stat in entry.get("summary", {}).get("statistics", {}): lines.append(labels.get(stat, stat) + ": " + str(entry.summary.statistics[stat]))
	preload("res://src/ui/components/reading_dialog.gd").open(ui, "Historia del retorno", "\n".join(lines))
