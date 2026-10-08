extends RefCounted
# Bounded local statistics only. No network, no RNG, no time-dependent gameplay.
static func card(game: RefCounted, id: String) -> void:
	if game.run.get("training", false): return
	var metrics: Dictionary = game.run.get_or_add("telemetry", {"cards":{}, "offered":{}, "picked":{}, "unused":{}, "battles":[]})
	metrics.cards[id] = int(metrics.cards.get(id, 0)) + 1

static func unused(game: RefCounted, hand: Array) -> void:
	if game.run.get("training", false): return
	var metrics: Dictionary = game.run.get("telemetry", {})
	if metrics.is_empty(): return
	for instance in hand: metrics.unused[instance.id] = int(metrics.unused.get(instance.id, 0)) + 1

static func offers(game: RefCounted) -> void:
	var metrics: Dictionary = game.run.get("telemetry", {})
	if metrics.is_empty() or game.run.get("training", false): return
	for instance in game.run.reward: metrics.offered[instance.id] = int(metrics.offered.get(instance.id, 0)) + 1

static func picked(game: RefCounted, index: int) -> void:
	var metrics: Dictionary = game.run.get("telemetry", {})
	if metrics.is_empty() or index < 0: return
	var id: String = game.run.reward[index].id
	metrics.picked[id] = int(metrics.picked.get(id, 0)) + 1

static func battle(game: RefCounted) -> void:
	if game.run.get("training", false): return
	var metrics: Dictionary = game.run.get("telemetry", {})
	if metrics.is_empty(): return
	metrics.battles.append({"floor":game.run.get("floor",1),"room":game.run.current,"turns":game.run.combat.turn,"seconds":maxi(0, int(Time.get_unix_time_from_system())-int(game.run.combat.get("started_at", Time.get_unix_time_from_system()))),"party":game.run.party.duplicate(),"hp":game.run.heroes.map(func(h): return h.hp)})
