extends RefCounted
# Temporary percentages. No stacking: the strongest application wins.
# Missing fields are zero, preserving saves made before these cards existed.
const KEYS = ["strength_pct", "weak_pct", "fracture_pct"]

static func clear(unit: Dictionary) -> void:
	for key in KEYS: unit.erase(key)

static func empower(unit: Dictionary, card: Dictionary) -> void:
	if card.get("strength_pct", 0) > 0:
		unit.strength_pct = maxi(int(unit.get("strength_pct", 0)), int(card.strength_pct))

static func debuff(unit: Dictionary, card: Dictionary) -> void:
	if card.get("weak_pct", 0) > 0:
		unit.weak_pct = maxi(int(unit.get("weak_pct", 0)), int(card.weak_pct))
	var old = int(unit.get("fracture_pct", 0))
	var amount = maxi(old, int(card.get("fracture_pct", 0)))
	if amount > old:
		unit.block = floori(float(unit.block) * (100 - amount) / (100 - old))
	if amount > 0: unit.fracture_pct = amount

static func damage(amount: int, unit: Dictionary) -> int:
	return floori(amount * (1.0 + int(unit.get("strength_pct", 0)) / 100.0))

static func intent(unit: Dictionary) -> Dictionary:
	var result: Dictionary = unit.intent.duplicate(true)
	result.damage = floori(int(result.get("damage", 0)) * (1.0 - int(unit.get("weak_pct", 0)) / 100.0))
	result.block = floori(int(result.get("block", 0)) * (1.0 - int(unit.get("fracture_pct", 0)) / 100.0))
	return result

static func description(card: Dictionary) -> Array[String]:
	var lines: Array[String] = []
	if card.get("strength_pct", 0) > 0:
		lines.append("+%d%% daño este turno." % card.strength_pct)
	if card.get("weak_pct", 0) > 0:
		lines.append("-%d%% ataque al actuar." % card.weak_pct)
	if card.get("fracture_pct", 0) > 0:
		lines.append("-%d%% al bloqueo\nactual y al actuar." % card.fracture_pct)
	return lines
