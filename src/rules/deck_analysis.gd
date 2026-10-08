extends RefCounted
static func summarize(content: RefCounted, deck: Array) -> Dictionary:
	var result = {"attack":0, "defense":0, "heal":0, "cost":0.0, "cards":deck.size()}
	for instance in deck:
		var card: Dictionary = content.card(instance)
		result.attack += 1 if card.damage > 0 or card.poison > 0 else 0
		result.defense += 1 if card.block > 0 else 0
		result.heal += 1 if card.heal > 0 else 0
		result.cost += float(card.cost)
	result.cost = result.cost / maxf(1, deck.size())
	return result

static func format(stats: Dictionary) -> String:
	return "%d ataques · %d defensas · %d curaciones · coste medio %.1f" % [stats.attack, stats.defense, stats.heal, stats.cost]
