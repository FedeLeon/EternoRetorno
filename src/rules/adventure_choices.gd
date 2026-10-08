extends RefCounted
const CURSES = {
	"blood":{"name":"Deuda de sangre","description":"Cada héroe vivo pierde 1 PV al terminar tu turno; nunca lo mata."},
	"burden":{"name":"Carga sombría","description":"En el primer turno de cada combate tenés 1 energía menos."},
	"scar":{"name":"Cicatriz antigua","description":"Las cartas de curación restauran 2 PV menos (mínimo 1)."}}

static func prepare(game: RefCounted) -> void:
	if game.run.get("polish_version", 0) == 0: return
	var events: Array = game.run.nodes.filter(func(n): return n.kind == "event" and n.event != "wandering_merchant")
	if not events.is_empty(): events[0].event = "pact_" + CURSES.keys()[int(game.run.floor)-1]
	if events.size() > 1: events[1].event = "pair_" + preload("res://src/rules/adventure_extensions.gd").pair_key(game.run.party)
	# Mark only an optional combat branch; another room in its layer stays ordinary.
	for node in game.run.nodes:
		if node.kind != "combat" or node.stage < 3: continue
		var alternatives = game.run.nodes.filter(func(n): return n.stage == node.stage and n.id != node.id)
		if alternatives.is_empty(): continue
		# Every parent that offers the risk also offers a safe alternative.
		for parent in game.run.nodes:
			if node.id in parent.next and not parent.next.any(func(id): return id != node.id):
				parent.next.append(alternatives[0].id)
				parent.next.sort()
		node.risk = {"name":"Emboscada opcional","warning":"Enemigos con +20% PV y +2 daño por ataque. Premio: una poción de curación y 20 almas adicionales."}
		break

static func definition(game: RefCounted, id: String) -> Dictionary:
	if id.begins_with("pact_"):
		var curse: Dictionary = CURSES.get(id.trim_prefix("pact_"), {})
		if curse.is_empty(): return {}
		return {"name":"Un pacto bajo las sombras","text":"Una voz ofrece una reliquia de aventura. A cambio: " + curse.description + " Podés limpiar la maldición en un descanso o ante el mercader.","choices":["Aceptar: reliquia aleatoria + maldición " + curse.name,"Rechazar el pacto"],"background":"altar"}
	if id.begins_with("pair_"):
		var names: Array = game.run.party.map(func(hero): return game.content.heroes[hero].name)
		var key: String = id.trim_prefix("pair_")
		var data: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://data/pair_events.json")).get(key, {})
		return {"name":data.get("name", "Una promesa compartida"),"text":data.get("text", "%s y %s descubren una forma de cubrirse mutuamente." % names),"choices":[data.get("choice", "Prepararse juntos: +4 bloqueo al comenzar el siguiente combate"),"Descansar juntos: recuperar 6 PV cada uno"],"background":data.get("background", "forest_hunter")}
	return {}

static func choose(game: RefCounted, id: String, index: int) -> bool:
	if index not in [0,1] or definition(game, id).is_empty(): return false
	if id.begins_with("pact_") and index == 0:
		var curse = id.trim_prefix("pact_")
		if curse in game.run.get("curses", []): return false
		var relic: String = game._roll_relic()
		if relic.is_empty(): return false
		game.run.get_or_add("curses", []).append(curse)
		game.RunRelics.grant(game.run, game.content.relics, relic)
		game._log("Pacto: %s; recibiste %s." % [CURSES[curse].name, game.content.relics[relic].name])
	elif id.begins_with("pair_"):
		if id != "pair_" + preload("res://src/rules/adventure_extensions.gd").pair_key(game.run.party): return false
		if index == 0:
			game.run.get_or_add("event_flags", {}).pair_guard = 4
			game.run.event_flags.pair_focus = true
		else:
			for hero in game.run.heroes: hero.hp = mini(hero.max_hp, hero.hp + 6)
	game.run.phase = "map"
	return true

static func cleanse(game: RefCounted) -> bool:
	if game.run.get("curses", []).is_empty(): return false
	if game.run.phase == "merchant":
		if game.profile.souls < 35: return false
		game.profile.souls -= 35
	elif game._room_is("rest"): game.run.phase = "map"
	else: return false
	var curse: String = game.run.curses.pop_front()
	game._log("Se disipó " + CURSES[curse].name + ".")
	return true

static func end_turn(game: RefCounted) -> void:
	if "blood" in game.run.get("curses", []):
		for hero in game.run.heroes:
			if hero.hp > 1: hero.hp -= 1

static func risk_enter(game: RefCounted) -> void:
	var node: Dictionary = game.run.nodes[game.run.current]
	if not node.has("risk"): return
	for enemy in game.run.combat.enemies:
		enemy.hp = ceili(enemy.hp * 1.2); enemy.max_hp = enemy.hp; enemy.risky = true
	game._log(node.risk.warning)
