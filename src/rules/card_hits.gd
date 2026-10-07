extends RefCounted
# Ordered, transient impact receipts. Game owns damage calculation and checkpoint.
static func resolve(game: RefCounted, card: Dictionary, owner: int, targets: Array) -> Array:
	var events: Array = []
	var hero = game.run.heroes[owner]
	for index in targets:
		var enemy = game.run.combat.enemies[index]
		if card.get("interrupt", false): preload("res://src/rules/combat_depth.gd").interrupt(game, enemy)
		for hit in range(int(card.hits)):
			if enemy.hp <= 0 or hero.hp <= 0: break
			if card.damage <= 0: continue
			var damage = int(card.damage) + (1 if "fang" in game.run.relics else 0)
			if not preload("res://src/rules/combat_depth.gd").root_hit(game, enemy, damage): game._damage(enemy, damage, card.pierce)
			events.append({"kind":"hit", "hit_index":hit, "enemy":index, "owner":owner, "hp":enemy.hp, "block":enemy.block, "damage":damage})
			if enemy.hp > 0 and int(enemy.intent.get("counter", 0)) > 0:
				game.run.attacker_name = game.content.enemies[enemy.id].name + " (contraataque)"
				game._damage(hero, 4)
				events.append({"kind":"counter", "enemy":index, "owner":owner, "hp":hero.hp, "block":hero.block, "damage":4})
		if hero.hp > 0 and enemy.hp > 0:
			enemy.poison += int(card.poison)
	return events
