extends RefCounted
## Small deterministic exercises. Only operates on the disposable practice run.
const STEPS = [
	["Probá el bloqueo", "Jugá la defensa sobre su dueño hasta sumar 6 de bloqueo."],
	["Dejá que ataque", "Terminá el turno y observá cómo el bloqueo absorbe el golpe."],
	["Guardá una carta", "Elegí una carta y pulsá Guardar carta: quedará boca abajo."],
	["Conservala para después", "Terminá el turno: la carta vuelve de frente en la nueva mano."],
	["Actuá en pareja", "Combiná las dos cartas marcadas y elegí el maniquí."]
]
static func ready(game: RefCounted) -> bool:
	var lesson: Dictionary = game.run.guided_lesson
	var b: Dictionary = game.run.combat
	match int(lesson.step):
		0: return game.run.heroes[0].block >= 6
		1, 3: return b.turn > lesson.turn
		2: return not b.get("reserved", []).is_empty()
		4: return game.run.log.any(func(line): return "Sinergia: " + lesson.combo_name + "." in str(line))
	return false

static func prepare(game: RefCounted, step: int) -> void:
	assert(game.run.get("training", false) and game.run.has("guided_lesson"))
	var lesson: Dictionary = game.run.guided_lesson
	var b: Dictionary = game.run.combat
	lesson.step = step; lesson.turn = b.turn
	b.energy = 3
	if step == 0:
		for hero in game.run.heroes: hero.block = 0
	if step in [0, 2, 4]:
		b.hand.clear(); b.reserved = []; b.erase("reserved_index")
		if step == 4:
			var recipe = game.content.synergies.filter(func(c): return c.heroes.all(func(id): return id in game.run.party))[0]
			lesson.combo_name = recipe.name
			for id in recipe.cards: b.hand.append({"id":id, "upgraded":false})
		else:
			var owner = game.run.party[0]
			var defenses = game.content.cards.keys().filter(func(id): return game.content.cards[id].owner == owner and int(game.content.cards[id].block) >= 6 and game.content.cards[id].target in ["self", "ally", "all_allies"] and int(game.content.cards[id].cost) <= 3 and int(game.content.cards[id].get("discard_cost", 0)) == 0)
			b.hand.append({"id":defenses[0], "upgraded":false})
	if step == 4:
		for hero in game.run.heroes: hero.block = 6
		b.enemies[0].block = 8; b.enemies[0].poison = 3
		b.enemies[0].intent.counter = 4
