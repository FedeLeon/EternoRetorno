extends RefCounted
## Combat rules only; ERGame owns the checkpoint after accepted actions.

static func play_synergy(game: RefCounted, id: String, target: int) -> bool:
	game.resolved_card_hits.clear()
	if target not in game.synergy_targets(id): return false
	var combo: Dictionary = {}
	for candidate in game.available_synergies():
		if candidate.id == id: combo = candidate
	var b = game.run.combat
	game.run.get("event_flags", {}).erase("pair_focus")
	b.energy -= int(combo.cost)
	# Descending indices preserve both exact instances, including upgrades.
	var indices: Array = combo.indices.duplicate()
	indices.sort()
	indices.reverse()
	for index in indices:
		preload("res://src/rules/combat_telemetry.gd").card(game,b.hand[index].id)
		b.discard.append(b.hand[index])
		b.hand.remove_at(index)
	combo.damage = preload("res://src/rules/boss_mechanics.gd").hit(game,b.enemies[target],int(combo.damage),combo.pierce)
	if not preload("res://src/rules/combat_depth.gd").root_hit(game, b.enemies[target], int(combo.damage)):
		game._damage(b.enemies[target], int(combo.damage), combo.pierce)
	if b.enemies[target].hp > 0 and int(b.enemies[target].intent.get("counter", 0)) > 0:
		var attacker = game.run.party.find(combo.heroes[0])
		game._damage(game.run.heroes[attacker], 4)
		game.resolved_card_hits.append({"kind":"counter", "enemy":target, "owner":attacker, "hp":game.run.heroes[attacker].hp, "block":game.run.heroes[attacker].block, "damage":4})
	b.enemies[target].poison += int(combo.poison)
	for hero in game.run.heroes:
		if hero.hp <= 0: continue
		hero.block += int(combo.block)
		hero.hp = mini(hero.max_hp, hero.hp + int(combo.heal))
	game._log("Sinergia: %s." % combo.name)
	game._check_combat_end()
	return true


