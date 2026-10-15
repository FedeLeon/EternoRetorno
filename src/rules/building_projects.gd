extends RefCounted
const PROJECTS = {
	"reservation":{"building":"market","name":"Mostrador de reservas","cost":350,"description":"Reservá una carta del mercado. Su próxima compra cuesta 20 celdas menos."},
	"refresh":{"building":"market","name":"Red de suministros","cost":450,"description":"El mercader errante renueva sus tres consumibles por 25 celdas, una vez por piso."},
	"scouting":{"building":"expeditions","name":"Mesa de exploración","cost":400,"description":"En el mapa, reconocé todas las salas disponibles por 20 celdas. Sus detalles aparecen al señalar cada sala."}}

static func owned(profile: Dictionary, id: String) -> bool:
	return profile.get("projects", {}).get(id, false)

static func buy(profile: Dictionary, id: String) -> bool:
	if not PROJECTS.has(id) or owned(profile, id): return false
	var project: Dictionary = PROJECTS[id]
	if not profile.buildings.get(project.building, false) or profile.souls < project.cost: return false
	profile.souls -= int(project.cost)
	profile.get_or_add("projects", {})[id] = true
	return true

static func reserve(game: RefCounted, id: String) -> bool:
	var card: Dictionary = game.content.cards.get(id, {})
	if not owned(game.profile, "reservation") or card.is_empty() or int(card.get("market_price",0)) <= 0 or id in game.profile.get("market_cards", []): return false
	game.profile.reserved_card = id
	return true

static func price(profile: Dictionary, card: Dictionary) -> int:
	return maxi(0, int(card.market_price) - (20 if profile.get("reserved_card", "") == card.id else 0))

static func refresh(game: RefCounted) -> bool:
	if game.run.get("phase", "") != "merchant" or not owned(game.profile, "refresh") or game.profile.souls < 25 or int(game.run.get("merchant_refresh_floor", 0)) == int(game.run.floor): return false
	game.profile.souls -= 25
	game.run.merchant_refresh_floor = int(game.run.floor)
	game.run.erase("merchant_offers")
	preload("res://src/rules/travel_encounters.gd").prepare(game)
	return true

static func scout(game: RefCounted) -> bool:
	if game.run.get("phase", "") != "map" or not owned(game.profile, "scouting") or game.profile.souls < 20: return false
	var eligible: Array = game.available_nodes().filter(func(i): return not game.run.nodes[i].get("scouted", false))
	if eligible.is_empty(): return false
	game.profile.souls -= 20
	for i in eligible: game.run.nodes[i].scouted = true
	return true
