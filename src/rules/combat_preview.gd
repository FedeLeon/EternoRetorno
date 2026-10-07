extends RefCounted
# Execute the same rules on an isolated snapshot; never consume the real RNG/save.
static func describe(game: RefCounted, hand_index: int, target: int) -> String:
	if target not in game.valid_targets(hand_index): return "Objetivo no válido"
	var copy = load("res://src/game.gd").new("user://unused-preview.save", false)
	copy.content = game.content
	copy.profile = game.profile.duplicate(true)
	copy.run = game.run.duplicate(true)
	copy.rng.state = game.rng.state
	var before = copy.run.combat.enemies.duplicate(true)
	var heroes = copy.run.heroes.duplicate(true)
	var card = game.effective_card(game.run.combat.hand[hand_index])
	copy.play_card(hand_index, target)
	var lines: Array[String] = []
	for i in range(before.size()):
		var hits = copy.resolved_card_hits.filter(func(hit): return hit.kind == "hit" and hit.enemy == i)
		if not hits.is_empty():
			var last = hits.back()
			lines.append("%s: %d daño a vida · %d bloqueo%s%s" % [game.content.enemies[before[i].id].name, before[i].hp - last.hp, before[i].block - last.block, " · cae" if last.hp <= 0 else "", " · %d×%d" % [hits.size(),card.damage] if card.hits > 1 else ""])
	var counters = copy.resolved_card_hits.filter(func(hit): return hit.kind == "counter")
	if not counters.is_empty(): lines.append("Devuelve %d contraataques de 4 PV" % counters.size())
	for i in range(heroes.size()):
		var after: Dictionary = copy.run.heroes[i]
		var delta = after.hp - heroes[i].hp
		var guard = after.block - heroes[i].block
		if delta != 0 or guard != 0:
			lines.append("%s: %s%d PV · %s%d bloqueo" % [game.content.heroes[heroes[i].id].name, "+" if delta >= 0 else "", delta, "+" if guard >= 0 else "", guard])
	if card.poison > 0: lines.append("Aplica %d de veneno" % card.poison)
	if card.damage <= 0:
		lines.append(game.content.describe(game.run.combat.hand[hand_index], card))
	return "\n".join(lines)
