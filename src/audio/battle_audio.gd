extends RefCounted
# Sounds accompany presentation of already committed actions.
static func hero(audio: Node, hero_id: String, action: String = "attack", card: Dictionary = {}) -> void:
	if action == "heal": audio.play_sfx("heal"); return
	if action == "defense": audio.play_sfx("cloth_guard" if hero_id in ["mage","rogue"] else "shield_impact"); return
	var events = {"warrior":"sword_heavy" if int(card.get("cost",1))>=2 else "blade", "guardian":"shield_bash" if "bash" in card.get("id","") else "blade", "rogue":"dagger", "mage":"frost"}
	audio.play_sfx(events.get(hero_id, "blade"))

static func enemy(audio: Node, visual: String) -> void:
	var event = "monster"
	if visual.begins_with("skeleton"): event = "bones"
	elif visual.begins_with("goblin"): event = "goblin"
	elif visual.begins_with("elemental"): event = "magic"
	elif visual.begins_with("bandit"): event = "blade"
	if visual == "bandit_6": event = "arrow_release"
	elif visual == "bandit_4": event = "fire_spell"
	elif visual == "elemental_4": event = "poison"
	elif visual == "elemental_3": event = "frost"
	elif visual == "flying_5": event = "wing"
	elif visual in ["flying_1","flying_6"]: event = "wing"
	elif visual == "beast_6": event = "frost"
	elif visual == "crypt_bandit": event = "dagger"
	elif visual == "bandit_7": event = "sword_heavy"
	audio.play_sfx(event)
