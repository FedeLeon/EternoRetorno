extends RefCounted
const TRAP_PERCENT = 15
const TRAP_DAMAGE = 4

static func prepare(rng: RandomNumberGenerator, items: Array) -> Dictionary:
	return {"item": items[rng.randi_range(0, items.size() - 1)], "trapped": rng.randi_range(0, 99) < TRAP_PERCENT, "opened": false, "losses": []}

static func state(value: Variant) -> Dictionary:
	# Preserve an already rolled relic in a legacy saved room.
	if value is String:
		return {"legacy_relic": value, "trapped": false, "opened": false, "losses": []}
	return value

static func open(run: Dictionary) -> bool:
	var result = state(run.get("treasure", {}))
	if result.is_empty() or result.get("opened", false):
		return false
	if result.has("legacy_relic"):
		var id = result.legacy_relic
		if id != "" and id not in run.relics:
			run.relics.append(id)
	else:
		if not run.has("inventory"):
			run.inventory = {}
		var id = result.item
		run.inventory[id] = int(run.inventory.get(id, 0)) + 1
	if result.trapped:
		for hero in run.heroes:
			# Environmental chip damage: never lethal, no combat block or phoenix use.
			var damage = mini(TRAP_DAMAGE, maxi(0, int(hero.hp) - 1))
			hero.hp -= damage
			result.losses.append(damage)
	result.opened = true
	run.treasure = result
	return true
