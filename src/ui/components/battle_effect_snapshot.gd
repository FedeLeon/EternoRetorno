extends RefCounted
# Read-only descriptions of existing combat state. Never applies rules or saves.
static var catalog: Dictionary = preload("res://src/data/json_catalog.gd").dictionary("res://data/battle_effects.json")

static func entry(id: String, value: int = 0, text: String = "") -> Dictionary:
	var data: Dictionary = catalog[id]
	return {"id":id, "title":data.title, "description":data.description if text.is_empty() else text,
		"asset":"res://assets/battle_effects/%s.png" % id, "value":value}

static func common(unit: Dictionary) -> Array:
	var result: Array = preload("res://src/ui/components/combat_modifier_badges.gd").entries(unit)
	var poison = int(unit.get("poison", 0))
	if poison > 0:
		result.append(entry("poison", poison, "Veneno activo: %d acumulaciones. En los enemigos causa ese daño antes de su acción, ignora el bloqueo y pierde una acumulación tras aplicarse." % poison))
	return result

static func enemy(game: RefCounted, index: int) -> Array:
	var unit: Dictionary = game.run.combat.enemies[index]
	if unit.hp <= 0: return []
	var result = common(unit)
	var covered = game.run.combat.enemies.any(func(e): return e.hp > 0 and game.content.enemies[e.id].get("role", "") == "protector")
	if unit.get("rear", false) and covered: result.append(entry("rear_guard"))
	if int(unit.get("root_hp", 0)) > 0:
		result.append(entry("roots", unit.root_hp, "Las raíces absorben los golpes directos antes de perder vida. Quedan %d PV de raíces. El veneno las ignora." % unit.root_hp))
	var special: String = unit.intent.get("special", "")
	var special_ids = {"resurrect":"resurrection", "embers":"embers", "prison":"imprisonment", "armored_strike":"charged_strike"}
	if special_ids.has(special):
		var effect = entry(special_ids[special], 4 if special == "embers" else 0)
		effect.description += " Una carta de interrupción cancela esta intención especial."
		result.append(effect)
	var modifier: String = unit.get("modifier", "")
	if modifier in ["vampiric", "bulwark", "frenzied"]:
		result.append(entry("frenzy" if modifier == "frenzied" else modifier))
	var role: String = game.content.enemies[unit.id].get("role", "")
	if role == "protector": result.append(entry("protector", 3))
	if role == "support": result.append(entry("healer", 3))
	var coordination: String = unit.intent.get("coordination", "")
	if coordination == "hunt": result.append(entry("beast_command", 3))
	if coordination == "grief": result.append(entry("grief", 3))
	if unit.get("enraged", false): result.append(entry("enraged"))
	if unit.get("risky", false): result.append(entry("ambush"))
	if unit.get("tainted", false): result.append(entry("tainted"))
	var objective: Dictionary = game.run.combat.get("boss_objective", {})
	if not objective.is_empty() and game.content.enemies[unit.id].get("boss", false):
		var effect: Dictionary = {}
		if objective.kind == "source" and not objective.broken:
			effect = entry("source", objective.hp, "Fuente de resurrección: quedan %d de 20 PV. Cada acción cuesta 1 energía y quita 10 PV a la fuente. Romperla impide que reviva al guardián." % objective.hp)
			if objective.get("revival_used", false): effect.description += " La fuente ya devolvió al guardián a la vida; no puede repetirlo."
		elif objective.kind == "armor" and not objective.broken:
			effect = entry("armor_plates", objective.hp, preload("res://src/rules/boss_mechanics.gd").describe(objective))
		elif objective.kind == "prison" and objective.trapped >= 0:
			effect = entry("imprisonment", 0, "El bosque mantiene atrapado a %s. No puede jugar sus cartas ni participar de enlaces. Liberarlo cuesta 1 energía; también se libera tras el siguiente turno enemigo." % game.content.heroes[game.run.heroes[objective.trapped].id].name)
		if not effect.is_empty():
			effect.objective_action = true
			# A prison intention and an active prison share artwork, but have different meaning.
			effect.id += "_active" if effect.id == "imprisonment" else ""
			result.append(effect)
	return result

static func hero(game: RefCounted, index: int) -> Array:
	var unit: Dictionary = game.run.heroes[index]
	if unit.hp <= 0: return []
	var result = common(unit)
	for stat in ["turn_strength", "turn_magic"]:
		var value = int(unit.get(stat, 0))
		if value > 0:
			result.append(entry("weapon_boost" if stat == "turn_strength" else "magic_boost", value,
				"%s: +%d de daño a sus cartas ofensivas durante este turno. Expira al comenzar el siguiente turno aliado." % ["Potencia física" if stat == "turn_strength" else "Potencia mágica", value]))
	var prepared: Array = game.run.combat.get("prepared", []).filter(func(a): return a.owner == index)
	if not prepared.is_empty():
		var names: Array[String] = []
		for attack in prepared: names.append(attack.card.name)
		result.append(entry("prepared", prepared.size(), "Ataques preparados: %s. Se ejecutan al comenzar el próximo turno aliado, después de las acciones enemigas, si el héroe sigue vivo." % ", ".join(names)))
	if preload("res://src/rules/boss_mechanics.gd").trapped(game, index):
		var prison = entry("imprisonment", 0, "Este héroe está atrapado: no puede jugar sus cartas ni participar de enlaces. Liberarlo cuesta 1 energía; también se libera tras el siguiente turno enemigo.")
		prison.objective_action = true; result.append(prison)
	if game.run.get("event_flags", {}).get("pair_focus", false): result.append(entry("bond_focus", 2))
	for curse in game.run.get("curses", []):
		var definition: Dictionary = preload("res://src/rules/adventure_choices.gd").CURSES[curse]
		result.append(entry("curse_" + curse, 0, definition.description + " Puede limpiarse en un descanso o ante el mercader."))
	for set_data in preload("res://src/rules/relic_sets.gd").active(game.run):
		var id: String = {"multi":"set_multi", "poison":"set_poison", "block":"set_block", "heal":"set_heal"}[set_data.type]
		result.append(entry(id, set_data.value, set_data.effect + " Se activa mientras tengas ambas reliquias de la combinación."))
	return result
