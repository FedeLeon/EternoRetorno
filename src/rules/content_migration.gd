extends RefCounted
## Remove unknown catalogue entries without changing valid progress or RNG.
static func clean(profile: Dictionary, run: Dictionary, content: RefCounted) -> Dictionary:
	var before = profile.duplicate(true)
	var heroes: Array = content.heroes.keys()
	for field in ["unlocked_cards", "market_cards"]:
		if profile.has(field): profile[field] = profile[field].filter(func(id): return content.cards.has(id))
	for field in ["starter_attacks", "forge_upgrades"]:
		if profile.has(field): retain_keys(profile[field], heroes)
	if profile.has("reserved_card") and not content.cards.has(profile.reserved_card): profile.erase("reserved_card")
	var pairs: Array = []
	for a in heroes:
		for b in heroes:
			if a != b: pairs.append(preload("res://src/rules/adventure_extensions.gd").pair_key([a,b]))
	for field in ["bonds", "bond_variants"]:
		if profile.has(field): retain_keys(profile[field], pairs)
	if profile.has("specializations"):
		var state: Dictionary = profile.specializations
		var specs = preload("res://src/rules/specializations.gd").catalog()
		state.victorious = state.get("victorious", []).filter(func(id): return id in heroes)
		state.owned = state.get("owned", []).filter(func(id): return specs.has(id))
		for hero in state.get("active", {}).keys():
			var id = state.active[hero]
			if hero not in heroes or id not in state.owned or specs[id].hero != hero: state.active.erase(hero)
	if profile.has("expeditions"):
		var previous: Dictionary = profile.expeditions.get("last", {})
		if not previous.is_empty() and preload("res://src/rules/expeditions.gd").definition(previous.get("id", "")).is_empty(): profile.expeditions.last = {}
	if profile.has("history"):
		profile.history = profile.history.filter(func(entry): return entry.get("party", []).all(func(id): return id in heroes))
	for entry in profile.get("history", []):
		if entry.has("deck"): entry.deck = entry.deck.filter(func(card): return content.cards.has(card.get("id", "")))
	if profile.has("achievements"):
		var ids: Array = []
		for entry in preload("res://src/rules/achievements.gd").catalog(): ids.append(entry.id)
		profile.achievements.unlocked = profile.achievements.get("unlocked", []).filter(func(id): return id in ids)
		for key in profile.achievements.get("totals", {}).keys():
			if str(key).begins_with("hero_") and str(key).trim_prefix("hero_") not in heroes: profile.achievements.totals.erase(key)
	if profile.has("cinematics_seen"):
		var stories = preload("res://src/data/json_catalog.gd").dictionary("res://data/cinematics.json")
		if profile.cinematics_seen is Dictionary: retain_keys(profile.cinematics_seen, stories.keys())
		elif profile.cinematics_seen is Array: profile.cinematics_seen = profile.cinematics_seen.filter(func(id): return stories.has(id))
	var closed = false
	if not run.is_empty():
		closed = run.get("party", []).any(func(id): return id not in heroes)
		var cards: Array = run.get("deck", []).duplicate()
		for pile in ["draw", "hand", "discard", "inactive", "reserved"]: cards.append_array(run.get("combat", {}).get(pile, []))
		for card in cards:
			var id = card.get("id", "") if card is Dictionary else card
			if not content.cards.has(id): closed = true
	if closed: run = {}
	return {"changed": before != profile or closed, "run": run, "closed": closed}

static func retain_keys(state: Dictionary, allowed: Array) -> void:
	for key in state.keys():
		if key not in allowed: state.erase(key)
