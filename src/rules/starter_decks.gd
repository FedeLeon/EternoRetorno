extends RefCounted
# Eight basic slots (2–6 attacks), plus the two original class cards.
const MIN_ATTACKS = 2
const MAX_ATTACKS = 6

static func attack_count(profile: Dictionary, hero: String) -> int:
	var saved = profile.get("starter_attacks", {})
	if not saved is Dictionary: return 4
	var value = saved.get(hero, 4)
	if not (value is int or value is float): return 4
	return clampi(int(value), MIN_ATTACKS, MAX_ATTACKS)

static func deck(content: RefCounted, profile: Dictionary, hero: String) -> Array:
	if not content.heroes.has(hero): return []
	var original: Array = content.heroes[hero].starter
	var attacks = attack_count(profile, hero)
	var result: Array = []
	for i in range(attacks): result.append(original[0])
	for i in range(8 - attacks): result.append(original[4])
	result.append_array(original.slice(8, 10))
	return result

static func configure(content: RefCounted, profile: Dictionary, hero: String, attacks: int) -> bool:
	if not content.heroes.has(hero) or attacks < MIN_ATTACKS or attacks > MAX_ATTACKS: return false
	if not profile.get("starter_attacks", {}) is Dictionary: profile.starter_attacks = {}
	if not profile.has("starter_attacks"): profile.starter_attacks = {}
	profile.starter_attacks[hero] = attacks
	return true
