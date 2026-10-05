extends Control
# Selection is temporary UI state; only confirmation invokes the game action.
var ui: Control
var selected = -1
var cards: Array = []
var contents: Control
var confirm: Button

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	cards = ui.game.run.deck.duplicate(true)
	ui.header("Templar una carta", "Elegí una carta para ver su mejora y confirmá con Mejorar.")
	var scroll = ScrollContainer.new()
	ui.rect(scroll, 36, 140, 1208, 485, self)
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	contents = Control.new()
	contents.custom_minimum_size = Vector2(1180, ceil(cards.size() / 5.0) * 260)
	scroll.add_child(contents)
	confirm = ui.button("Mejorar", 920, 646, 324, 54, commit, false, self)
	confirm.name = "ConfirmUpgrade"
	ui.button("Volver", 36, 646, 230, 54, func():
		ui.screen = ui.return_screen
		ui.upgrade_mode = false
		ui.render(), true, self)
	refresh()

func refresh() -> void:
	for child in contents.get_children():
		contents.remove_child(child)
		child.queue_free()
	for i in range(cards.size()):
		var preview = cards[i].duplicate(true)
		if i == selected: preview.upgraded = true
		var card = ui.card_panel(preview, (i % 5) * 238, (i / 5) * 260, 224, 244,
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
			glow.material = material
			card.add_child(glow)
			card.modulate = Color(1.15, 1.12, 1.02)
	confirm.disabled = selected < 0

func select(index: int) -> void:
	if cards[index].upgraded: return
	selected = index
	refresh()

func commit() -> void:
	if selected < 0: return
	confirm.disabled = true
	ui.audio.play_sfx("upgrade")
	ui.act(func(): ui.game.rest(false, selected))
