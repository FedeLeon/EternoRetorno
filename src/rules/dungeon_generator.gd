extends RefCounted
# Seeded layered DAG: every room is reachable, all routes reach the later elite and boss.
static func shuffle(values: Array, rng: RandomNumberGenerator) -> void:
	for i in range(values.size() - 1, 0, -1):
		var j = rng.randi_range(0, i)
		var swap = values[i]
		values[i] = values[j]
		values[j] = swap

static func create(rng: RandomNumberGenerator, floor_number: int, config: Dictionary) -> Array:
	var widths: Array = [1, 3, 2, 3, 1, 3, 2, 3, 1, 3, 2, 3, 1]
	for start in [5, 9]:
		var group: Array = widths.slice(start, start + 3)
		shuffle(group, rng)
		for i in range(3): widths[start + i] = group[i]
	if rng.randf() < 0.5:
		widths[2] = 3
		widths[3] = 2
	var pool: Array = []
	# Same room inventory as the previous 28-room floor.
	for entry in [["combat",12],["rest",6],["event",4],["treasure",2]]:
		for i in range(entry[1]): pool.append(entry[0])
	shuffle(pool, rng)
	var nodes: Array = []
	var layers: Array = []
	for stage in range(widths.size()):
		var layer: Array = []
		for lane in range(widths[stage]):
			var id = nodes.size()
			var kind = "combat" if stage == 0 else ("boss" if stage == 12 else ("elite" if stage in [4,8] else pool.pop_back()))
			var column = stage if stage < 7 else 13 - stage
			var x = 140 + column * 142 + rng.randi_range(-9, 9)
			var y = (252 if stage < 7 else 525) + (lane - (widths[stage] - 1) / 2.0) * 82 + rng.randi_range(-6, 6)
			nodes.append({"id":id,"kind":kind,"next":[],"position":[x,y],"encounter":[],"event":config.get("events", ["well","altar","library"])[rng.randi_range(0,2)],"stage":stage})
			layer.append(id)
		layers.append(layer)
	# The early elite is an optional branch; the later elite guards every route.
	var early_choices: Array = layers[2] + layers[3]
	var early = early_choices[rng.randi_range(0, early_choices.size() - 1)]
	var checkpoint = layers[4][0]
	nodes[checkpoint].kind = nodes[early].kind
	nodes[early].kind = "elite"
	for stage in range(layers.size() - 1):
		var here: Array = layers[stage]
		var following: Array = layers[stage + 1]
		# Cover all nodes on both sides, then add seed-dependent alternate paths.
		for i in range(maxi(here.size(), following.size())):
			connect_rooms(nodes, here[i % here.size()], following[i % following.size()])
		for from in here:
			for to in following:
				if rng.randf() < 0.40: connect_rooms(nodes, from, to)
		for from in here: nodes[from].next.sort()
	var common_nodes: Array = []
	for node in nodes:
		if node.kind == "combat" and node.id != 0: common_nodes.append(node.id)
	# More groups than solitary fights, with triples restricted to later stages.
	shuffle(common_nodes, rng)
	var doubles: Array = common_nodes.slice(0, 7)
	var triples: Array = common_nodes.filter(func(id): return nodes[id].stage >= 6).slice(0, 2 if floor_number == 1 else 3)
	for node in nodes:
		if node.kind == "combat":
			var count = 3 if node.id in triples else (2 if node.id in doubles or floor_number >= 2 else 1)
			if node.id == 0: count = 1 if floor_number == 1 else 2
			if config.get("distinct_common", false):
				# Configured floors mix types and introduce tougher families later.
				var eligible: Array = config.common.filter(func(id): return node.stage >= int(config.get("min_stage", {}).get(id, 0)))
				shuffle(eligible, rng)
				var chosen: Array = []
				if count >= 2 and node.stage >= 2:
					var support: Array = eligible.filter(func(id): return config.get("roles", {}).get(id, "attacker") in ["protector", "support"])
					var attackers: Array = eligible.filter(func(id): return config.get("roles", {}).get(id, "attacker") == "attacker")
					if not support.is_empty() and not attackers.is_empty(): chosen = [attackers[0], support[0]]
				for candidate in eligible:
					if chosen.size() >= count: break
					if candidate not in chosen: chosen.append(candidate)
				node.encounter = chosen
			else:
				for i in range(count): node.encounter.append(config.common[rng.randi_range(0, config.common.size() - 1)])
		elif node.kind == "elite":
			node.encounter = [config.elite]
			if floor_number == 2 and node.stage == 8: node.encounter.append("forest_wolf")
		elif node.kind == "boss":
			node.encounter = [config.boss]
			if floor_number >= 2: node.encounter.append(config.escort)
	return nodes

static func connect_rooms(nodes: Array, from: int, to: int) -> void:
	if to not in nodes[from].next: nodes[from].next.append(to)
