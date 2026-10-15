extends RefCounted
# Replay committed hits individually; never applies damage or touches save state.
static func play(ui: Control, events: Array, motion: String) -> void:
	var shown_strikes: Array = []
	var cut_in: Control
	var melee = preload("res://src/presentation/melee_motion.gd")
	for event in events:
		if event.kind == "hit":
			var hit_index = int(event.get("hit_index", 0))
			var strike = "%d:%d:%d" % [int(event.get("action_index", 0)), int(event.owner), hit_index]
			var hero: String = event.get("hero",ui.game.run.party[event.owner])
			var actor: Control = ui.hero_art[event.owner]
			var close_attack = melee.applies(event.get("card",{}),hero)
			var action=preload("res://src/presentation/action_motion.gd").for_card(event.get("card",{}),hit_index) if event.has("card") else motion
			if strike not in shown_strikes:
				shown_strikes.append(strike)
				preload("res://src/audio/battle_audio.gd").hero(ui.audio, ui.game.run.party[event.owner],"attack",event.get("card",{}))
				cut_in = preload("res://src/presentation/hero_cut_in.gd").play(ui.layer, ui.game.run.party[event.owner])
				if cut_in != null and not close_attack: await cut_in.finished
				if not close_attack:
					actor.play_once(action)
					await ui.get_tree().create_timer(0.28).timeout
			var visit: Dictionary = {}
			if close_attack:
				visit = await melee.approach(ui.layer,actor,ui.enemy_art[event.enemy])
				actor.play_once(action)
				await ui.get_tree().create_timer(0.28).timeout
			else:
				var projectile=preload("res://src/presentation/battle_projectile.gd").play(ui.layer,actor,ui.enemy_art[event.enemy],hero)
				await projectile.landed
			await preload("res://src/presentation/impact_feedback.gd").play(ui,ui.enemy_art[event.enemy],event)
			var bar = ui.enemy_health[event.enemy]
			update_block(bar, event.block)
			bar.animate_to(event.hp)
			if bar.animating: await bar.animation_finished
			if close_attack:
				await melee.retreat(actor,visit)
				if is_instance_valid(cut_in) and not cut_in.is_queued_for_deletion(): await cut_in.finished
		elif event.kind == "revive":
			ui.enemy_art[event.enemy].set_fallen(false)
			ui.enemy_health[event.enemy].animate_to(event.hp)
			ui.audio.play_sfx("magic")
			await ui.get_tree().create_timer(0.25).timeout
		else:
			var visual = ui.game.content.enemies[ui.game.run.combat.enemies[event.enemy].id].visual
			preload("res://src/audio/battle_audio.gd").enemy(ui.audio, visual)
			await ui.enemy_art[event.enemy].play_once("attack")
			ui.CombatEffects.attack_flash(ui.layer)
			await preload("res://src/presentation/impact_feedback.gd").play(ui, ui.hero_art[event.owner], event)
			var bar = ui.hero_health[event.owner]
			update_block(bar, event.block)
			bar.animate_to(event.hp)
			if bar.animating: await bar.animation_finished
			await ui.hero_art[event.owner].play_once("death" if event.hp <= 0 else "guard" if int(event.get("absorbed", 0)) > 0 else "hurt")


static func update_block(bar: Control, amount: int) -> void:
	for sibling in bar.get_parent().get_children():
		if sibling.get_script() == preload("res://src/ui/components/status_effects.gd"):
			var indicator = sibling.get_node_or_null("Block")
			if indicator != null: indicator.update_active_block(amount)
