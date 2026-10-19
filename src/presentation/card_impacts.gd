extends RefCounted
# Replay committed hits individually; never applies damage or touches save state.
static func play(ui: Control, events: Array, motion: String) -> void:
	var shown_strikes: Array = []
	var cut_in: Control
	var active_actor: Control
	var active_revision = 0
	var playback = preload("res://src/presentation/hero_attack_playback.gd")
	for event in events:
		if event.kind == "hit":
			var hit_index = int(event.get("hit_index",0))
			var strike = "%d:%d:%d" % [int(event.get("action_index",0)),int(event.owner),hit_index]
			var hero: String = event.get("hero",ui.game.run.party[event.owner])
			var actor: Control = ui.hero_art[event.owner]
			var card: Dictionary = event.get("card",{})
			var action = preload("res://src/presentation/action_motion.gd").for_card(card,hit_index) if not card.is_empty() else motion
			var revision: int = actor.action_revision
			if strike not in shown_strikes:
				await playback.recover(ui,active_actor,active_revision,cut_in if is_instance_valid(cut_in) else null)
				if is_instance_valid(cut_in): await ui.get_tree().process_frame
				shown_strikes.append(strike)
				cut_in = preload("res://src/presentation/hero_cut_in.gd").play(ui.layer,hero)
				revision = await playback.contact(ui,actor,hero,action,card,cut_in)
				active_actor = actor
				active_revision = revision
			await preload("res://src/presentation/impact_feedback.gd").play(ui,ui.enemy_art[event.enemy],event)
			var bar = ui.enemy_health[event.enemy]
			update_block(bar,event.block)
			bar.animate_to(event.hp)
			if bar.animating: await bar.animation_finished
		elif event.kind == "revive":
			ui.enemy_art[event.enemy].set_fallen(false)
			ui.enemy_health[event.enemy].animate_to(event.hp)
			ui.audio.play_sfx("magic")
			await ui.get_tree().create_timer(0.25).timeout
		else:
			await playback.recover(ui,active_actor,active_revision,cut_in if is_instance_valid(cut_in) else null)
			if is_instance_valid(cut_in): await ui.get_tree().process_frame
			var enemy_id: String = ui.enemy_art[event.enemy].get_meta("battle_enemy_id", "")
			preload("res://src/audio/battle_audio.gd").enemy(ui.audio, enemy_id)
			var enemy_actor = ui.enemy_art[event.enemy]
			var revision: int = enemy_actor.begin_action("attack")
			var enemy_cut = preload("res://src/presentation/enemy_cut_in.gd").play(ui.layer,enemy_actor.visual_id)
			if enemy_cut != null: await enemy_cut.finished
			enemy_actor.finish_action(revision)
			await preload("res://src/presentation/impact_feedback.gd").play(ui, ui.hero_art[event.owner], event)
			var bar = ui.hero_health[event.owner]
			update_block(bar, event.block)
			bar.animate_to(event.hp)
			if bar.animating: await bar.animation_finished
			await ui.hero_art[event.owner].play_once("death" if event.hp <= 0 else "guard" if int(event.get("absorbed", 0)) > 0 else "hurt")

	await playback.recover(ui,active_actor,active_revision,cut_in if is_instance_valid(cut_in) else null)


static func update_block(bar: Control, amount: int) -> void:
	for sibling in bar.get_parent().get_children():
		if sibling.get_script() == preload("res://src/ui/components/status_effects.gd"):
			var indicator = sibling.get_node_or_null("Block")
			if indicator != null: indicator.update_active_block(amount)
