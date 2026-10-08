extends RefCounted
# Extra costs are validated before the ordinary card transaction changes anything.
static func affordable(game: RefCounted, card: Dictionary, owner: int) -> bool:
	var hero: Dictionary = game.run.heroes[owner]
	return hero.hp > int(card.get("health_cost", 0)) and hero.block >= int(card.get("block_cost", 0)) and game.run.combat.hand.size() > int(card.get("discard_cost", 0))

static func pay(game: RefCounted, card: Dictionary, owner: int) -> void:
	var hero: Dictionary = game.run.heroes[owner]
	hero.hp -= int(card.get("health_cost", 0))
	hero.block -= int(card.get("block_cost", 0))
	game.run.combat.energy += int(card.get("energy_gain", 0))
	# Discard the rightmost other card. Exact rule is shown on the card, deterministic.
	for i in range(int(card.get("discard_cost", 0))):
		game.run.combat.discard.append(game.run.combat.hand.pop_back())

static func description(card: Dictionary) -> Array[String]:
	var result: Array[String] = []
	if card.get("health_cost", 0) > 0: result.append("Pagá %d PV (no puede matarte)." % card.health_cost)
	if card.get("energy_gain", 0) > 0: result.append("Ganás %d energía." % card.energy_gain)
	if card.get("block_cost", 0) > 0: result.append("Sacrificá %d bloqueo propio." % card.block_cost)
	if card.get("discard_cost", 0) > 0: result.append("Descartá la otra carta más a la derecha.")
	return result
