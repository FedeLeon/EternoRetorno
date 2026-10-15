extends RefCounted
# Stage committed prepared-hit receipts after enemy actions, without resolving again.
static func before_hp(events: Array, index: int, fallback: int) -> int:
	for event in events:
		if event.kind == "hit" and int(event.enemy) == index:
			return int(event.hp) + int(event.get("lost", 0))
	return fallback

static func play(ui: Control) -> void:
	var events: Array = ui.game.resolved_prepared_hits
	if events.is_empty(): return
	await preload("res://src/presentation/card_impacts.gd").play(ui, events, "heavy")
	var last: Dictionary = {}
	for event in events:
		if event.kind == "hit": last[int(event.enemy)] = event
	var current: Array = ui.game.run.combat.get("enemies", [])
	for index in last:
		if index < current.size() and int(current[index].hp) > 0: continue
		if int(last[index].hp) > 0 or ui.enemy_art[index].fallen: continue
		ui.audio.play_sfx("death")
		ui.audio.play_sfx("ash", -8)
		await ui.enemy_art[index].play_once("death")
