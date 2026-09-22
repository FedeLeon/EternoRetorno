extends RefCounted
# Run relic rules only. Game owns checkpoints; presentation receives catalog snapshots.
static func amount(run: Dictionary, catalog: Dictionary, effect: String) -> int:
	var total = 0
	for id in run.get("relics", []):
		var relic: Dictionary = catalog.get(id, {})
		if relic.get("condition", "") == effect: total += int(relic.value)
	return total

static func roll(run: Dictionary, profile: Dictionary, catalog: Dictionary, rng: RandomNumberGenerator) -> String:
	var pool: Array = []
	for id in catalog:
		if id not in run.relics and (not catalog[id].locked or id in profile.unlocked_relics): pool.append(id)
	return "" if pool.is_empty() else pool[rng.randi_range(0, pool.size() - 1)]

static func grant(run: Dictionary, catalog: Dictionary, id: String) -> bool:
	if id == "" or not catalog.has(id) or id in run.relics: return false
	run.relics.append(id)
	var relic: Dictionary = catalog[id]
	if relic.get("condition", "") == "max_hp":
		for hero in run.heroes:
			hero.max_hp += int(relic.value)
			if hero.hp > 0: hero.hp = mini(hero.max_hp, hero.hp + int(relic.value))
	return true

static func apply(card: Dictionary, instance: Dictionary, hero: Dictionary, run: Dictionary, catalog: Dictionary) -> void:
	var turn = int(run.get("combat", {}).get("turn", 0))
	for id in run.get("relics", []):
		var relic: Dictionary = catalog.get(id, {})
		var stat = relic.get("stat", "")
		if stat == "" or int(card.get(stat, 0)) <= 0: continue
		var allowed = false
		match relic.condition:
			"always": allowed = true
			"single": allowed = int(card.hits) == 1
			"multi": allowed = int(card.hits) > 1
			"area": allowed = card.target == "all_enemies"
			"pierce": allowed = card.pierce
			"costly": allowed = int(card.cost) >= 2
			"wounded": allowed = int(hero.hp) * 2 <= int(hero.max_hp)
			"healthy": allowed = hero.hp == hero.max_hp
			"upgraded": allowed = instance.get("upgraded", false)
			"self": allowed = card.target == "self"
			"ally": allowed = card.target in ["ally", "all_allies"]
			"opening": allowed = turn == 1
			"late": allowed = turn >= 3
		if allowed: card[stat] += int(relic.value)
