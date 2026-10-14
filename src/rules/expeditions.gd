extends RefCounted
# Contracts: deterministic offers independent from the adventure RNG, paid once at finish.
static func catalog() -> Array:
	return preload("res://src/data/json_catalog.gd").dictionary("res://data/camp_expansion.json").contracts

static func definition(id: String) -> Dictionary:
	for contract in catalog():
		if contract.id == id: return contract
	return {}

static func migrate(profile: Dictionary, run: Dictionary = {}) -> bool:
	if profile.has("expeditions"):
		var state = profile.expeditions
		var invalid_selection = not state.selected.is_empty() and definition(state.selected).is_empty()
		if invalid_selection or state.offers.any(func(id): return definition(id).is_empty() or not preload("res://src/rules/hero_roster.gd").supports(definition(id).get("party",[]))):
			var selected: String = state.selected
			refresh(profile)
			if not definition(selected).is_empty() and preload("res://src/rules/hero_roster.gd").supports(definition(selected).get("party",[])):
				if selected not in state.offers: state.offers[0] = selected
				state.selected = selected
			return true
		return false
	profile.expeditions = {"cycle": 0, "offers": [], "selected": "", "last": {}}
	refresh(profile)
	return true

static func refresh(profile: Dictionary) -> void:
	var state = profile.expeditions
	var previous: Array = state.offers.duplicate()
	var pairs: Array = []
	var general: Array = []
	for contract in catalog():
		if contract.id in previous: continue
		if not preload("res://src/rules/hero_roster.gd").supports(contract.party): continue
		if contract.party.size() == 2: pairs.append(contract.id)
		else: general.append(contract.id)
	var random = RandomNumberGenerator.new()
	random.seed = 741103 + int(state.cycle) * 7919
	state.offers = [pairs[random.randi_range(0, pairs.size() - 1)]]
	for i in range(2):
		var index = random.randi_range(0, general.size() - 1)
		state.offers.append(general.pop_at(index))
	state.selected = ""
	state.cycle += 1

static func select(profile: Dictionary, run: Dictionary, id: String) -> bool:
	if not profile.buildings.get("expeditions", false): return false
	if not run.is_empty() and run.phase not in ["victory", "defeat"]: return false
	if id != "" and id not in profile.expeditions.offers: return false
	profile.expeditions.selected = id
	return true

static func start(profile: Dictionary, run: Dictionary) -> void:
	run.contract = profile.expeditions.selected if profile.buildings.get("expeditions", false) else ""
	run.expedition_stats = {}

static func add(run: Dictionary, metric: String, amount: int = 1) -> void:
	if not run.has("expedition_stats"): run.expedition_stats = {}
	run.expedition_stats[metric] = int(run.expedition_stats.get(metric, 0)) + amount

static func progress(run: Dictionary, contract: Dictionary) -> int:
	for hero in contract.get("party", []):
		if hero not in run.get("party", []): return 0
	return mini(int(contract.get("target", 1)), int(run.get("expedition_stats", {}).get(contract.get("metric", ""), 0)))

static func finish(profile: Dictionary, run: Dictionary, won: bool) -> void:
	if won: add(run, "victory")
	var contract = definition(run.get("contract", ""))
	var result: Dictionary = {}
	if not contract.is_empty():
		var complete = progress(run, contract) >= int(contract.target)
		var reward = int(contract.reward) if complete else 0
		profile.souls += reward
		result = {"id":contract.id, "name":contract.name, "complete":complete, "reward":reward}
	run.contract_result = result
	profile.expeditions.last = result.duplicate(true)
	refresh(profile)
