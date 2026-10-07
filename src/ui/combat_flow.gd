extends RefCounted
const BattleAudio = preload("res://src/audio/battle_audio.gd")
# Coordinates committed actions and their presentation; save precedes animation.
static func run(ui: Control, hand_index: int = -1, target_index: int = -1, synergy_id: String = "") -> void:
	if ui.combat_busy: return
	var previous_speed = Engine.time_scale
	Engine.time_scale = preload("res://src/presentation/preferences.gd").speed()
	await present(ui, hand_index, target_index, synergy_id)
	Engine.time_scale = previous_speed

static func present(ui: Control, hand_index: int, target_index: int, synergy_id: String) -> void:
	if ui.combat_busy or ui.game.run.phase != "combat":
		return
	var before = ui.game.run.heroes.duplicate(true)
	var old_enemies = ui.game.run.combat.enemies.duplicate(true)
	var owner = -1
	var offensive = false
	var defensive = false
	var healing = false
	var poisonous = false
	var motion = "attack"
	if hand_index >= 0:
		var instance = ui.game.run.combat.hand[hand_index]
		var card = ui.game.content.card(instance)
		offensive = card.damage > 0 or card.poison > 0
		defensive = card.block > 0
		healing = card.heal > 0
		poisonous = card.poison > 0
		owner = ui.game.owner_index(instance)
		motion = "heavy" if card.cost >= 2 else "attack"
		if card.owner == "mage":
			motion = "heavy" if card.target == "all_enemies" else "attack"
		if instance.id == "guardian_bash":
			motion = "bash"
		if card.damage == 0:
			motion = "guard"
		if card.owner == "cleric":
			motion = "attack" if card.damage > 0 else ("heal" if card.heal > 0 else "guard")
		if instance.id == "rogue_venom":
			motion = "poison"
	var spent_indices: Array = [hand_index] if hand_index >= 0 else []
	if synergy_id != "":
		for combo in ui.game.available_synergies():
			if combo.id == synergy_id:
				spent_indices = combo.indices.duplicate()
	elif hand_index < 0:
		# Snapshot the outgoing hand before end_turn discards it and draws another.
		spent_indices = range(ui.game.run.combat.hand.size())
	# Resolve and persist first. Closing Android during the animation never replays it.
	var accepted: bool
	if synergy_id != "":
		accepted = ui.game.play_synergy(synergy_id, target_index)
	else:
		accepted = ui.game.play_card(hand_index, target_index) if hand_index >= 0 else ui.game.end_turn()
	if not accepted:
		ui.audio.play_sfx("error")
		return
	ui.audio.play_sfx("card_use" if hand_index >= 0 or synergy_id != "" else "ash", -6)
	if healing: ui.audio.play_sfx("heal")
	if poisonous: ui.audio.play_sfx("poison", -4)
	if hand_index >= 0 or synergy_id != "":
		ui.layer.get_node("CombatHUD").update_energy(ui.game.run.combat.energy)
	var impacts: Array = ui.game.resolved_card_hits.duplicate(true) if hand_index >= 0 or synergy_id != "" else []
	ui.combat_busy = true
	for tip in ui.get_tree().get_nodes_in_group("combat_tip"): tip.queue_free()
	var ash_effects: Array = []
	var hand_view = ui.layer.get_node_or_null("CombatHand")
	if hand_view != null:
		var cards = hand_view.get_child(0).get_children()
		for index in spent_indices:
			if index >= 0 and index < cards.size():
				ash_effects.append(preload("res://src/presentation/card_ash.gd").play(ui.layer, cards[index]))
	for actor in ui.hero_art.values() + ui.enemy_art.values():
		var glow = actor.get_node_or_null("TargetGlow")
		if glow != null:
			glow.hide()
	# End-turn discard finishes before poison reactions or enemy actions begin.
	if hand_index < 0 and synergy_id == "":
		while ash_effects.any(func(effect): return is_instance_valid(effect)):
			await ui.get_tree().process_frame
	if synergy_id != "":
		ui.CombatEffects.attack_flash(ui.layer)
		for actor in ui.hero_art.values():
			await actor.play_once("attack")
		if not impacts.is_empty():
			await preload("res://src/presentation/card_impacts.gd").play(ui, impacts, motion)
	if owner >= 0 and ui.game.run.party[owner] in ui.ANIMATED_HEROES:
		if offensive:
			ui.CombatEffects.attack_flash(ui.layer)
		if (offensive or defensive) and impacts.is_empty():
			BattleAudio.hero(ui.audio, ui.game.run.party[owner], "attack" if offensive else "defense")
			var cut_in = preload("res://src/presentation/hero_cut_in.gd").play(ui.layer, ui.game.run.party[owner], "attack" if offensive else "defense")
			if cut_in != null:
				await cut_in.finished
		if impacts.is_empty():
			await ui.hero_art[owner].play_once(motion)
		else:
			await preload("res://src/presentation/card_impacts.gd").play(ui, impacts, motion)
	# The committed result can already be reward/defeat; show the old arena until
	# reactions finish, so a lethal strike and a falling hero remain visible.
	var current_enemies = ui.game.run.combat.get("enemies", [])
	for i in range(old_enemies.size()):
		if i < current_enemies.size() and old_enemies[i].hp > 0:
			if current_enemies[i].hp < old_enemies[i].hp:
				ui.enemy_health[i].animate_to(current_enemies[i].hp)
			if current_enemies[i].hp <= 0:
				ui.audio.play_sfx("death")
				ui.audio.play_sfx("ash", -8)
				ui.flash_hit(ui.enemy_art[i])
				await ui.enemy_art[i].play_once("death")
			elif current_enemies[i].hp < old_enemies[i].hp and impacts.is_empty():
				await ui.enemy_art[i].play_once("hurt")
		if hand_index < 0 and synergy_id == "" and ui.game.resolved_enemy_blocks.has(i):
			var block = int(ui.game.resolved_enemy_blocks[i])
			preload("res://src/presentation/card_impacts.gd").update_block(ui.enemy_health[i], block)
			if block > 0:
				ui.audio.play_sfx("block", -4)
				await ui.get_tree().create_timer(0.30).timeout
		if hand_index < 0 and synergy_id == "" and i in ui.game.resolved_enemy_attacks:
			ui.CombatEffects.attack_flash(ui.layer)
			var visual = ui.game.content.enemies[old_enemies[i].id].visual
			BattleAudio.enemy(ui.audio, visual)
			var cut_in = preload("res://src/presentation/enemy_cut_in.gd").play(ui.layer, visual)
			if cut_in != null:
				await cut_in.finished
			await ui.enemy_art[i].play_once("attack")
			for hero_index in ui.game.resolved_hero_blocks.get(i, {}):
				preload("res://src/presentation/card_impacts.gd").update_block(ui.hero_health[hero_index], ui.game.resolved_hero_blocks[i][hero_index])
			for hero_index in ui.game.resolved_hero_defenses.get(i, []):
				ui.audio.play_sfx("block")
				if ui.game.run.party[hero_index] in ui.ANIMATED_HEROES:
					await ui.hero_art[hero_index].play_once("guard")
	for i in range(before.size()):
		var after = ui.game.run.heroes[i]
		ui.hero_health[i].animate_to(after.hp)
		if hand_index < 0 and synergy_id == "":
			preload("res://src/presentation/card_impacts.gd").update_block(ui.hero_health[i], after.block)
		if after.hp < before[i].hp:
			ui.audio.play_sfx("hurt", -5)
			ui.flash_hit(ui.hero_art[i])
		if ui.game.run.party[i] not in ui.ANIMATED_HEROES:
			continue
		if before[i].hp > 0 and after.hp <= 0:
			await ui.hero_art[i].play_once("death")
		elif before[i].hp <= 0 and after.hp > 0:
			await ui.hero_art[i].play_once("revive")
		elif after.hp < before[i].hp and impacts.is_empty():
			await ui.hero_art[i].play_once("hurt")
	for bar in ui.hero_health.values() + ui.enemy_health.values():
		if bar.animating:
			await bar.animation_finished
	while ash_effects.any(func(effect): return is_instance_valid(effect)):
		await ui.get_tree().process_frame
	while not ui.get_tree().get_nodes_in_group("block_ash").is_empty():
		await ui.get_tree().process_frame
	await ui.get_tree().create_timer(0.18).timeout
	if ui.game.run.phase == "reward":
		await ui.CombatEffects.leave_room(ui.layer, ui.hero_art.values())
	ui.combat_busy = false
	ui.continue_run()
