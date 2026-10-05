extends RefCounted
# Sounds accompany presentation of already committed actions.
static func hero(audio: Node, hero_id: String, action: String = "attack") -> void:
	if action == "heal": audio.play_sfx("heal"); return
	if action == "defense": audio.play_sfx("block"); return
	var events = {"warrior":"blade", "guardian":"blade", "rogue":"blade", "mage":"magic", "cleric":"magic", "ranger":"bow"}
	audio.play_sfx(events.get(hero_id, "blade"))

static func enemy(audio: Node, visual: String) -> void:
	var event = "monster"
	if visual.begins_with("skeleton"): event = "bones"
	elif visual.begins_with("goblin"): event = "goblin"
	elif visual.begins_with("elemental"): event = "magic"
	elif visual.begins_with("bandit"): event = "blade"
	audio.play_sfx(event)
