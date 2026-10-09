extends RefCounted
## Replay one committed enemy action without resolving or saving again.
static func play(ui: Control, index: int, visual: String) -> void:
	var impacts = preload("res://src/presentation/card_impacts.gd")
	if ui.game.resolved_enemy_blocks.has(index):
		var amount = int(ui.game.resolved_enemy_blocks[index])
		impacts.update_block(ui.enemy_health[index], amount)
		if amount > 0:
			ui.audio.play_sfx("block", -4)
			preload("res://src/presentation/support_feedback.gd").play(ui.layer,ui.enemy_art[index],"block")
			await ui.get_tree().create_timer(0.30).timeout
	if index not in ui.game.resolved_enemy_attacks: return
	ui.CombatEffects.attack_flash(ui.layer)
	if not ui.game.run.get("training", false):
		preload("res://src/audio/battle_audio.gd").enemy(ui.audio,visual)
		var cut = preload("res://src/presentation/enemy_cut_in.gd").play(ui.layer,visual)
		if cut != null: await cut.finished
	await ui.enemy_art[index].play_once("attack")
	for event in ui.game.resolved_enemy_hits.get(index, []):
		var owner = int(event.owner)
		var actor: Control = ui.hero_art[owner]
		await preload("res://src/presentation/impact_feedback.gd").play(ui,actor,event)
		impacts.update_block(ui.hero_health[owner],int(event.block))
		ui.hero_health[owner].animate_to(int(event.hp))
		if ui.game.run.party[owner] in ui.ANIMATED_HEROES:
			await actor.play_once("death" if event.hp <= 0 else "guard" if int(event.absorbed)>0 else "hurt")
		if ui.hero_health[owner].animating: await ui.hero_health[owner].animation_finished
