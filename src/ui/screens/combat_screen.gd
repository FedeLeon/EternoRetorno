extends RefCounted
# Combat view composition; uses controller helpers during the UI migration.
static func build(ui: Control) -> void:
	var b = ui.game.run.combat
	var hud = ui.CombatHUD.new()
	hud.item_count = ui.game.run.get("inventory", {}).values().reduce(func(total, amount): return total + maxi(0, int(amount)), 0)
	hud.name = "CombatHUD"
	hud.turn = b.turn
	hud.energy = b.energy
	hud.relics = ui.equipped_relics()
	hud.equipment = preload("res://src/presentation/equipment_badges.gd").entries(ui.game.run.heroes, ui.game.content.heroes)
	hud.bag_requested.connect(func():
		if not ui.combat_busy:
			ui.audio.play_sfx("bag", -5)
			ui.selected_item = ""; ui.screen = "items"; ui.render())
	hud.menu_requested.connect(func():
		if not ui.combat_busy: ui.pause_menu())
	hud.deck_requested.connect(func():
		if not ui.combat_busy: ui.open_deck())
	hud.relic_requested.connect(func(index):
		if not ui.combat_busy:
			hud.show_relic(index))
	ui.rect(hud, 0, 0, 1280, 720)
	var targets: Array = []
	var c: Dictionary = {}
	if ui.selected_card >= 0 and ui.selected_card < b.hand.size():
		c = ui.game.content.card(b.hand[ui.selected_card])
		targets = ui.game.valid_targets(ui.selected_card)
	if ui.selected_synergy != "":
		c = {"target": "enemy"}
		targets = ui.game.synergy_targets(ui.selected_synergy)
	for i in range(2):
		var h = ui.game.run.heroes[i]
		var x = 80 + i * 234
		var valid = not c.is_empty() and c.target in ["self", "ally", "all_allies"] and i in targets
		var target = ui.button("", x, 150, 204, 348, func(): ui.target_clicked(i), valid)
		target.name = "HeroTarget%d" % i
		ui.combat_target_style(target)
		if valid and ui.selected_card >= 0:
			target.tooltip_text = preload("res://src/rules/combat_preview.gd").describe(ui.game, ui.selected_card, i)
		var visual = ui.art(h.id, 30, 123, 144, 136, target, h.get("forge", {}))
		preload("res://src/ui/components/combat_actor_scale.gd").hero(visual, h.id)
		ui.TargetGlow.attach(visual, valid)
		ui.hero_art[i] = visual
		if h.id in ui.ANIMATED_HEROES:
			visual.set_fallen(h.hp <= 0)
		ui.hero_health[i] = ui.health_bar(h, 16, 20, 172, target)
		preload("res://src/ui/components/combat_modifier_badges.gd").attach(target, h, Rect2(54, 53, 184, 28))
		if h.hp > 0:
			var effects = ui.StatusEffects.new()
			effects.unit = h
			effects.show_backplates = true
			effects.block_position = Vector2(-15, 30)
			ui.rect(effects, 10, -17, 184, 28, target)
		else:
			ui.label_at("Vuelve si ganás", 10, -17, 184, 24, 16, Color("9cbacb"), target).horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	for i in range(b.enemies.size()):
		var e = b.enemies[i]
		var def = ui.game.content.enemies[e.id]
		var x = (570 + i * 226) if b.enemies.size() >= 3 else (768 + i * 234 if b.enemies.size() > 1 else 884)
		var valid = not c.is_empty() and c.target in ["enemy", "all_enemies"] and i in targets
		var target = ui.button("", x, 150, 214, 348, func(): ui.target_clicked(i), valid)
		target.name = "EnemyTarget%d" % i
		ui.combat_target_style(target)
		if valid and ui.selected_card >= 0:
			target.tooltip_text = preload("res://src/rules/combat_preview.gd").describe(ui.game, ui.selected_card, i)
		var enemy_visual = ui.EnemySprite.new()
		enemy_visual.visual_id = def.visual
		enemy_visual.fallen = e.hp <= 0
		ui.rect(enemy_visual, 43, 130, 128, 132, target)
		preload("res://src/ui/components/combat_actor_scale.gd").enemy(enemy_visual)
		ui.TargetGlow.attach(enemy_visual, valid)
		ui.enemy_art[i] = enemy_visual
		var name_plate = preload("res://src/ui/components/combat_backplate.gd").attach(target, Rect2(3, -66, 208, 28))
		var caption: String = def.name + (" · Fase II" if e.get("enraged", false) else "")
		var enemy_name = ui.label_at(caption, 7, -65, 200, 26, 12 if caption.length() > 26 else 14, ui.TEXT, target)
		enemy_name.name = "EnemyName"
		enemy_name.tooltip_text = {"protector":"Protector: al actuar da 3 de bloqueo a sus aliados.","support":"Apoyo: al actuar cura 3 PV a sus aliados vivos.","attacker":"Atacante: observá su intención antes de jugar."}.get(def.get("role", "attacker"), "")
		if target.tooltip_text.is_empty(): target.tooltip_text = enemy_name.tooltip_text
		enemy_name.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		var crowded = b.enemies.size() >= 3
		ui.enemy_health[i] = ui.health_bar(e, 66 if crowded else 16, 20, 142 if crowded else 182, target)
		var health = ui.enemy_health[i]
		var update_visibility = func(hp: int):
			health.visible = hp > 0
			enemy_name.visible = hp > 0
			name_plate.visible = hp > 0
		health.value_changed.connect(update_visibility)
		update_visibility.call(e.hp)
		preload("res://src/ui/components/combat_modifier_badges.gd").attach(target, e, Rect2(20, 88 if e.get("poison", 0) > 0 else 53, 184, 28))
		var effects = ui.StatusEffects.new()
		effects.unit = e
		effects.block_position = Vector2(38 if crowded else -12, 33)
		effects.poison_position = Vector2(62, 73)
		ui.rect(effects, 7, -20, 200, 28, target)
		if e.hp > 0:
			var intent_view = ui.EnemyIntent.new()
			intent_view.name = "EnemyIntent%d" % i
			intent_view.intent = preload("res://src/rules/combat_modifiers.gd").intent(e)
			intent_view.heroes = ui.game.run.heroes.duplicate(true)
			ui.rect(intent_view, x - 12, 125, 240, 42)

	if ui.selected_card >= 0 and ui.selected_card < b.hand.size() and ui.game.available_synergies().is_empty():
		ui.SynergyView.hint(ui, b.hand[ui.selected_card].id, ui.game.content.synergies, ui.game.run.party, ui.game.content.cards)
	ui.SynergyView.build(ui, ui.game.available_synergies(), ui.selected_synergy, b.energy, ui.game.content.cards, func(id):
		ui.selected_synergy = "" if ui.selected_synergy == id else id
		ui.selected_card = -1
		ui.render())
	var count = b.hand.size()
	var scroll = ScrollContainer.new()
	scroll.name = "CombatHand"
	ui.rect(scroll, 160, 350, 954, 370)
	scroll.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_AUTO
	var contents = Control.new()
	contents.custom_minimum_size = Vector2(ui.HandLayout.content_width(count), 370)
	scroll.add_child(contents)
	scroll.set_deferred("scroll_horizontal", ui.hand_scroll)
	var drag = preload("res://src/ui/components/card_drag.gd").install(ui)
	for i in range(count):
		var card = ui.card_panel(b.hand[i], 0, 0, 218 if i == ui.selected_card else 174, 278, func(): ui.select_card(i), i == ui.selected_card, not ui.game.valid_targets(i).is_empty(), contents)
		# Inspection is always allowed; valid_targets/play_card still gate playing.
		card.disabled = false
		ui.HandLayout.arrange(card, i, count, i == ui.selected_card)
		drag.bind(card, i)
	if count == 0:
		ui.label_at("Terminá el turno para robar cartas.", 380, 590, 640, 70, 24, ui.MUTED)
	var end_turn = ui.button("Terminar\nturno", 1120, 568, 136, 136, func(): ui.animate_combat_action())
	preload("res://src/ui/components/end_turn_button.gd").decorate(end_turn)
