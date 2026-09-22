extends RefCounted
# Card reward composition. Selection still resolves and saves through game.
static func build(ui: Control) -> void:
	var background = TextureRect.new()
	background.name = "RewardBackground"
	background.texture = preload("res://assets/reward/background.png")
	background.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	background.mouse_filter = Control.MOUSE_FILTER_IGNORE
	ui.rect(background, 0, 0, 1280, 720)
	var hud = ui.CombatHUD.new()
	hud.name = "CombatHUD"
	hud.turn = ui.game.run.combat.get("turn", 1)
	hud.show_energy = false
	hud.relics = ui.equipped_relics()
	hud.equipment = preload("res://src/presentation/equipment_badges.gd").entries(ui.game.run.heroes, ui.game.content.heroes)
	hud.deck_requested.connect(ui.open_deck)
	hud.menu_requested.connect(ui.pause_menu)
	hud.bag_requested.connect(func(): ui.selected_item = ""; ui.screen = "items"; ui.render())
	hud.relic_requested.connect(func(index): hud.show_relic(index))
	ui.rect(hud, 0, 0, 1280, 720)
	ui.label_at("Un eco para tu mazo", 160, 78, 960, 44, 30, ui.GOLD).horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	ui.label_at("Elegí una carta para continuar", 160, 120, 960, 30, 18, ui.TEXT).horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	var count = ui.game.run.reward.size()
	var width = 248.0
	var gap = 40.0
	var left = (1280 - count * width - maxi(0, count - 1) * gap) / 2.0
	var relic_id = ui.game.run.get("reward_relic", "")
	if ui.game.content.relics.has(relic_id):
		preload("res://src/ui/components/elite_relic_reward.gd").build(ui, ui.game.content.relics[relic_id])
		gap = 20.0
		left = 418.0 + (838.0 - count * width - maxi(0, count - 1) * gap) / 2.0
	for i in range(count):
		var card = ui.card_panel(ui.game.run.reward[i], left + i * (width + gap), 160, width, 414, func(): ui.act(func(): ui.game.choose_reward(i)))
		card.name = "RewardCard%d" % i
	ui.button("Saltar recompensa", 461, 605, 358, 54, func(): ui.act(func(): ui.game.choose_reward(-1)))
	if not ui.game.run.new_unlocks.is_empty():
		ui.label_at("Nuevo eco: " + ", ".join(ui.game.run.new_unlocks), 80, 663, 1110, 27, 17, ui.GOLD).horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
