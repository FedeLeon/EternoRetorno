extends RefCounted
# Compare confirmed state only: this receipt never rolls rewards or applies effects.
static func snapshot(game: RefCounted) -> Dictionary:
	return {"heroes":game.run.heroes.duplicate(true), "souls":int(game.profile.souls), "deck":game.run.deck.duplicate(true), "relics":game.run.relics.duplicate(), "flags":game.run.get("event_flags", {}).duplicate(true), "curses":game.run.get("curses", []).duplicate()}

static func describe(game: RefCounted, before: Dictionary) -> String:
	var lines: Array[String] = []
	for i in range(game.run.heroes.size()):
		var hero: Dictionary = game.run.heroes[i]
		var delta = int(hero.hp) - int(before.heroes[i].hp)
		if delta != 0: lines.append("%s: %s%d PV" % [game.content.heroes[hero.id].name, "+" if delta > 0 else "", delta])
	var cells = int(game.profile.souls) - int(before.souls)
	if cells: lines.append("%s%d celdas" % ["+" if cells > 0 else "", cells])
	for i in range(mini(game.run.deck.size(), before.deck.size())):
		if game.run.deck[i].upgraded and not before.deck[i].upgraded:
			lines.append("Carta mejorada: " + game.content.cards[game.run.deck[i].id].name)
	for id in game.run.relics:
		if id not in before.relics: lines.append("Componente: " + game.content.relics[id].name)
	for curse in game.run.get("curses", []):
		if curse not in before.curses: lines.append("Avería: " + preload("res://src/rules/adventure_choices.gd").CURSES[curse].name)
	var flags: Dictionary = game.run.get("event_flags", {})
	for flag in ["guide", "sanctuary", "knowledge", "pair_guard"]:
		if flags.get(flag, false) and not before.flags.get(flag, false):
			lines.append({"guide":"Próximo mercader: provisiones por 20 celdas.", "sanctuary":"Próximo descanso: +5 PV adicionales.", "knowledge":"Próximo cofre: una ampolla extra.", "pair_guard":"Próximo combate: +4 bloqueo inicial y +2 daño en la primera sinergia."}[flag])
	match game.run.phase:
		"event_cards": lines.append("Ahora podés elegir la carta de tu mazo.")
		"reward": lines.append("Elegí una de las cartas encontradas.")
	if lines.is_empty(): return "El grupo sigue su camino."
	return "\n".join(lines)
