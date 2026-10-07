extends RefCounted
# Legacy upgrades retain their original values. New choices are explicit in instances.
static func choices(card: Dictionary) -> Array:
	if int(card.heal) > 0 and int(card.damage) == 0 and int(card.poison) == 0 and card.target != "all_allies":
		return [{"id":"power", "name":"Restauración", "description":"Más curación sobre el objetivo."}, {"id":"shared", "name":"Amparo compartido", "description":"Cura a ambos héroes con menor potencia individual."}]
	return [{"id":"power", "name":"Potencia", "description":"Aumenta los valores de la carta."}, {"id":"efficient", "name":"Eficiencia", "description":"Reduce el coste en 1; las cartas gratuitas ganan bloqueo o un golpe adicional."}]

static func apply(card: Dictionary, instance: Dictionary) -> void:
	if not instance.get("upgraded", false): return
	var variant = instance.get("upgrade_variant", "power")
	card.name += " +"
	if variant == "efficient":
		if int(card.cost) > 0: card.cost = maxi(0, int(card.cost) - 1)
		elif int(card.damage) > 0: card.hits += 1
		else: card.block += 3
		return
	if variant == "shared" and int(card.heal) > 0 and int(card.damage) == 0:
		card.target = "all_allies"
		card.heal = maxi(1, int(ceil(int(card.heal) * 0.75)))
		return
	for stat in ["damage", "block", "heal"]:
		if card[stat] > 0: card[stat] += 3
	if card.poison > 0: card.poison += 2
	for stat in preload("res://src/rules/combat_modifiers.gd").KEYS:
		if card.get(stat, 0) > 0: card[stat] += 10
