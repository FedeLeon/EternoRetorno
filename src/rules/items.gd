extends RefCounted
# Consumable targets and effects; caller owns the checkpoint.
static func targets(game: RefCounted, id: String) -> Array:
	if game.run.is_empty() or game.run.phase != "combat" or not game.content.items.has(id) or game.run.get("inventory", {}).get(id, 0) <= 0:
		return []
	var target = game.content.items[id].target
	if target == "team":
		return [0]
	var result: Array = []
	if target == "enemy":
		for i in range(game.run.combat.enemies.size()):
			if game.run.combat.enemies[i].hp > 0:
				result.append(i)
	else:
		for i in range(game.run.heroes.size()):
			var hero = game.run.heroes[i]
			if target == "fallen" and hero.hp <= 0:
				result.append(i)
			elif hero.hp > 0 and (target == "living" or (target == "caster" and hero.id in ["mage", "cleric"])):
				result.append(i)
	return result

static func apply(game: RefCounted, id: String, target: int) -> bool:
	if target not in targets(game, id):
		return false
	var item = game.content.items[id]
	var value = int(item.value)
	match item.effect:
		"energy": game.run.combat.energy += value
		"draw": game._draw(value)
		"poison": game.run.combat.enemies[target].poison += value
		"heal": game.run.heroes[target].hp = mini(game.run.heroes[target].max_hp, game.run.heroes[target].hp + value)
		"block": game.run.heroes[target].block += value
		"strength": game.run.heroes[target].turn_strength = int(game.run.heroes[target].get("turn_strength", 0)) + value
		"magic": game.run.heroes[target].turn_magic = int(game.run.heroes[target].get("turn_magic", 0)) + value
		"revive":
			game.run.heroes[target].hp = maxi(1, int(ceil(game.run.heroes[target].max_hp * value / 100.0)))
			var inactive = game.run.combat.inactive
			for i in range(inactive.size() - 1, -1, -1):
				if game.owner_index(inactive[i]) == target:
					game.run.combat.discard.append(inactive[i])
					inactive.remove_at(i)
	game.run.inventory[id] -= 1
	game._log("Usaste " + item.name + ".")
	return true
