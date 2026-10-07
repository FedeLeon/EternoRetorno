extends RefCounted
# Validation and rules only; checkpoint belongs to Game.
static func play(game: RefCounted, hand_index: int, target: int) -> bool:
	game.resolved_card_hits.clear()
	if target not in game.valid_targets(hand_index):
		return false
	var b = game.run.combat
	var instance = b.hand[hand_index]
	var c = game.effective_card(instance)
	var owner = game.owner_index(instance)
	b.energy -= int(c.cost)
	b.hand.remove_at(hand_index)
	b.discard.append(instance)
	var enemy_targets: Array = []
	var ally_targets: Array = []
	match c.target:
		"enemy":
			enemy_targets = [target]
			ally_targets = [owner]
		"all_enemies":
			for i in range(b.enemies.size()):
				if b.enemies[i].hp > 0:
					enemy_targets.append(i)
		"ally": ally_targets = [target]
		"all_allies": ally_targets = game.living_heroes()
		"self": ally_targets = [owner]
	for i in enemy_targets: game.Modifiers.debuff(b.enemies[i], c)
	if c.get("charge", false):
		preload("res://src/rules/combat_depth.gd").prepare(game, c, owner, enemy_targets)
	else:
		game.resolved_card_hits = preload("res://src/rules/card_hits.gd").resolve(game, c, owner, enemy_targets)
	for i in ally_targets:
		var hero = game.run.heroes[i]
		if hero.hp <= 0: continue
		var hp_before: int = hero.hp
		game.Modifiers.empower(hero, c)
		hero.block += int(c.block)
		hero.hp = mini(hero.max_hp, hero.hp + int(c.heal))
		if int(c.block) > 0 or hero.hp > hp_before:
			game._log("%s: +%d bloqueo, +%d PV." % [game.content.heroes[hero.id].name, c.block, hero.hp-hp_before])
	game._log("%s: %s." % [game.content.heroes[game.run.party[owner]].name, c.name])
	game._check_combat_end()
	return true
