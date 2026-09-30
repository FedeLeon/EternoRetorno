extends RefCounted
# Permanent, idempotent milestones. No UI, RNG, rewards or file access for saves.
const HEROES = ["warrior", "guardian", "rogue", "mage", "cleric", "ranger"]
const METRICS = ["battles", "elites", "bosses", "treasures", "upgrades"]
static var _catalog: Array = []

static func catalog() -> Array:
	if _catalog.is_empty():
		_catalog = JSON.parse_string(FileAccess.get_file_as_string("res://data/achievements.json"))
	return _catalog

static func sync(profile: Dictionary, run: Dictionary) -> bool:
	var before: Dictionary = profile.get("achievements", {}).duplicate(true)
	if not profile.has("achievements"):
		profile.achievements = {"unlocked": [], "totals": {}}
	var state: Dictionary = profile.achievements
	var totals: Dictionary = state.totals
	# The per-adventure receipt is saved in the same atomic envelope as the profile.
	# Reloading, changing floors, or rendering cannot count an action twice.
	if not run.is_empty():
		if not run.has("achievement_receipt"): run.achievement_receipt = {}
		var receipt: Dictionary = run.achievement_receipt
		for metric in METRICS:
			var current = int(run.get("expedition_stats", {}).get(metric, 0))
			var previous = int(receipt.get(metric, 0))
			totals[metric] = int(totals.get(metric, 0)) + maxi(0, current - previous)
			receipt[metric] = maxi(previous, current)
		if run.get("contract_result", {}).get("complete", false) and not receipt.get("contract", false):
			totals.contracts = int(totals.get("contracts", 0)) + 1
			receipt.contract = true
		if run.get("phase", "") == "victory":
			for hero in run.get("heroes", []):
				if int(hero.hp) > 0 and int(hero.hp) <= 5: totals.last_breath = 1
	# Backfill only verifiable permanent facts; older battles were never recorded.
	totals.attempts = int(profile.get("attempts", 0))
	totals.victories = int(profile.get("victories", 0))
	totals.purchases = profile.get("market_cards", []).size()
	var winners: Array = profile.get("specializations", {}).get("victorious", []).duplicate()
	for entry in profile.get("history", []):
		if not entry.get("won", false): continue
		var party: Array = entry.get("party", [])
		for hero in party:
			if hero not in winners: winners.append(hero)
		if "warrior" in party and "guardian" in party: totals.pair_iron = 1
		if "rogue" in party and "mage" in party: totals.pair_arcane = 1
	totals.all_heroes = 0
	for hero in HEROES:
		totals["hero_" + hero] = 1 if hero in winners else 0
		totals.all_heroes += totals["hero_" + hero]
	for track in ["weapon", "armor"]:
		for levels in profile.get("forge_upgrades", {}).values():
			totals[track] = maxi(int(totals.get(track, 0)), int(levels.get(track, 0)))
	totals.buildings = 0
	for id in ["market", "forge", "church", "expeditions"]:
		if profile.get("buildings", {}).get(id, false): totals.buildings += 1
	for achievement in catalog():
		if int(totals.get(achievement.metric, 0)) >= int(achievement.target) and achievement.id not in state.unlocked:
			state.unlocked.append(achievement.id)
	return before != state

static func entries(profile: Dictionary) -> Array:
	# UI snapshot: secret conditions never leave the rules/catalog layer.
	var state: Dictionary = profile.get("achievements", {})
	var result: Array = []
	for definition in catalog():
		var unlocked: bool = definition.id in state.get("unlocked", [])
		var secret: bool = definition.secret
		result.append({"id": definition.id, "name": "Eco desconocido" if secret and not unlocked else definition.name,
			"description": ("Un secreto que ya forma parte de tu historia." if unlocked else "Su historia permanece oculta.") if secret else definition.description,
			"secret": secret, "unlocked": unlocked,
			"progress": -1 if secret else mini(int(definition.target), int(state.get("totals", {}).get(definition.metric, 0))),
			"target": -1 if secret else int(definition.target)})
	return result
