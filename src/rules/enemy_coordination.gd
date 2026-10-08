extends RefCounted
static func plan(game: RefCounted, enemy: Dictionary, intent: Dictionary) -> void:
	if game.run.get("polish_version", 0) == 0: return
	var role: String = game.content.enemies[enemy.id].get("role", "")
	var allies: Array = game.run.combat.enemies.filter(func(e): return e != enemy and e.hp > 0)
	var dead_partner = game.run.combat.enemies.any(func(e): return e != enemy and e.hp <= 0)
	if role == "support" and allies.any(func(e): return game.content.enemies[e.id].visual.begins_with("beast")):
		intent.coordination = "hunt"
		intent.coordination_text = "Potencia a las bestias: +3 daño durante esta ronda."
	if dead_partner and role in ["protector", "support"]:
		intent.damage += 3
		intent.coordination = "grief"
		intent.coordination_text = "Sin su compañero, cambia a un ataque agresivo: +3 daño."
	if role == "protector" and allies.any(func(e): return "archer" in game.content.enemies[e.id].visual):
		intent.coordination_text = "Protege al arquero. Los ataques penetrantes y a distancia atraviesan la formación."

static func intent(game: RefCounted, enemy: Dictionary) -> Dictionary:
	var result = preload("res://src/rules/combat_modifiers.gd").intent(enemy)
	if game.run.get("polish_version", 0) == 0: return result
	if not game.content.enemies[enemy.id].visual.begins_with("beast"): return result
	var supporters: Array = game.run.combat.enemies.filter(func(ally): return ally.hp > 0 and ally.intent.get("coordination", "") == "hunt")
	result.damage += supporters.size() * 3
	return result
