extends RefCounted
# Rules only. Game facade retains public API and owns checkpoints.
static func start(game: RefCounted) -> void:
	var battle = game.run.combat
	battle.turn += 1
	battle.energy = game.turn_energy()
	for h in game.run.heroes:
		h.block = game.relic_bonus(h, "block") if h.hp > 0 else 0
		game.Modifiers.clear(h)
		if h.hp > 0:
			h.block += game.RunRelics.amount(game.run, game.content.relics, "turn_block")
			if battle.turn == 1: h.block += game.RunRelics.amount(game.run, game.content.relics, "start_block")
		h.turn_strength = 0
		h.turn_magic = 0
	for enemy in battle.enemies:
		if enemy.hp <= 0:
			continue
		game.Modifiers.clear(enemy)
		var intent = preload("res://src/rules/adventure_extensions.gd").intent(enemy, game.content.enemies[enemy.id], battle.turn, battle.enemies)
		var living = game.living_heroes()
		intent.target = living[game.rng.randi_range(0, living.size() - 1)]
		enemy.intent = intent
	game._draw(6 + (game.RunRelics.amount(game.run, game.content.relics, "opening_draw") if battle.turn == 1 else 0))


static func end(game: RefCounted) -> bool:
	game.resolved_enemy_attacks.clear()
	game.resolved_enemy_blocks.clear()
	game.resolved_hero_defenses.clear()
	game.resolved_hero_blocks.clear()
	if game.run.is_empty() or game.run.phase != "combat":
		return false
	var b = game.run.combat
	b.discard.append_array(b.hand)
	b.hand.clear()
	# Poison ticks simultaneously before enemy actions, bypassing block.
	for enemy in b.enemies:
		if enemy.hp > 0 and enemy.poison > 0:
			game._damage(enemy, enemy.poison, true)
			enemy.poison = maxi(0, enemy.poison - 1)
	if game._check_combat_end():
		return true
	# Clear last turn's guard before any protector grants allied guard.
	for enemy in b.enemies: enemy.block = 0
	for enemy_index in range(b.enemies.size()):
		var enemy = b.enemies[enemy_index]
		if enemy.hp <= 0:
			continue
		var intent = game.Modifiers.intent(enemy)
		if int(intent.get("damage", 0)) > 0:
			game.resolved_enemy_attacks.append(enemy_index)
		preload("res://src/rules/adventure_extensions.gd").role_support(game, enemy_index, intent)
		enemy.block += int(intent.get("block", 0))
		game.resolved_enemy_blocks[enemy_index] = enemy.block
		var targets = game.living_heroes() if intent.get("all", false) else [intent.target]
		if not intent.get("all", false) and game.run.heroes[targets[0]].hp <= 0:
			targets = [game.living_heroes()[0]]
		for i in targets:
			var block_before: int = game.run.heroes[i].block
			game._damage(game.run.heroes[i], int(intent.damage))
			if int(intent.damage) > 0:
				if not game.resolved_hero_blocks.has(enemy_index): game.resolved_hero_blocks[enemy_index] = {}
				game.resolved_hero_blocks[enemy_index][i] = game.run.heroes[i].block
			if game.run.heroes[i].block < block_before:
				if not game.resolved_hero_defenses.has(enemy_index):
					game.resolved_hero_defenses[enemy_index] = []
				game.resolved_hero_defenses[enemy_index].append(i)
		game._log("%s ataca por %d." % [game.content.enemies[enemy.id].name, intent.damage])
		if game.living_heroes().is_empty():
			game._finish(false)
			return true
	game._remove_inactive()
	game._start_turn()
	return true

