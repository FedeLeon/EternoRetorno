extends RefCounted
# Derives opportunities from the current hand. No mutation or persistence.
static func available(run: Dictionary, recipes: Array) -> Array:
	var result: Array = []
	if run.is_empty() or run.phase != "combat" or run.heroes.any(func(h): return h.hp <= 0):
		return result
	var hand = run.combat.hand
	for recipe in recipes:
		if not recipe.heroes.all(func(id): return id in run.party): continue
		var indices: Array = []
		for id in recipe.cards:
			var found = -1
			for i in range(hand.size()):
				if hand[i].id == id and i not in indices:
					found = i
					break
			if found >= 0: indices.append(found)
		if indices.size() != 2: continue
		var combo = recipe.duplicate(true)
		combo.indices = indices
		for index in indices:
			if hand[index].get("upgraded", false): combo.damage += 3
		result.append(combo)
	return result
