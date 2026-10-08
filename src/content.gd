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
	cards.merge(JSON.parse_string(FileAccess.get_file_as_string("res://data/risk_cards.json")))
	cards.merge(JSON.parse_string(FileAccess.get_file_as_string("res://data/tactical_cards.json")))
	cards.merge(JSON.parse_string(FileAccess.get_file_as_string("res://data/support_cards.json")))
	enemies = data.enemies
	enemies.merge(JSON.parse_string(FileAccess.get_file_as_string("res://data/crypt_enemies.json")))
	enemies.merge(JSON.parse_string(FileAccess.get_file_as_string("res://data/forest_enemies.json")))
	enemies.merge(JSON.parse_string(FileAccess.get_file_as_string("res://data/enemy_expansion.json")))
	enemies.merge(JSON.parse_string(FileAccess.get_file_as_string("res://data/adventure_enemies.json")))
	enemies.merge(JSON.parse_string(FileAccess.get_file_as_string("res://data/cinematic_enemies.json")))
	relics = data.relics
	relics.merge(JSON.parse_string(FileAccess.get_file_as_string("res://data/boss_relics.json")))
	relics.merge(JSON.parse_string(FileAccess.get_file_as_string("res://data/elite_relics.json")))
	var legacy_icons = {"ember":2, "fang":3, "chalice":0, "hourglass":7}
	for id in legacy_icons: relics[id].icon = legacy_icons[id]
	events = data.events
	events.merge(JSON.parse_string(FileAccess.get_file_as_string("res://data/polish_events.json")))
	events.merge(JSON.parse_string(FileAccess.get_file_as_string("res://data/travel_events.json")))
	events.merge(JSON.parse_string(FileAccess.get_file_as_string("res://data/adventure_events.json")))
	var objects = JSON.parse_string(FileAccess.get_file_as_string("res://data/equipment.json"))
	equipment = objects.relics
	items = objects.items

func card(instance: Dictionary) -> Dictionary:
	var result = cards[instance.id].duplicate(true)
	preload("res://src/rules/card_upgrades.gd").apply(result, instance)
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
	if c.get("charge", false): lines.append("Se ejecuta al comenzar tu próximo turno.")
	if c.get("interrupt", false): lines.append("Interrumpe intención especial y contraataque.")
	lines.append_array(preload("res://src/rules/combat_modifiers.gd").description(c))
	lines.append_array(preload("res://src/rules/risk_cards.gd").description(c))
	var targets = {"enemy": "Un enemigo", "ally": "Un aliado vivo", "self": "Su dueño", "all_allies": "Ambos aliados vivos", "all_enemies": "Todos los enemigos"}
	lines.append(targets[c.target])
	return "\n".join(lines)
