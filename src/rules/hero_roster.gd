extends RefCounted
## Active release roster. Unknown content is removed by the save migration.
const ACTIVE = ["warrior", "guardian", "rogue", "mage"]
static func ids(heroes: Dictionary) -> Array:
	return ACTIVE.filter(func(id): return heroes.has(id))
static func heroes(all: Dictionary) -> Dictionary:
	var result = {}
	for id in ids(all): result[id] = all[id].duplicate(true)
	return result
static func supports(party: Array) -> bool:
	return party.all(func(id): return id in ACTIVE)
