extends Control
# Selection is temporary UI state; only confirmation invokes the game action.
var ui: Control
var selected = -1
var variant = "power"
var branches: Array[Button] = []
var cards: Array = []
var contents: Control
var confirm: Button

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	cards = ui.game.run.deck.duplicate(true)
	ui.panel(20, 12, 1240, 116, ui.GOLD, self)
	ui.label_at("Templar una carta", 36, 32, 950, 44, 30, ui.TEXT, self)
	ui.button("Menú", 1134, 30, 110, 48, ui.pause_menu, true, self)
	ui.label_at("Elegí una carta y su mejora.", 36, 89, 350, 38, 17, ui.TEXT, self)
	var scroll = ScrollContainer.new()
	ui.rect(scroll, 36, 140, 1208, 485, self)
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	contents = Control.new()
	contents.custom_minimum_size = Vector2(1180, ceil(cards.size() / 4.0) * 368)
	scroll.add_child(contents)
	confirm = ui.button("Mejorar", 920, 646, 324, 54, commit, false, self)
	confirm.name = "ConfirmUpgrade"
	ui.button("Volver", 36, 646, 230, 54, func():
		ui.screen = ui.return_screen
		ui.upgrade_mode = false
		ui.render(), true, self)
	for i in range(2):
		var choice = ui.button("", 400 + i * 265, 82, 255, 42, func(): choose_branch(i), true, self)
		branches.append(choice)
	refresh()

func refresh() -> void:
	for child in contents.get_children():
		contents.remove_child(child)
		child.queue_free()
	for i in range(cards.size()):
		var preview = cards[i].duplicate(true)
		if i == selected:
			preview.upgraded = true
			preview.upgrade_variant = variant
		var card = ui.card_panel(preview, (i % 4) * 296, (i / 4) * 368, 280, 350,
			func(): select(i), false, not cards[i].upgraded, contents)
		card.name = "UpgradeCard%d" % i
		card.set_meta("upgrade_preview", i == selected)
		if i == selected:
			var glow = TextureRect.new()
			glow.name = "UpgradeGlow"
			glow.texture = load("res://assets/cards/frames/%s.png" % ui.game.content.cards[preview.id].owner)
			glow.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
			glow.size = card.size
			glow.mouse_filter = Control.MOUSE_FILTER_IGNORE
			var material = ShaderMaterial.new()
			material.shader = preload("res://assets/shaders/card_link_glow.gdshader")
			material.set_shader_parameter("intensity", 0.3)
			material.set_shader_parameter("halo_width", 8.0)
			glow.material = material
			glow.modulate.a = 0.25
			card.add_child(glow)
			card.modulate = Color(1.15, 1.12, 1.02)
	confirm.disabled = selected < 0
	for i in range(branches.size()):
		branches[i].visible = selected >= 0
		if selected < 0: continue
		var choice = preload("res://src/rules/card_upgrades.gd").choices(ui.game.content.cards[cards[selected].id])[i]
		branches[i].text = choice.name
		branches[i].tooltip_text = choice.description
		branches[i].disabled = choice.id == variant

func select(index: int) -> void:
	if cards[index].upgraded: return
	selected = index
	variant = "power"
	refresh()

func choose_branch(index: int) -> void:
	if selected < 0: return
	variant = preload("res://src/rules/card_upgrades.gd").choices(ui.game.content.cards[cards[selected].id])[index].id
	refresh()

func commit() -> void:
	if selected < 0: return
	confirm.disabled = true
	ui.audio.play_sfx("upgrade")
	ui.act(func(): ui.game.rest(false, selected, variant))
