extends RefCounted
# Offers and chained consequences are stored in the run, never rolled by views.
static func prepare(game: RefCounted) -> void:
	if game.run.has("merchant_offers"): return
	var item_ids = game.content.items.keys()
	var offers: Array = []
	for i in range(3):
		var index = game.rng.randi_range(0, item_ids.size() - 1)
		var id = item_ids[index]
		item_ids.remove_at(index)
		offers.append({"item":id, "price":20 if game.run.get("event_flags", {}).get("guide", false) else 30, "sold":false})
	game.run.merchant_offers = offers
	game.run.merchant_relic = game._roll_relic()
	game.run.merchant_traded = false
	game.run.merchant_discount = game.run.get("event_flags", {}).get("guide", false)
	if game.run.merchant_discount: game.run.event_flags.guide = false

static func transact(game: RefCounted, action: String, index: int) -> bool:
	if game.run.get("phase", "") != "merchant": return false
	if action == "leave": game.run.phase = "map"; game.run.erase("merchant_offers"); return true
	if action == "buy":
		var offers: Array = game.run.get("merchant_offers", [])
		if index < 0 or index >= offers.size(): return false
		var offer: Dictionary = offers[index]
		if offer.sold or game.profile.souls < offer.price: return false
		game.profile.souls -= int(offer.price)
		game.run.inventory[offer.item] = int(game.run.inventory.get(offer.item, 0)) + 1
		offer.sold = true
		return true
	if action == "trade":
		if game.run.get("merchant_traded", true) or index < 0 or index >= game.run.relics.size(): return false
		var relic: String = game.run.merchant_relic
		if relic.is_empty() or relic in game.run.relics: return false
		var offered: String = game.run.relics[index]
		# Maximum-life relics are not exchangeable: avoid retaining their permanent benefit.
		if game.content.relics[offered].get("condition", "") == "max_hp": return false
		game.run.relics.remove_at(index)
		game.RunRelics.grant(game.run, game.content.relics, relic)
		game.run.merchant_traded = true
		return true
	return false

static func chain(game: RefCounted, event: String) -> void:
	if not game.run.has("event_flags"): game.run.event_flags = {}
	if event == "forest_hunter":
		game.run.event_flags.guide = true
		game._log("Encontrás una contraseña en el campamento: el próximo mercader vende por 20 almas.")
	elif event == "forest_spirit":
		game.run.event_flags.sanctuary = true
		game._log("El bosque recuerda tu ayuda: el siguiente descanso restaurará 5 PV adicionales.")
	elif event == "library":
		game.run.event_flags.knowledge = true
		game._log("Un mapa antiguo señala un escondite: el siguiente cofre tendrá otra poción.")

static func apply_room(game: RefCounted, kind: String) -> void:
	var flags: Dictionary = game.run.get("event_flags", {})
	if kind == "treasure" and flags.get("knowledge", false):
		game.run.inventory.healing_potion = int(game.run.inventory.get("healing_potion", 0)) + 1
		flags.knowledge = false
		game.run.room_note = "El mapa antiguo te permitió encontrar otra poción de curación."

static func rest_bonus(game: RefCounted) -> int:
	var flags: Dictionary = game.run.get("event_flags", {})
	if not flags.get("sanctuary", false): return 0
	flags.sanctuary = false
	return 5
