extends RefCounted
## Combat rules only; ERGame owns the checkpoint after accepted actions.

static func damage(game: RefCounted, unit: Dictionary, amount: int, pierce: bool = false) -> void:
	if unit.has("equipped_relic"):
		amount = maxi(0, amount - game.relic_bonus(unit, "armor"))
	var was_alive = unit.hp > 0
	var hp_before: int = unit.hp
	var absorbed = 0 if pierce else mini(unit.block, amount)
	unit.block -= absorbed
	unit.hp = maxi(0, unit.hp - (amount - absorbed))
	if game.run.get("phase", "") == "combat": preload("res://src/rules/combat_depth.gd").record(game, unit, amount, absorbed, hp_before - unit.hp)
	if unit.has("equipped_relic"):
		preload("res://src/rules/adventure_extensions.gd").statistic(game.run, "damage_taken", hp_before - unit.hp)
	if was_alive and unit.hp == 0 and game.relic_bonus(unit, "phoenix") > 0 and not unit.get("phoenix_used", false):
		unit.hp = 1
		unit.phoenix_used = true
		game._log("%s evita un golpe fatal." % game.content.equipment.get(unit.get("equipped_relic", ""), {}).get("name", "El relé de emergencia"))
	if was_alive and unit.hp == 0 and unit.has("equipped_relic") and game.run.phase == "combat":
		game.run.combat.hero_fell = true
		preload("res://src/rules/adventure_extensions.gd").statistic(game.run, "fallen")


static func turn_energy(game: RefCounted) -> int:
	var amount = 3 + game.RunRelics.amount(game.run, game.content.relics, "extra_energy")
	if game.run.combat.turn == 1:
		amount += 1 if "hourglass" in game.run.relics else 0
		for hero in game.run.heroes:
			if hero.hp > 0:
				amount += game.relic_bonus(hero, "energy")
				if game.run.get("team_relic", "") != "":
					break
	if game.run.combat.turn == 1 and "burden" in game.run.get("curses", []): amount = maxi(0, amount - 1)
	return amount


static func attack_bonus(game: RefCounted, hero: Dictionary, owner: String) -> int:
	var bonus = int(hero.get("turn_strength", 0)) + int(hero.get("forge", {}).get("strength", 0))
	if game.run.get("team_relic", "") != "" or owner in ["mage"]:
		bonus += game.relic_bonus(hero, "magic")
	if owner in ["mage"]:
		bonus += int(hero.get("turn_magic", 0))
	return bonus


static func effective_card(game: RefCounted, instance: Dictionary) -> Dictionary:
	var c = game.content.card(instance)
	if game.run.is_empty() or c.owner not in game.run.party:
		return c
	var hero = game.run.heroes[game.run.party.find(c.owner)]
	if c.damage > 0:
		c.damage += game.attack_bonus(hero, c.owner)
	if c.block > 0:
		c.block += int(hero.get("forge", {}).get("block", 0))
	if c.poison > 0:
		c.poison += game.relic_bonus(hero, "poison")
	game.Specializations.apply(c, hero, int(game.run.get("combat", {}).get("turn", 0)))
	game.RunRelics.apply(c, instance, hero, game.run, game.content.relics)
	if c.heal > 0 and "scar" in game.run.get("curses", []): c.heal = maxi(1, c.heal - 2)
	if c.damage > 0: c.damage = game.Modifiers.damage(int(c.damage), hero)
	return c


