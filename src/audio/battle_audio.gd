extends RefCounted
## Audio follows committed presentation receipts, never combat rules or game RNG.
const Catalog = preload("res://src/data/json_catalog.gd")

static func hero(audio: Node, hero_id: String, action: String = "attack", card: Dictionary = {}) -> void:
	if action == "heal":
		audio.play_sfx("heal")
		return
	audio.play_sfx("voice_%s_%s" % [hero_id, action])
	if action == "defense":
		audio.play_sfx("shield_impact", -5)
		return
	var events = {"warrior":"sword_heavy" if int(card.get("cost",1))>=2 else "blade", "guardian":"shield_bash" if "bash" in card.get("id","") else "blade", "rogue":"dagger", "mage":"frost"}
	audio.play_sfx(events.get(hero_id, "blade"))

static func enemy(audio: Node, enemy_id: String, action: String = "attack") -> void:
	var profiles = Catalog.dictionary("res://data/battle_audio.json").enemies
	# Visual IDs remain accepted for legacy presentation callers and previews.
	if not profiles.has(enemy_id):
		for id in profiles:
			if profiles[id].visual == enemy_id:
				enemy_id = id
				break
	if profiles.has(enemy_id):
		audio.play_sfx("enemy_%s_%s" % [enemy_id, action])
	else:
		audio.play_sfx("shield_bash" if action == "attack" else "shield_impact" if action == "guard" else "ash")

static func impact(audio: Node, event: Dictionary, hero_id: String = "", enemy_id: String = "") -> void:
	var absorbed = int(event.get("absorbed", 0))
	var lost = int(event.get("lost", event.get("damage", 0)))
	# Block always takes precedence over piercing in the audible contact layer.
	if absorbed > 0:
		audio.play_sfx("shield_impact")
	elif lost > 0:
		audio.play_sfx("machine_impact" if enemy_id != "" else "pierce" if event.get("pierce", false) else "flesh_impact")
	if hero_id != "":
		if absorbed > 0 and lost == 0:
			audio.play_sfx("voice_%s_defense" % hero_id)
		elif lost > 0:
			audio.play_sfx("voice_%s_hurt" % hero_id)
