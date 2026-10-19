extends RefCounted
## Replay one committed enemy action without resolving or saving again.
static func play(ui: Control, index: int, visual: String) -> void:
	var enemy_id: String = ui.enemy_art[index].get_meta("battle_enemy_id", visual)
	var impacts = preload("res://src/presentation/card_impacts.gd")
	if ui.game.resolved_enemy_blocks.has(index):
		var amount = int(ui.game.resolved_enemy_blocks[index])
		impacts.update_block(ui.enemy_health[index], amount)
		if amount > 0:
			preload("res://src/audio/battle_audio.gd").enemy(ui.audio, enemy_id, "guard")
			await illustrate(ui,ui.enemy_art[index],visual,"guard")
	if index not in ui.game.resolved_enemy_attacks: return
	if not ui.game.run.get("training", false):
		preload("res://src/audio/battle_audio.gd").enemy(ui.audio,enemy_id)
	await illustrate(ui,ui.enemy_art[index],visual,"attack")
	for event in ui.game.resolved_enemy_hits.get(index, []):
		var owner = int(event.owner)
		var actor: Control = ui.hero_art[owner]
		await preload("res://src/presentation/impact_feedback.gd").play(ui,actor,event)
		impacts.update_block(ui.hero_health[owner],int(event.block))
		ui.hero_health[owner].animate_to(int(event.hp))
		if ui.game.run.party[owner] in ui.BATTLE_HEROES:
			await actor.play_once("death" if event.hp <= 0 else "guard" if int(event.absorbed)>0 else "hurt")
		if ui.hero_health[owner].animating: await ui.hero_health[owner].animation_finished

static func illustrate(ui: Control, actor: Control, visual: String, action: String) -> void:
	var revision: int = actor.begin_action(action)
	var cut: Control
	if not ui.game.run.get("training",false):
		cut = preload("res://src/presentation/enemy_cut_in.gd").play(ui.layer,visual,"defense" if action=="guard" else "attack")
	if cut != null: await cut.finished
	else: await ui.get_tree().create_timer(.28).timeout
	actor.finish_action(revision)
