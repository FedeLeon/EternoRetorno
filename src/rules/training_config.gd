extends RefCounted
static func available(game: RefCounted) -> Array:
	return game.content.enemies.keys().filter(func(id): return game.profile.get("bestiary", {}).has(id))

static func validate(game: RefCounted, config: Dictionary) -> bool:
	var enemies: Array = config.get("enemies", [])
	return enemies.size() <= 3 and enemies.all(func(id): return id in available(game)) and config.get("mode", "pattern") in ["pattern","custom"] and int(config.get("damage", 6)) in range(0,31) and int(config.get("block", 0)) in range(0,21)

static func intent(game: RefCounted, _enemy: Dictionary, original: Dictionary) -> Dictionary:
	var config: Dictionary = game.run.get("training_config", {})
	if not config.get("enemies", []).is_empty() and config.get("mode", "pattern") == "pattern": return original
	return {"damage":int(config.get("damage", 6)),"block":int(config.get("block", 0)),"counter":4 if config.get("counter", false) else 0,"target":int(original.get("target", 0)),"all":config.get("all", false)}
