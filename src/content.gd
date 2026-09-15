class_name ERContent
extends RefCounted

var heroes: Dictionary
var cards: Dictionary
var enemies: Dictionary
var relics: Dictionary
var events: Dictionary

func _init() -> void:
	var data = JSON.parse_string(FileAccess.get_file_as_string("res://data/content.json"))
	heroes = data.heroes
	cards = data.cards
	enemies = data.enemies
	relics = data.relics
	events = data.events

func card(instance: Dictionary) -> Dictionary:
	var result = cards[instance.id].duplicate(true)
	if instance.get("upgraded", false):
		result.name += " +"
		for stat in ["damage", "block", "heal"]:
			if result[stat] > 0:
				result[stat] += 3
		if result.poison > 0:
			result.poison += 2
	return result

func describe(instance: Dictionary) -> String:
	var c = card(instance)
	var lines: Array[String] = []
	if c.damage > 0:
		lines.append("%d de daño%s%s." % [c.damage, " × %d" % c.hits if c.hits > 1 else "", " penetrante" if c.pierce else ""])
	if c.block > 0:
		lines.append("%d de bloqueo." % c.block)
	if c.heal > 0:
		lines.append("Cura %d %s." % [c.heal, "al dueño" if c.target == "enemy" else "de vida"])
	if c.poison > 0:
		lines.append("Aplica %d de veneno." % c.poison)
	var targets = {"enemy": "Un enemigo", "ally": "Un aliado vivo", "self": "Su dueño", "all_allies": "Ambos aliados vivos", "all_enemies": "Todos los enemigos"}
	lines.append(targets[c.target])
	return "\n".join(lines)
