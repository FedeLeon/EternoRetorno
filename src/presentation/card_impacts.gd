extends RefCounted
# Replay committed hits individually; never applies damage or touches save state.
static func play(ui: Control, events: Array, motion: String) -> void:
	var shown_strikes: Array = []
	for event in events:
		if event.kind == "hit":
			var strike = int(event.get("hit_index", 0))
			if strike not in shown_strikes:
				shown_strikes.append(strike)
				preload("res://src/audio/battle_audio.gd").hero(ui.audio, ui.game.run.party[event.owner])
				var cut_in = preload("res://src/presentation/hero_cut_in.gd").play(ui.layer, ui.game.run.party[event.owner])
				if cut_in != null: await cut_in.finished
			await ui.hero_art[event.owner].play_once(motion)
			ui.CombatEffects.attack_flash(ui.layer)
			ui.flash_hit(ui.enemy_art[event.enemy])
			ui.audio.play_sfx("block" if event.block > 0 else "hit")
			var bar = ui.enemy_health[event.enemy]
			update_block(bar, event.block)
			bar.animate_to(event.hp)
			if bar.animating: await bar.animation_finished
		else:
			var visual = ui.game.content.enemies[ui.game.run.combat.enemies[event.enemy].id].visual
			preload("res://src/audio/battle_audio.gd").enemy(ui.audio, visual)
			await ui.enemy_art[event.enemy].play_once("attack")
			ui.CombatEffects.attack_flash(ui.layer)
			ui.flash_hit(ui.hero_art[event.owner])
			ui.audio.play_sfx("hit")
			var bar = ui.hero_health[event.owner]
			update_block(bar, event.block)
			bar.animate_to(event.hp)
			if bar.animating: await bar.animation_finished
			if event.hp > 0: await ui.hero_art[event.owner].play_once("hurt")


static func update_block(bar: Control, amount: int) -> void:
	for sibling in bar.get_parent().get_children():
		if sibling.get_script() == preload("res://src/ui/components/status_effects.gd"):
			var indicator = sibling.get_node_or_null("Block")
			if indicator != null: indicator.update_active_block(amount)
