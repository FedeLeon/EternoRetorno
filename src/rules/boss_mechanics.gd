extends RefCounted
# Optional objectives are run state, gated so old saves retain their original fights.
static func initialize(game: RefCounted) -> void:
	if game.run.get("polish_version", 0) == 0 or game.run.get("training", false): return
	if game.run.nodes[game.run.current].kind != "boss": return
	var floor_number = int(game.run.get("floor",1))
	game.run.combat.boss_objective = {"kind":["source","prison","armor"][floor_number-1],"hp":20 if floor_number == 1 else 2,"max_hp":20 if floor_number == 1 else 2,"trapped":-1,"broken":false}
	if floor_number == 1:
		# The source also sustains its guardian once. Destroying it prevents resurrection.
		game.run.combat.boss_objective.revival_used = false
	game._log(describe(game.run.combat.boss_objective))

static func describe(state: Dictionary) -> String:
	match state.kind:
		"source": return "Relé de reactivación: 20 PV. Rompela en dos acciones de 1 energía para impedir el regreso del guardián."
		"prison": return "El sistema de sujeción puede inmovilizar a un héroe: liberarlo cuesta 1 energía. Cada prisión dura como máximo un turno enemigo."
		"armor": return "Dos placas reducen el daño directo a la mitad. Cada golpe penetrante rompe una; también podés romperlas por 1 energía. Romper la última interrumpe el golpe cargado."
	return ""

static func trapped(game: RefCounted, owner: int) -> bool:
	return int(game.run.combat.get("boss_objective", {}).get("trapped", -1)) == owner

static func player_action(game: RefCounted) -> bool:
	if game.run.get("phase", "") != "combat" or game.run.combat.energy < 1: return false
	var objective: Dictionary = game.run.combat.get("boss_objective", {})
	if objective.is_empty() or objective.broken: return false
	if objective.kind == "prison" and objective.trapped < 0: return false
	game.run.combat.energy -= 1
	if objective.kind == "prison": objective.trapped = -1
	else:
		objective.hp = maxi(0, int(objective.hp) - (10 if objective.kind == "source" else 1))
		objective.broken = objective.hp <= 0
		if objective.broken:
			for enemy in game.run.combat.enemies:
				if objective.kind == "source" and enemy.intent.get("special", "") == "resurrect": enemy.intent.erase("special")
				if objective.kind == "armor": enemy.intent.damage = mini(int(enemy.intent.damage), 8); enemy.intent.erase("special")
	game._log("Liberaste al compañero." if objective.kind == "prison" else "Objetivo: %d restantes." % objective.hp)
	return true

static func plan(game: RefCounted, enemy: Dictionary, intent: Dictionary) -> void:
	var objective: Dictionary = game.run.combat.get("boss_objective", {})
	if objective.is_empty() or not game.content.enemies[enemy.id].get("boss", false): return
	if objective.kind == "source" and objective.broken and intent.get("special", "") == "resurrect": intent.erase("special")
	if objective.kind == "prison" and game.run.combat.turn % 3 == 1 and game.living_heroes().size() == 2: intent.special = "prison"
	if objective.kind == "armor" and not objective.broken and game.run.combat.turn % 3 == 2:
		intent.damage += 8
		intent.special = "armored_strike"

static func action(game: RefCounted, enemy: Dictionary, intent: Dictionary) -> void:
	var objective: Dictionary = game.run.combat.get("boss_objective", {})
	if objective.is_empty() or not game.content.enemies[enemy.id].get("boss", false): return
	if intent.get("special", "") == "prison" and game.living_heroes().size() == 2:
		objective.trapped = int(intent.target)
		objective.released_turn = game.run.combat.turn + 1
		game._log("Un cable de sujeción inmoviliza a %s. Liberalo o resistí hasta el próximo turno." % game.content.heroes[game.run.heroes[objective.trapped].id].name)

static func new_turn(game: RefCounted) -> void:
	var objective: Dictionary = game.run.combat.get("boss_objective", {})
	if objective.get("kind", "") == "prison" and (game.run.combat.turn > int(objective.get("released_turn", 999)) or game.living_heroes().size() < 2): objective.trapped = -1

static func hit(game: RefCounted, enemy: Dictionary, damage: int, pierce: bool) -> int:
	var objective: Dictionary = game.run.combat.get("boss_objective", {})
	if objective.get("kind", "") != "armor" or objective.broken or not game.content.enemies[enemy.id].get("boss", false): return damage
	if pierce:
		objective.hp = maxi(0, int(objective.hp)-1)
		objective.broken = objective.hp == 0
		if objective.broken: enemy.intent.damage = mini(int(enemy.intent.damage), 8); enemy.intent.erase("special")
		return damage
	return maxi(1, damage / 2)

static func sustain(game: RefCounted) -> bool:
	var objective: Dictionary = game.run.combat.get("boss_objective", {})
	if objective.get("kind", "") != "source" or objective.broken or objective.revival_used: return false
	for enemy in game.run.combat.enemies:
		if enemy.hp <= 0 and game.content.enemies[enemy.id].get("boss", false):
			enemy.hp = maxi(1, int(enemy.max_hp / 3)); enemy.resurrected = true; objective.revival_used = true
			game.resolved_card_hits.append({"kind":"revive","enemy":game.run.combat.enemies.find(enemy),"hp":enemy.hp,"block":enemy.block})
			game._log("El relé reactiva al guardián. No podrá hacerlo de nuevo.")
			return true
	return false
