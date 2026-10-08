extends RefCounted

# Generation only: existing saved rooms keep their original encounters.
static func choose(nodes: Array, room: Dictionary, count: int, config: Dictionary, usage: Dictionary, rng: RandomNumberGenerator) -> Array:
	var eligible: Array = config.common.filter(func(id): return room.stage >= int(config.get("min_stage", {}).get(id, 0)))
	for i in range(eligible.size() - 1, 0, -1):
		var j = rng.randi_range(0, i)
		var swap = eligible[i]
		eligible[i] = eligible[j]
		eligible[j] = swap
	var ancestors: Dictionary = {}
	var recent: Dictionary = {}
	var recent_formations: Array = []
	var pending: Array = [room.id]
	while not pending.is_empty():
		var child = pending.pop_front()
		for previous in nodes:
			if child not in previous.next or ancestors.has(previous.id): continue
			ancestors[previous.id] = true
			pending.append(previous.id)
	# Stop each reverse branch at its closest ordinary battle.
	var visited: Dictionary = {}
	pending = [room.id]
	while not pending.is_empty():
		var child = pending.pop_front()
		for previous in nodes:
			if child not in previous.next or visited.has(previous.id): continue
			visited[previous.id] = true
			if previous.kind == "combat":
				var formation: Array = previous.encounter.duplicate()
				formation.sort()
				recent_formations.append(formation)
				for id in previous.encounter: recent[id] = true
			else: pending.append(previous.id)
	var path_usage: Dictionary = {}
	for index in ancestors:
		for id in nodes[index].encounter:
			path_usage[id] = int(path_usage.get(id, 0)) + 1
	var chosen: Array = []
	var prefer_support = count >= 2 and room.stage >= 2 and rng.randf() < 0.6
	while chosen.size() < count and not eligible.is_empty():
		var best = ""
		var best_score = INF
		for id in eligible:
			if chosen.size() == count - 1:
				var formation: Array = chosen.duplicate()
				formation.append(id)
				formation.sort()
				if formation in recent_formations: continue
			var score = int(usage.get(id, 0)) * 2 + int(path_usage.get(id, 0)) * 4 + (100 if recent.has(id) else 0)
			var role = config.get("roles", {}).get(id, "attacker")
			if chosen.is_empty() and role == "attacker": score -= 3
			if chosen.size() == 1 and prefer_support and role in ["support", "protector"]: score -= 3
			if score < best_score:
				best = id
				best_score = score
		# Tiny custom rosters may have no alternative formation.
		if best.is_empty(): best = eligible[0]
		chosen.append(best)
		eligible.erase(best)
		usage[best] = int(usage.get(best, 0)) + 1
	return chosen
