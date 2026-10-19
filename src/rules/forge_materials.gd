extends RefCounted
## Persistent salvage economy. No consumables, UI, audio or file writes.

static func config() -> Dictionary:
	return preload("res://src/data/json_catalog.gd").dictionary("res://data/forge.json")

static func migrate(profile: Dictionary) -> bool:
	var previous = profile.get("forge_materials", {})
	var stock = previous if previous is Dictionary else {}
	var normalized = {"scrap": maxi(0, int(stock.get("scrap", 0))), "alloy": maxi(0, int(stock.get("alloy", 0)))}
	if profile.has("forge_materials") and previous == normalized: return false
	profile.forge_materials = normalized
	return true

static func view(profile: Dictionary) -> Dictionary:
	var stock = profile.get("forge_materials", {})
	var scrap = int(stock.get("scrap", 0))
	var rate = int(config().smelt_scrap_per_alloy)
	var batches = scrap / rate
	return {"scrap": scrap, "alloy": int(stock.get("alloy", 0)), "rate": rate, "batches": batches, "smelt_scrap": batches * rate}

static func smelt(profile: Dictionary, batches: int) -> bool:
	if not profile.get("buildings", {}).get("forge", false) or batches <= 0: return false
	var stock = view(profile)
	if batches > stock.batches: return false
	profile.forge_materials.scrap -= batches * stock.rate
	profile.forge_materials.alloy += batches
	return true

static func spend(profile: Dictionary, alloy: int) -> bool:
	if alloy <= 0 or int(profile.get("forge_materials", {}).get("alloy", 0)) < alloy: return false
	profile.forge_materials.alloy -= alloy
	return true

static func award(profile: Dictionary, run: Dictionary) -> Dictionary:
	if run.get("training", false) or run.get("phase", "") != "combat": return {}
	if run.combat.get("salvage_awarded", false): return run.get("reward_salvage", {})
	var settings = config()
	var kind = run.nodes[run.current].kind
	var bonus = int(settings.scrap_boss_bonus) if kind == "boss" else int(settings.scrap_elite_bonus) if kind == "elite" else 0
	var floor_bonus = maxi(0, int(run.get("floor", 1)) - 1) * int(settings.scrap_floor_bonus)
	# Independent deterministic rolls preserve map/card/relic RNG and resume behavior.
	var random = RandomNumberGenerator.new()
	random.seed = (str(run.seed) + ":" + str(run.get("floor", 1)) + ":" + str(run.current) + ":salvage").hash()
	var drops: Array = []
	var total = 0
	for enemy in run.combat.enemies:
		if enemy.hp > 0: return {} # Only a completed battle grants salvage.
		var amount = random.randi_range(int(settings.scrap_drop_min), int(settings.scrap_drop_max)) + floor_bonus + bonus
		drops.append({"enemy": enemy.id, "scrap": amount})
		total += amount
	if total <= 0: return {}
	migrate(profile)
	profile.forge_materials.scrap += total
	run.combat.salvage_awarded = true
	run.reward_salvage = {"scrap": total, "drops": drops}
	return run.reward_salvage
