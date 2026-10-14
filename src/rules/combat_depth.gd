extends RefCounted
# Tactical state is serialized with the run. Visuals never resolve these rules.
const ELITES = {
	"vampiric":{"name":"Vampírico", "description":"Recupera 3 PV si su ataque quita vida."},
	"bulwark":{"name":"Baluarte", "description":"Su intención gana 2 de bloqueo por turno, hasta 10."},
	"frenzied":{"name":"Frenético", "description":"Con menos de la mitad de vida, causa 3 de daño adicional."}}

static func initialize(game: RefCounted) -> void:
	var b: Dictionary = game.run.combat
	b.prepared = []
	b.journal = []
	var node: Dictionary = game.run.nodes[game.run.current]
	var protectors = b.enemies.filter(func(e): return game.content.enemies[e.id].get("role", "") == "protector")
	for i in range(b.enemies.size()):
		var e: Dictionary = b.enemies[i]
		e.rear = game.run.get("tactics_version", 0) > 0 and not protectors.is_empty() and e not in protectors
		if node.kind == "elite" and game.run.get("tactics_version", 0) > 0:
			e.modifier = node.elite_modifier if node.has("elite_modifier") else ELITES.keys()[game.rng.randi_range(0, 2)]
		var entry: Dictionary = game.profile.get("bestiary", {}).get(e.id, {"encounters":0, "kills":0})
		entry.encounters += 1
		if not game.profile.has("bestiary"): game.profile.bestiary = {}
		game.profile.bestiary[e.id] = entry
	if game.run.get("tactics_version", 0) > 0 and int(game.run.get("floor", 1)) == 2 and int(node.get("stage", 0)) in [3, 6, 9, 12] and not b.enemies.is_empty():
		b.enemies.back().root_hp = 10
		game._log("Las raíces protegen al enemigo: destruí sus 10 PV antes de herirlo.")

static func targets(game: RefCounted, card: Dictionary, candidates: Array) -> Array:
	if game.run.get("tactics_version", 0) == 0: return candidates
	if card.target == "all_enemies" or card.pierce or card.owner in ["mage"]: return candidates
	var b: Dictionary = game.run.combat
	var covered = b.enemies.any(func(e): return e.hp > 0 and game.content.enemies[e.id].get("role", "") == "protector")
	return candidates.filter(func(i): return not covered or not b.enemies[i].get("rear", false))

static func plan(game: RefCounted, enemy: Dictionary, intent: Dictionary) -> void:
	if game.run.get("tactics_version", 0) == 0: return
	if int(game.run.get("difficulty", 0)) == 0 and int(game.run.get("floor", 1)) >= 2:
		intent.damage = roundi(int(intent.damage) * 0.88)
	match enemy.get("modifier", ""):
		"bulwark": intent.block = int(intent.get("block", 0)) + mini(10, game.run.combat.turn * 2)
		"frenzied":
			if enemy.hp * 2 < enemy.max_hp: intent.damage += 3
	if game.run.get("tactics_version", 0) == 0: return
	var floor_number = int(game.run.get("floor", 1))
	if floor_number == 1 and game.run.combat.turn % 3 == 0 and game.run.combat.enemies.any(func(e): return e.hp <= 0 and not e.get("resurrected", false)):
		intent.special = "resurrect"
	if floor_number == 3 and game.run.combat.turn % 3 == 2:
		intent.special = "embers"
		intent.special_damage = 4

static func interrupt(game: RefCounted, enemy: Dictionary) -> void:
	if not enemy.intent.get("special", "").is_empty():
		game._log("Interrumpiste %s." % enemy.intent.special)
		enemy.intent.erase("special")
	if enemy.intent.get("counter", 0) > 0:
		enemy.intent.counter = 0
		game._log("Contraataque interrumpido.")

static func action(game: RefCounted, enemy: Dictionary, intent: Dictionary) -> void:
	match intent.get("special", ""):
		"resurrect":
			for corpse in game.run.combat.enemies:
				if corpse.hp <= 0 and not corpse.get("resurrected", false):
					corpse.hp = maxi(1, int(corpse.max_hp / 3))
					corpse.resurrected = true
					game._log("%s regresa con %d PV." % [game.content.enemies[corpse.id].name, corpse.hp])
					break
		"embers":
			for hero in game.run.heroes:
				if hero.hp > 0: game._damage(hero, 4)
			game._log("Las brasas anunciadas causan 4 de daño a cada héroe.")

static func prepare(game: RefCounted, card: Dictionary, owner: int, targets_list: Array) -> void:
	game.run.combat.get_or_add("prepared", []).append({"card":card.duplicate(true), "owner":owner, "targets":targets_list.duplicate(), "turn":game.run.combat.turn + 1})
	game._log("%s prepara %s para el próximo turno." % [game.content.heroes[game.run.heroes[owner].id].name, card.name])

static func release(game: RefCounted) -> void:
	var b: Dictionary = game.run.combat
	for attack in b.get("prepared", []).duplicate():
		if attack.turn > b.turn: continue
		b.prepared.erase(attack)
		if game.run.heroes[attack.owner].hp <= 0: continue
		var living: Array = []
		for i in range(b.enemies.size()):
			if b.enemies[i].hp > 0: living.append(i)
		var eligible: Array = targets(game, attack.card, living)
		var selected: Array = eligible if attack.card.target == "all_enemies" else attack.targets.filter(func(i): return i in eligible)
		if selected.is_empty() and not eligible.is_empty(): selected.append(eligible[0])
		game.resolved_prepared_hits.append_array(preload("res://src/rules/card_hits.gd").resolve(game, attack.card, attack.owner, selected))
		game._log("Se ejecuta %s." % attack.card.name)

static func record(game: RefCounted, unit: Dictionary, amount: int, absorbed: int, lost: int) -> void:
	var hero = game.content.heroes.has(unit.get("id", ""))
	var catalog: Dictionary = game.content.heroes if hero else game.content.enemies
	var name: String = catalog.get(unit.get("id", ""), {"name":"Unidad"}).name
	var entry = "%s: %d daño, %d absorbido, %d PV perdidos." % [name, amount, absorbed, lost]
	game.run.combat.get_or_add("journal", []).append(entry)
	if game.run.combat.journal.size() > 200: game.run.combat.journal.pop_front()
	if unit.hp <= 0:
		if hero: game.run.killer = game.run.get("attacker_name", "Daño ambiental o contraataque")
		elif not unit.get("kill_recorded", false):
			unit.kill_recorded = true
			if game.profile.get("bestiary", {}).has(unit.id): game.profile.bestiary[unit.id].kills += 1

static func root_hit(game: RefCounted, enemy: Dictionary, damage: int) -> bool:
	if int(enemy.get("root_hp", 0)) <= 0: return false
	enemy.root_hp = maxi(0, int(enemy.root_hp) - damage)
	game._log("Raíces: reciben %d de daño; quedan %d PV." % [damage, enemy.root_hp])
	return true
