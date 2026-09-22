extends RefCounted
const Expeditions = preload("res://src/rules/expeditions.gd")
const Specializations = preload("res://src/rules/specializations.gd")

static func buildings() -> Dictionary:
	return JSON.parse_string(FileAccess.get_file_as_string("res://data/camp_expansion.json")).buildings

static func migrate(profile: Dictionary) -> bool:
	var contracts_changed = Expeditions.migrate(profile)
	var specs_changed = Specializations.migrate(profile)
	return contracts_changed or specs_changed

static func transact(profile: Dictionary, run: Dictionary, action: String, payload: Dictionary) -> bool:
	match action:
		"build":
			var id = payload.get("id", "")
			var definition: Dictionary = buildings().get(id, {})
			if definition.is_empty() or profile.buildings.get(id, false) or profile.souls < int(definition.cost): return false
			profile.souls -= int(definition.cost)
			profile.buildings[id] = true
			return true
		"contract": return Expeditions.select(profile, run, payload.get("id", ""))
		"buy_specialization": return Specializations.buy(profile, payload.get("id", ""))
		"activate_specialization": return Specializations.activate(profile, payload.get("hero", ""), payload.get("id", ""))
	return false
