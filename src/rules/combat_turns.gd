extends RefCounted
# Rules only. Game facade retains public API and owns checkpoints.
static func start(game: RefCounted) -> void:
	var battle = game.run.combat
	battle.turn += 1
	preload("res://src/rules/boss_mechanics.gd").new_turn(game)
	battle.energy = 3 if game.run.has("guided_lesson") else (99 if game.run.get("training", false) else game.turn_energy())
	for h in game.run.heroes:
		h.block = game.relic_bonus(h, "block") if h.hp > 0 else 0
		game.Modifiers.clear(h)
		if h.hp > 0:
			h.block += game.RunRelics.amount(game.run, game.content.relics, "turn_block")
			h.block += preload("res://src/rules/pet_companions.gd").opening_bonus(game.run, "opening_block")
			if battle.turn == 1: h.block += game.RunRelics.amount(game.run, game.content.relics, "start_block")
		if battle.turn == 1: h.block += int(game.run.get("event_flags", {}).get("pair_guard", 0))
		h.turn_strength = 0
		h.turn_magic = 0
	game.run.get("event_flags", {}).erase("pair_guard")
	for enemy in battle.enemies:
		if enemy.hp <= 0:
			continue
		game.Modifiers.clear(enemy)
		var intent = preload("res://src/rules/adventure_extensions.gd").intent(enemy, game.content.enemies[enemy.id], battle.turn, battle.enemies)
		var living = game.living_heroes()
		intent.target = living[game.rng.randi_range(0, living.size() - 1)]
		if enemy.get("risky", false): intent.damage += 2
		preload("res://src/rules/combat_depth.gd").plan(game, enemy, intent)
		preload("res://src/rules/boss_mechanics.gd").plan(game, enemy, intent)
		preload("res://src/rules/enemy_coordination.gd").plan(game, enemy, intent)
		if game.run.get("training", false): intent = preload("res://src/rules/training_config.gd").intent(game, enemy, intent)
		if game.run.has("guided_lesson"): intent.target = 0
		enemy.intent = intent
	preload("res://src/rules/combat_depth.gd").release(game)
	var ended = game._check_combat_end()
	# A source revival after release belongs to the same prepared-action replay.
	for event in game.resolved_card_hits:
		if event.kind == "revive": game.resolved_prepared_hits.append(event)
	if ended: return
	preload("res://src/rules/card_reserve.gd").restore(game)
	game._draw(6 + preload("res://src/rules/pet_companions.gd").opening_bonus(game.run, "opening_draw") + (game.RunRelics.amount(game.run, game.content.relics, "opening_draw") if battle.turn == 1 else 0))


static func end(game: RefCounted) -> bool:
	game.resolved_prepared_hits.clear()
	game.resolved_card_hits.clear()
	game.resolved_enemy_attacks.clear()
	game.resolved_enemy_blocks.clear()
	game.resolved_hero_defenses.clear()
	game.resolved_hero_blocks.clear()
	game.resolved_enemy_hits.clear()
	game.resolved_poison_hits.clear()
	if game.run.is_empty() or game.run.phase != "combat":
		return false
	var b = game.run.combat
	preload("res://src/rules/adventure_choices.gd").end_turn(game)
	preload("res://src/rules/combat_telemetry.gd").unused(game, b.hand)
	b.discard.append_array(b.hand)
	b.hand.clear()
	# Poison ticks simultaneously before enemy actions, bypassing block.
	for enemy_index in range(b.enemies.size()):
		var enemy = b.enemies[enemy_index]
		if enemy.hp > 0 and enemy.poison > 0:
			var hp_before: int = enemy.hp
			game._damage(enemy, enemy.poison, true)
			game.resolved_poison_hits[enemy_index] = {"hp": enemy.hp, "lost": hp_before - enemy.hp}
			enemy.poison = maxi(0, enemy.poison - 1)
	if game._check_combat_end():
		return true
	# Clear last turn's guard before any protector grants allied guard.
	for enemy in b.enemies: enemy.block = 0
	for enemy_index in range(b.enemies.size()):
		var enemy = b.enemies[enemy_index]
		if enemy.hp <= 0:
			continue
		var intent = preload("res://src/rules/enemy_coordination.gd").intent(game, enemy)
		preload("res://src/rules/boss_mechanics.gd").action(game, enemy, intent)
		game.run.attacker_name = game.content.enemies[enemy.id].name
		preload("res://src/rules/combat_depth.gd").action(game, enemy, intent)
		if game.living_heroes().is_empty():
			game._finish(false)
			return true
		var health_before: int = game.run.heroes.reduce(func(total, hero): return total + int(hero.hp), 0)
		if int(intent.get("damage", 0)) > 0:
			game.resolved_enemy_attacks.append(enemy_index)
		preload("res://src/rules/adventure_extensions.gd").role_support(game, enemy_index, intent)
		enemy.block += int(intent.get("block", 0))
		if int(intent.get("block", 0)) > 0: game._log("%s obtiene %d de bloqueo." % [game.content.enemies[enemy.id].name, intent.block])
		game.resolved_enemy_blocks[enemy_index] = enemy.block
		var targets = game.living_heroes() if intent.get("all", false) else [intent.target]
		if not intent.get("all", false) and game.run.heroes[targets[0]].hp <= 0:
			targets = [game.living_heroes()[0]]
		for i in targets:
			var block_before: int = game.run.heroes[i].block
			var hp_before: int = game.run.heroes[i].hp
			game._damage(game.run.heroes[i], int(intent.damage))
			if int(intent.damage) > 0:
				if not game.resolved_enemy_hits.has(enemy_index): game.resolved_enemy_hits[enemy_index] = []
				game.resolved_enemy_hits[enemy_index].append({"owner":i,"hp":game.run.heroes[i].hp,"block":game.run.heroes[i].block,"damage":int(intent.damage),"absorbed":block_before-game.run.heroes[i].block,"lost":maxi(0,hp_before-game.run.heroes[i].hp)})
				if not game.resolved_hero_blocks.has(enemy_index): game.resolved_hero_blocks[enemy_index] = {}
				game.resolved_hero_blocks[enemy_index][i] = game.run.heroes[i].block
			if game.run.heroes[i].block < block_before:
				if not game.resolved_hero_defenses.has(enemy_index):
					game.resolved_hero_defenses[enemy_index] = []
				game.resolved_hero_defenses[enemy_index].append(i)
		if enemy.get("modifier", "") == "vampiric" and game.run.heroes.reduce(func(total, hero): return total + int(hero.hp), 0) < health_before: enemy.hp = mini(enemy.max_hp, enemy.hp + 3)
		game._log("%s ataca por %d." % [game.content.enemies[enemy.id].name, intent.damage])
		if game.living_heroes().is_empty():
			game._finish(false)
			return true
	game._remove_inactive()
	game._start_turn()
	return true
