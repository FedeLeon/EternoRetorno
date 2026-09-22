class_name ERContent
extends RefCounted

var synergies: Array
var heroes: Dictionary
var cards: Dictionary
var enemies: Dictionary
var relics: Dictionary
var events: Dictionary
var equipment: Dictionary
var items: Dictionary

func _init() -> void:
	synergies = JSON.parse_string(FileAccess.get_file_as_string("res://data/synergies.json"))
	var data = JSON.parse_string(FileAccess.get_file_as_string("res://data/content.json"))
	heroes = data.heroes
	cards = data.cards
	cards.merge(JSON.parse_string(FileAccess.get_file_as_string("res://data/support_cards.json")))
	enemies = data.enemies
	enemies.merge(JSON.parse_string(FileAccess.get_file_as_string("res://data/crypt_enemies.json")))
	enemies.merge(JSON.parse_string(FileAccess.get_file_as_string("res://data/forest_enemies.json")))
	relics = data.relics
	relics.merge(JSON.parse_string(FileAccess.get_file_as_string("res://data/elite_relics.json")))
	var legacy_icons = {"ember":2, "fang":3, "chalice":0, "hourglass":7}
	for id in legacy_icons: relics[id].icon = legacy_icons[id]
	events = data.events
	var objects = JSON.parse_string(FileAccess.get_file_as_string("res://data/equipment.json"))
	equipment = objects.relics
	items = objects.items

func card(instance: Dictionary) -> Dictionary:
	var result = cards[instance.id].duplicate(true)
	if instance.get("upgraded", false):
		result.name += " +"
		for stat in ["damage", "block", "heal"]:
			if result[stat] > 0:
				result[stat] += 3
		if result.poison > 0:
			result.poison += 2
		for stat in preload("res://src/rules/combat_modifiers.gd").KEYS:
			if result.get(stat, 0) > 0: result[stat] += 10
	return result

func describe(instance: Dictionary, effective: Dictionary = {}) -> String:
	var c = card(instance) if effective.is_empty() else effective
	var compact = c.get("support", false)
	var lines: Array[String] = []
	if c.damage > 0:
		lines.append(("%d daño%s%s." if compact else "%d de daño%s%s.") % [c.damage, " × %d" % c.hits if c.hits > 1 else "", " penetrante" if c.pierce else ""])
	if c.block > 0:
		if compact and c.damage > 0:
			lines[-1] = lines[-1].trim_suffix(".") + ", %d bloqueo." % c.block
		else:
			lines.append("%d de bloqueo." % c.block)
	if c.heal > 0:
		lines.append("Cura %d %s." % [c.heal, "al dueño" if c.target == "enemy" else "de vida"])
	if c.poison > 0:
		lines.append("Aplica %d de veneno." % c.poison)
	lines.append_array(preload("res://src/rules/combat_modifiers.gd").description(c))
	var targets = {"enemy": "Un enemigo", "ally": "Un aliado vivo", "self": "Su dueño", "all_allies": "Ambos aliados vivos", "all_enemies": "Todos los enemigos"}
	lines.append(targets[c.target])
	return "\n".join(lines)
