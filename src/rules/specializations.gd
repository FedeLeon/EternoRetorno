extends RefCounted
# Unlock eligibility, purchases and permanent selection. Adventure uses a snapshot.
static func catalog() -> Dictionary:
	return preload("res://src/data/json_catalog.gd").dictionary("res://data/camp_expansion.json").specializations

static func migrate(profile: Dictionary) -> bool:
	if profile.has("specializations"): return false
	profile.specializations = {"victorious": [], "owned": [], "active": {}}
	# Recover eligibility from retained historic wins without inventing older results.
	for entry in profile.get("history", []):
		if entry.get("won", false):
			for hero in entry.get("party", []):
				if hero not in profile.specializations.victorious: profile.specializations.victorious.append(hero)
	return true

static func victory(profile: Dictionary, party: Array) -> void:
	for hero in party:
		if hero not in profile.specializations.victorious: profile.specializations.victorious.append(hero)

static func buy(profile: Dictionary, id: String) -> bool:
	var spec: Dictionary = catalog().get(id, {})
	if spec.is_empty() or not profile.buildings.get("church", false): return false
	var state = profile.specializations
	if spec.hero not in state.victorious or id in state.owned or profile.souls < int(spec.cost): return false
	profile.souls -= int(spec.cost)
	state.owned.append(id)
	state.active[spec.hero] = id
	return true

static func activate(profile: Dictionary, hero: String, id: String) -> bool:
	if not profile.buildings.get("church", false): return false
	if hero not in ["warrior", "guardian", "rogue", "mage", "cleric", "ranger"]: return false
	if id == "":
		profile.specializations.active.erase(hero)
		return true
	var spec: Dictionary = catalog().get(id, {})
	if spec.get("hero", "") != hero or id not in profile.specializations.owned: return false
	profile.specializations.active[hero] = id
	return true

static func snapshot(profile: Dictionary, hero: String) -> Dictionary:
	var state = profile.specializations
	var id = state.active.get(hero, "")
	if id not in state.owned: return {}
	var spec: Dictionary = catalog().get(id, {}).duplicate(true)
	if spec.get("hero", "") != hero: return {}
	spec.id = id
	return spec

static func apply(card: Dictionary, hero: Dictionary, turn: int) -> void:
	var spec: Dictionary = hero.get("specialization", {})
	if spec.is_empty() or int(card.get(spec.stat, 0)) <= 0: return
	var allowed = false
	var hits = int(card.get("hits", 1))
	match spec.condition:
		"always": allowed = true
		"multi": allowed = hits > 1
		"single": allowed = hits == 1
		"ally": allowed = card.target in ["ally", "all_allies"]
		"guarded": allowed = int(hero.get("block", 0)) > 0
		"pierce": allowed = card.get("pierce", false)
		"area": allowed = card.target == "all_enemies"
		"focused": allowed = card.target == "enemy" and hits == 1
		"opening": allowed = turn == 1
	if allowed: card[spec.stat] += int(spec.bonus)
