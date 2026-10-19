extends RefCounted
# Combat view composition; uses controller helpers during the UI migration.
static func build(ui: Control) -> void:
	var b = ui.game.run.combat
	var layout = preload("res://src/ui/components/combat_layout.gd")
	var ground = layout.ground_for(ui)
	var hero_ground = layout.hero_ground_for(ui, ground)
	var top = layout.TOP
	var hud = ui.CombatHUD.new()
	hud.item_count = ui.game.run.get("inventory", {}).values().reduce(func(total, amount): return total + maxi(0, int(amount)), 0)
	hud.name = "CombatHUD"
	hud.turn = b.turn
	hud.energy = b.energy
	hud.show_journal = true
	hud.journal_requested.connect(func(): preload("res://src/ui/components/tactical_badges.gd").open_journal(ui))
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
	if ui.game.run.has("guided_lesson"): preload("res://src/ui/guided_practice_navigation.gd").build(ui)
	elif ui.game.run.get("training", false): preload("res://src/ui/training_navigation.gd").toolbar(ui)
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
		var target = ui.button("", x, top, 204, 348, func(): ui.target_clicked(i), valid)
		target.name = "HeroTarget%d" % i
		ui.combat_target_style(target)
		if valid and ui.selected_card >= 0:
			target.tooltip_text = preload("res://src/rules/combat_preview.gd").describe(ui.game, ui.selected_card, i)
		var visual = preload("res://src/presentation/detailed_hero.gd").new()
		visual.hero_id = h.id
		visual.gear = h.get("forge", {})
		ui.rect(visual, 4, ground - top - 164, 196, 164, target)
		preload("res://src/ui/components/combat_actor_scale.gd").hero(visual, h.id)
		visual.scale *= minf(1.0, (ground - 112) / preload("res://src/ui/components/combat_actor_scale.gd").HERO_HEIGHT)
		layout.place_hero(visual, hero_ground)
		ui.TargetGlow.attach(visual, valid)
		ui.hero_art[i] = visual
		var hero_effects = preload("res://src/ui/components/battle_effect_snapshot.gd").hero(ui.game, i)
		if h.id in ui.BATTLE_HEROES:
			visual.set_fallen(h.hp <= 0)
		ui.hero_health[i] = preload("res://src/ui/components/combat_vitals.gd").build(ui, target, h, hero_effects, hero_ground)
	for i in range(b.enemies.size()):
		var e = b.enemies[i]
		var def = ui.game.content.enemies[e.id]
		var x = (570 + i * 226) if b.enemies.size() >= 3 else (768 + i * 234 if b.enemies.size() > 1 else 884)
		var valid = not c.is_empty() and c.target in ["enemy", "all_enemies"] and i in targets
		var target = ui.button("", x, top, 214, 348, func():
			if c.is_empty(): preload("res://src/ui/components/enemy_inspection.gd").open(ui, i)
			else: ui.target_clicked(i), valid or (c.is_empty() and e.hp > 0))
		target.name = "EnemyTarget%d" % i
		ui.combat_target_style(target)
		if valid and ui.selected_card >= 0:
			target.tooltip_text = preload("res://src/rules/combat_preview.gd").describe(ui.game, ui.selected_card, i)
		var enemy_visual = ui.EnemySprite.new()
		enemy_visual.set_meta("battle_enemy_id", e.id)
		enemy_visual.visual_id = def.visual
		enemy_visual.fallen = e.hp <= 0
		ui.rect(enemy_visual, 43, ground - top - 132, 128, 132, target)
		if ui.game.run.get("training", false) and ui.game.run.get("training_config",{}).get("enemies",[]).is_empty():
			enemy_visual.replace_illustration(preload("res://assets/combat_depth/dummy.png"))
		preload("res://src/ui/components/combat_actor_scale.gd").enemy(enemy_visual)
		preload("res://src/ui/components/combat_actor_scale.gd").fit_enemy(enemy_visual, ground - 126, 220.0 if b.enemies.size() > 1 else 440.0)
		ui.TargetGlow.attach(enemy_visual, valid)
		ui.enemy_art[i] = enemy_visual
		var cables = preload("res://src/ui/components/tactical_badges.gd").enemy(ui, target, e)
		var enemy_effects = preload("res://src/ui/components/battle_effect_snapshot.gd").enemy(ui.game, i)
		target.tooltip_text = target.tooltip_text if not target.tooltip_text.is_empty() else "Tocá para inspeccionar"
		var health = preload("res://src/ui/components/combat_vitals.gd").build(ui, target, e, enemy_effects, ground, true)
		ui.enemy_health[i] = health
		if cables != null:
			cables.visible = e.hp > 0
			health.value_changed.connect(func(hp): cables.visible = hp > 0)
		if e.hp > 0:
			var intent_view = ui.EnemyIntent.new()
			intent_view.name = "EnemyIntent%d" % i
			intent_view.intent = preload("res://src/rules/enemy_coordination.gd").intent(ui.game, e)
			intent_view.heroes = ui.game.run.heroes.duplicate(true)
			intent_view.ui = ui
			ui.rect(intent_view, x, layout.INTENT_TOP, 214, layout.INTENT_ROW_HEIGHT)
			health.value_changed.connect(func(hp): intent_view.visible = hp > 0)

	if ui.selected_card >= 0 and ui.selected_card < b.hand.size() and ui.game.available_synergies().is_empty():
		ui.SynergyView.hint(ui, b.hand[ui.selected_card].id, ui.game.content.synergies, ui.game.run.party, ui.game.content.cards)
	ui.SynergyView.build(ui, ui.game.available_synergies(), ui.selected_synergy, b.energy, ui.game.content.cards, func(id):
		ui.selected_synergy = "" if ui.selected_synergy == id else id
		ui.selected_card = -1
		ui.render())
	preload("res://src/ui/components/combat_hand.gd").build(ui)
	var end_turn = ui.button("Terminar\nturno", 1120, 568, 136, 136, func(): ui.animate_combat_action())
	preload("res://src/ui/components/end_turn_button.gd").decorate(end_turn)
