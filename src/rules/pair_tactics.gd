extends RefCounted
## Optional cooperative interactions. Old adventures keep their original recipes.
const TEXT = {
	"cover":"Si ambos héroes ya tienen bloqueo, interrumpe el contraataque antes del golpe.",
	"incision":"Si el objetivo ya tiene corrosión, este golpe atraviesa su bloqueo.",
	"circuit":"Si el objetivo tiene bloqueo, elimina hasta 8 antes del golpe.",
	"screen":"Si algún héroe ya tiene bloqueo, reduce 25% el daño de su intención este turno.",
	"interference":"Si anuncia un poder especial o contraataque, lo interrumpe antes del golpe.",
	"chain":"Si el objetivo ya tiene corrosión, propaga 3 a los demás enemigos vivos."
}

static func active(game: RefCounted, combo: Dictionary, target: int) -> bool:
	if game.run.get("pair_tactics_version", 0) < 1: return false
	var enemy: Dictionary = game.run.combat.enemies[target]
	match combo.get("tactic", ""):
		"cover": return game.run.heroes.all(func(h): return h.hp > 0 and h.block > 0) and int(enemy.intent.get("counter",0)) > 0
		"incision", "chain": return enemy.poison > 0
		"circuit": return enemy.block > 0
		"screen": return game.run.heroes.any(func(h): return h.hp > 0 and h.block > 0)
		"interference": return int(enemy.intent.get("counter",0)) > 0 or enemy.intent.get("special", "") != ""
	return false

static func apply(game: RefCounted, combo: Dictionary, target: int) -> void:
	if not active(game, combo, target): return
	var enemy: Dictionary = game.run.combat.enemies[target]
	match combo.tactic:
		"cover": enemy.intent.counter = 0
		"interference": preload("res://src/rules/combat_depth.gd").interrupt(game, enemy)
		"incision": combo.pierce = true
		"circuit": enemy.block = maxi(0, int(enemy.block)-8)
		"screen": game.Modifiers.debuff(enemy, {"weak_pct":25})
		"chain":
			for i in range(game.run.combat.enemies.size()):
				var other: Dictionary = game.run.combat.enemies[i]
				if i != target and other.hp > 0: other.poison += 3
	game._log("Cooperación: " + TEXT[combo.tactic])
