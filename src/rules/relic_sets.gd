extends RefCounted
const SETS = [
	{"ids":["storm_drum","fang"],"name":"Cadencia sangrienta","effect":"Cada golpe de cartas múltiples gana 1 de daño extra.","stat":"damage","value":1,"type":"multi"},
	{"ids":["viper_tooth","drill_tusk"],"name":"Pacto tóxico","effect":"Las cartas de veneno añaden 2 acumulaciones extra.","stat":"poison","value":2,"type":"poison"},
	{"ids":["ivory_mirror","turtle_charm"],"name":"Baluarte","effect":"Las cartas defensivas ganan 2 de bloqueo extra.","stat":"block","value":2,"type":"block"},
	{"ids":["dawn_bell","chalice"],"name":"Fuente vital","effect":"Las cartas de curación restauran 2 PV extra.","stat":"heal","value":2,"type":"heal"}]

static func active(run: Dictionary) -> Array:
	return SETS.filter(func(set_data): return set_data.ids.all(func(id): return id in run.get("relics", [])))

static func apply(card: Dictionary, run: Dictionary) -> void:
	for set_data in active(run):
		if (set_data.type == "multi" and int(card.hits) > 1) or (set_data.type != "multi" and int(card.get(set_data.stat, 0)) > 0):
			card[set_data.stat] += set_data.value
