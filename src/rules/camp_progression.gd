extends RefCounted
const CONFIG_PATH = "res://data/progression.json"

static func config() -> Dictionary:
	return JSON.parse_string(FileAccess.get_file_as_string(CONFIG_PATH))

static func migrate(profile: Dictionary) -> bool:
	var before = profile.duplicate(true)
	if not profile.has("souls"): profile.souls = 0
	if not profile.has("buildings"): profile.buildings = {}
	if not profile.has("market_cards"): profile.market_cards = []
	if not profile.has("test_grants"): profile.test_grants = []
	var grant = config().test_grant
	if grant.enabled and grant.id not in profile.test_grants:
		profile.souls += int(grant.amount)
		profile.test_grants.append(grant.id)
	return before != profile

static func build(profile: Dictionary) -> bool:
	var cost = int(config().market_cost)
	if profile.buildings.get("market", false) or profile.souls < cost:
		return false
	profile.souls -= cost
	profile.buildings.market = true
	return true

static func buy(profile: Dictionary, cards: Dictionary, id: String) -> bool:
	if not profile.buildings.get("market", false) or not cards.has(id): return false
	var price = int(cards[id].get("market_price", 0))
	if price <= 0 or id in profile.market_cards or profile.souls < price: return false
	profile.souls -= price
	profile.market_cards.append(id)
	return true

static func available(profile: Dictionary, card: Dictionary) -> bool:
	if int(card.get("market_price", 0)) > 0:
		return card.id in profile.market_cards
	return not card.locked or card.id in profile.unlocked_cards

static func award(profile: Dictionary, run: Dictionary) -> int:
	if not run.has("soul_rooms"): run.soul_rooms = []
	if run.current in run.soul_rooms: return 0
	var kind = run.nodes[run.current].kind
	var amount = int(config().battle_souls.get(kind, 0))
	if amount <= 0: return 0
	amount = ceili(amount * (1.0 + int(run.get("difficulty", 0)) * 0.15 + (0.25 if run.get("variant", "normal") == "dangerous" else 0.0)))
	profile.souls += amount
	run.soul_rooms.append(run.current)
	run.last_souls = amount
	return amount
