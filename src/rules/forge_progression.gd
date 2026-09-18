extends RefCounted
# Permanent purchases. No UI, animation or file writes.
const HEROES = ["warrior", "guardian", "rogue", "mage", "cleric", "ranger"]
const TRACKS = ["weapon", "armor"]

static func config() -> Dictionary:
	return JSON.parse_string(FileAccess.get_file_as_string("res://data/forge.json"))

static func migrate(profile: Dictionary) -> bool:
	if profile.has("forge_upgrades"):
		return false
	profile.forge_upgrades = {}
	return true

static func levels(profile: Dictionary, hero: String) -> Dictionary:
	var saved = profile.get("forge_upgrades", {}).get(hero, {})
	return {"weapon": clampi(int(saved.get("weapon", 0)), 0, 3), "armor": clampi(int(saved.get("armor", 0)), 0, 3)}

static func build(profile: Dictionary) -> bool:
	var cost = int(config().build_cost)
	if profile.buildings.get("forge", false) or profile.souls < cost:
		return false
	profile.souls -= cost
	profile.buildings.forge = true
	return true

static func buy(profile: Dictionary, hero: String, track: String, expected_level: int) -> bool:
	if hero not in HEROES or track not in TRACKS or not profile.buildings.get("forge", false):
		return false
	var current = levels(profile, hero)
	var level = int(current[track])
	if level >= 3 or expected_level != level + 1:
		return false
	var cost = int(config().prices[level])
	if profile.souls < cost:
		return false
	profile.souls -= cost
	current[track] = level + 1
	profile.forge_upgrades[hero] = current
	return true

static func snapshot(profile: Dictionary, hero: String) -> Dictionary:
	var result = levels(profile, hero)
	var settings = config()
	result.strength = result.weapon * int(settings.strength_per_level)
	result.block = result.armor * int(settings.block_per_level)
	return result
